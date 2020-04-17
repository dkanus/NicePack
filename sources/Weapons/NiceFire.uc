class NiceFire extends KFFire
    abstract;
var bool bDoSpam;
var     name        FireIncompleteAnim;
var     name        FireIncompleteAimedAnim;
var     name        FireIncompleteLoopAnim;
var     name        FireIncompleteLoopAimedAnim;
var     float       zedTimeFireSpeedUp;
// Projectile-related variables
var()   bool        bProjectileFire;
var()   bool        bCanFireIncomplete;
var()   int         ProjPerFire;
var()   Vector      ProjSpawnOffset;
var()   float       EffectiveRange;
var()   vector      KickMomentum;
var()   float       LowGravKickMomentumScale;   // How much to scale up kick momentum in low grav so guys fly around hilariously :)
var()   float       ProjectileSpeed;            // How fast projectile should move
var()   bool        bDisabled;
var()   bool        bSemiMustBurst;
var()   int         MaxBurstLength;
var()   int         burstShotsMade;
var     bool        bResetRecoil;   // Set this flag to 'true' to disable recoil for the next shot; flag will be automatically reset to 'false' after that
var     bool        zoomOutOnShot;
var     bool        bShouldBounce;
var     bool        bCausePain;
var     bool        bBetterBurst;
var class<NiceBullet> bulletClass;
var class<NiceWeaponDamageType> explosionDamageType;
var int     explosionDamage;
var float   explosionRadius;
var float   explosionExponent;
var float   explosionMomentum;
var float   fuseTime;
var bool    explodeOnFuse;
var bool    explodeOnPawnHit;
var bool    explodeOnWallHit;
var bool    projAffectedByScream;
var bool    bShouldStick;
var int resetTicks;
var float niceNextFireTime;
struct FireModeContext{
    var bool            bHipfire;
    var NiceWeapon      sourceWeapon;
    var NiceHumanPawn   Instigator;
    var bool            bIsBursting;
    var int             burstLength;
    var float           continiousBonus;
    var float           lockonTime;
    var NiceMonster     lockonZed;
};
var FireModeContext currentContext;
// Secondary fire effect, - allows to spawn additional projectiles along with main hitscan/projectile
struct ShotType{
    var bool                        bShouldBounce;  // Bullets should bounce off the walls
    var int                         damage;
    var int                         projPerFire;
    var float                       spread;
    var float                       projSpeed;
    var float                       momentum;
    var ESpreadStyle                spreadStyle;
    var class<NiceWeaponDamageType> shotDamageType;
    var class<NiceWeaponDamageType> explosionDamageType;
    var class<NiceBullet>           bulletClass;
    var int                         explosionDamage;
    var float                       explosionRadius;
    var float                       explosionExponent;
    var float                       explosionMomentum;
    var float                       fuseTime;
    var bool                        bCausePain;
    var bool                        explodeOnFuse;
    var bool                        explodeOnPawnHit;
    var bool                        explodeOnWallHit;
    var bool                        projAffectedByScream;
    var bool                        bShouldStick;
};
// All the available shot types; shot type at index zero is auto-filled from the usual kf's parameters
var array<ShotType> fireShots;
// Index of the shot we're currently generating
var int             currentShot;
// Variables for managing damage boosts for fast firing
var float contBonus;
var bool contBonusReset; // does bonus reset after reaching the top value? 'false' means it'll keep being maxed out until player releases fire button
var int maxBonusContLenght;
var int currentContLenght;
var float period;
static function PreloadAssets(LevelInfo LevelInfo, optional KFFire Spawned){
    local int i;
    if(default.FireSound == none && default.FireSoundRef != "")
       default.FireSound = sound(DynamicLoadObject(default.FireSoundRef, class'Sound', true));
    if(default.StereoFireSound == none){
       if(default.StereoFireSoundRef != "")
           default.StereoFireSound = sound(DynamicLoadObject(default.StereoFireSoundRef, class'Sound', true));
       else
           default.StereoFireSound = default.FireSound;
    }
    if(default.NoAmmoSound == none && default.NoAmmoSoundRef != "")
       default.NoAmmoSound = sound(DynamicLoadObject(default.NoAmmoSoundRef, class'Sound', true));
    if(Spawned != none){
       Spawned.FireSound = default.FireSound;
       Spawned.StereoFireSound = default.StereoFireSound;
       Spawned.NoAmmoSound = default.NoAmmoSound;
    }
    if(default.bulletClass != none)
       default.bulletClass.static.PreloadAssets();
    for(i = 0;i < default.fireShots.Length;i ++)
       if(default.fireShots[i].bulletClass != none)
           default.fireShots[i].bulletClass.static.PreloadAssets();
}
static function bool UnloadAssets(){
    default.FireSound = none;
    default.StereoFireSound = none;
    default.NoAmmoSound = none;
    if(default.bulletClass != none)
       default.bulletClass.static.UnloadAssets();
    return true;
}
simulated function PostBeginPlay(){
    local ShotType defaultShotType;
    currentContext.continiousBonus = 1.0;
    currentContext.burstLength = 1;
    // Build index-zero shot type
    defaultShotType.damage                  = DamageMax;
    defaultShotType.projPerFire             = ProjPerFire;
    defaultShotType.spread                  = Spread;
    defaultShotType.projSpeed               = projectileSpeed;
    defaultShotType.momentum                = momentum;
    defaultShotType.spreadStyle             = spreadStyle;
    defaultShotType.bShouldBounce           = bShouldBounce;
    defaultShotType.shotDamageType          = class<NiceWeaponDamageType>(DamageType);
    defaultShotType.explosionDamageType     = explosionDamageType;
    defaultShotType.bulletClass             = bulletClass;
    defaultShotType.explosionDamage         = explosionDamage;
    defaultShotType.explosionRadius         = explosionRadius;
    defaultShotType.explosionExponent       = explosionExponent;
    defaultShotType.explosionMomentum       = explosionMomentum;
    defaultShotType.fuseTime                = fuseTime;
    defaultShotType.explodeOnFuse           = explodeOnFuse;
    defaultShotType.explodeOnPawnHit        = explodeOnPawnHit;
    defaultShotType.explodeOnWallHit        = explodeOnWallHit;
    defaultShotType.projAffectedByScream    = projAffectedByScream;
    defaultShotType.bCausePain              = bCausePain;
    defaultShotType.bShouldStick            = bShouldStick;
    fireShots[0] = defaultShotType;
    super.PostBeginPlay();
}
simulated function int GetBurstLength(){
    return currentContext.burstLength;
}
simulated function ModeTick(float delta){
    local float headLevel;
    local NiceMonster currTarget;
    if(currentContext.Instigator == none)
       currentContext.Instigator = NiceHumanPawn(Instigator);
    if(currentContext.sourceWeapon == none)
       currentContext.sourceWeapon = NiceWeapon(Weapon);
    if(burstShotsMade >= GetBurstLength() && currentContext.bIsBursting){
       SetTimer(0, false);
       currentContext.bIsBursting = false;
    }
    // Lock-on update
    if(Instigator.Role < Role_AUTHORITY){
       period += delta;
       headLevel = TraceZed(currTarget);
       if(headLevel <= 0.0 || currTarget == none){
           currentContext.lockonTime = 0.0;
           currentContext.lockonZed = none;
       }
       else{
           if(currTarget == currentContext.lockonZed)
               currentContext.lockonTime += delta ;
           else
               currentContext.lockonTime = 0.0;
           currentContext.lockonZed = currTarget;
       }
       if(period > 0.1 && currentContext.lockonTime > 0.0)
           period = 0.0;
    }
    // Reset 'FireCount'
    if(Instigator.Controller.bFire == 0 && Instigator.Controller.bAltFire == 0)
       FireCount = 0;
    super.ModeTick(delta);
}
simulated function Timer(){
    if(!AllowFire())
       burstShotsMade = GetBurstLength();
    if(currentContext.bIsBursting && burstShotsMade < GetBurstLength())
       ModeDoFire();
}
simulated function bool AllowFire(){
    local int magAmmo;
    local bool allowZeroShot;
    local bool bRegularFire;
    local KFPawn kfPwn;
    bRegularFire = !currentContext.sourceWeapon.bHasSecondaryAmmo || ThisModeNum == 0;
    //if(niceNextFireTime > Level.TimeSeconds)
    //    return false;
    if(currentContext.sourceWeapon == none || Instigator == none)
       return false;
    if(currentContext.bIsBursting && burstShotsMade >= GetBurstLength())
       return false;
    if(currentContext.sourceWeapon.bHasChargePhase && !currentContext.sourceWeapon.bRoundInChamber && bRegularFire)
       return false;
    if(currentContext.sourceWeapon.secondaryCharge < default.AmmoPerFire && !bCanFireIncomplete && !bRegularFire)
       return false;
    // Check reloading
    magAmmo = currentContext.sourceWeapon.GetMagazineAmmo();
    if(currentContext.sourceWeapon != none)
       allowZeroShot = (Instigator.Role == Role_AUTHORITY && !currentContext.sourceWeapon.bServerFiredLastShot);
    if(currentContext.sourceWeapon.bIsReloading || (magAmmo < 1 && !allowZeroShot && bRegularFire)
       || (magAmmo < default.AmmoPerFire && !bCanFireIncomplete && !allowZeroShot && bRegularFire))
       return false;
    // Check pawn actions
    kfPwn = KFPawn(Instigator);
    if(kfPwn == none || kfPwn.SecondaryItem != none || kfPwn.bThrowingNade)
       return false;
    return super(WeaponFire).AllowFire();
}
simulated function DoBurst(optional bool bSkipFirstShot){
    local NicePlayerController nicePlayer;
    local class<NiceVeterancyTypes> niceVet;
    if(NextFireTime > Level.TimeSeconds || currentContext.bIsBursting)
       return;
    nicePlayer = NicePlayerController(Instigator.Controller);
    if(nicePlayer != none)
       niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(nicePlayer.PlayerReplicationInfo);
    currentContext.bIsBursting = true;
    burstShotsMade = 0;
    FireCount = 0;
    if(!bSkipFirstShot)
       ModeDoFire();
    SetTimer(FireRate / GetBurstLength(), true);
}
event ModeDoFire(){
    local float Rec;
    local int magAmmo;
    local bool bForceBurst;
    if(bDisabled || Instigator == none || Instigator.Controller == none || currentContext.sourceWeapon == none)
       return;
    // Update how much we can fire
    magAmmo = currentContext.sourceWeapon.GetMagazineAmmo();
    if(bCanFireIncomplete)
       AmmoPerFire = min(default.AmmoPerFire, magAmmo);
    else
       AmmoPerFire = default.AmmoPerFire;
    UpdateFireSpeed();
    // Should we be allowed to fire?
    if(!AllowFire())
       return;
    // Bursting
    bForceBurst = bSemiMustBurst && bWaitForRelease;
    if(!currentContext.bIsBursting && bForceBurst)
       DoBurst(true);
    if(currentContext.bIsBursting)
       burstShotsMade ++;
    // If we made it this far with zero AmmoPerFire, - it's a last shot that can be incomplete and was enforced, so make it shoot something
    if(AmmoPerFire <= 0 && bCanFireIncomplete)
       AmmoPerFire = 1;
    if(Level.TimeSeconds > niceNextFireTime + FireRate){
       currentContLenght = 1;
       currentContext.continiousBonus = 1.0;
    }
    else{
        currentContLenght ++;
        if(currentContLenght > maxBonusContLenght)
        {
            if(contBonusReset)
                currentContext.continiousBonus = 1.0;
        }
        else
            currentContext.continiousBonus *= contBonus;
    }
    MDFEffects(AmmoPerFire);
    if(Instigator.Role == Role_AUTHORITY)
       MDFEffectsServer(AmmoPerFire);
    else{
       // Compute recoil
       Rec = 1.0;
       if(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none)
           KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.ModifyRecoilSpread(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self, Rec);
       if(currentContext.bIsBursting)
           Rec = Rec / GetBurstLength();
       MDFEffectsClient(AmmoPerFire, Rec);
    }
}
// Fire effects that should affect both client and server
simulated function MDFEffects(float newAmmoPerFire){
    local NicePlayerController nicePlayer;
    if(instigator != none)
       nicePlayer = NicePlayerController(instigator.controller);
    if(Weapon.Owner != none && !bFiringDoesntAffectMovement && Weapon.Owner.Physics != PHYS_Falling){
       if(FireRate > 0.25){
           Weapon.Owner.Velocity.x *= 0.1;
           Weapon.Owner.Velocity.y *= 0.1;
       }
       else{
           Weapon.Owner.Velocity.x *= 0.5;
           Weapon.Owner.Velocity.y *= 0.5;
       }
    }
    if(MaxHoldTime > 0.0)
       HoldTime = FMin(HoldTime, MaxHoldTime);
    Weapon.IncrementFlashCount(ThisModeNum);
    niceNextFireTime = UpdateNextFireTime(niceNextFireTime);
    NextFireTime = niceNextFireTime;
    AmmoPerFire = newAmmoPerFire;
    Load = AmmoPerFire;
    HoldTime = 0;
    if(currentContext.sourceWeapon != none && (zoomOutOnShot || currentContext.sourceWeapon.reloadType == RTYPE_AUTO))
       currentContext.sourceWeapon.ZoomOut(false);
    if(Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != none){
       bIsFiring = false;
       Weapon.PutDown();
    }
    for(currentShot = 0;currentShot < fireShots.Length;currentShot ++)
       DoFireEffect();
}
// Fire effects that should only affect shooting client.
simulated function MDFEffectsClient(float newAmmoPerFire, float Rec){
    local NicePlayerController nicePlayer;
    if(Instigator != none)
       nicePlayer = NicePlayerController(Instigator.Controller);
    if(nicePlayer == none || !nicePlayer.IsZedTimeActive() || !class'NiceVeterancyTypes'.static.hasSkill(nicePlayer, class'NiceSkillSharpshooterZEDHundredGauntlets'))
       ReduceAmmoClient();
    InitEffects();
    ShakeView();
    PlayFiring();
    FlashMuzzleFlash();
    StartMuzzleSmoke();
    currentContext.lockonTime = 0.0;
    currentContext.lockonZed = none;
    if(bDoClientRagdollShotFX && Weapon.Level.NetMode == NM_Client)
       DoClientOnlyFireEffect();
    HandleRecoil(Rec);
}
// Fire effects that should only be done on server
simulated function MDFEffectsServer(float newAmmoPerFire){
    local NicePlayerController nicePlayer;
    if(Instigator != none)
       nicePlayer = NicePlayerController(Instigator.Controller);
    HoldTime = 0;
    if((Instigator == none) || (Instigator.Controller == none))
       return;
    Instigator.DeactivateSpawnProtection();
    ServerPlayFiring();
    if(currentContext.sourceWeapon.MagAmmoRemaining <= 0)
       currentContext.sourceWeapon.bServerFiredLastShot = true;
}
simulated function ReduceAmmoClient(){
    if(currentContext.sourceWeapon.MagAmmoRemainingClient > 0 && (ThisModeNum == 0 || !currentContext.sourceWeapon.bHasSecondaryAmmo)){
       currentContext.sourceWeapon.MagAmmoRemainingClient -= Load;
       if(currentContext.sourceWeapon.MagAmmoRemainingClient <= 0){
           currentContext.sourceWeapon.MagAmmoRemainingClient = 0;
           currentContext.sourceWeapon.bRoundInChamber = false;
       }
       // Force server's magazine size
       currentContext.sourceWeapon.ServerReduceMag(currentContext.sourceWeapon.MagAmmoRemainingClient, Level.TimeSeconds, ThisModeNum);
    }
    else if(ThisModeNum == 1){
       currentContext.sourceWeapon.secondaryCharge -= Load;
       currentContext.sourceWeapon.ServerReduceMag(currentContext.sourceWeapon.MagAmmoRemainingClient, Level.TimeSeconds, ThisModeNum);
       currentContext.sourceWeapon.ServerSetSndCharge(currentContext.sourceWeapon.secondaryCharge);
    }
}
function name GetCorrectAnim(bool bLoop, bool bAimed){
    local bool bIncomplete;
    bIncomplete = Load < default.AmmoPerFire;
    if(bLoop){
       if(bAimed){
           if(bIncomplete && Weapon.HasAnim(FireIncompleteLoopAimedAnim))
               return FireIncompleteLoopAimedAnim;
           else
               return FireLoopAimedAnim;
       }
       else{
           if(bIncomplete && Weapon.HasAnim(FireIncompleteLoopAnim))
               return FireIncompleteLoopAnim;
           else
               return FireLoopAnim;
       }
    }
    else{
       if(bAimed){
           if(bIncomplete && Weapon.HasAnim(FireIncompleteAimedAnim))
               return FireIncompleteAimedAnim;
           else
               return FireAimedAnim;
       }
       else{
           if(bIncomplete && Weapon.HasAnim(FireIncompleteAnim))
               return FireIncompleteAnim;
           else
               return FireAnim;
       }
    }
    return FireAnim;
}
function PlayFiring(){
    local float RandPitch;
    if(Weapon.Mesh != none){
       if(FireCount > 0){
           if(KFWeap.bAimingRifle){
               if(Weapon.HasAnim(FireLoopAimedAnim))
                   Weapon.PlayAnim(GetCorrectAnim(true, true), FireLoopAnimRate, 0.0);
               else if(Weapon.HasAnim(FireAimedAnim))
                   Weapon.PlayAnim(GetCorrectAnim(false, true), FireAnimRate, TweenTime);
               else
                   Weapon.PlayAnim(GetCorrectAnim(false, false), FireAnimRate, TweenTime);
           }
           else{
               if(Weapon.HasAnim(FireLoopAnim))
                   Weapon.PlayAnim(GetCorrectAnim(true, false), FireLoopAnimRate, 0.0);
               else
                   Weapon.PlayAnim(GetCorrectAnim(false, false), FireAnimRate, TweenTime);
           }
       }
       else{
           if(KFWeap.bAimingRifle){
               if(Weapon.HasAnim(FireAimedAnim))
                   Weapon.PlayAnim(GetCorrectAnim(false, true), FireAnimRate, TweenTime);
               else
                   Weapon.PlayAnim(GetCorrectAnim(false, false), FireAnimRate, TweenTime);
           }
           else
               Weapon.PlayAnim(GetCorrectAnim(false, false), FireAnimRate, TweenTime);
       }
    }
    if(Weapon.Instigator != none && Weapon.Instigator.IsLocallyControlled() && Weapon.Instigator.IsFirstPerson() && StereoFireSound != none){
       if(bRandomPitchFireSound){
           RandPitch = FRand() * RandomPitchAdjustAmt;
           if(FRand() < 0.5)
               RandPitch *= -1.0;
       }
       Weapon.PlayOwnedSound(StereoFireSound,SLOT_Interact,TransientSoundVolume * 0.85,,TransientSoundRadius,(1.0 + RandPitch),false);
    }
    else{
       if(bRandomPitchFireSound){
           RandPitch = FRand() * RandomPitchAdjustAmt;
           if(FRand() < 0.5)
               RandPitch *= -1.0;
       }
       Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,(1.0 + RandPitch),false);
    }
    ClientPlayForceFeedback(FireForce);
    if(!currentContext.bIsBursting)
       FireCount ++;
}
// Handle setting new recoil
simulated function HandleRecoil(float Rec){
    local int stationarySeconds;
    local rotator NewRecoilRotation;
    local NicePlayerController nicePlayer;
    local NiceHumanPawn nicePawn;
    local vector AdjustedVelocity;
    local float AdjustedSpeed;
    if(Instigator != none){
       nicePlayer = NicePlayerController(Instigator.Controller);
       nicePawn = NiceHumanPawn(Instigator);
    }
    if(nicePlayer == none || nicePawn == none)
       return;
    if(bResetRecoil || nicePlayer.IsZedTimeActive() && class'NiceVeterancyTypes'.static.hasSkill(nicePlayer, class'NiceSkillEnforcerZEDBarrage')){
       Rec = 0.0;
       bResetRecoil = false;
    }
    if(nicePawn.stationaryTime > 0.0 && class'NiceVeterancyTypes'.static.hasSkill(nicePlayer, class'NiceSkillHeavyStablePosition')){
       stationarySeconds = Ceil(2 * nicePawn.stationaryTime) - 1;
       Rec *= FMax(0.0, 1.0 - (stationarySeconds * class'NiceSkillHeavyStablePosition'.default.recoilDampeningBonus));
    }
    if(!nicePlayer.bFreeCamera){
       if(Weapon.GetFireMode(ThisModeNum).bIsFiring || currentContext.bIsBursting){
           NewRecoilRotation.Pitch = RandRange(maxVerticalRecoilAngle * 0.5, maxVerticalRecoilAngle);
           NewRecoilRotation.Yaw = RandRange(maxHorizontalRecoilAngle * 0.5, maxHorizontalRecoilAngle);

           if(!bRecoilRightOnly && Rand(2) == 1)
               NewRecoilRotation.Yaw *= -1;

           if(RecoilVelocityScale > 0){
               if(Weapon.Owner != none && Weapon.Owner.Physics == PHYS_Falling &&
                   Weapon.Owner.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z){
                   AdjustedVelocity = Weapon.Owner.Velocity;
                   // Ignore Z velocity in low grav so we don't get massive recoil
                   AdjustedVelocity.Z = 0;
                   AdjustedSpeed = VSize(AdjustedVelocity);

                   // Reduce the falling recoil in low grav
                   NewRecoilRotation.Pitch += (AdjustedSpeed * RecoilVelocityScale * 0.5);
                   NewRecoilRotation.Yaw += (AdjustedSpeed * RecoilVelocityScale * 0.5);
               }
               else{
                   NewRecoilRotation.Pitch += (VSize(Weapon.Owner.Velocity) * RecoilVelocityScale);
                   NewRecoilRotation.Yaw += (VSize(Weapon.Owner.Velocity) * RecoilVelocityScale);
               }
           }

           NewRecoilRotation.Pitch += (Instigator.HealthMax / Instigator.Health * 5);
           NewRecoilRotation.Yaw += (Instigator.HealthMax / Instigator.Health * 5);
           NewRecoilRotation *= Rec;

           if(default.FireRate <= 0)
               nicePlayer.SetRecoil(NewRecoilRotation, RecoilRate);
           else
               nicePlayer.SetRecoil(NewRecoilRotation, RecoilRate * (FireRate / default.FireRate));
       }
    }
}
function DoFireEffect(){
    local bool bIsShotgunBullet, bForceComplexTraj;
    local bool bPinpoint;
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor other;
    local int p;
    local float activeSpread;
    local ESpreadStyle activeSpreadStyle;
    local int SpawnCount;
    local float theta;
    local NicePlayerController nicePlayer;
    nicePlayer = NicePlayerController(Instigator.Controller);
    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X, Y, Z);
    StartTrace = Instigator.Location + Instigator.EyePosition();
    StartProj = StartTrace + X * ProjSpawnOffset.X;
    if(!Weapon.WeaponCentered() && !KFWeap.bAimingRifle)
       StartProj = StartProj + Weapon.Hand * Y * ProjSpawnOffset.Y + Z * ProjSpawnOffset.Z;
    other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    activeSpread = fireShots[currentShot].spread;
    if(class'NiceVeterancyTypes'.static.hasSkill(nicePlayer, class'NiceSkillEnforcerBombard')){
       bPinpoint = true;
       activeSpread *= class'NiceSkillEnforcerBombard'.default.spreadMult;
    }
    bIsShotgunBullet = ClassIsChildOf(fireShots[currentShot].bulletClass, class'NiceShotgunPellet');
    if( bIsShotgunBullet && weapon.class != class'NicePack.NiceSpas' && weapon.class != class'NiceNailGun'
       && class'NiceVeterancyTypes'.static.hasSkill(nicePlayer, class'NiceSkillSupportSlugs') )
       activeSpread = 0.0;
    if(bIsShotgunBullet && activeSpread <= 0.0 && !bPinpoint)
       bForceComplexTraj = true;
    if(other != none)
       StartProj = HitLocation;
    Aim = AdjustAim(StartProj, AimError);
    SpawnCount = Max(0, fireShots[currentShot].projPerFire * int(Load));
    if(class'NiceVeterancyTypes'.static.hasSkill(nicePlayer, class'NiceSkillSupportZEDBulletStorm') && nicePlayer.IsZedTimeActive())
       SpawnCount *= class'NiceSkillSupportZEDBulletStorm'.default.projCountMult;
    activeSpreadStyle = fireShots[currentShot].spreadStyle;
    DoTraceHack(StartProj, Aim);
    currentContext.bHipfire = false;
    if(currentContext.sourceWeapon != none && !currentContext.sourceWeapon.bAimingRifle
       && !currentContext.sourceWeapon.bZoomingIn && !currentContext.sourceWeapon.bZoomingOut
       && !currentContext.sourceWeapon.bFastZoomOut)
       currentContext.bHipfire = true;
    switch(activeSpreadStyle){
    case SS_Random:
       X = Vector(Aim);
       for(p = 0; p < SpawnCount;p ++){
           if(p > 0 || !bPinpoint){
               R.Yaw = activeSpread * (FRand()-0.5);
               R.Pitch = activeSpread * (FRand()-0.5);
               R.Roll = activeSpread * (FRand()-0.5);
           }
           class'NiceProjectileSpawner'.static.MakeProjectile(StartProj, Rotator(X >> R), fireShots[currentShot], currentContext, bForceComplexTraj);
       }
       break;
    case SS_Line:
       X = Vector(Aim);
       for(p = 0; p < SpawnCount;p ++){
           if(p > 0 || !bPinpoint){
               theta = activeSpread * PI/32768 * (p - float(SpawnCount-1)/2.0);
               X.X = cos(theta);
               X.Y = sin(theta);
               X.Z = 0.0;
           }
           class'NiceProjectileSpawner'.static.MakeProjectile(StartProj, Rotator(X >> Aim), fireShots[currentShot], currentContext, bForceComplexTraj);
       }
       break;
    case SS_None:
    default:
       for(p = 0; p < SpawnCount;p ++)
           class'NiceProjectileSpawner'.static.MakeProjectile(StartProj, Aim, fireShots[currentShot], currentContext, bForceComplexTraj);
    }
    if(Instigator != none && Instigator.Role == Role_AUTHORITY){
       if(Instigator.Physics != PHYS_Falling)
           Instigator.AddVelocity(KickMomentum >> Instigator.GetViewRotation());
       else if(Instigator.Physics == PHYS_Falling && Instigator.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z)
           Instigator.AddVelocity((KickMomentum * LowGravKickMomentumScale) >> Instigator.GetViewRotation());
    }
}
simulated function float TraceZed(out NiceMonster tracedZed, optional out Vector hitLoc, optional out Vector hitNorm,
    optional float hsMultiplier){
    local Vector    Start, End, hitLocation, HitNormal;
    local Rotator   aim;
    local Actor     tracedActor;
    if(hsMultiplier <= 0.0)
       hsMultiplier = 1.0;
    MaxRange();
    Start = Instigator.Location + Instigator.EyePosition();
    aim = AdjustAim(Start, AimError);
    End = Start + TraceRange * Vector(aim);
    tracedActor = Instigator.Trace(hitLocation, hitNormal, End, Start);
    hitLoc = hitLocation;
    hitNorm = hitNormal;
    tracedZed = NiceMonster(tracedActor);
    if(tracedZed == none && ExtendedZCollision(tracedActor) != none && tracedActor.owner != none)
       tracedZed = NiceMonster(tracedActor.owner);
    if(tracedZed != none)
       return tracedZed.IsHeadshotClient(hitLocation, Vector(aim), tracedZed.clientHeadshotScale * hsMultiplier);
    return 0;
}
simulated function TraceWall(out Actor tracedActor, optional out Vector hitLoc, optional out Vector hitNorm){
    local Vector    Start, End, hitLocation, hitNormal;
    local Rotator   aim;
    MaxRange();
    Start = Instigator.Location + Instigator.EyePosition();
    aim = AdjustAim(Start, AimError);
    End = Start + TraceRange * Vector(Aim);
    tracedActor = Instigator.Trace(hitLocation, hitNormal, End, Start);
    hitLoc = hitLocation;
    hitNorm = hitNormal;
    if(KFPawn(tracedActor) != none && ExtendedZCollision(tracedActor) != none)
       tracedActor = none;
}
simulated function NiceReplicationInfo GetNiceRI(){
    if(Instigator != none && NicePlayerController(Instigator.Controller) != none)
       return NicePlayerController(Instigator.Controller).NiceRI;
    return none;
}
function DoTraceHack(Vector Start, Rotator Dir){
    local Actor other;
    local array<int> HitPoints;
    local Vector X, End, HitLocation, HitNormal;
    X = Vector(Dir);
    End = Start + TraceRange * X;
    other = Instigator.HitPointTrace(HitLocation, HitNormal, End, HitPoints, Start,, 1);
    if(Trigger(other) != none)
       other.TakeDamage(35, Instigator, HitLocation, Momentum * X, DamageType);
}
// All weapons should have 100% accuracy anyway
simulated function AccuracyUpdate(float Velocity){}
// This function is called when 'FireRate', 'FireAnimRate' or 'ReloadAnimRate' need to be updated
simulated function UpdateFireSpeed(){
    local float fireSpeedMod;
    fireSpeedMod = GetFireSpeed();
    if(NiceSingle(Weapon) != none || NiceDualies(Weapon) != none)
       fireSpeedMod /= (Level.TimeDilation / 1.1);
    fireSpeedMod *= 1.0 + 1.1 * (zedTimeFireSpeedUp - 1.0) * (1.1 - Level.TimeDilation);
    FireRate = default.FireRate / fireSpeedMod;
    FireAnimRate = default.FireAnimRate * fireSpeedMod;
    ReloadAnimRate = default.ReloadAnimRate * fireSpeedMod;
}
// This function is called when next fire time needs to be updated
simulated function float UpdateNextFireTime(float fireTimeVar){
    local float burstSlowDown;
    local NiceHumanPawn nicePawn;
    local class<NiceVeterancyTypes> niceVet;
    nicePawn = NiceHumanPawn(Instigator);
    if(nicePawn != none)
       niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(nicePawn.PlayerReplicationInfo);
    fireTimeVar = FMax(fireTimeVar, Level.TimeSeconds);
    if(bFireOnRelease){
       if(bIsFiring)
           fireTimeVar += MaxHoldTime + FireRate;
       else
           fireTimeVar = Level.TimeSeconds + FireRate;
    }
    else{
       if(currentContext.bIsBursting && GetBurstLength() > 1){
           if( niceVet != none
               && (bBetterBurst ||
                   niceVet.static.hasSkill(NicePlayerController(nicePawn.Controller), class'NiceSkillCommandoExplosivePower'))
             )
               burstSlowDown = 1.0;
           else
               burstSlowDown = 1.3;
           fireTimeVar += FireRate * burstSlowDown;
       }
       else
           fireTimeVar += FireRate;
       fireTimeVar = FMax(fireTimeVar, Level.TimeSeconds);
    }
    return fireTimeVar;
}

defaultproperties
{
     zedTimeFireSpeedUp=1.000000
     ProjPerFire=1
     ProjectileSpeed=1524.000000
     MaxBurstLength=3
     bulletClass=Class'NicePack.NiceBullet'
     contBonus=1.200000
     contBonusReset=True
     maxBonusContLenght=1
     AmmoPerFire=1
}
