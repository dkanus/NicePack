// Zombie Monster for KF Invasion gametype
class NiceZombieSiren extends NiceZombieSirenBase;
var float           screamLength;
var float           screamStartTime;
var int             currScreamTiming;
var int             currentScreamID;
var array<float>    screamTimings;
simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    screamLength = GetAnimDuration('Siren_Scream');
}
simulated event SetAnimAction(name NewAction)
{
    local int meleeAnimIndex;
    if( NewAction=='' )       Return;
    if(NewAction == 'Claw')
    {       meleeAnimIndex = Rand(3);       NewAction = meleeAnims[meleeAnimIndex];
    }
    ExpectingChannel = DoAnimAction(NewAction);
    if( AnimNeedsWait(NewAction) )
    {       bWaitForAnim = true;
    }
    else
    {       bWaitForAnim = false;
    }
    if( Level.NetMode!=NM_Client )
    {       AnimAction = NewAction;       bResetAnimAct = True;       ResetAnimActTime = Level.TimeSeconds+0.3;
    }
}
simulated function bool AnimNeedsWait(name TestAnim)
{
    return false;
}
function bool FlipOver()
{
    return true;
}
function DoorAttack(Actor A)
{
    if ( bShotAnim || Physics == PHYS_Swimming || bDecapitated || A==none )       return;
    bShotAnim = true;
    SetAnimAction('Siren_Scream');
}
function MakeNewScreamBall(){
    local int i;
    local NicePack niceMut;
    if(screamStartTime > 0){       niceMut = class'NicePack'.static.Myself(Level);       if(niceMut != none){           for(i = 0;i < niceMut.playersList.Length;i ++)               if(niceMut.playersList[i] != none && screamStartTime > 0)                   niceMut.playersList[i].SpawnSirenBall(self);       }
    }    
}
function DiscardCurrentScreamBall(){
    local int i;
    local NicePack niceMut;
    if(screamStartTime > 0){       niceMut = class'NicePack'.static.Myself(Level);       if(niceMut != none){           for(i = 0;i < niceMut.playersList.Length;i ++)               if(niceMut.playersList[i] != none)                   niceMut.playersList[i].ClientRemoveSirenBall(currentScreamID);       }       screamStartTime = -1.0;       currScreamTiming = -1;
    }    
}
function RangedAttack(Actor A)
{
    local int LastFireTime;
    local float Dist;
    if ( bShotAnim )       return;
    Dist = VSize(A.Location - Location);
    if ( Physics == PHYS_Swimming )
    {       SetAnimAction('Claw');       bShotAnim = true;       LastFireTime = Level.TimeSeconds;
    }
    else if(Dist < MeleeRange + CollisionRadius + A.CollisionRadius && A != Self)
    {       bShotAnim = true;       LastFireTime = Level.TimeSeconds;       SetAnimAction('Claw');       Controller.bPreparingMove = true;       Acceleration = vect(0,0,0);
    }
    else if( Dist <= ScreamRadius && !bDecapitated && !bZapped )
    {       bShotAnim=true;       SetAnimAction('Siren_Scream');       if(screamStartTime > 0)           DiscardCurrentScreamBall();       currScreamTiming = 0;       screamStartTime = Level.TimeSeconds;       // Only stop moving if we are close       if( Dist < ScreamRadius * 0.25 )       {           Controller.bPreparingMove = true;           Acceleration = vect(0,0,0);       }       else       {           Acceleration = AccelRate * Normal(A.Location - Location);       }
    }
}
simulated function int DoAnimAction( name AnimName )
{
    if( AnimName=='Siren_Scream' || AnimName=='Siren_Bite' || AnimName=='Siren_Bite2' )
    {       AnimBlendParams(1, 1.0, 0.0,, SpineBone1);       PlayAnim(AnimName,, 0.1, 1);       return 1;
    }
    PlayAnim(AnimName,,0.1);
    Return 0;
}
// Scream Time
simulated function SpawnTwoShots(){
    if(bZapped)       return;
    if(Health > 0 && HeadHealth > 0 && !bIsStunned)       DoShakeEffect();
    if( Level.NetMode!=NM_Client )
    {       // Deal Actual Damage.       if(controller!=none && KFDoorMover(Controller.Target) != none)           Controller.Target.TakeDamage(ScreamDamage*0.6,Self,Location,vect(0,0,0),ScreamDamageType);       else HurtRadius(ScreamDamage ,ScreamRadius, ScreamDamageType, ScreamForce, Location);       if(screamStartTime > 0)           currScreamTiming ++;       else           Log("ERROR: unexpected siren scream happend!");
    }
}
// Shake nearby players screens
simulated function DoShakeEffect()
{
    local PlayerController PC;
    local NicePlayerController nicePlayer;
    local float Dist, scale, BlurScale;
    //viewshake
    if (Level.NetMode != NM_DedicatedServer)
    {        PC = Level.GetLocalPlayerController();
        nicePlayer = NicePlayerController(PC);        if (PC != none && PC.ViewTarget != none)        {            Dist = VSize(Location - PC.ViewTarget.Location);            if (Dist < ScreamRadius )            {                scale = (ScreamRadius - Dist) / (ScreamRadius);                scale *= ShakeEffectScalar;
                if(nicePlayer != none)
                    scale *= nicePlayer.sirenScreamMod;
                        BlurScale = scale;
                // Reduce blur if there is something between us and the siren                if( !FastTrace(PC.ViewTarget.Location,Location) )                {                   scale *= 0.25;                   BlurScale = scale;                }                else                {                    if(nicePlayer != none)
                        scale = Lerp(scale, MinShakeEffectScale * nicePlayer.sirenScreamMod, 1.0);
                    else
                        scale = Lerp(scale, MinShakeEffectScale, 1.0);                }
                PC.SetAmbientShake(Level.TimeSeconds + ShakeFadeTime, ShakeTime, OffsetMag * Scale, OffsetRate, RotMag * Scale, RotRate);
                if( KFHumanPawn(PC.ViewTarget) != none )                {                   KFHumanPawn(PC.ViewTarget).AddBlur(ShakeTime, BlurScale * ScreamBlurScale);                }
                // 10% chance of player saying something about our scream                if ( Level != none && Level.Game != none && !KFGameType(Level.Game).bDidSirenScreamMessage && FRand() < 0.10 )                {                   PC.Speech('AUTO', 16, "");                   KFGameType(Level.Game).bDidSirenScreamMessage = true;                }            }        }
    }
}
simulated function HurtRadius(float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
    local actor Victims;
    local float InitMomentum;
    local float damageScale, dist;
    local vector dir;
    local float UsedDamageAmount;
    local KFHumanPawn humanPawn;
    local class<NiceVeterancyTypes> niceVet;
    if(bHurtEntry || Health <= 0 || HeadHealth <= 0 || bIsStunned)       return;
    bHurtEntry = true;
    InitMomentum = Momentum;
    if(screamStartTime > 0 && currScreamTiming == 0)       MakeNewScreamBall();
    foreach VisibleCollidingActors(class 'Actor', Victims, DamageRadius, HitLocation){       Momentum = InitMomentum;       // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag       // Or Karma actors in this case. Self inflicted Death due to flying chairs is uncool for a zombie of your stature.       if((Victims != self) && !Victims.IsA('FluidSurfaceInfo') && !Victims.IsA('KFMonster') && !Victims.IsA('ExtendedZCollision')){           dir = Victims.Location - HitLocation;           dist = FMax(1,VSize(dir));           dir = dir/dist;           damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);           humanPawn = KFHumanPawn(Victims);           if(humanPawn == none)    // If it aint human, don't pull the vortex crap on it.               Momentum = 0;           else{                               // Also don't do it if we're sharpshooter with a right skill               niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(humanPawn.PlayerReplicationInfo);               if(niceVet != none && !niceVet.static.CanBePulled(KFPlayerReplicationInfo(humanPawn.PlayerReplicationInfo)))                   Momentum = 0;           }
           if(Victims.IsA('KFGlassMover')) // Hack for shattering in interesting ways.               UsedDamageAmount = 100000;  // Siren always shatters glass           else               UsedDamageAmount = DamageAmount;
           Victims.TakeDamage(damageScale * UsedDamageAmount,Instigator, Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir, (damageScale * Momentum * dir), DamageType);
           if (Instigator != none && Vehicle(Victims) != none && Vehicle(Victims).Health > 0)               Vehicle(Victims).DriverRadiusDamage(UsedDamageAmount, DamageRadius, Instigator.Controller, DamageType, Momentum, HitLocation);       }
    }
    bHurtEntry = false;
}
// When siren loses her head she's got nothin' Kill her.
function RemoveHead(){
    Super.RemoveHead();
}
simulated function Tick( float Delta )
{
    local float currScreamTime;
    Super.Tick(Delta);
    if( bAboutToDie && Level.TimeSeconds>DeathTimer )
    {       if( Health>0 && Level.NetMode!=NM_Client )           KilledBy(LastDamagedBy);       bAboutToDie = False;
    }
    if( Role == ROLE_Authority )
    {       if( bShotAnim )       {           SetGroundSpeed(GetOriginalGroundSpeed() * 0.65);
           if( LookTarget!=none )           {               Acceleration = AccelRate * Normal(LookTarget.Location - Location);           }       }       else       {           SetGroundSpeed(GetOriginalGroundSpeed());       }
    }
    if(Role == ROLE_Authority && screamStartTime > 0){       currScreamTime = Level.TimeSeconds - screamStartTime;       if(currScreamTiming >= screamTimings.Length ||           currScreamTime - 0.1 > screamTimings[currScreamTiming] * screamLength){           DiscardCurrentScreamBall();       }
    }
    if(bOnFire && !bShotAnim)       RangedAttack(Self);
}
function PlayDyingSound()
{
    if( !bAboutToDie )       Super.PlayDyingSound();
}
simulated function ProcessHitFX()
{
    local Coords boneCoords;
    local class<xEmitter> HitEffects[4];
    local int i,j;
    local float GibPerterbation;
    if( (Level.NetMode == NM_DedicatedServer) || bSkeletized || (Mesh == SkeletonMesh))
    {       SimHitFxTicker = HitFxTicker;       return;
    }
    for ( SimHitFxTicker = SimHitFxTicker; SimHitFxTicker != HitFxTicker; SimHitFxTicker = (SimHitFxTicker + 1) % ArrayCount(HitFX) )
    {       j++;       if ( j > 30 )       {           SimHitFxTicker = HitFxTicker;           return;       }
       if( (HitFX[SimHitFxTicker].damtype == none) || (Level.bDropDetail && (Level.TimeSeconds - LastRenderTime > 3) && !IsHumanControlled()) )           continue;
       //log("Processing effects for damtype "$HitFX[SimHitFxTicker].damtype);
       if( HitFX[SimHitFxTicker].bone == 'obliterate' && !class'GameInfo'.static.UseLowGore())       {           SpawnGibs( HitFX[SimHitFxTicker].rotDir, 1);           bGibbed = true;           // Wait a tick on a listen server so the obliteration can replicate before the pawn is destroyed           if( Level.NetMode == NM_ListenServer )           {               bDestroyNextTick = true;               TimeSetDestroyNextTickTime = Level.TimeSeconds;           }           else           {               Destroy();           }           return;       }
       boneCoords = GetBoneCoords( HitFX[SimHitFxTicker].bone );
       if ( !Level.bDropDetail && !class'GameInfo'.static.NoBlood() && !bSkeletized && !class'GameInfo'.static.UseLowGore())       {           //AttachEmitterEffect( BleedingEmitterClass, HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );
           HitFX[SimHitFxTicker].damtype.static.GetHitEffects( HitEffects, Health );
           if( !PhysicsVolume.bWaterVolume ) // don't attach effects under water           {               for( i = 0; i < ArrayCount(HitEffects); i++ )               {                   if( HitEffects[i] == none )                       continue;
                     AttachEffect( HitEffects[i], HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );               }           }       }       if ( class'GameInfo'.static.UseLowGore() )           HitFX[SimHitFxTicker].bSever = false;
       if( HitFX[SimHitFxTicker].bSever )       {           GibPerterbation = HitFX[SimHitFxTicker].damtype.default.GibPerterbation;
           switch( HitFX[SimHitFxTicker].bone )           {               case 'obliterate':                   break;
               case LeftThighBone:                   if( !bLeftLegGibbed )                   {                       SpawnSeveredGiblet( DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );                       KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;                       KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;                       KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;                       bLeftLegGibbed=true;                   }                   break;
               case RightThighBone:                   if( !bRightLegGibbed )                   {                       SpawnSeveredGiblet( DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );                       KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;                       KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;                       KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;                       bRightLegGibbed=true;                   }                   break;
               case LeftFArmBone:                   break;
               case RightFArmBone:                   break;
               case 'head':                   if( !bHeadGibbed )                   {                       if ( HitFX[SimHitFxTicker].damtype == class'DamTypeDecapitation' )                       {                           DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, false);                       }                       else if( HitFX[SimHitFxTicker].damtype == class'DamTypeProjectileDecap' )                       {                           DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, false, true);                       }                       else if( HitFX[SimHitFxTicker].damtype == class'DamTypeMeleeDecapitation' )                       {                           DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, true);                       }
                         bHeadGibbed=true;                     }                   break;           }
           if( HitFX[SimHitFXTicker].bone != 'Spine' && HitFX[SimHitFXTicker].bone != FireRootBone &&               HitFX[SimHitFXTicker].bone != LeftFArmBone && HitFX[SimHitFXTicker].bone != RightFArmBone &&               HitFX[SimHitFXTicker].bone != 'head' && Health <=0 )               HideBone(HitFX[SimHitFxTicker].bone);       }
    }
}
static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.siren_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.siren_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.siren_diffuse');
    myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.siren_hair');
    myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.siren_hair_fb');
}
defaultproperties
{    screamTimings(0)=0.420000    screamTimings(1)=0.510000    screamTimings(2)=0.590000    screamTimings(3)=0.670000    screamTimings(4)=0.760000    screamTimings(5)=0.840000    stunLoopStart=0.200000    stunLoopEnd=0.820000    idleInsertFrame=0.920000    EventClasses(0)="NicePack.NiceZombieSiren"    MoanVoice=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Talk'    JumpSound=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Jump'    DetachedLegClass=Class'KFChar.SeveredLegSiren'    DetachedHeadClass=Class'KFChar.SeveredHeadSiren'    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Pain'    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Death'    ControllerClass=Class'NicePack.NiceZombieSirenController'    AmbientSound=Sound'KF_BaseSiren.Siren_IdleLoop'    Mesh=SkeletalMesh'KF_Freaks_Trip.Siren_Freak'    Skins(0)=FinalBlend'KF_Specimens_Trip_T.siren_hair_fb'    Skins(1)=Combiner'KF_Specimens_Trip_T.siren_cmb'
}
