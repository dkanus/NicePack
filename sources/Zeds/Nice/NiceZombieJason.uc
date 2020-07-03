class NiceZombieJason extends NiceZombieScrake;
#exec load obj file=ScrnZedPack_T.utx
#exec load obj file=ScrnZedPack_S.uax
#exec load obj file=ScrnZedPack_A.ukx
var int OriginalMeleeDamage; // default melee damage, adjusted by game's difficulty
var bool bWasRaged; // set to true, if Jason is raged or was raged before
var float RageHealthPct;
var float RegenDelay;
var float RegenRate;    // Speed of regeneration, in percents of max health
var float RegenAcc;
var float RegenAccHead;
simulated function PostBeginPlay(){
    super.PostBeginPlay();
    OriginalMeleeDamage = MeleeDamage;
}
function bool IsStunPossible(){
    return false;
}
function bool CheckMiniFlinch(int flinchScore, Pawn instigatedBy, Vector hitLocation, Vector momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, KFPlayerReplicationInfo KFPRI){
    return super.CheckMiniFlinch(flinchScore * 1.5, instigatedBy, hitLocation, momentum, damageType, headshotLevel, KFPRI);
}
simulated function Tick(float DeltaTime){
    super.Tick(DeltaTime);
    if(Role < ROLE_Authority)
       return;
    if(lastTookDamageTime + RegenDelay < Level.TimeSeconds && Health > 0){
       RegenAcc += DeltaTime * RegenRate * HealthMax * 0.01;
       RegenAccHead += DeltaTime * RegenRate * HeadHealthMax * 0.01;
       if(RegenAcc > 1){
           Health += RegenAcc;
           if(Health > HealthMax)
               Health = HealthMax;
           RegenAcc = 0.0;
       }
       if(RegenAccHead > 1){
           HeadHealth += RegenAccHead;
           if(HeadHealth > HeadHealthMax)
               HeadHealth = HeadHealthMax;
           RegenAccHead = 0.0;
       }
    }
    else{
       RegenAcc = 0.0;
       RegenAccHead = 0.0;
    }
}
// Machete has no Exhaust ;)
simulated function SpawnExhaustEmitter(){}
simulated function UpdateExhaustEmitter(){}
function bool CanGetOutOfWay()
{
    return !bIsStunned; // can't dodge husk fireballs while stunned
}
simulated function Unstun(){
    bCharging = true;
    MovementAnims[0] = 'ChargeF';
    super.Unstun();
}
function TakeDamageClient(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, float lockonTime){
    Super.TakeDamageClient(Damage, instigatedBy, hitLocation, momentum, damageType, headshotLevel, lockonTime);
    if(bIsStunned && Health > 0 && (headshotLevel <= 0.0) && Level.TimeSeconds > LastStunTime + 0.1)
       Unstun();
}
function TakeFireDamage(int Damage, Pawn Instigator){
    Super.TakeFireDamage(Damage, Instigator);
    if(bIsStunned && Health > 0 && Damage > 150 && Level.TimeSeconds > LastStunTime + 0.1)
       Unstun();
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
    if( !bShotAnim && !bDecapitated ) {
       if(bConfusedState)
           return;
       if ( bWasRaged || float(Health)/HealthMax < 0.5 
               || (float(Health)/HealthMax < RageHealthPct) )
           GoToState('RunningState');
    }
}
State SawingLoop
{
    function RangedAttack(Actor A)
    {
       if ( bShotAnim )
           return;
       else if ( CanAttack(A) )
       {
           Acceleration = vect(0,0,0);
           bShotAnim = true;
           MeleeDamage = OriginalMeleeDamage * 0.6;
           SetAnimAction('SawImpaleLoop');
           if( AmbientSound != SawAttackLoopSound )
           {
               AmbientSound=SawAttackLoopSound;
           }
       }
       else GoToState('');
    }
}
simulated function float GetOriginalGroundSpeed()
{
    local float result;
    result = OriginalGroundSpeed;
    if ( bWasRaged || bCharging )
       result *= 3.5;
    else if( bZedUnderControl )
       result *= 1.25;
       return result;
}
state RunningState
{
    function BeginState()
    {
       local NiceHumanPawn rageTarget;
       bWasRaged = true;
       if(bWasCalm){
           bWasCalm = false;
           rageTarget = NiceHumanPawn(Controller.focus);
           if( rageTarget != none && KFGameType(Level.Game) != none
               && class'NiceVeterancyTypes'.static.HasSkill(NicePlayerController(rageTarget.Controller),
                   class'NiceSkillCommandoPerfectExecution') ){
                NiceGameType(Level.Game).lessDramatic = true;
               KFGameType(Level.Game).DramaticEvent(1.0);
           }
       }
       if( bZapped )
           GoToState('');
       else {
           bCharging = true;
           SetGroundSpeed(GetOriginalGroundSpeed());
           if( Level.NetMode!=NM_DedicatedServer )
               PostNetReceive();
           NetUpdateTime = Level.TimeSeconds - 1;
       }
    }
    function EndState()
    {
       bCharging = False;
       if( !bZapped )
           SetGroundSpeed(GetOriginalGroundSpeed());
       if( Level.NetMode!=NM_DedicatedServer )
           PostNetReceive();
    }
}
defaultproperties
{
    RageHealthPct=0.750000
    RegenDelay=5.000000
    RegenRate=4.000000
    SawAttackLoopSound=Sound'KF_BaseGorefast.Attack.Gorefast_AttackSwish3'
    ChainSawOffSound=None
    StunThreshold=1.000000
    MoanVoice=None
    StunsRemaining=5
    BleedOutDuration=7.000000
    MeleeDamage=25
    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_HitPlayer'
    JumpSound=None
    HeadHealth=800.000000
    HitSound(0)=None
    DeathSound(0)=None
    ChallengeSound(0)=None
    ChallengeSound(1)=None
    ChallengeSound(2)=None
    ChallengeSound(3)=None
    ScoringValue=300
    MenuName="Jason"
    AmbientSound=Sound'ScrnZedPack_S.Jason.Jason_Sound'
    Mesh=SkeletalMesh'ScrnZedPack_A.JasonMesh'
    Skins(0)=Shader'ScrnZedPack_T.Jason.Jason__FB'
    Skins(1)=Texture'ScrnZedPack_T.Jason.JVMaskB'
    Skins(2)=Combiner'ScrnZedPack_T.Jason.Machete_cmb'
}
