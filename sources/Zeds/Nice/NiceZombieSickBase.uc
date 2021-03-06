// Zombie Monster for KF Invasion gametype
class NiceZombieSickBase extends NiceMonster;
var name WalkAnim, RunAnim;
#exec OBJ LOAD FILE=KF_EnemiesFinalSnd.uax
var BileJet BloatJet;
var bool bPlayBileSplash;
var bool bMovingPukeAttack;
var float RunAttackTimeout;
var()       float   AttackChargeRate; 
//-------------------------------------------------------------------------------
// NOTE: All Code resides in the child class(this class was only created to
//         eliminate hitching caused by loading default properties during play)
//-------------------------------------------------------------------------------
defaultproperties
{
    AttackChargeRate=2.500000
    StunThreshold=4.000000
    fuelRatio=0.250000
    bWeakHead=True
    clientHeadshotScale=1.500000
    MeleeAnims(0)="Strike"
    MeleeAnims(1)="Strike"
    MeleeAnims(2)="Strike"
    MoanVoice=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Talk'
    BleedOutDuration=6.000000
    ZombieFlag=3
    MeleeDamage=14
    damageForce=70000
    bFatAss=True
    KFRagdollName="Clot_Trip"
    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_HitPlayer'
    JumpSound=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Jump'
    PuntAnim="BloatPunt"
    Intelligence=BRAINS_Stupid
    bCanDistanceAttackDoors=True
    bUseExtendedCollision=True
    ColOffset=(Z=55.000000)
    ColRadius=29.000000
    ColHeight=18.000000
    SeveredArmAttachScale=1.400000
    SeveredLegAttachScale=1.400000
    SeveredHeadAttachScale=1.400000
    PlayerCountHealthScale=0.250000
    HeadlessWalkAnims(0)="WalkF"
    HeadlessWalkAnims(1)="WalkB"
    HeadlessWalkAnims(2)="WalkL"
    HeadlessWalkAnims(3)="WalkR"
    BurningWalkFAnims(0)="WalkF"
    BurningWalkFAnims(1)="WalkF"
    BurningWalkFAnims(2)="WalkF"
    BurningWalkAnims(0)="WalkB"
    BurningWalkAnims(1)="WalkL"
    BurningWalkAnims(2)="WalkR"
    PoundRageBumpDamScale=0.010000
    OnlineHeadshotOffset=(X=22.000000,Y=5.000000,Z=58.000000)
    HeadHealth=50.000000
    MotionDetectorThreat=3.000000
    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Pain'
    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Death'
    ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Challenge'
    ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Challenge'
    ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Challenge'
    ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Challenge'
    AmmunitionClass=Class'KFMod.BZombieAmmo'
    ScoringValue=75
    IdleHeavyAnim="Idle"
    IdleRifleAnim="Idle"
    RagdollLifeSpan=20.000000
    RagDeathVel=150.000000
    RagShootStrength=300.000000
    RagSpinScale=12.500000
    RagDeathUpKick=50.000000
    MeleeRange=30.000000
    GroundSpeed=175.000000
    WaterSpeed=150.000000
    HealthMax=925.000000
    Health=925
    HeadHeight=2.200000
    HeadScale=1.610000
    AmbientSoundScaling=8.000000
    MenuName="Sick"
    MovementAnims(0)="WalkF"
    MovementAnims(1)="WalkB"
    MovementAnims(2)="WalkL"
    MovementAnims(3)="WalkR"
    WalkAnims(1)="WalkB"
    WalkAnims(2)="WalkL"
    WalkAnims(3)="WalkR"
    IdleCrouchAnim="Idle"
    IdleWeaponAnim="Idle"
    IdleRestAnim="Idle"
    AmbientSound=Sound'KF_BaseGorefast.Gorefast_Idle'
    Mesh=SkeletalMesh'NicePackA.MonsterSick.Sick'
    DrawScale=1.100000
    PrePivot=(Z=5.000000)
    Skins(0)=Combiner'NicePackT.MonsterSick.Sick_cmb'
    SoundVolume=200
    Mass=400.000000
    RotationRate=(Yaw=45000,Roll=0)
}
