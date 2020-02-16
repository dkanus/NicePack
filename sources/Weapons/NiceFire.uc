//==============================================================================
//  NicePack / NiceFire
//==============================================================================
//  New base class for fire modes, more fit for use with our 'bullet' system.
//  Functionality:
//      - Support for defining most information about bullet behaviour
//      - Support for burst fire
//      - Support for shooting different types of bullets at once
//      - Support for swappable shot types
//      - Support for increased damage when shooting in bursts
//  This class is setup to fit needs of as many weapons as possible with
//  minimal hassle, but some weapons might require additional work, most likely
//  including modification of 'AllowFire' and 'ConsumeAmmo' functions.
//  See classes of NicePack weapons and comment for 'IsMainFire'
//  for more details.
//==============================================================================
//  Class hierarchy: Object > WeaponFire > InstantFire > KFFire > NiceFire
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceFire extends KFFire
    dependson(NiceWeapon)
    abstract;


//==============================================================================
//==============================================================================
//  >   Weapon fire parameters
//  All the parameters are contained in a structure that can be swapped
//  to alter the effects of the shooting via this mode.
//  These are supposed to be immutable;any skill that attempts to change them
//  should work with the copy of their value

//==============================================================================
//  >>  Weapon fire effects
//  Effects that weapon's context can have on bullets,
//  like bonus damage for firing continiously,
//  or ways bullets are fired, like bursting
struct  NWFWeaponType{
    //  How many bullets are fired at once?
    var int     bulletsAmount;
    //  How many ammo for one shot?
    var int     ammoPerFire;
    //  Can these bullets be fired with incomplete ammo?
    var bool    bCanFireIncomplete;
    //  Time windows between two shots
    var float   fireRate;

    //  --  These variables deal with increasing damage during continious damage
    //      (this is used for ZCU's weapon mechanic)
    //  Multiplier at which we increase our damage while firing continiously
    var float   contFireBonusDamage;
    //  Maximum of consequtive shots that can receive damage bonus
    var int     maxBonusContLenght;

    //  -- Are we firing in auto mode or are we bursting?
    var bool    bAutoFire;  //  NICETODO: must update waitforrelease
    //  This is auto-updated to be at least one after 'FillFireType'
    //  to make semi-auto fire work as expected.
    var int     maxBurstLength;
};

//==============================================================================
//  >>  Shooting rebound
//  Settings related to recoil, push-back from firing
//  or leaving ironsights on fire
struct  NWFRebound{
    //  Recoil rotation
    //  NOTE:   -   in vanilla actual recoil was randomised between
    //              provided angle and it's half;
    //          -   horizontal recoil still functions that way
    //          -   vertical recoil, however, is now a fixed value,
    //              so setting it to the same value will result in higher actual
    //              recoil (since randomization could only lower it)
    //          -   so if you want to preserve the same average recoil, then
    //              set 'recoilVertical' to 75% of the value,
    //              you'd use for vanilla
    var int     recoilVertical, recoilHorizontal;
    //  How much should firing move player around
    var Vector  kickMomentum;
    //  How much to scale up kick momentum in low grav so guys fly around
    var float   lowGravKickMomentumScale;
    //  Should we leave iron sight upon shooting?
    var bool    bLeaveIronSights;
};

//==============================================================================
//  >>  Parameters of bullet spawning
//  Bullet parameters upon launch: offset, speed and spread
struct  NWFBulletMovement{
    var class<NiceBullet>   bulletClass;
    var Vector              spawnOffset;
    var float               speed;
    var float               spread;
    //  If set above zero, bullets will fall for that much time after hitting
    //  a wall (similar to vanilla's behavior of blunt grenades and rockets)
    var float               fallTime;
};

//==============================================================================
//  >>  Damage and other effects on zeds
struct  NWFBulletEffects{
    //  Damage that bullet should deal
    var int                         damage;
    //  Momentum that should be transferred to zed
    var float                       momentum;
    //  Damage type of this bullet
    var class<NiceWeaponDamageType> shotDamageType;
    //  Always deal original damage to zeds even after penetration
    var bool                        bCausePain;
    //  Bullet should stick to zeds
    var bool                        bStickToZeds;
    //  Bullet should stick to walls
    var bool                        bStickToWalls;
    //  Should bullet be affected by scream? (being destroyed by default)
    var bool                        bAffectedByScream;
    //  Should this projectile bounce off the walls?
    var bool                        bBounce;
};

//==============================================================================
//  >>  Explosion effects for this bullet
struct  NWFExplosionEffects{
    //  Damage type of the explosion
    var class<NiceWeaponDamageType> damageType;
    //  Maximum damage explosion can deal
    var int                         damage;
    //  Maximum radius eplosion can affect
    var float                       radius;
    //  Defines how fast damage falls off with distance
    //  If  we represent distance from explosion location
    //  as number \alpha between 0 and 1:
    //      ...1.0 is the location of explosion,
    //      ...0.0 is any location on the border of explosion,
    //  then \alpha^exponent would be the damage scale multiplier.
    //  \alpha > 1 => damage quickly falls down when shifting from center
    //  \alpha < 1 => more slowly
    var float                       exponent;
    //  Momentum zeds would recieve from the explosion
    var float                       momentum;
    //  Time from launch untill the fuse going off
    var float                       fuseTime;
    //  Minimal distance at which we can detonate
    var float                       minArmDistance;
    //  When should projectile explode?
    var bool                        bOnFuse;
    var bool                        bOnPawnHit;
    var bool                        bOnWallHit;
};

