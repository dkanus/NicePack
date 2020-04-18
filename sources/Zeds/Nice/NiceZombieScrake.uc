// Chainsaw Zombie Monster for KF Invasion gametype
// He's not quite as speedy as the other Zombies, But his attacks are TRULY damaging.
class NiceZombieScrake extends NiceZombieScrakeBase;
var bool bConfusedState;
var bool bWasCalm;
//----------------------------------------------------------------------------
// NOTE: All Variables are declared in the base class to eliminate hitching
//----------------------------------------------------------------------------
simulated function PostNetBeginPlay()
{
    EnableChannelNotify ( 1,1);
    AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
    super.PostNetBeginPlay();
}
simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    bWasCalm = true;
    SpawnExhaustEmitter();
}
// Make the scrakes's ambient scale higher, since there are just a few, and thier chainsaw need to be heard from a distance
simulated function CalcAmbientRelevancyScale()
{
    // Make the zed only relevant by their ambient sound out to a range of 30 meters
    CustomAmbientRelevancyScale = 1500 / (100 * SoundRadius);
}
simulated function PostNetReceive()
{
    if (bCharging)
       MovementAnims[0]='ChargeF';
    else if( !(bCrispified && bBurnified) )
       MovementAnims[0]=default.MovementAnims[0];
}
// Deprecated
function bool FlipOverWithIntsigator(Pawn InstigatedBy){
    local bool bFlippedOver;
    bFlippedOver = super.FlipOverWithIntsigator(InstigatedBy);
    if(bFlippedOver){
       // do not rotate while stunned
       Controller.Focus = none; 
       Controller.FocalPoint = Location + 512*vector(Rotation);
    }
    return bFlippedOver;
}
function bool CanGetOutOfWay()
{
    return false;
}
function float GetIceCrustScale(){
    //return 25000 / (default.health * default.health);
    return 0.01;
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
           if( !IsInState('RunningToMarker') )
           {
               GotoState('RunningToMarker');
           }
           else
           {
               NumZCDHits = 1;
               if( IsInState('RunningToMarker') )
               {
                   GotoState('');
               }
           }
       }
       else
       {
           if( IsInState('RunningToMarker') )
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
    if( bCharging && NumZCDHits > 1  )
    {
       GotoState('RunningToMarker');
    }
    else
    {
       GotoState('');
    }
}
simulated function SpawnExhaustEmitter()
{
    if ( Level.NetMode != NM_DedicatedServer )
    {
       if ( ExhaustEffectClass != none )
       {
           ExhaustEffect = Spawn(ExhaustEffectClass, self);

           if ( ExhaustEffect != none )
           {
               AttachToBone(ExhaustEffect, 'Chainsaw_lod1');
               ExhaustEffect.SetRelativeLocation(vect(0, -20, 0));
           }
       }
    }
}
simulated function UpdateExhaustEmitter()
{
    local byte Throttle;
    if ( Level.NetMode != NM_DedicatedServer )
    {
       if ( ExhaustEffect != none )
       {
           if ( bShotAnim )
           {
               Throttle = 3;
           }
           else
           {
               Throttle = 0;
           }
       }
       else
       {
           if ( !bNoExhaustRespawn )
           {
               SpawnExhaustEmitter();
           }
       }
    }
}
simulated function Tick(float DeltaTime)
{
    super.Tick(DeltaTime);
    UpdateExhaustEmitter();
}
function RangedAttack(Actor A)
{
    if ( bShotAnim || Physics == PHYS_Swimming)
       return;
    else if ( CanAttack(A) )
    {
       bShotAnim = true;
       SetAnimAction(MeleeAnims[Rand(2)]);
       //PlaySound(sound'Claw2s', SLOT_none); KFTODO: Replace this
       if(NiceMonster(A) == none)
           GoToState('SawingLoop');
    }
    if( !bShotAnim && !bDecapitated )
    {
       if(bConfusedState)
           return;
       if ( float(Health)/HealthMax < 0.75)
           GoToState('RunningState');
    }
}
state RunningState
{
    // Set the zed to the zapped behavior
    simulated function SetZappedBehavior()
    {
       Global.SetZappedBehavior();
       GoToState('');
    }
    // Don't override speed in this state
    function bool CanSpeedAdjust()
    {
       return false;
    }
    simulated function float GetOriginalGroundSpeed() {
       return 3.5 * OriginalGroundSpeed;
    }
    function BeginState(){
       local NiceHumanPawn rageTarget, rageCause;

       if(Health <= 0)
           return;

       if(bWasCalm){
           bWasCalm = false;
           rageTarget = NiceHumanPawn(Controller.focus);
           rageCause = NiceHumanPawn(LastDamagedBy);
           if( rageTarget != none && KFGameType(Level.Game) != none
               && class'NiceVeterancyTypes'.static.HasSkill(NicePlayerController(rageTarget.Controller),
                   class'NiceSkillCommandoPerfectExecution') ){
               KFGameType(Level.Game).DramaticEvent(1.0);
           }
           else if( rageCause != none && KFGameType(Level.Game) != none
               && class'NiceVeterancyTypes'.static.HasSkill(NicePlayerController(rageCause.Controller),
                   class'NiceSkillCommandoPerfectExecution') ){
               KFGameType(Level.Game).DramaticEvent(1.0);
           }
       }
       if(bZapped)
           GoToState('');
       else{
           SetGroundSpeed(OriginalGroundSpeed * 3.5);
           bCharging = true;
           if( Level.NetMode!=NM_DedicatedServer )
               PostNetReceive();

           NetUpdateTime = Level.TimeSeconds - 1;
       }
    }
    function EndState()
    {
       if( !bZapped )
       {
           SetGroundSpeed(GetOriginalGroundSpeed());
       }
       bCharging = False;
       if( Level.NetMode!=NM_DedicatedServer )
           PostNetReceive();
    }
    function RemoveHead()
    {
       GoToState('');
       Global.RemoveHead();
    }
    function RangedAttack(Actor A)
    {
       if ( bShotAnim || Physics == PHYS_Swimming)
           return;
       else if ( CanAttack(A) )
       {
           bShotAnim = true;
           SetAnimAction(MeleeAnims[Rand(2)]);
           if(NiceMonster(A) == none)
               GoToState('SawingLoop');
       }
    }
}
// State where the zed is charging to a marked location.
// Not sure if we need this since its just like RageCharging,
// but keeping it here for now in case we need to implement some
// custom behavior for this state
state RunningToMarker extends RunningState
{
}

