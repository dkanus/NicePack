// Zombie Monster for KF Invasion gametype
class NiceZombieBloat extends NiceZombieBloatBase;
#exec OBJ LOAD FILE=KF_EnemiesFinalSnd.uax
//----------------------------------------------------------------------------
// NOTE: All Variables are declared in the base class to eliminate hitching
//----------------------------------------------------------------------------
var class<FleshHitEmitter> BileExplosion;
var class<FleshHitEmitter> BileExplosionHeadless;
function bool FlipOver()
{
    return true;
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
           SetAnimAction('ZombieBarf');
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
    else if ( (KFDoorMover(A) != none || VSize(A.Location-Location) <= 250) && !bDecapitated )
    {
       bShotAnim = true;

       // Randomly do a moving attack so the player can't kite the zed
       if( FRand() < 0.8 )
       {
           SetAnimAction('ZombieBarfMoving');
           RunAttackTimeout = GetAnimDuration('ZombieBarf', 1.0);
           bMovingPukeAttack=true;
       }
       else
       {
           SetAnimAction('ZombieBarf');
           Controller.bPreparingMove = true;
           Acceleration = vect(0,0,0);
       }

       // Randomly send out a message about Bloat Vomit burning(3% chance)
       if ( FRand() < 0.03 && KFHumanPawn(A) != none && PlayerController(KFHumanPawn(A).Controller) != none )
       {
           PlayerController(KFHumanPawn(A).Controller).Speech('AUTO', 7, "");
       }
    }
}
// Overridden to handle playing upper body only attacks when moving
simulated event SetAnimAction(name NewAction)
{
    local int meleeAnimIndex;
    local bool bWantsToAttackAndMove;
    if( NewAction=='' )
       Return;
    bWantsToAttackAndMove = NewAction == 'ZombieBarfMoving';
    if( NewAction == 'Claw' )
    {
       meleeAnimIndex = Rand(3);
       NewAction = meleeAnims[meleeAnimIndex];
    }
    if( bWantsToAttackAndMove )
    {
      ExpectingChannel = AttackAndMoveDoAnimAction(NewAction);
    }
    else
    {
      ExpectingChannel = DoAnimAction(NewAction);
    }
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
// Handle playing the anim action on the upper body only if we're attacking and moving
simulated function int AttackAndMoveDoAnimAction( name AnimName )
{
    if( AnimName=='ZombieBarfMoving' )
    {
       AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
       PlayAnim('ZombieBarf',, 0.1, 1);

       return 1;
    }
    return super.DoAnimAction( AnimName );
}

function PlayDyingSound()
{
    if( Level.NetMode!=NM_Client )
    {
       if ( bGibbed )
       {
           PlaySound(sound'KF_EnemiesFinalSnd.Bloat_DeathPop', SLOT_Pain,2.0,true,525);
           return;
       }

       if( bDecapitated )
       {
           PlaySound(HeadlessDeathSound, SLOT_Pain,1.30,true,525);
       }
       else
       {
           PlaySound(sound'KF_EnemiesFinalSnd.Bloat_DeathPop', SLOT_Pain,2.0,true,525);
       }
    }
}

// Barf Time.
function SpawnTwoShots()
{
    local vector X,Y,Z, FireStart;
    local rotator FireRotation;
    if( Controller!=none && KFDoorMover(Controller.Target)!=none )
    {
       Controller.Target.TakeDamage(22,Self,Location,vect(0,0,0),Class'DamTypeVomit');
       return;
    }
    GetAxes(Rotation,X,Y,Z);
    FireStart = Location+(vect(30,0,64) >> Rotation)*DrawScale;
    if ( !SavedFireProperties.bInitialized )
    {
       SavedFireProperties.AmmoClass = Class'SkaarjAmmo';
       SavedFireProperties.ProjectileClass = Class'KFBloatVomit';
       SavedFireProperties.WarnTargetPct = 1;
       SavedFireProperties.MaxRange = 500;
       SavedFireProperties.bTossed = False;
       SavedFireProperties.bTrySplash = False;
       SavedFireProperties.bLeadTarget = True;
       SavedFireProperties.bInstantHit = True;
       SavedFireProperties.bInitialized = True;
    }
    // Turn off extra collision before spawning vomit, otherwise spawn fails
    ToggleAuxCollision(false);
    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
    Spawn(Class'KFBloatVomit',,,FireStart,FireRotation);
    FireStart-=(0.5*CollisionRadius*Y);
    FireRotation.Yaw -= 1200;
    spawn(Class'KFBloatVomit',,,FireStart, FireRotation);
    FireStart+=(CollisionRadius*Y);
    FireRotation.Yaw += 2400;
    spawn(Class'KFBloatVomit',,,FireStart, FireRotation);
    // Turn extra collision back on
    ToggleAuxCollision(true);
}

simulated function Tick(float deltatime)
{
    local vector BileExplosionLoc;
    local FleshHitEmitter GibBileExplosion;
    Super.tick(deltatime);
    if( Role == ROLE_Authority && bMovingPukeAttack )
    {
       // Keep moving toward the target until the timer runs out (anim finishes)
       if( RunAttackTimeout > 0 )
       {
           RunAttackTimeout -= DeltaTime;

           if( RunAttackTimeout <= 0 )
           {
               RunAttackTimeout = 0;
               bMovingPukeAttack=false;
           }
       }

       // Keep the gorefast moving toward its target when attacking
       if( bShotAnim && !bWaitForAnim )
       {
           if( LookTarget!=none )
           {
               Acceleration = AccelRate * Normal(LookTarget.Location - Location);
           }
       }
    }
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
    if ( Level.NetMode!=NM_DedicatedServer && /*Gored>0*/Health <= 0 && !bPlayBileSplash &&
       HitDamageType != class'DamTypeBleedOut' )
    {
       if ( !class'GameInfo'.static.UseLowGore() )
       {
           BileExplosionLoc = self.Location;
           BileExplosionLoc.z += (CollisionHeight - (CollisionHeight * 0.5));

           if (bDecapitated)
           {
               GibBileExplosion = Spawn(BileExplosionHeadless,self,, BileExplosionLoc );
           }
           else
           {
               GibBileExplosion = Spawn(BileExplosion,self,, BileExplosionLoc );
           }
           bPlayBileSplash = true;
       }
       else
       {
           BileExplosionLoc = self.Location;
           BileExplosionLoc.z += (CollisionHeight - (CollisionHeight * 0.5));

           GibBileExplosion = Spawn(class 'LowGoreBileExplosion',self,, BileExplosionLoc );
           bPlayBileSplash = true;
       }
    }
}
function BileBomb()
{
    BloatJet = spawn(class'BileJet', self,,Location,Rotator(-PhysicsVolume.Gravity));
}
function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
//    local bool AttachSucess;
    super.PlayDyingAnimation(DamageType, HitLoc);
    // Don't blow up with bleed out
    if( bDecapitated && DamageType == class'DamTypeBleedOut' )
    {
       return;
    }
    if ( !class'GameInfo'.static.UseLowGore() )
    {
       HideBone(SpineBone2);
    }
    if(Role == ROLE_Authority)
    {
       BileBomb();
//    if(BloatJet!=none)
//    {
//    if(Gored < 5)
//    AttachSucess=AttachToBone(BloatJet,FireRootBone);
//    // else
//    // AttachSucess=AttachToBone(BloatJet,SpineBone1);
//
//    if(!AttachSucess)
//    {
//    log("DEAD Bloaty Bile didn't like the Boning :o");
//    BloatJet.SetBase(self);
//    }
//    BloatJet.SetRelativeRotation(rot(0,-4096,0));
//    }
    }
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
       {
           HitFX[SimHitFxTicker].bSever = false;

           switch( HitFX[SimHitFxTicker].bone )
           {
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

           return;
       }

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
                       SpawnSeveredGiblet( DetachedArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
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

           // Don't do this right now until we get the effects sorted - Ramm
           if( HitFX[SimHitFXTicker].bone != 'Spine' && HitFX[SimHitFXTicker].bone != FireRootBone &&
               HitFX[SimHitFXTicker].bone != LeftFArmBone && HitFX[SimHitFXTicker].bone != RightFArmBone &&
               HitFX[SimHitFXTicker].bone != 'head' && Health <=0 )
               HideBone(HitFX[SimHitFxTicker].bone);
       }
    }
}
simulated function HideBone(name boneName)
{
    local int BoneScaleSlot;
    local coords boneCoords;
    local bool bValidBoneToHide;

      if( boneName == LeftThighBone )
    {
       boneScaleSlot = 0;
       bValidBoneToHide = true;
       if( SeveredLeftLeg == none )
       {
           SeveredLeftLeg = Spawn(SeveredLegAttachClass,self);
           SeveredLeftLeg.SetDrawScale(SeveredLegAttachScale);
           boneCoords = GetBoneCoords( 'lleg' );
           AttachEmitterEffect( LimbSpurtEmitterClass, 'lleg', boneCoords.Origin, rot(0,0,0) );
           AttachToBone(SeveredLeftLeg, 'lleg');
       }
    }
    else if ( boneName == RightThighBone )
    {
       boneScaleSlot = 1;
       bValidBoneToHide = true;
       if( SeveredRightLeg == none )
       {
           SeveredRightLeg = Spawn(SeveredLegAttachClass,self);
           SeveredRightLeg.SetDrawScale(SeveredLegAttachScale);
           boneCoords = GetBoneCoords( 'rleg' );
           AttachEmitterEffect( LimbSpurtEmitterClass, 'rleg', boneCoords.Origin, rot(0,0,0) );
           AttachToBone(SeveredRightLeg, 'rleg');
       }
    }
    else if( boneName == RightFArmBone )
    {
       boneScaleSlot = 2;
       bValidBoneToHide = true;
       if( SeveredRightArm == none )
       {
           SeveredRightArm = Spawn(SeveredArmAttachClass,self);
           SeveredRightArm.SetDrawScale(SeveredArmAttachScale);
           boneCoords = GetBoneCoords( 'rarm' );
           AttachEmitterEffect( LimbSpurtEmitterClass, 'rarm', boneCoords.Origin, rot(0,0,0) );
           AttachToBone(SeveredRightArm, 'rarm');
       }
    }
    else if ( boneName == LeftFArmBone )
    {
       boneScaleSlot = 3;
       bValidBoneToHide = true;
       if( SeveredLeftArm == none )
       {
           SeveredLeftArm = Spawn(SeveredArmAttachClass,self);
           SeveredLeftArm.SetDrawScale(SeveredArmAttachScale);
           boneCoords = GetBoneCoords( 'larm' );
           AttachEmitterEffect( LimbSpurtEmitterClass, 'larm', boneCoords.Origin, rot(0,0,0) );
           AttachToBone(SeveredLeftArm, 'larm');
       }
    }
    else if ( boneName == HeadBone )
    {
       // Only scale the bone down once
       if( SeveredHead == none )
       {
           bValidBoneToHide = true;
           boneScaleSlot = 4;
           SeveredHead = Spawn(SeveredHeadAttachClass,self);
           SeveredHead.SetDrawScale(SeveredHeadAttachScale);
           boneCoords = GetBoneCoords( 'neck' );
           AttachEmitterEffect( NeckSpurtEmitterClass, 'neck', boneCoords.Origin, rot(0,0,0) );
           AttachToBone(SeveredHead, 'neck');
       }
       else
       {
           return;
       }
    }
    else if ( boneName == 'spine' )
    {
       bValidBoneToHide = true;
       boneScaleSlot = 5;
    }
    else if ( boneName == SpineBone2 )
    {
       bValidBoneToHide = true;
       boneScaleSlot = 6;
    }
    // Only hide the bone if it is one of the arms, legs, or head, don't hide other misc bones
    if( bValidBoneToHide )
    {
       SetBoneScale(BoneScaleSlot, 0.0, BoneName);
    }
}