//==============================================================================
//  >>  Huge structure that combines everything that descibes our fire type
struct  NWFireType{
    var string              fireTypeName;
    var NWFRebound          rebound;
    var NWFWeaponType       weapon;
    var NWFBulletMovement   movement;
    var NWFBulletEffects    bullet;
    var NWFExplosionEffects explosion;
};
var array<NWFireType>           fireTypes;
var int                         curFireType;
var NiceWeapon.FireAnimationSet fireAnims;

//==============================================================================
//==============================================================================
//  >   State of this fire mode
//  These parameters are either supposed to change over the course of the game

//==============================================================================
//  >>  Contains variables describing most basic and low-level state variables
struct  NWFCBaseState{
    //  This fire mode is disabled and won't shoot
    var bool                    bDisabled;
    //  If 'true' semi-auto fire will cause burst fire
    var bool                    bSemiIsBurst;
    //  How much time should pass before player can fire again
    var float                   fireCooldown;
    //  Set this flag to 'true' to disable recoil for the next shot;
    //  it will be automatically reset to 'false' after that
    var bool                    bResetRecoil;
    //  Did we shoot after latest fire button press?
    //  Always 'false' when fire button is released
    var bool                    bShotOnClick;
    //  Latest played fire animation and fire rate for which it is playing,
    //  stored to correctly update it's speed;
    var NiceWeapon.FireAnim     latestFireAnim;
    var float                   latestFireRate;
    //  Amount of time yet to pass before we can replicate input flags again
    var float                   flagReplicationCooldown;
    //  Instigator, controller and weapon used for firing
    var NiceWeapon              sourceWeapon;
    var NiceHumanPawn           instigator;
    var NicePlayerController    instigatorCtrl;
};

//==============================================================================
//  >>  Describes current lock-on status
struct  NWFCLockonState{
    var NiceMonster target;
    var float       time;
};

//==============================================================================
//  >>  Describes status of bursting
struct  NWFCBurstState{
    //  Are we actively bursting right now?
    var bool    bIsActive;
    //  Shots in the burst we've made so far
    var int     shotsMade;
};

//==============================================================================
//  >>  Describes status of continious fire
struct  NWFCAutoFireState{
    var float   accumulatedBonus;
    var int     lenght;
};

//==============================================================================
//  >>  Contains all the information about context of this weapon fire
struct  NWCFireState{
    var NWFCBaseState       base;
    var NWFCLockonState     lockon;
    var NWFCBurstState      burst;
    var NWFCAutoFireState   autoFire;
};
var NWCFireState fireState;

simulated function PostBeginPlay(){
    local int i;
    super.PostBeginPlay();
    FillFireType();
    fireState.autoFire.accumulatedBonus = 1.0;
    //  Burst fire is semi-auto fire, so it's length must be at least 1
    for(i = 0;i < fireTypes.length;i ++)
        if(fireTypes[i].weapon.maxBurstLength < 1)
            fireTypes[i].weapon.maxBurstLength = 1;
}

simulated function FillFireType(){
}

//  Returns true if this fire mode is 'Main'
//      - Fire mode is considered 'main' if they use 'magAmmoRemaining'
//      and 'magAmmoRemainingClient' for keeping track of loaded ammo;
//      - the rest are non-'main' fire modes and they're assumed
//      to use 'secondaryCharge' instead.
//
//  The default rules for deciding whether we're 'main' mode are:
//      1. All primary fire modes are 'main'.
//      2. All secondary fire modes without their own ammo are also 'main'
//      (since it's likely just another way to fire
//      the same ammo from the same mag)
//      3. Everything else is non-'main' fire mode
//
//  This distinction is introduced,
//  because almost all weapons can fit in this model:
//      1. Simple rifles and shotguns require one 'main' fire mode and
//      'magAmmoRemaining'/'magAmmoRemainingClient' variables for
//      storing currently loaded and ready for shooting ammo.
//      2. Assault rifles (as well as nailgun oe hunting shotgun) can have two
//      fire modes, that still take ammo from the same source/magazine,
//      so both of their fire modes are 'main'.
//      3. Something like M4M203 has two fifferent fire modes with two different
//      ammo pools, which can't share the same magazine;
//      for secondary, nade, fire 'secondaryCharge' is used to denote
//      whether or not nade is loaded.
//      4. Medic guns fire darts as their secondary fire and also can't draw
//      from the same ammo pool, so they should use 'secondaryCharge';
//      but standart rules define them as 'main', so they have to change
//      'AllowFire' and 'ConsumeAmmo' functions.
simulated function bool IsMainFire(){
    return thisModeNum == 0 || !fireState.base.sourceWeapon.bHasSecondaryAmmo;
}