State SawingLoop
{
    // Don't override speed in this state
    function bool CanSpeedAdjust()
    {
       return false;
    }
    simulated function float GetOriginalGroundSpeed() {
       return OriginalGroundSpeed * AttackChargeRate;
    }
    function bool CanGetOutOfWay()
    {
       return false;
    }
    function BeginState()
    {
       bConfusedState = false;

       // Randomly have the scrake charge during an attack so it will be less predictable
       if(Health/HealthMax < 0.5 || FRand() <= 0.95)
       {
           SetGroundSpeed(OriginalGroundSpeed * AttackChargeRate);
           bCharging = true;
           if( Level.NetMode!=NM_DedicatedServer )
               PostNetReceive();

           NetUpdateTime = Level.TimeSeconds - 1;
       }
    }
    function RangedAttack(Actor A)
    {
       if ( bShotAnim )
           return;
       else if ( CanAttack(A) )
       {
           Acceleration = vect(0,0,0);
           bShotAnim = true;
           MeleeDamage = default.MeleeDamage*0.6;
           SetAnimAction('SawImpaleLoop');
           if( AmbientSound != SawAttackLoopSound )
           {
               AmbientSound=SawAttackLoopSound;
           }
       }
       else GoToState('');
    }
    function AnimEnd( int Channel )
    {
       Super.AnimEnd(Channel);
       if( Controller!=none && Controller.Enemy!=none )
           RangedAttack(Controller.Enemy); // Keep on attacking if possible.
    }
    function Tick( float Delta )
    {
       // Keep the scrake moving toward its target when attacking
       if( Role == ROLE_Authority && bShotAnim && !bWaitForAnim )
       {
           if( LookTarget!=none )
           {
               Acceleration = AccelRate * Normal(LookTarget.Location - Location);
           }
       }

       global.Tick(Delta);
    }
    function EndState()
    {
       AmbientSound=default.AmbientSound;
       MeleeDamage = Max( DifficultyDamageModifer() * default.MeleeDamage, 1 );

       SetGroundSpeed(GetOriginalGroundSpeed());
       bCharging = False;
       if(Level.NetMode != NM_DedicatedServer)
           PostNetReceive();
    }
}
function ModDamage(out int Damage, Pawn instigatedBy, Vector hitLocation, Vector momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, KFPlayerReplicationInfo KFPRI, optional float lockonTime){
    super.ModDamage(Damage, instigatedBy, hitLocation, momentum, damageType, headshotLevel, KFPRI);
    if(damageType == class'ScrnZedPack.DamTypeEMP')
       Damage *= 0.01;
}
function TakeDamageClient(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, float lockonTime){
    local bool bCanGetConfused;
    local int OldHealth;
    local PlayerController PC;
    local KFSteamStatsAndAchievements Stats;
    OldHealth = Health;
    bCanGetConfused = false;
    if(StunsRemaining != 0 && float(Health)/HealthMax >= 0.75)
       bCanGetConfused = true;
    super.takeDamageClient(Damage, instigatedBy, hitLocation, momentum, damageType, headshotLevel, lockonTime);
    if (
       bCanGetConfused &&
       !IsInState('SawingLoop') &&
       (OldHealth - Health) <= (float(default.Health)/1.5) && float(Health)/HealthMax < 0.75 &&
       (LastDamageAmount >= (0.5 * default.Health) ||
           (VSize(LastDamagedBy.Location - Location) <= (MeleeRange * 2) && ClassIsChildOf(LastDamagedbyType,class 'DamTypeMelee') &&
           KFPawn(LastDamagedBy) != none && LastDamageAmount > (0.10 * default.Health)))
       )
       bConfusedState = true;
    if(bConfusedState && Health > 0 && (headshotLevel <= 0.0) && damageType != none){
       bConfusedState = false;
       GoToState('RunningState');
    }
    if(!bConfusedState && !IsInState('SawingLoop') && !IsInState('RunningState') && float(Health) / HealthMax < 0.75)
       RangedAttack(InstigatedBy);
    if(damageType == class'DamTypeDBShotgun'){
       PC = PlayerController( InstigatedBy.Controller );
       if(PC != none){
           Stats = KFSteamStatsAndAchievements( PC.SteamStatsAndAchievements );
           if( Stats != none )
               Stats.CheckAndSetAchievementComplete( Stats.KFACHIEVEMENT_PushScrakeSPJ );
       }
    }
}
function TakeFireDamage(int Damage, Pawn Instigator)
{
    Super.TakeFireDamage(Damage, Instigator);
    if(bConfusedState && Health > 0 && Damage > 150){
       bConfusedState = false;
       GoToState('RunningState');
    }
}
function bool CheckMiniFlinch(int flinchScore, Pawn instigatedBy, Vector hitLocation, Vector momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, KFPlayerReplicationInfo KFPRI){
    // Scrakes are better at enduring pain, so we need a bit more to flinch them
    if(StunsRemaining == 0 || flinchScore < 150)
       return false;
    return super.CheckMiniFlinch(flinchScore, instigatedBy, hitLocation, momentum, damageType, headshotLevel, KFPRI);
}
function DoStun(optional Pawn instigatedBy, optional Vector hitLocation, optional Vector momentum, optional class<NiceWeaponDamageType> damageType, optional float headshotLevel, optional KFPlayerReplicationInfo KFPRI){
    super.DoStun(instigatedBy, hitLocation, momentum, damageType, headshotLevel, KFPRI);
    StunsRemaining = 0;
}
simulated function int DoAnimAction( name AnimName )
{
    if( AnimName=='SawZombieAttack1' || AnimName=='SawZombieAttack2' )
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
    if(NewAction == 'Claw')
    {
       meleeAnimIndex = Rand(3);
       NewAction = meleeAnims[meleeAnimIndex];
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
    if( TestAnim == 'SawImpaleLoop' || TestAnim == 'DoorBash' || TestAnim == 'KnockDown' )
    {
       return true;
    }
    return false;
}
function PlayDyingSound()
{
    if( Level.NetMode!=NM_Client )
    {
       if ( bGibbed )
       {
           // Do nothing for now
           PlaySound(GibGroupClass.static.GibSound(), SLOT_Pain,2.0,true,525);
           return;
       }

       if( bDecapitated )
       {

           PlaySound(HeadlessDeathSound, SLOT_Pain,1.30,true,525);
       }
       else
       {
           PlaySound(DeathSound[0], SLOT_Pain,1.30,true,525);
       }

       PlaySound(ChainSawOffSound, SLOT_Misc, 2.0,,525.0);
    }
}
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    AmbientSound = none;
    if ( ExhaustEffect != none )
    {
       ExhaustEffect.Destroy();
       ExhaustEffect = none;
       bNoExhaustRespawn = true;
    }
    super.Died( Killer, damageType, HitLocation );
}
simulated function ProcessHitFX()
{
    local Coords boneCoords;
    local class<xEmitter> HitEffects[4];
    local int i,j;
    local float GibPerterbation;
    if( (Level.NetMode == NM_DedicatedServer) || bSkeletized || (Mesh == SkeletonMesh))
    {
       SimHitFxTicker = HitFxTicker;
       return;
    }
    for ( SimHitFxTicker = SimHitFxTicker; SimHitFxTicker != HitFxTicker; SimHitFxTicker = (SimHitFxTicker + 1) % ArrayCount(HitFX) )
    {
       j++;
       if ( j > 30 )
       {
           SimHitFxTicker = HitFxTicker;
           return;
       }

       if( (HitFX[SimHitFxTicker].damtype == none) || (Level.bDropDetail && (Level.TimeSeconds - LastRenderTime > 3) && !IsHumanControlled()) )
           continue;

       //log("Processing effects for damtype "$HitFX[SimHitFxTicker].damtype);

       if( HitFX[SimHitFxTicker].bone == 'obliterate' && !class'GameInfo'.static.UseLowGore())
       {
           SpawnGibs( HitFX[SimHitFxTicker].rotDir, 1);
           bGibbed = true;
           // Wait a tick on a listen server so the obliteration can replicate before the pawn is destroyed
           if( Level.NetMode == NM_ListenServer )
           {
               bDestroyNextTick = true;
               TimeSetDestroyNextTickTime = Level.TimeSeconds;
           }
           else
           {
               Destroy();
           }
           return;
       }

       boneCoords = GetBoneCoords( HitFX[SimHitFxTicker].bone );

       if ( !Level.bDropDetail && !class'GameInfo'.static.NoBlood() && !bSkeletized && !class'GameInfo'.static.UseLowGore() )
       {
           //AttachEmitterEffect( BleedingEmitterClass, HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );

           HitFX[SimHitFxTicker].damtype.static.GetHitEffects( HitEffects, Health );

           if( !PhysicsVolume.bWaterVolume ) // don't attach effects under water
           {
               for( i = 0; i < ArrayCount(HitEffects); i++ )
               {
                   if( HitEffects[i] == none )
                       continue;

                     AttachEffect( HitEffects[i], HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );
               }
           }
       }
       if ( class'GameInfo'.static.UseLowGore() )
           HitFX[SimHitFxTicker].bSever = false;

       if( HitFX[SimHitFxTicker].bSever )
       {
           GibPerterbation = HitFX[SimHitFxTicker].damtype.default.GibPerterbation;

           switch( HitFX[SimHitFxTicker].bone )
           {
               case 'obliterate':
                   break;

               case LeftThighBone:
                   if( !bLeftLegGibbed )
                   {
                       SpawnSeveredGiblet( DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
                       KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                       KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                       KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                       bLeftLegGibbed=true;
                   }
                   break;

               case RightThighBone:
                   if( !bRightLegGibbed )
                   {
                       SpawnSeveredGiblet( DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
                       KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                       KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                       KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                       bRightLegGibbed=true;
                   }
                   break;

               case LeftFArmBone:
                   if( !bLeftArmGibbed )
                   {
                       SpawnSeveredGiblet( DetachedArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
                       KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                       KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;;
                       bLeftArmGibbed=true;
                   }
                   break;

               case RightFArmBone:
                   if( !bRightArmGibbed )
                   {
                       SpawnSeveredGiblet( DetachedSpecialArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
                       KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                       KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                       bRightArmGibbed=true;
                   }
                   break;

               case 'head':
                   if( !bHeadGibbed )
                   {
                       if ( HitFX[SimHitFxTicker].damtype == class'DamTypeDecapitation' )
                       {
                           DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, false);
                       }
                       else if( HitFX[SimHitFxTicker].damtype == class'DamTypeProjectileDecap' )
                       {
                           DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, false, true);
                       }
                       else if( HitFX[SimHitFxTicker].damtype == class'DamTypeMeleeDecapitation' )
                       {
                           DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, true);
                       }

                         bHeadGibbed=true;
                     }
                   break;
           }

           if( HitFX[SimHitFXTicker].bone != 'Spine' && HitFX[SimHitFXTicker].bone != FireRootBone &&
               HitFX[SimHitFXTicker].bone != 'head' && Health <=0 )
               HideBone(HitFX[SimHitFxTicker].bone);
       }
    }
}
// Maybe spawn some chunks when the player gets obliterated
simulated function SpawnGibs(Rotator HitRotation, float ChunkPerterbation)
{
    if ( ExhaustEffect != none )
    {
       ExhaustEffect.Destroy();
       ExhaustEffect = none;
       bNoExhaustRespawn = true;
    }
    super.SpawnGibs(HitRotation,ChunkPerterbation);
}
static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.scrake_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.scrake_diff');
    myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.scrake_spec');
    myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.scrake_saw_panner');
    myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.scrake_FB');
    myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.Chainsaw_blade_diff');
}
defaultproperties
{
    SawAttackLoopSound=Sound'KF_BaseScrake.Chainsaw.Scrake_Chainsaw_Impale'
    ChainSawOffSound=SoundGroup'KF_ChainsawSnd.Chainsaw_Deselect'
    remainingStuns=1
    stunLoopStart=0.240000
    stunLoopEnd=0.820000
    idleInsertFrame=0.900000
    EventClasses(0)="NicePack.NiceZombieScrake"
    MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Talk'
    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Chainsaw_HitPlayer'
    JumpSound=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Jump'
    DetachedArmClass=Class'KFChar.SeveredArmScrake'
    DetachedLegClass=Class'KFChar.SeveredLegScrake'
    DetachedHeadClass=Class'KFChar.SeveredHeadScrake'
    DetachedSpecialArmClass=Class'KFChar.SeveredArmScrakeSaw'
    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Pain'
    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Death'
    ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
    ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
    ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
    ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
    ControllerClass=Class'NicePack.NiceZombieScrakeController'
    AmbientSound=Sound'KF_BaseScrake.Chainsaw.Scrake_Chainsaw_Idle'
    Mesh=SkeletalMesh'KF_Freaks_Trip.Scrake_Freak'
    Skins(0)=Shader'KF_Specimens_Trip_T.scrake_FB'
    Skins(1)=TexPanner'KF_Specimens_Trip_T.scrake_saw_panner'
}
