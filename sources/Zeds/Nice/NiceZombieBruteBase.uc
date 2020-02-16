class NiceZombieBruteBase extends NiceMonster;
#exec load obj file=ScrnZedPack_T.utx
#exec load obj file=ScrnZedPack_S.uax
#exec load obj file=ScrnZedPack_A.ukx
#exec OBJ LOAD FILE=KFWeaponSound.uax
var bool bChargingPlayer;
var bool bClientCharge;
var bool bFrustrated;
var int MaxRageCounter; // Maximum amount of players we can hit before calming down
var int RageCounter; // Decreases each time we successfully hit a player
var float RageSpeedTween;
var int TwoSecondDamageTotal;
var float LastDamagedTime;
var int RageDamageThreshold;
var int BlockHitsLanded; // Hits made while blocking or raging
var name ChargingAnim;
var Sound RageSound;
// View shaking for players
var() vector    ShakeViewRotMag;
var() vector    ShakeViewRotRate;
var() float        ShakeViewRotTime;
var() vector    ShakeViewOffsetMag;
var() vector    ShakeViewOffsetRate;
var() float        ShakeViewOffsetTime;
var float PushForce;
var vector PushAdd; // Used to add additional height to push
var float RageDamageMul; // Multiplier for hit damage when raging
var float RageBumpDamage; // Damage done when we hit other specimens while raging
var float BlockAddScale; // Additional head scale when blocking
var bool bBlockedHS;
var bool bBlocking;
var bool bServerBlock;
var bool bClientBlock;
var float BlockDmgMul; // Multiplier for damage taken from blocked shots
var float BlockFireDmgMul;
var float BurnGroundSpeedMul; // Multiplier for ground speed when burning
replication
{
    reliable if(Role == ROLE_Authority)       bChargingPlayer, bServerBlock;
}
//--------------------------------------------------------------------------
// NOTE: All Code resides in the child class(this class was only created to
//         eliminate hitching caused by loading default properties during play)
//--------------------------------------------------------------------------
defaultproperties
{    RageDamageThreshold=50    ChargingAnim="BruteRun"    RageSound=SoundGroup'ScrnZedPack_S.Brute.BruteRage'    ShakeViewRotMag=(X=500.000000,Y=500.000000,Z=600.000000)    ShakeViewRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)    ShakeViewRotTime=6.000000    ShakeViewOffsetMag=(X=5.000000,Y=10.000000,Z=5.000000)    ShakeViewOffsetRate=(X=300.000000,Y=300.000000,Z=300.000000)    ShakeViewOffsetTime=3.500000    PushForce=860.000000    PushAdd=(Z=150.000000)    RageDamageMul=1.100000    RageBumpDamage=4.000000    BlockAddScale=2.500000    BlockDmgMul=0.100000    BlockFireDmgMul=1.000000    BurnGroundSpeedMul=0.700000    StunThreshold=4.000000    flameFuel=0.500000    clientHeadshotScale=1.300000    MeleeAnims(0)="BruteAttack1"    MeleeAnims(1)="BruteAttack2"    MeleeAnims(2)="BruteBlockSlam"    MoanVoice=SoundGroup'ScrnZedPack_S.Brute.BruteTalk'    BleedOutDuration=7.000000    ZombieFlag=3    MeleeDamage=20    damageForce=25000    bFatAss=True    KFRagdollName="FleshPound_Trip"    MeleeAttackHitSound=SoundGroup'ScrnZedPack_S.Brute.BruteHitPlayer'    JumpSound=SoundGroup'ScrnZedPack_S.Brute.BruteJump'    SpinDamConst=20.000000    SpinDamRand=20.000000    bMeleeStunImmune=True    bUseExtendedCollision=True    ColOffset=(Z=52.000000)    ColRadius=35.000000    ColHeight=25.000000    SeveredArmAttachScale=1.300000    SeveredLegAttachScale=1.200000    SeveredHeadAttachScale=1.500000    PlayerCountHealthScale=0.250000    OnlineHeadshotOffset=(X=22.000000,Z=68.000000)    OnlineHeadshotScale=1.300000    HeadHealth=180.000000    PlayerNumHeadHealthScale=0.200000    MotionDetectorThreat=5.000000    HitSound(0)=SoundGroup'ScrnZedPack_S.Brute.BrutePain'    DeathSound(0)=SoundGroup'ScrnZedPack_S.Brute.BruteDeath'    ChallengeSound(0)=SoundGroup'ScrnZedPack_S.Brute.BruteChallenge'    ChallengeSound(1)=SoundGroup'ScrnZedPack_S.Brute.BruteChallenge'    ChallengeSound(2)=SoundGroup'ScrnZedPack_S.Brute.BruteChallenge'    ChallengeSound(3)=SoundGroup'ScrnZedPack_S.Brute.BruteChallenge'    ScoringValue=60    IdleHeavyAnim="BruteIdle"    IdleRifleAnim="BruteIdle"    RagDeathUpKick=100.000000    MeleeRange=85.000000    GroundSpeed=140.000000    WaterSpeed=120.000000    HealthMax=1000.000000    Health=1000    HeadHeight=2.500000    HeadScale=1.300000    MenuName="Brute"    MovementAnims(0)="BruteWalkC"    MovementAnims(1)="BruteWalkC"    WalkAnims(0)="BruteWalkC"    WalkAnims(1)="BruteWalkC"    WalkAnims(2)="RunL"    WalkAnims(3)="RunR"    IdleCrouchAnim="BruteIdle"    IdleWeaponAnim="BruteIdle"    IdleRestAnim="BruteIdle"    AmbientSound=SoundGroup'ScrnZedPack_S.Brute.BruteIdle1Shot'    Mesh=SkeletalMesh'ScrnZedPack_A.BruteMesh'    PrePivot=(Z=0.000000)    Skins(0)=Combiner'ScrnZedPack_T.Brute.Brute_Final'    Mass=600.000000    RotationRate=(Yaw=45000,Roll=0)
}