//  All weapons should have 100% accuracy anyway
simulated function AccuracyUpdate(float Velocity){}

//  Returns currently active fire type
simulated function NWFireType GetFireType(){
    if(curFireType < 0 || curFireType >= fireTypes.length)
        return fireTypes[0];
    return fireTypes[curFireType];
}

simulated function int GetBurstLength(){
    return GetFireType().weapon.maxBurstLength;
}

simulated function StopBursting(){
    fireState.burst.bIsActive = false;
    fireState.burst.shotsMade = 0;
}

//  Tests whether fire button, corresponding to our fire mode is pressed atm.
simulated function bool IsFireButtonPressed(){
    local NicePlayerController nicePlayer;
    nicePlayer = fireState.base.instigatorCtrl;
    if(nicePlayer == none) return false;
    if(instigator.role == Role_AUTHORITY)
        return (thisModeNum == 0 && nicePlayer.bNiceFire == 1)
            || (thisModeNum == 1 && nicePlayer.bNiceAltFire == 1);
    else
        return (thisModeNum == 0 && nicePlayer.bFire == 1)
            || (thisModeNum == 1 && nicePlayer.bAltFire == 1);
}

simulated function TryReplicatingInputFlags(float delta){
    local NicePlayerController nicePlayer;
    //  If server already has current version of the flags -
    //  there's nothing to replicate
    nicePlayer = fireState.base.instigatorCtrl;
    if(nicePlayer == none) return;
    if(     nicePlayer.bFire    == nicePlayer.bNiceFire
        &&  nicePlayer.bAltFire == nicePlayer.bNiceAltFire) return;
    //  Otherwise - check cooldown and replicate if it's over
    fireState.base.flagReplicationCooldown -= delta / level.timeDilation;
    if(fireState.base.flagReplicationCooldown <= 0){
        fireState.base.flagReplicationCooldown = 0.1;
        nicePlayer.bNiceFire    = nicePlayer.bFire;
        nicePlayer.bNiceAltFire = nicePlayer.bAltFire;
        nicePlayer.ServerSetFireFlags(nicePlayer.bFire, nicePlayer.bAltFire);
    }
}

simulated function ModeTick(float delta){
    local float         headAimLevel;
    local NiceMonster   currentTarget;

    if(instigator.role < Role_AUTHORITY)
        TryReplicatingInputFlags(delta);

    //  Update instigator, controller and weapon, if necessary
    if(fireState.base.instigator == none)
        fireState.base.instigator = NiceHumanPawn(instigator);
    else if(fireState.base.instigatorCtrl == none)
        fireState.base.instigatorCtrl =
            NicePlayerController(instigator.controller);
    if(fireState.base.sourceWeapon == none)
        fireState.base.sourceWeapon = NiceWeapon(weapon);

    //  Update lock-on
    if(instigator.role < Role_AUTHORITY){
        headAimLevel = 0.0;//TraceZed(currentTarget);
        if(headAimLevel <= 0.0 || currentTarget == none){
            fireState.lockon.time = 0.0;
            fireState.lockon.target = none;
        }
        else{
            if(currentTarget == fireState.lockon.target)
                fireState.lockon.time += delta ;
            else
                fireState.lockon.time = 0.0;
            fireState.lockon.target = currentTarget;
        }
    }

    //  Reset continious fire length here to make sure
    if(instigator.controller.bFire == 0 && instigator.controller.bAltFire == 0){
        fireState.autoFire.lenght = 0;
        fireState.autoFire.accumulatedBonus = 1.0;
    }

    HandleFiring(delta);
    super.ModeTick(delta);
}

