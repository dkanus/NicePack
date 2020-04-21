// Zombie Monster for KF Invasion gametype
class NiceZombieFleshpound extends NiceZombieFleshpoundBase;
var bool bFirstRageAttack;
simulated function PostNetBeginPlay(){
    if(AvoidArea == none)
       AvoidArea = Spawn(class'NiceAvoidMarkerFP', self);
    if(AvoidArea != none)
       AvoidArea.InitFor(Self);
    EnableChannelNotify(1, 1);
    AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
    super.PostNetBeginPlay();
}
function bool CanGetOutOfWay(){
    return false;
}
function bool IsStunPossible(){
    return false;
}
// This zed has been taken control of. Boost its health and speed
function SetMindControlled(bool bNewMindControlled)
{
    if( bNewMindControlled )
    {
       NumZCDHits++;

       // if we hit him a couple of times, make him rage!
       if( NumZCDHits > 1 )
       {
           if( !IsInState('ChargeToMarker') )
           {
               GotoState('ChargeToMarker');
           }
           else
           {
               NumZCDHits = 1;
               if( IsInState('ChargeToMarker') )
               {
                   GotoState('');
               }
           }
       }
       else
       {
           if( IsInState('ChargeToMarker') )
           {
               GotoState('');
           }
       }

       if( bNewMindControlled != bZedUnderControl )
       {
           SetGroundSpeed(OriginalGroundSpeed * 1.25);
           Health *= 1.25;
           HealthMax *= 1.25;
       }
    }
    else
    {
       NumZCDHits=0;
    }
    bZedUnderControl = bNewMindControlled;
}
// Handle the zed being commanded to move to a new location
function GivenNewMarker()
{
    if( bChargingPlayer && NumZCDHits > 1  )
    {
       GotoState('ChargeToMarker');
    }
    else
    {
       GotoState('');
    }
}
function bool CheckMiniFlinch(int flinchScore, Pawn instigatedBy, Vector hitLocation, Vector momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, KFPlayerReplicationInfo KFPRI){
    if(Controller.IsInState('WaitForAnim') || flinchScore < 100)
       return false;
    return super.CheckMiniFlinch(flinchScore, instigatedBy, hitLocation, momentum, damageType, headshotLevel, KFPRI);
}
function ModDamage(out int Damage, Pawn instigatedBy, Vector hitLocation, Vector momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, KFPlayerReplicationInfo KFPRI, optional float lockonTime){
    super.ModDamage(Damage, instigatedBy, hitLocation, momentum, damageType, headshotLevel, KFPRI);
    // Already low damage also isn't cut down
    if(Damage <= 35)
       return;
    // Melee weapons damage is cut by the same amount
    if(class<NiceDamageTypeVetBerserker>(DamageType) != none){
       Damage *= 0.75;
       return;
    }//MEANTODO
    // He takes less damage to small arms fire (non explosives)
    // Frags and LAW rockets will bring him down way faster than bullets and shells.
    if (DamageType != class 'DamTypeFrag' && DamageType != class 'DamTypePipeBomb'
       && DamageType!=class'NiceDamTypeM41AGrenade' && DamageType != class'NiceDamTypeRocket'
       && (DamageType == none || !DamageType.default.bIsExplosive))
    {
       // Don't reduce the damage so much if it's a headshot
       if(headshotLevel > 0.0){
           if(DamageType!= none && DamageType.default.HeadShotDamageMult >= 1.5)
               Damage *= 0.75;
           else
               Damage *= 0.5;
       }
       else
           Damage *= 0.5;
    }
    // double damage from handheld explosives or poison
    else if (DamageType == class 'DamTypeFrag' || DamageType == class 'DamTypePipeBomb' || DamageType == class 'DamTypeMedicNade'){
       Damage *= 2.0;
    }
    // A little extra damage from the grenade launchers, they are HE not shrapnel,
    // and its shrapnel that REALLY hurts the FP ;)//MEANTODO
    else if(DamageType == class'NiceDamTypeM41AGrenade'
        || (DamageType != none && DamageType.default.bIsExplosive))
       Damage *= 1.25;
    if(AnimAction == 'PoundBlock')
       Damage *= BlockDamageReduction;
    if(damageType == class 'DamTypeVomit')
       Damage = 0;
    else if(damageType == class 'DamTypeBlowerThrower')
      Damage *= 0.25;
}
function TakeDamageClient(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, float lockonTime){
    local bool bWasBurning;
    local int OldHealth;
    bWasBurning = bOnFire;
    if(LastDamagedTime < Level.TimeSeconds )
       TwoSecondDamageTotal = 0;
    LastDamagedTime = Level.TimeSeconds + 2;
    OldHealth = Health;
    // Shut off his "Device" when dead
    if(Damage >= Health)
       PostNetReceive();
    Super.TakeDamageClient(Damage, instigatedBy, hitLocation, momentum, damageType, headshotLevel, lockonTime);
    TwoSecondDamageTotal += OldHealth - Health;
    if( !bDecapitated && TwoSecondDamageTotal > RageDamageThreshold && !bChargingPlayer &&
       (!(bWasBurning && bCrispified) || bFrustrated) )
       StartChargingFP(InstigatedBy);
}
// changes colors on Device (notified in anim)
simulated function DeviceGoRed()
{
    Skins[1]=Shader'KFCharacters.FPRedBloomShader';
}
simulated function DeviceGoNormal()
{
    Skins[1] = Shader'KFCharacters.FPAmberBloomShader';
}
function RangedAttack(Actor A){
    local NiceZombieFleshpoundController fpController;
    if(bShotAnim || Physics == PHYS_Swimming)
       return;
    else if(CanAttack(A))
    {
       fpController = NiceZombieFleshpoundController(Controller);
       if(fpController != none)
           fpController.RageFrustrationTimer = 0;
       bShotAnim = true;
       SetAnimAction('Claw');
       return;
    }
}
// Sets the FP in a berserk charge state until he either strikes his target, or hits timeout
function StartChargingFP(Pawn instigatedBy){
    local float RageAnimDur;
    local NiceZombieFleshpoundController fpController;
    local NiceHumanPawn rageTarget, altRageTarget;
    if(Health <= 0)
       return;
    bFirstRageAttack = true;
    SetAnimAction('PoundRage');
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    Velocity.X = 0;
    Velocity.Y = 0;
    Controller.GoToState('WaitForAnim');
    fpController = NiceZombieFleshpoundController(Controller);
    if(fpController != none)
       fpController.bUseFreezeHack = True;
    RageAnimDur = GetAnimDuration('PoundRage');
    if(fpController != none)
       fpController.SetPoundRageTimout(RageAnimDur);
    GoToState('BeginRaging');
    rageTarget = NiceHumanPawn(instigatedBy);
    altRageTarget = NiceHumanPawn(controller.focus);
    if( rageTarget != none && KFGameType(Level.Game) != none
       && class'NiceVeterancyTypes'.static.HasSkill(NicePlayerController(rageTarget.Controller),
           class'NiceSkillCommandoPerfectExecution') ){
       KFGameType(Level.Game).DramaticEvent(1.0);
    }
    else if( altRageTarget != none && KFGameType(Level.Game) != none
       && class'NiceVeterancyTypes'.static.HasSkill(NicePlayerController(altRageTarget.Controller),
           class'NiceSkillCommandoPerfectExecution') ){
       KFGameType(Level.Game).DramaticEvent(1.0);
    }
}
state BeginRaging
{
    Ignores StartChargingFP;
    function bool CanGetOutOfWay()
    {
       return false;
    }
    simulated function bool HitCanInterruptAction()
    {
       return false;
    }
    function Tick( float Delta )
    {
       Acceleration = vect(0,0,0);

       global.Tick(Delta);
    }
Begin:
    Sleep(GetAnimDuration('PoundRage'));
    GotoState('RageCharging');
}
state RageCharging
{
Ignores StartChargingFP;
    function bool CheckMiniFlinch(int flinchScore, Pawn instigatedBy, Vector hitLocation, Vector momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, KFPlayerReplicationInfo KFPRI){
       if(!bShotAnim)
           return super.CheckMiniFlinch(flinchScore, instigatedBy, hitLocation, momentum, damageType, headshotLevel, KFPRI);
       return false;
    }
    function bool CanGetOutOfWay()
    {
       return false;
    }
    // Don't override speed in this state
    function bool CanSpeedAdjust()
    {
       return false;
    }
    function BeginState()
    {
       bChargingPlayer = true;
       if( Level.NetMode!=NM_DedicatedServer )
           ClientChargingAnims();

       RageEndTime = (Level.TimeSeconds + 15) + (FRand() * 18);
       NetUpdateTime = Level.TimeSeconds - 1;
    }
    function EndState()
    {
       local NiceZombieFleshpoundController fpController;
       bChargingPlayer = False;
       bFrustrated = false;

       fpController = NiceZombieFleshPoundController(Controller);
       if(fpController == none)
           fpController.RageFrustrationTimer = 0;

       if( Health>0 && !bZapped )
       {
           SetGroundSpeed(GetOriginalGroundSpeed());
       }

       if( Level.NetMode!=NM_DedicatedServer )
           ClientChargingAnims();

       NetUpdateTime = Level.TimeSeconds - 1;
    }
    function Tick( float Delta )
    {
       if( !bShotAnim )
       {
           SetGroundSpeed(OriginalGroundSpeed * 2.3);//2.0;
           if( !bFrustrated && !bZedUnderControl && Level.TimeSeconds>RageEndTime )
           {
               GoToState('');
           }
       }

       // Keep the flesh pound moving toward its target when attacking
       if( Role == ROLE_Authority && bShotAnim)
       {
           if( LookTarget!=none )
           {
               Acceleration = AccelRate * Normal(LookTarget.Location - Location);
           }
       }

       global.Tick(Delta);
    }
    function Bump( Actor Other )
    {
       local float RageBumpDamage;
       local KFMonster KFMonst;

       KFMonst = KFMonster(Other);

       // Hurt/Kill enemies that we run into while raging
       if( !bShotAnim && KFMonst!=none && NiceZombieFleshPound(Other)==none && Pawn(Other).Health>0 )
       {
           // Random chance of doing obliteration damage
           if( FRand() < 0.4 )
           {
                RageBumpDamage = 501;
           }
           else
           {
                RageBumpDamage = 450;
           }

           RageBumpDamage *= KFMonst.PoundRageBumpDamScale;

           Log("DAMAGE!"@String(RageBumpDamage));
           Other.TakeDamage(RageBumpDamage, self, Other.Location, Velocity * Other.Mass, class'NiceDamTypePoundCrushed');
       }
       else Global.Bump(Other);
    }
    // If fleshie hits his target on a charge, then he should settle down for abit.
    function bool MeleeDamageTarget(int hitdamage, vector pushdir)
    {
       local bool RetVal,bWasEnemy;

       bWasEnemy = (Controller.Target==Controller.Enemy);
       RetVal = Super.MeleeDamageTarget(hitdamage*1.75, pushdir*3);
       if( RetVal && bWasEnemy )
           GoToState('');
       return RetVal;
    }
}
// State where the zed is charging to a marked location.
// Not sure if we need this since its just like RageCharging,
// but keeping it here for now in case we need to implement some
// custom behavior for this state
state ChargeToMarker extends RageCharging
{
Ignores StartChargingFP;
    function Tick( float Delta )
    {
       if( !bShotAnim )
       {
           SetGroundSpeed(OriginalGroundSpeed * 2.3);
           if( !bFrustrated && !bZedUnderControl && Level.TimeSeconds>RageEndTime )
           {
               GoToState('');
           }
       }

       // Keep the flesh pound moving toward its target when attacking
       if( Role == ROLE_Authority && bShotAnim)
       {
           if( LookTarget!=none )
           {
               Acceleration = AccelRate * Normal(LookTarget.Location - Location);
           }
       }

       global.Tick(Delta);
    }
}
simulated function PostNetReceive()
{
    if( bClientCharge!=bChargingPlayer && !bZapped )
    {
       bClientCharge = bChargingPlayer;
       if (bChargingPlayer)
       {
           MovementAnims[0]=ChargingAnim;
           MeleeAnims[0]='FPRageAttack';
           MeleeAnims[1]='FPRageAttack';
           MeleeAnims[2]='FPRageAttack';
           DeviceGoRed();
       }
       else
       {
           MovementAnims[0]=default.MovementAnims[0];
           MeleeAnims[0]=default.MeleeAnims[0];
           MeleeAnims[1]=default.MeleeAnims[1];
           MeleeAnims[2]=default.MeleeAnims[2];
           DeviceGoNormal();
       }
    }
}
simulated function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
    Super.PlayDyingAnimation(DamageType,HitLoc);
    if( Level.NetMode!=NM_DedicatedServer )
       DeviceGoNormal();
}
simulated function ClientChargingAnims()
{
    PostNetReceive();
}
function ClawDamageTarget()
{
    local vector PushDir;
    local KFHumanPawn HumanTarget;
    local KFPlayerController HumanTargetController;
    local float UsedMeleeDamage;
    local name  Sequence;
    local float Frame, Rate;
    GetAnimParams( ExpectingChannel, Sequence, Frame, Rate );
    if( MeleeDamage > 1 )
    {
      UsedMeleeDamage = (MeleeDamage - (MeleeDamage * 0.05)) + (MeleeDamage * (FRand() * 0.1));
    }
    else
    {
      UsedMeleeDamage = MeleeDamage;
    }
    // Reduce the melee damage for anims with repeated attacks, since it does repeated damage over time
    if( Sequence == 'PoundAttack1' )
    {
       UsedMeleeDamage *= 0.5;
    }
    else if( Sequence == 'PoundAttack2' )
    {
       UsedMeleeDamage *= 0.25;
    }
    if(Controller!=none && Controller.Target!=none)
    {
       //calculate based on relative positions
       PushDir = (damageForce * Normal(Controller.Target.Location - Location));
    }
    else
    {
       //calculate based on way Monster is facing
       PushDir = damageForce * vector(Rotation);
    }
    if ( MeleeDamageTarget( UsedMeleeDamage, PushDir))
    {
       HumanTarget = KFHumanPawn(Controller.Target);
       if( HumanTarget!=none )
           HumanTargetController = KFPlayerController(HumanTarget.Controller);
       if( HumanTargetController!=none )
           HumanTargetController.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
       PlaySound(MeleeAttackHitSound, SLOT_Interact, 1.25);
    }
}
function SpinDamage(actor Target)
{
    local vector HitLocation;
    local Name TearBone;
    local Float dummy;
    local float DamageAmount;
    local vector PushDir;
    local KFHumanPawn HumanTarget;
    if(target==none)
       return;
    PushDir = (damageForce * Normal(Target.Location - Location));
    damageamount = (SpinDamConst + rand(SpinDamRand) );
    // FLING DEM DEAD BODIEZ!
    if (Target.IsA('KFHumanPawn') && Pawn(Target).Health <= DamageAmount)
    {
       KFHumanPawn(Target).RagDeathVel *= 3;
       KFHumanPawn(Target).RagDeathUpKick *= 1.5;
    }
    if (Target !=none && Target.IsA('KFDoorMover'))
    {
       Target.TakeDamage(DamageAmount , self ,HitLocation,pushdir, class 'NicePack.NiceZedMeleeDamageType');
       PlaySound(MeleeAttackHitSound, SLOT_Interact, 1.25);
    }
    if (KFHumanPawn(Target)!=none)
    {
       HumanTarget = KFHumanPawn(Target);
       if (HumanTarget.Controller != none)
           HumanTarget.Controller.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

       //TODO - line below was KFPawn. Does this whole block need to be KFPawn, or is it OK as KFHumanPawn?
       KFHumanPawn(Target).TakeDamage(DamageAmount, self ,HitLocation,pushdir, class 'NicePack.NiceZedMeleeDamageType');

       if (KFHumanPawn(Target).Health <=0)
       {
           KFHumanPawn(Target).SpawnGibs(rotator(pushdir), 1);
           TearBone=KFPawn(Target).GetClosestBone(HitLocation,Velocity,dummy);
           KFHumanPawn(Controller.Target).HideBone(TearBone);
       }
    }
}
simulated function int DoAnimAction( name AnimName )
{
    if( AnimName=='PoundAttack1' || AnimName=='PoundAttack2' || AnimName=='PoundAttack3'
       ||AnimName=='FPRageAttack' || AnimName=='ZombieFireGun' )
    {
       AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
       PlayAnim(AnimName,, 0.1, 1);
       Return 1;
    }
    Return Super.DoAnimAction(AnimName);
}
simulated event SetAnimAction(name NewAction)
{
    local int meleeAnimIndex;
    if( NewAction=='' )
       Return;
    // Remove one of the attacks during fp's rage
    if(NewAction == 'Claw')
    {
       if(IsInState('RageCharging') && bFirstRageAttack){
           bFirstRageAttack = false;
           meleeAnimIndex = Rand(2);
           NewAction = meleeAnims[meleeAnimIndex+1];
       }
       else{
           meleeAnimIndex = Rand(3);
           NewAction = meleeAnims[meleeAnimIndex];
       }
    }
    ExpectingChannel = DoAnimAction(NewAction);
    if( AnimNeedsWait(NewAction) )
    {
       bWaitForAnim = true;
    }
    if( Level.NetMode!=NM_Client )
    {
       AnimAction = NewAction;
       bResetAnimAct = True;
       ResetAnimActTime = Level.TimeSeconds+0.3;
    }
}
// The animation is full body and should set the bWaitForAnim flag
simulated function bool AnimNeedsWait(name TestAnim)
{
    if( TestAnim == 'PoundRage' || TestAnim == 'DoorBash' )
    {
       return true;
    }
    return false;
}
simulated function Tick(float DeltaTime)
{
    super.Tick(DeltaTime);
    // Keep the flesh pound moving toward its target when attacking
    if( Role == ROLE_Authority && bShotAnim)
    {
       if( LookTarget!=none )
       {
           Acceleration = AccelRate * Normal(LookTarget.Location - Location);
       }
    }
}

