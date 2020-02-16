//  ScrN copy
class NiceCryoNade extends Nade;
#exec OBJ LOAD FILE=KF_GrenadeSnd.uax
#exec OBJ LOAD FILE=Inf_WeaponsTwo.uax
#exec OBJ LOAD FILE=KF_LAWSnd.uax
//  How many times do freezing
var int     totalFreezes;
//  How often to do freezeing
var float   freezeRate;
//  The next time that this nade will freeze
var float   nextFreezeTime;
//  The sound of nade's explosion
var sound   explosionSound;
//  Whether or not effects have been played yet
var bool    bNeedToPlayEffects;
replication
{
    reliable if (Role==ROLE_Authority)       bNeedToPlayEffects;
}
simulated function PostNetReceive()
{
    super.PostNetReceive();
    if(!bHasExploded && bNeedToPlayEffects){       bNeedToPlayEffects = false;       Explode(Location, vect(0,0,1));
    }
}
simulated function Explode(vector hitLocation, vector hitNormal){
    bHasExploded = true;
    BlowUp(hitLocation);
    PlaySound(ExplosionSound,,TransientSoundVolume);
    if(Role == ROLE_Authority){       bNeedToPlayEffects = true;       AmbientSound=Sound'Inf_WeaponsTwo.smoke_loop';
    }
    if(EffectIsRelevant(location, false)){       Spawn(class'NiceCryoNadeCloud',,, hitLocation, rotator(vect(0,0,1)));       Spawn(explosionDecal, self,, hitLocation, rotator(-hitNormal));       if(level.detailMode >= DM_High)           Spawn(class'NiceNitroGroundEffect', self,, location);
    }
}
function Timer(){
    if(!bHidden){       if(!bHasExploded)           Explode(location, vect(0,0,1));
    }
    else if(bDisintegrated){       AmbientSound = none;       Destroy();
    }
}
simulated function BlowUp(vector hitLocation){
    DoFreeze(damage, damageRadius, MyDamageType, momentumTransfer, hitLocation);
    if(role == ROLE_Authority)       MakeNoise(1.0);
}
function DoFreeze(  float DamageAmount, float DamageRadius,                   class<DamageType> DamageType,                   float Momentum, vector HitLocation){
    local NiceMonster niceZed;
    if(bHurtEntry)       return;
    bHurtEntry = true;
    nextFreezeTime = level.timeSeconds + freezeRate;
    foreach CollidingActors(class 'NiceMonster', niceZed,                           damageRadius, hitLocation){       if(niceZed.Health <= 0) continue;       if(instigator == none || instigator.controller == none)           niceZed.SetDelayedDamageInstigatorController(instigatorController);       niceZed.TakeDamage( damageAmount, instigator, niceZed.location,                           vect(0,0,0), damageType);
    }
    bHurtEntry = false;
}
function TakeDamage(int Damage, Pawn InstigatedBy, Vector hitlocation,                   Vector momentum, class<DamageType> damageType,                   optional int HitIndex){
    if(damageType == class'SirenScreamDamage')       Disintegrate(HitLocation, vect(0,0,1));
}
// Overridden to tweak the handling of the impact sound
simulated function HitWall(vector hitNormal, Actor wall){
    local Vector vnorm;
    local PlayerController player;
    if(Pawn(wall) != none || GameObjective(wall) != none){       Explode(Location, HitNormal);       return;
    }
    if(!bTimerSet){       SetTimer(ExplodeTimer, false);       bTimerSet = true;
    }
    // Reflect off Wall w/damping
    vnorm = (velocity dot hitNormal) * hitNormal;
    Velocity = -vnorm * DampenFactor +       (Velocity - vnorm) * dampenFactorParallel;
    RandSpin(100000);
    desiredRotation.roll = 0;
    RotationRate.roll = 0;
    speed = VSize(velocity);
    if(speed < 20){       bBounce = False;       PrePivot.Z = -1.5;           SetPhysics(PHYS_None);       Timer();       SetTimer(0.0,False);       desiredRotation = Rotation;       desiredRotation.Roll = 0;       desiredRotation.Pitch = 0;       SetRotation(desiredRotation);       if(trail != none)           trail.mRegen = false;       return;
    }
    if(level.NetMode != NM_DedicatedServer && Speed > 50)       PlaySound(ImpactSound, SLOT_Misc );
    else{       bFixedRotationDir = false;       bRotateToDesired = true;       DesiredRotation.Pitch = 0;       RotationRate.Pitch = 50000;
    }
    
    if(level.bDropDetail || level.DetailMode == DM_Low)       return;
    if(     (level.TimeSeconds - lastSparkTime > 0.5)       &&  EffectIsRelevant(location, false)){       player = level.GetLocalPlayerController();       if(     player.viewTarget != none           &&  VSize(player.viewTarget.location - location) < 6000)           Spawn(HitEffectClass,,, Location, Rotator(HitNormal));       LastSparkTime = Level.TimeSeconds;
    }
}
function Tick(float deltaTime){
    if(     totalFreezes > 0 && nextFreezeTime > 0       &&  nextFreezeTime < level.timeSeconds){       totalFreezes--;       DoFreeze(damage, damageRadius, myDamageType, momentumTransfer, location);       if(totalFreezes == 0)           ambientSound = none;
    }
}
defaultproperties
{    totalFreezes=100    freezeRate=0.030000    ExplosionSound=SoundGroup'KF_GrenadeSnd.NadeBase.MedicNade_Explode'    Damage=0.000000    DamageRadius=175.000000    MyDamageType=Class'NicePack.NiceDamTypeCryoNade'    ExplosionDecal=Class'NicePack.NiceNitroDecal'    StaticMesh=StaticMesh'KF_pickups5_Trip.nades.MedicNade_Pickup'    LifeSpan=8.000000    DrawScale=1.000000    SoundVolume=150    SoundRadius=100.000000    TransientSoundVolume=2.000000    TransientSoundRadius=200.000000
}