// NICETODO: rewrite StopFire function to force it to also stop burst fire
simulated function HandleFiring(float delta){
    //  These flags represent 3 conditions that must be satisfied for
    //  shooting attempt yo even be attempted:
    //  'bFirePressed': is fire button pressed?
    //  'bFireExpected': sometimes (ex. semiauto weapons) weapons shouldn't fire
    //      even thout fire button is pressed
    //  'bCooldownPassed' has cooldown passed?
    local bool  bFirePressed, bFireExpected, bCooldownPassed;
    //  Did we fire the weapon?
    local bool  shotFired;
    local float currentFireSpeed;

    //  Check if we're pressing the fire button;
    //  if not - reset flag that says we've shot during latest button press;
    //  if we're bursting - emulate button press (but still reset a flag)
    bFirePressed = IsFireButtonPressed();
    if(!bFirePressed)
        fireState.base.bShotOnClick = false;
    bFirePressed = bFirePressed || fireState.burst.bIsActive;
    //  Firing is only expected if we're auto firing, bursting or
    //  haven't yet shot during latest fire button press
    bFireExpected = GetFireType().weapon.bAutoFire;
    bFireExpected = bFireExpected || fireState.burst.bIsActive;
    bFireExpected = bFireExpected || !fireState.base.bShotOnClick;
    //  Temporarily extend 'delta' time period according to fire speed;
    //  we need to decrease it back after reducing cooldown to avoid any
    //  multiplication stacking from recursion.
    currentFireSpeed = GetFireSpeed();
    delta *= currentFireSpeed;
    bCooldownPassed = ReduceCooldown(delta);
    delta /= currentFireSpeed;

    //  Fire if all the flags are set to 'true'
    if(bCooldownPassed && bFirePressed && bFireExpected)
        shotFired = NiceModeDoFire();
    //  If shot was actually fired - update fire state and cooldown;
    if(shotFired){
        //  Update appropriate state variable
        UpdateContiniousFire(bFirePressed);
        fireState.base.bShotOnClick = true;
        if(fireState.burst.bIsActive)
            fireState.burst.shotsMade ++;
        //  New cooldown after shot
        DoFireCooldown();
        //  Try and shoot again, if there's any time left
        if(delta > 0.0)
            HandleFiring(delta);
    }
    //  Otherwise - just update current animation
    else{
        if(bCooldownPassed && fireState.base.latestFireAnim.bLoop)
            //  Finish looped animation by playing appropriate fire end anim;
            //  Waiting for cooldown may, in theory, lead to issues
            //  with some weapons, but since looped fire animations are only
            //  used for high rate of fire ones, it should be fine
            FinishFireLoopAnimation();
        else
            UpdateFireAnimation();
    }
}

//  This function is called when next fire time needs to be updated
simulated function DoFireCooldown(){
    //  - If we aren't bursting - simply set cooldown to 'fireRate'
    if(!fireState.burst.bIsActive){
        fireState.base.fireCooldown = GetFireType().weapon.fireRate;
        return;
    }

    //  - If we're bursting, we have two cases:
    //      1.  It's not a final burst, so we cut burst time to fir all
    //          shots into regular fire time
    if(fireState.burst.shotsMade < GetBurstLength()){
        fireState.base.fireCooldown =
            GetFireType().weapon.fireRate / GetBurstLength();
        return;
    }
    //      2.  It was a final burst, so we set a slightly increased cooldown
    fireState.base.fireCooldown =
        GetFireType().weapon.fireRate * fireState.burst.shotsMade * 1.3;
    StopBursting();
}

//  Reduces cooldown by 'using up' passed time given by 'deltaPassed'.
//  'deltaPassed' will be reduced on the amount required to reduce
//  cooldown as much as possible;
//  returns 'true' if cooldown was finished
simulated function bool ReduceCooldown(out float deltaPassed){
    //  If there's not enough time - use up all the 'deltaPassed'
    if(fireState.base.fireCooldown > deltaPassed){
        fireState.base.fireCooldown -= deltaPassed;
        deltaPassed = 0.0;
        return false;
    }
    //  If 'deltaPassed' is more than enough time - use up only part of it
    deltaPassed -= fireState.base.fireCooldown;
    fireState.base.fireCooldown = 0.0;
    return true;
}

simulated function bool AllowFire(){
    local float         magAmmo;
    local bool          bLacksCharge, bLacksAmmo;
    local KFPawn        kfPwn;
    local NWFWeaponType weaponType;
    weaponType = GetFireType().weapon;
    kfPwn = KFPawn(instigator);

    if(fireState.base.sourceWeapon == none || kfPwn == none) return false;

    //  Reject weapons that are swapping variants
    if(fireState.base.sourceWeapon.variantSwapState != SWAP_NONE) return false;

    //  Reject bursting for way too long
    if(fireState.burst.bIsActive
        && fireState.burst.shotsMade >= GetBurstLength()) return false;

    //  By default we assume that 'primary' fire modes care about chambered
    //  bullets and all the rest - about charge
    //  -- Reject shots hen there's no chambered round (for primary fire)
    if(IsMainFire() && fireState.base.sourceWeapon.bHasChargePhase
        && !fireState.base.sourceWeapon.bRoundInChamber) return false;
    //  -- Reject shot when there's not enough charge
    bLacksCharge = fireState.base.sourceWeapon.secondaryCharge <
        weaponType.ammoPerFire;
    if(!IsMainFire() && bLacksCharge && !weaponType.bCanFireIncomplete)
        return false;

    //  Check reloading
    if(fireState.base.sourceWeapon.bIsReloading) return false;

    //  Check ammo in the mag
    magAmmo = fireState.base.sourceWeapon.GetMagazineAmmo();
    //  - Need to have at least some ammo
    if(magAmmo < 1) return false;
    //  - If still not enough for 1 shot - we must be able to fire incomplete
    bLacksAmmo = magAmmo < weaponType.ammoPerFire;
    if(bLacksAmmo && !weaponType.bCanFireIncomplete) return false;

    //  Check pawn actions
    if(kfPwn.SecondaryItem != none || kfPwn.bThrowingNade) return false;
    return super(WeaponFire).AllowFire();
}