function bool FlipOver()
{
    return false;
}
function bool SameSpeciesAs(Pawn P)
{
    return (NiceZombieFleshPound(P)!=none);
}
simulated function Destroyed()
{
    if( AvoidArea!=none )
       AvoidArea.Destroy();
    Super.Destroyed();
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.fleshpound_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.fleshpound_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.fleshpound_diff');
}
defaultproperties
{
    stunLoopStart=0.140000
    stunLoopEnd=0.650000
    idleInsertFrame=0.950000
    EventClasses(0)="NicePack.NiceZombieFleshpound"
    MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Talk'
    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_HitPlayer'
    JumpSound=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Jump'
    DetachedArmClass=Class'KFChar.SeveredArmPound'
    DetachedLegClass=Class'KFChar.SeveredLegPound'
    DetachedHeadClass=Class'KFChar.SeveredHeadPound'
    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Pain'
    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Death'
    ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
    ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
    ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
    ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
    ControllerClass=Class'NicePack.NiceZombieFleshpoundController'
    AmbientSound=Sound'KF_BaseFleshpound.FP_IdleLoop'
    Mesh=SkeletalMesh'KF_Freaks_Trip.FleshPound_Freak'
    Skins(0)=Combiner'KF_Specimens_Trip_T.fleshpound_cmb'
}