State Dying
{
  function tick(float deltaTime)
  {
   if (BloatJet != none)
   {
    BloatJet.SetLocation(location);
    BloatJet.SetRotation(GetBoneRotation(FireRootBone));
   }
    super.tick(deltaTime);
  }
}
function RemoveHead()
{
    bCanDistanceAttackDoors = False;
    Super.RemoveHead();
}
function ModDamage(out int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, KFPlayerReplicationInfo KFPRI, optional float lockonTime){
    if(damageType == class 'DamTypeVomit' || damageType == class 'DamTypeBlowerThrower')
       Damage = 0;
    else
       Super.ModDamage(Damage, instigatedBy, hitlocation, momentum, damageType, headshotLevel, KFPRI);
}
static simulated function PreCacheStaticMeshes(LevelInfo myLevel)
{//should be derived and used.
    Super.PreCacheStaticMeshes(myLevel);
    myLevel.AddPrecacheStaticMesh(StaticMesh'kf_gore_trip_sm.limbs.bloat_head');
}
static simulated function PreCacheMaterials(LevelInfo myLevel)
{
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.bloat_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.bloat_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.bloat_diffuse');
}
defaultproperties
{
    BileExplosion=Class'KFMod.BileExplosion'
    BileExplosionHeadless=Class'KFMod.BileExplosionHeadless'
    stunLoopStart=0.100000
    stunLoopEnd=0.600000
    idleInsertFrame=0.950000
    EventClasses(0)="NicePack.NiceZombieBloat"
    MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_Talk'
    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_HitPlayer'
    JumpSound=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_Jump'
    DetachedArmClass=Class'KFChar.SeveredArmBloat'
    DetachedLegClass=Class'KFChar.SeveredLegBloat'
    DetachedHeadClass=Class'KFChar.SeveredHeadBloat'
    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_Pain'
    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_Death'
    ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_Challenge'
    ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_Challenge'
    ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_Challenge'
    ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_Challenge'
    AmbientSound=Sound'KF_BaseBloat.Bloat_Idle1Loop'
    Mesh=SkeletalMesh'KF_Freaks_Trip.Bloat_Freak'
    Skins(0)=Combiner'KF_Specimens_Trip_T.bloat_cmb'
}