//  This function will cause weapon to burst
simulated function DoBurst(){
    if(fireState.base.fireCooldown > 0) return;
    if(fireState.burst.bIsActive || fireState.base.bShotOnClick) return;
    if(GetFireType().weapon.maxBurstLength <= 0) return;
    fireState.burst.bIsActive = true;
    fireState.burst.shotsMade = 0;
}

simulated function UpdateContiniousFire(bool bPlayerWantsToFire){
    //  Player stopped shooting for a moment - reset bonus
    if(!bPlayerWantsToFire){
        fireState.autoFire.lenght           = 0;
        fireState.autoFire.accumulatedBonus = 1.0;
        return;
    }
    fireState.autoFire.lenght ++;
    if(fireState.autoFire.lenght > GetFireType().weapon.maxBonusContLenght)
        fireState.autoFire.accumulatedBonus = 1.0;
    else
        fireState.autoFire.accumulatedBonus *=
            GetFireType().weapon.contFireBonusDamage;
}

event ModeDoFire(){}

simulated function bool NiceModeDoFire(){
    local float recoilMult;
    local int   ammoToFire;
    if(instigator == none) return false;
    if(fireState.base.bDisabled) return false;
    if(fireState.base.sourceWeapon == none) return false;
    if(!AllowFire()) return false;

    //  How much ammo should we fire?
    ammoToFire = GetFireType().weapon.ammoPerFire;
    if(GetFireType().weapon.bCanFireIncomplete)
        ammoToFire =
            Min(ammoToFire, fireState.base.sourceWeapon.GetMagazineAmmo());

    //  Do shooting effects from standart classes, the only thing that
    //  should be really different is replaced 'DoFireEffect'
    MDFEffects(ammoToFire);
    if(instigator.role == Role_AUTHORITY){
        MDFEffectsServer(ammoToFire);
        ServerPlayFiring();
    }
    else{
        //  Compute right recoil
        recoilMult = 1.0;
        if(fireState.burst.bIsActive)
            recoilMult = recoilMult / GetBurstLength();
        MDFEffectsClient(ammoToFire, recoilMult);
    }
    return true;
}

//  Fire effects that should affect both client and server:
simulated function MDFEffects(int ammoToFire){
    if(fireState.base.sourceWeapon == none) return;

    //  Decrease player's speed while firing
    if(weapon.owner != none && weapon.owner.Physics != PHYS_Falling){
        if(GetFireType().weapon.fireRate > 0.25){
            weapon.owner.Velocity.x *= 0.1;
            weapon.owner.Velocity.y *= 0.1;
        }
        else{
            weapon.owner.Velocity.x *= 0.5;
            weapon.owner.Velocity.y *= 0.5;
        }
    }

    //  3rd person effects
    weapon.IncrementFlashCount(thisModeNum);

    //  Fire should cause some weapons to zoom out
    if( GetFireType().rebound.bLeaveIronSights
        || fireState.base.sourceWeapon.reloadType == RTYPE_AUTO)
        fireState.base.sourceWeapon.ZoomOut(false);

    //  Interrupt firing when we need to take another weapon
    //  NICETODO: can fuck usup in the future, if we were to redo firing innards
    if(instigator.pendingWeapon != weapon && instigator.pendingWeapon != none){
        bIsFiring = false;
        weapon.PutDown();
    }

    //  Actually launches bullets
    DoNiceFireEffect(ammoToFire);
}

// Fire effects that should only affect server.
simulated function MDFEffectsServer(int ammoToFire){
    local Vector eyesPoint;
    //  Alert zeds about shooting
    instigator.MakeNoise(1.0);

    //  Shoot buttons on ScrN testing grounds
    eyesPoint = instigator.location + instigator.EyePosition();
    DoTraceHack(eyesPoint, AdjustAim(eyesPoint, 0.0));
}

// Fire effects that should only affect shooting client.
simulated function MDFEffectsClient(int ammoToFire, float recoilMult){
    //  'true' if ammo is infinite
    local bool                  bUberAmmo;
    local NicePlayerController  nicePlayer;
    if(instigator == none) return;
    nicePlayer = NicePlayerController(instigator.controller);
    if(nicePlayer == none) return;

    //  Reduce ammo
    bUberAmmo = nicePlayer.IsZedTimeActive() && class'NiceVeterancyTypes'
        .static.hasSkill(   nicePlayer,
                            class'NiceSkillSharpshooterZEDHundredGauntlets');
    if(!bUberAmmo)
        ReduceAmmoClient(ammoToFire);
    //  Fire effects
    InitEffects();
    ShakeView();
    NicePlayFiring(ammoToFire < GetFireType().weapon.ammoPerFire);
    FlashMuzzleFlash();
    StartMuzzleSmoke();
    if(bDoClientRagdollShotFX && Weapon.Level.NetMode == NM_Client)
        DoClientOnlyFireEffect();
    //  Recoil
    HandleRecoil(recoilMult);
}

simulated function ReduceAmmoClient(int ammoToFire){
    if(IsMainFire())
        ReduceMainAmmoClient(ammoToFire);
    else
        ReduceNonMainAmmoClient(ammoToFire);
}

