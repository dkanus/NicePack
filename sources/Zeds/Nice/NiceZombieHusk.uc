//=============================================================================
// ZombieHusk
//=============================================================================
// Husk burned up fire projectile launching zed pawn class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class NiceZombieHusk extends NiceZombieHuskBase;
//----------------------------------------------------------------------------
// NOTE: All Variables are declared in the base class to eliminate hitching
//----------------------------------------------------------------------------
var class<Projectile> HuskFireProjClass;
simulated function HeatTick(){
    if(heat < 50){
       if(heat > 40)
           heat = 50;
       else
           heat = 50 - 0.8 * (50 - heat);
    }
    super.HeatTick();
}
simulated function PostBeginPlay()
{
    // Difficulty Scaling
    if (Level.Game != none && !bDiffAdjusted){
       ProjectileFireInterval = default.ProjectileFireInterval * 0.6;
    }
    super.PostBeginPlay();
}
// don't interrupt the bloat while he is puking
simulated function bool HitCanInterruptAction()
{
    if( bShotAnim )
    {
       return false;
    }
    return true;
}
function DoorAttack(Actor A)
{
    if ( bShotAnim || Physics == PHYS_Swimming)
       return;
    else if ( A!=none )
    {
       bShotAnim = true;
       if( !bDecapitated && bDistanceAttackingDoor )
       {
           SetAnimAction('ShootBurns');
       }
       else
       {
           SetAnimAction('DoorBash');
           GotoState('DoorBashing');
       }
    }
}
function RangedAttack(Actor A)
{
    local int LastFireTime;
    if ( bShotAnim )
       return;
    if ( Physics == PHYS_Swimming )
    {
       SetAnimAction('Claw');
       bShotAnim = true;
       LastFireTime = Level.TimeSeconds;
    }
    else if ( VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
    {
       bShotAnim = true;
       LastFireTime = Level.TimeSeconds;
       SetAnimAction('Claw');
       //PlaySound(sound'Claw2s', SLOT_Interact); KFTODO: Replace this
       Controller.bPreparingMove = true;
       Acceleration = vect(0,0,0);
    }
    else if ( (KFDoorMover(A) != none ||
       (!Region.Zone.bDistanceFog && VSize(A.Location-Location) <= 65535) ||
       (Region.Zone.bDistanceFog && VSizeSquared(A.Location-Location) < (Square(Region.Zone.DistanceFogEnd) * 0.8)))  // Make him come out of the fog a bit
       && !bDecapitated )
    {
       bShotAnim = true;

       SetAnimAction('ShootBurns');
       Controller.bPreparingMove = true;
       Acceleration = vect(0,0,0);

       NextFireProjectileTime = Level.TimeSeconds + ProjectileFireInterval + (FRand() * 2.0);
    }
}
// Overridden to handle playing upper body only attacks when moving
simulated event SetAnimAction(name NewAction)
{
    local int meleeAnimIndex;
    local bool bWantsToAttackAndMove;
    if( NewAction=='' )
       Return;
    if( NewAction == 'Claw' )
    {
       meleeAnimIndex = Rand(3);
       NewAction = meleeAnims[meleeAnimIndex];
    }
    ExpectingChannel = DoAnimAction(NewAction);
    if( !bWantsToAttackAndMove && AnimNeedsWait(NewAction) )
    {
       bWaitForAnim = true;
    }
    else
    {
       bWaitForAnim = false;
    }
    if( Level.NetMode!=NM_Client )
    {
       AnimAction = NewAction;
       bResetAnimAct = True;
       ResetAnimActTime = Level.TimeSeconds+0.3;
    }
}
function float GetStunDurationMult(Pawn instigatedBy, Vector hitLocation, Vector momentum, class<NiceWeaponDamageType> damageType,
    float headshotLevel, KFPlayerReplicationInfo KFPRI){
    if(headshotLevel > 0)
       return 1.0;
    return 0.5;
}

function SpawnTwoShots(){
    local vector X,Y,Z, FireStart;
    local rotator FireRotation;
    local KFMonsterController KFMonstControl;
    if(controller != none && KFDoorMover(controller.Target) != none){
       controller.Target.TakeDamage(22,Self,Location,vect(0,0,0),Class'DamTypeVomit');
       return;
    }
    GetAxes(Rotation,X,Y,Z);
    FireStart = GetBoneCoords('Barrel').Origin;
    if(!SavedFireProperties.bInitialized){
       SavedFireProperties.AmmoClass = Class'SkaarjAmmo';
       SavedFireProperties.ProjectileClass = HuskFireProjClass;
       SavedFireProperties.WarnTargetPct = 1;
       SavedFireProperties.MaxRange = 65535;
       SavedFireProperties.bTossed = false;
       SavedFireProperties.bTrySplash = true;
       SavedFireProperties.bLeadTarget = true;
       SavedFireProperties.bInstantHit = false;
       SavedFireProperties.bInitialized = true;
    }
    // Turn off extra collision before spawning vomit, otherwise spawn fails
    ToggleAuxCollision(false);
    if(controller != none)
       FireRotation = controller.AdjustAim(SavedFireProperties,FireStart,600);
    foreach DynamicActors(class'KFMonsterController', KFMonstControl)
       if(KFMonstControl != controller && PointDistToLine(KFMonstControl.Pawn.Location, vector(FireRotation), FireStart) < 75)
           KFMonstControl.GetOutOfTheWayOfShot(vector(FireRotation),FireStart);
    Spawn(HuskFireProjClass,,, FireStart, FireRotation);
    // Turn extra collision back on
    ToggleAuxCollision(true);
}
// Get the closest point along a line to another point
simulated function float PointDistToLine(vector Point, vector Line, vector Origin, optional out vector OutClosestPoint)
{
    local vector SafeDir;
    SafeDir = Normal(Line);
    OutClosestPoint = Origin + (SafeDir * ((Point-Origin) dot SafeDir));
    return VSize(OutClosestPoint-Point);
}
simulated function Tick(float deltatime)
{
    Super.tick(deltatime);
    // Hack to force animation updates on the server for the bloat if he is relevant to someone
    // He has glitches when some of his animations don't play on the server. If we
    // find some other fix for the glitches take this out - Ramm
    if( Level.NetMode != NM_Client && Level.NetMode != NM_Standalone )
    {
       if( (Level.TimeSeconds-LastSeenOrRelevantTime) < 1.0  )
       {
           bForceSkelUpdate=true;
       }
       else
       {
           bForceSkelUpdate=false;
       }
    }
}
function RemoveHead()
{
    bCanDistanceAttackDoors = False;
    Super.RemoveHead();
}
function ModDamage(out int damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, KFPlayerReplicationInfo KFPRI, optional float lockonTime){
    local float damageMod;
    if(damageType != none){
       damageMod = 0.2 * damageType.default.freezePower;
       damageMod = FMax(damageMod, 1.0);
    }
    damage *= damageMod;
    Super.ModDamage(damage, instigatedBy, hitlocation, momentum, damageType, headshotLevel, KFPRI);
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
function bool CheckStun(int stunScore, Pawn instigatedBy, Vector hitLocation, Vector momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, KFPlayerReplicationInfo KFPRI){
    if(Health > 0 && damageType != none && damageType.default.HeadShotDamageMult >= 1.2
       && stunScore >= 250 && ( /*(DamageType != class'NiceDamTypeMagnumPistol') ||*/ headshotLevel > 0.0) )//MEANTODO
       return true;
    return super.CheckStun(stunScore, instigatedBy, hitLocation, momentum, damageType, headshotLevel, KFPRI);
}
static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
    myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T_Two.burns_diff');
    myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T_Two.burns_emissive_mask');
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T_Two.burns_energy_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T_Two.burns_env_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T_Two.burns_fire_cmb');
    myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T_Two.burns_shdr');
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T_Two.burns_cmb');
}
defaultproperties
{
    HuskFireProjClass=Class'NicePack.NiceHuskFireProjectile'
    stunLoopStart=0.080000
    stunLoopEnd=0.900000
    idleInsertFrame=0.930000
    Heat=50.000000
    EventClasses(0)="NicePack.NiceZombieHusk"
    MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Talk'
    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_HitPlayer'
    JumpSound=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Jump'
    DetachedArmClass=Class'KFChar.SeveredArmHusk'
    DetachedLegClass=Class'KFChar.SeveredLegHusk'
    DetachedHeadClass=Class'KFChar.SeveredHeadHusk'
    DetachedSpecialArmClass=Class'KFChar.SeveredArmHuskGun'
    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Pain'
    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Death'
    ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Challenge'
    ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Challenge'
    ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Challenge'
    ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Challenge'
    ControllerClass=Class'NicePack.NiceZombieHuskController'
    AmbientSound=Sound'KF_BaseHusk.Husk_IdleLoop'
    Mesh=SkeletalMesh'KF_Freaks2_Trip.Burns_Freak'
    Skins(0)=Texture'KF_Specimens_Trip_T_Two.burns.burns_tatters'
}