simulated function ReduceMainAmmoClient(int ammoToFire){
    local NiceWeapon usedWeapon;
    usedWeapon = fireState.base.sourceWeapon;
    if(usedWeapon == none) return;
    //  Reduce ammo and reset round in chambered
    //  Doesn't hurt us to reset it even if weapon doesn't use it
    usedWeapon.MagAmmoRemainingClient -= ammoToFire;
    if(usedWeapon.MagAmmoRemainingClient <= 0){
        usedWeapon.MagAmmoRemainingClient = 0;
        usedWeapon.bRoundInChamber = false;
    }
    //  After introduction of alternative ammo types -
    //  we must also reduce it's counton the client
    usedWeapon.ConsumeNiceAmmo( usedWeapon.ammoState[0],
                                usedWeapon.availableAmmoTypes, 0, ammoToFire);
    //  Magazine weapons autoload their ammo from the magazine
    if(usedWeapon.bRoundInChamber && usedWeapon.reloadType == RTYPE_MAG){
        usedWeapon.AmmoStackPush(   usedWeapon.ammoState[0],
                                    usedWeapon.ammoState[0].currentAmmoType);
    }
    //  Force server's magazine size
    usedWeapon.ServerReduceMag( usedWeapon.MagAmmoRemainingClient,
                                level.TimeSeconds, thisModeNum);
}

simulated function ReduceNonMainAmmoClient(int ammoToFire){
    local NiceWeapon usedWeapon;
    usedWeapon = fireState.base.sourceWeapon;
    if(usedWeapon == none) return;
    usedWeapon.secondaryCharge -= ammoToFire;
    //  After introduction of alternative ammo types -
    //  we must also reduce it's counton the client
    usedWeapon.ConsumeNiceAmmo( usedWeapon.ammoState[1],
                                usedWeapon.availableAmmoTypesSecondary,
                                1, ammoToFire);
    //  Reduce secondary ammo in case we were using it
    usedWeapon.ServerReduceMag( usedWeapon.magAmmoRemainingClient,
                                level.TimeSeconds, thisModeNum);
    //  Reduce secondary charge
    usedWeapon.ServerSetSndCharge(usedWeapon.secondaryCharge);
}

//  Finds appropriate animation.
//  Since required animation can be different under various conditions:
//      -   incomplete shot (DB shotgun)
//      -   whether we're aiming or not
//  we must choose it based on these conditions.
function NiceWeapon.FireAnim GetCorrectAnim(bool bIncomplete, bool bAimed){
    if(bAimed){
        if(bIncomplete && weapon.HasAnim(fireAnims.incompleteAimed.anim))
            return fireAnims.incompleteAimed;
        else if(weapon.HasAnim(fireAnims.aimed.anim))
            return fireAnims.aimed;
    }
    else if(bIncomplete && weapon.HasAnim(fireAnims.incomplete.anim))
            return fireAnims.incomplete;
    return fireAnims.justFire;
}

function PlayFiringAnim(bool bIncomplete){
    local float                 animRate;
    //  Find appropriate animation and speed to play it at
    fireState.base.latestFireRate = GetFireSpeed();
    fireState.base.latestFireAnim =
        GetCorrectAnim(bIncomplete, kfWeap.bAimingRifle);
    animRate =
        fireState.base.latestFireAnim.rate * fireState.base.latestFireRate;
    //  Play it
    //  'LoopAnim' won't reset animation to initial position,
    //  so no need to check if we're already playing the same animation
    if(fireState.base.latestFireAnim.bLoop)
        weapon.LoopAnim(fireState.base.latestFireAnim.anim, animRate);
    else
        weapon.PlayAnim(fireState.base.latestFireAnim.anim, animRate);
}

//  NICETODO: don't update animations after certain point
//  Updates the speed of current fire animation according to fire rate
function UpdateFireAnimation(){
    local bool  fireRateChanged;
    local name  seqName;
    local float oFrame, oRate;
    local float animRate;
    weapon.GetAnimParams(0, seqName, oFrame, oRate);
    fireRateChanged = (fireState.base.latestFireRate != GetFireSpeed());
    //  Update animation only if it's speed changed
    //  AND it's still the same animation, since otherwise we may interfer with
    //  what we shouldn't
    if(fireRateChanged && fireState.base.latestFireAnim.anim == seqName){
        fireState.base.latestFireRate = GetFireSpeed();
        animRate =
            fireState.base.latestFireAnim.rate * fireState.base.latestFireRate;
        if(fireState.base.latestFireAnim.bLoop)
            weapon.LoopAnim(seqName, animRate);
        else{
            weapon.PlayAnim(seqName, animRate);
            weapon.SetAnimFrame(oFrame);
        }
    }
}

//  Starts end animation for currently running looped fire animation;
//  doesn't nothing if current animation isn't looped fire animation.
function FinishFireLoopAnimation(){
    local name  seqName;
    local float oFrame, oRate;
    //  Are we looping and does end animation even exist?
    if(!fireState.base.latestFireAnim.bLoop) return;
    if(fireState.base.latestFireAnim.animEnd == '') return;
    //  Was this animation initiated by us or something else?
    //  Bail if by something else.
    weapon.GetAnimParams(0, seqName, oFrame, oRate);
    if(seqName != fireState.base.latestFireAnim.anim) return;
    weapon.PlayAnim(fireState.base.latestFireAnim.animEnd, 1.0, 0.1);
}

function PlayFiringSound(){
    local bool  bDoStereoSound;
    local sound correctSound;
    local float correctVolume;
    local float randPitch;

    randPitch = FRand() * randomPitchAdjustAmt;
    if(FRand() < 0.5)
        randPitch *= -1.0;
    if(stereoFireSound != none && kfWeap.instigator.IsLocallyControlled())
        bDoStereoSound = kfWeap.instigator.IsFirstPerson();
    if(bDoStereoSound){
        correctSound    = stereoFireSound;
        correctVolume   = transientSoundVolume * 0.85;
    }
    else{
        correctSound    = fireSound;
        correctVolume   = transientSoundVolume;
    }
    weapon.PlayOwnedSound(  correctSound,
                            SLOT_Interact,
                            correctVolume,,
                            transientSoundRadius,
                            1.0 + randPitch,
                            false);
}

function NicePlayFiring(bool bIncomplete){
    if(kfWeap == none || weapon.mesh == none) return;
    if(kfWeap.instigator == none) return;
    PlayFiringAnim(bIncomplete);
    PlayFiringSound();
    ClientPlayForceFeedback(fireForce);
}

//  How reoil multiplier should be modified.
//  Added as a place for skills to take effect.
simulated function float ModRecoilMultiplier(float recoilMult){
    local int                   stationarySeconds;
    local bool                  bSkillRecoilReset;
    local NicePlayerController  nicePlayer;
    local NiceHumanPawn         nicePawn;

    if(instigator != none){
        nicePlayer = NicePlayerController(instigator.controller);
        nicePawn = NiceHumanPawn(instigator);
    }
    if(nicePawn == none || nicePlayer == none || nicePlayer.bFreeCamera)
        return 0.0;

    bSkillRecoilReset = (nicePlayer.IsZedTimeActive()
        && class'NiceVeterancyTypes'.static.
        hasSkill(nicePlayer, class'NiceSkillEnforcerZEDBarrage'));
    if(bSkillRecoilReset)
        recoilMult = 0.0;

    if(nicePawn.stationaryTime > 0.0
        &&  class'NiceVeterancyTypes'.static.
            hasSkill(nicePlayer, class'NiceSkillHeavyStablePosition')){
        stationarySeconds = Ceil(2 * nicePawn.stationaryTime) - 1;
        recoilMult *= 1.0 - stationarySeconds *
            class'NiceSkillHeavyStablePosition'.default.recoilDampeningBonus;
        recoilMult = FMax(0.0, recoilMult);
    }
    return recoilMult;
}

//  Mods recoil based on player's current movement.
//  Treats falling in low gravity differently from regular falling
//  to reduce recoil increase effects.
simulated function Rotator AdjustRecoilForVelocity(Rotator recoilRotation){
    local Vector    adjustedVelocity;
    local float     adjustedSpeed;
    local float     recoilIncrement;
    local bool      bLowGrav;
    if(weapon == none) return recoilRotation;
    if(recoilVelocityScale <= 0) return recoilRotation;

    if(weapon.owner != none && weapon.owner.physics == PHYS_Falling)
        bLowGrav = weapon.owner.PhysicsVolume.gravity.Z >
            class'PhysicsVolume'.default.gravity.Z;
    //  Treat low gravity as a special case
    if(bLowGrav){
        adjustedVelocity = weapon.owner.velocity;
        //  Ignore Z velocity in low grav so we don't get massive recoil
        adjustedVelocity.Z = 0;
        adjustedSpeed = VSize(adjustedVelocity);
        //  Reduce the falling recoil in low grav
        recoilIncrement = adjustedSpeed * recoilVelocityScale * 0.5;
    }
    else
        recoilIncrement = VSize(weapon.owner.velocity) * recoilVelocityScale;
    recoilRotation.pitch += recoilIncrement;
    recoilRotation.yaw += recoilIncrement;
    return recoilRotation;
}

//  Rendomize recoil and apply skills, movement, health and fire rate
//  modifiers to it
simulated function HandleRecoil(float recoilMult){
    local float                 recoilAngle;
    local Rotator               newRecoilRotation;
    local NicePlayerController  nicePlayer;
    if(weapon == none) return;
    if(instigator != none)
        nicePlayer = NicePlayerController(instigator.controller);
    if(nicePlayer == none || nicePlayer.bFreeCamera) return;
    //  Skills recoil mod
    recoilMult = ModRecoilMultiplier(recoilMult);

    //  Apply flag reset
    if(fireState.base.bResetRecoil)
        recoilMult = 0.0;
    fireState.base.bResetRecoil = false;

    //  Generate random values for a recoil
    //  (we now randomize only horizontal recoil)
    recoilAngle = GetFireType().rebound.recoilVertical;
    newRecoilRotation.pitch = recoilAngle;
    recoilAngle = GetFireType().rebound.recoilHorizontal;
    newRecoilRotation.yaw   = RandRange(recoilAngle * 0.5, recoilAngle);
    if(Rand(2) == 1)
        newRecoilRotation.yaw *= -1;

    //  Further increase it due to movement and low health
    newRecoilRotation = AdjustRecoilForVelocity(newRecoilRotation);
    newRecoilRotation.pitch += (instigator.healthMax / instigator.health * 5);
    newRecoilRotation.yaw   += (instigator.healthMax / instigator.health * 5);
    newRecoilRotation *= recoilMult;

    //  Scale it to the fire rate;
    //  calibrating recoil speed seems rather meaningless,
    //  so just set it to constant
    nicePlayer.SetRecoil(newRecoilRotation, 0.1 * level.timeDilation);
}

//  Finds appropriate point to spawn a bullet at, taking in the consideration
//  spawn offset setting and whether or not weapon is centered
//  (any weapon is centered when aiming down sights).
//
//  There might be a problem if bullet spawn point is too far, since then enemy
//  can fit between us and spawn point, making it impossible to hit it;
//  in that case function attempts to find some other point between us and enemy
function Vector FindBulletSpawnPoint(){
    local Vector bulletSpawn;
    local Vector eyesPoint;
    local Vector X, Y, Z;
    local Vector hitLocation, normal, offset;
    local Actor other;
    if(instigator == none || weapon == none || kfWeap == none)
        return Vect(0,0,0);

    eyesPoint   = instigator.location + instigator.EyePosition();
    offset      = GetFireType().movement.spawnOffset;
    //  Spawn point candidate ('bulletSpawn')
    weapon.GetViewAxes(X, Y, Z);
    bulletSpawn = eyesPoint + X * offset.X;
    if(!kfWeap.bAimingRifle && !weapon.WeaponCentered())
        bulletSpawn = bulletSpawn + weapon.hand * Y * offset.Y + Z * offset.Z;
    //  Try tracing to see if there's something between our eyes ('eyePoint')
    //  and our spawn point candidate ('bulletSpawn');
    //  if there is - spawn bullet at the first point
    //  where we hit it ('hitLocation')
    other = weapon.Trace(hitLocation, normal, bulletSpawn, eyesPoint, false);
    if(other != none)
        return hitLocation;
    //  Otherwise - return our previous candiate
    return bulletSpawn;
}

//  Applies kickback as required by specified NWFireType.
function DoKickback(NWFireType fireType){
    local bool      bLowGravity;
    local Vector    kickback;
    if(instigator == none || instigator.role < Role_AUTHORITY) return;

    kickback = fireType.rebound.kickMomentum;
    bLowGravity = instigator.physicsVolume.gravity.Z >
        class'PhysicsVolume'.default.gravity.Z;
    if(instigator.physics == PHYS_Falling && bLowGravity)
        kickback *= fireType.rebound.lowGravKickMomentumScale;
    instigator.AddVelocity(kickback >> instigator.GetViewRotation());
}

function DoNiceFireEffect(int ammoToFire){
    local Vector bulletSpawnPoint;
    local Rotator aim;
    local NWFireType fireType;
    local int bulletsToSpawn;
    if(instigator == none) return;

    //  Find proper projectile spawn point
    fireType = GetFireType();
    bulletSpawnPoint = FindBulletSpawnPoint();
    aim = AdjustAim(bulletSpawnPoint, aimError);
    bulletsToSpawn = ammoToFire * fireType.weapon.bulletsAmount;
    //  Fire actual bullets
    class'NiceBulletSpawner'.static.FireBullets(bulletsToSpawn,
                                                bulletSpawnPoint, aim,
                                                fireType.movement.spread,
                                                fireType, fireState);
    DoKickback(fireType);
}

//  NICETODO: redo 'TraceZed' and 'TraceWall'

//  Hack to trigger buttons on ScrN's testing grounds
function DoTraceHack(Vector start, Rotator dir){
    local Actor other;
    local array<int> hitPoints;
    local Vector dirVector, end;
    local Vector hitLocation, hitNormal;

    dirVector = Vector(dir);
    end = start + traceRange * dirVector;
    other = Instigator.HitPointTrace(   hitLocation, hitNormal,
                                        end, hitPoints, start,, 1);
    if(Trigger(other) != none)
        other.TakeDamage(35, instigator, hitLocation, dirVector, damageType);
}

defaultproperties
{
    aimerror=0.0
    /*ProjPerFire=1
    ProjectileSpeed=1524.000000
    MaxBurstLength=3
    bulletClass=Class'NicePack.NiceBullet'
    contBonus=1.200000
    maxBonusContLenght=1
    AmmoPerFire=1
    bRecoilRightOnly=false
    fireState.base.sourceWeapon=none*/
}