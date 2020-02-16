// Zombie Monster for KF Invasion gametype
// GOREFAST.
// He's speedy, and swings with a Single enlongated arm, affording him slightly more range
class NiceZombieGoreFast extends NiceZombieGoreFastBase;
#exec OBJ LOAD FILE=
//----------------------------------------------------------------------------
// NOTE: All Variables are declared in the base class to eliminate hitching
//----------------------------------------------------------------------------
simulated function PostNetReceive(){
    if(bRunning)       MovementAnims[0] = 'ZombieRun';
    else       MovementAnims[0] = default.MovementAnims[0];
}
// This zed has been taken control of. Boost its health and speed
function SetMindControlled(bool bNewMindControlled)
{
    if( bNewMindControlled )
    {       NumZCDHits++;
       // if we hit him a couple of times, make him rage!       if( NumZCDHits > 1 )       {           if( !IsInState('RunningToMarker') )           {               GotoState('RunningToMarker');           }           else           {               NumZCDHits = 1;               if( IsInState('RunningToMarker') )               {                   GotoState('');               }           }       }       else       {           if( IsInState('RunningToMarker') )           {               GotoState('');           }       }
       if( bNewMindControlled != bZedUnderControl )       {           SetGroundSpeed(OriginalGroundSpeed * 1.25);           Health *= 1.25;           HealthMax *= 1.25;       }
    }
    else
    {       NumZCDHits=0;
    }
    bZedUnderControl = bNewMindControlled;
}
// Handle the zed being commanded to move to a new location
function GivenNewMarker()
{
    if( bRunning && NumZCDHits > 1 )
    {       GotoState('RunningToMarker');
    }
    else
    {       GotoState('');
    }
}
function RangedAttack(Actor A){
    super.RangedAttack(A);
    if(!bShotAnim && !bDecapitated && VSize(A.Location - Location) <= 700)       GoToState('RunningState');
}
simulated function Tick(float DeltaTime){
    super.Tick(DeltaTime);
    if(IsInState('RunningState'))       SetGroundSpeed(GetOriginalGroundSpeed() * 1.875);
    else       SetGroundSpeed(GetOriginalGroundSpeed());
}
state RunningState{
    // Set the zed to the zapped behavior
    simulated function SetZappedBehavior(){       Global.SetZappedBehavior();       GoToState('');
    }
    // Don't override speed in this state
    function bool CanSpeedAdjust(){       return false;
    }
    simulated function BeginState(){       if(bZapped)           GoToState('');       else{           SetGroundSpeed(OriginalGroundSpeed * 1.875);           bRunning = true;           if(Level.NetMode != NM_DedicatedServer)               PostNetReceive();
           NetUpdateTime = Level.TimeSeconds - 1;       }
    }
    function EndState(){       SetGroundSpeed(GetOriginalGroundSpeed());       bRunning = false;       if(Level.NetMode != NM_DedicatedServer)           PostNetReceive();
       RunAttackTimeout=0;
       NetUpdateTime = Level.TimeSeconds - 1;
    }
    function RemoveHead(){       GoToState('');       Global.RemoveHead();
    }
    function RangedAttack(Actor A){
       if(bShotAnim || Physics == PHYS_Swimming)           return;       else if (CanAttack(A)){           bShotAnim = true;
           // Randomly do a moving attack so the player can't kite the zed           if(FRand() < 0.4){               SetAnimAction('ClawAndMove');               RunAttackTimeout = GetAnimDuration('GoreAttack1', 1.0);           }           else{               SetAnimAction('Claw');               Controller.bPreparingMove = true;               Acceleration = vect(0,0,0);               // Once we attack stop running               GoToState('');           }           return;       }
    }
    simulated function Tick(float DeltaTime){       // Keep moving toward the target until the timer runs out (anim finishes)       if(RunAttackTimeout > 0){           RunAttackTimeout -= DeltaTime;
           if(RunAttackTimeout <= 0 && !bZedUnderControl){               RunAttackTimeout = 0;               GoToState('');           }       }
       // Keep the gorefast moving toward its target when attacking       if(Role == ROLE_Authority && bShotAnim && !bWaitForAnim){           if(LookTarget != none)               Acceleration = AccelRate * Normal(LookTarget.Location - Location);       }       global.Tick(DeltaTime);
    }
Begin:
    GoTo('CheckCharge');
CheckCharge:
    if( Controller!=none && Controller.Target!=none && VSize(Controller.Target.Location-Location)<700 )
    {       Sleep(0.5+ FRand() * 0.5);       //log("Still charging");       GoTo('CheckCharge');
    }
    else
    {       //log("Done charging");       GoToState('');
    }
}
// State where the zed is charging to a marked location.
state RunningToMarker extends RunningState
{
    simulated function Tick(float DeltaTime)
    {       // Keep moving toward the target until the timer runs out (anim finishes)       if( RunAttackTimeout > 0 )       {           RunAttackTimeout -= DeltaTime;
           if( RunAttackTimeout <= 0 && !bZedUnderControl )           {               RunAttackTimeout = 0;               GoToState('');           }       }
       // Keep the gorefast moving toward its target when attacking       if( Role == ROLE_Authority && bShotAnim && !bWaitForAnim )       {           if( LookTarget!=none )           {               Acceleration = AccelRate * Normal(LookTarget.Location - Location);           }       }
       global.Tick(DeltaTime);
    }

Begin:
    GoTo('CheckCharge');
CheckCharge:
    if( bZedUnderControl || (Controller!=none && Controller.Target!=none && VSize(Controller.Target.Location-Location)<700) )
    {       Sleep(0.5+ FRand() * 0.5);       GoTo('CheckCharge');
    }
    else
    {       GoToState('');
    }
}
// Overridden to handle playing upper body only attacks when moving
simulated event SetAnimAction(name NewAction)
{
    local int meleeAnimIndex;
    local bool bWantsToAttackAndMove;
    if( NewAction=='' )       Return;
    bWantsToAttackAndMove = NewAction == 'ClawAndMove';
    if( NewAction == 'Claw' )
    {       meleeAnimIndex = Rand(3);       NewAction = meleeAnims[meleeAnimIndex];
    }
    if( bWantsToAttackAndMove )
    {      ExpectingChannel = AttackAndMoveDoAnimAction(NewAction);
    }
    else
    {      ExpectingChannel = DoAnimAction(NewAction);
    }
    if( !bWantsToAttackAndMove && AnimNeedsWait(NewAction) )
    {       bWaitForAnim = true;
    }
    else
    {       bWaitForAnim = false;
    }
    if( Level.NetMode!=NM_Client )
    {       AnimAction = NewAction;       bResetAnimAct = True;       ResetAnimActTime = Level.TimeSeconds+0.3;
    }
}
// Handle playing the anim action on the upper body only if we're attacking and moving
simulated function int AttackAndMoveDoAnimAction( name AnimName )
{
    local int meleeAnimIndex;
    if( AnimName == 'ClawAndMove' )
    {       meleeAnimIndex = Rand(3);       AnimName = meleeAnims[meleeAnimIndex];
    }
    if( AnimName=='GoreAttack1' || AnimName=='GoreAttack2' )
    {       AnimBlendParams(1, 1.0, 0.0,, FireRootBone);       PlayAnim(AnimName,, 0.1, 1);
       return 1;
    }
    return super.DoAnimAction( AnimName );
}
simulated function HideBone(name boneName)
{
    //  Gorefast does not have a left arm and does not need it to be hidden
    if (boneName != LeftFArmBone)
    {       super.HideBone(boneName);
    }
}
static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.gorefast_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.gorefast_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.gorefast_diff');
}
defaultproperties
{    stunLoopStart=0.287500    stunLoopEnd=0.637500    idleInsertFrame=0.750000    EventClasses(0)="NicePack.NiceZombieGorefast"    MoanVoice=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Talk'    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_HitPlayer'    JumpSound=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Jump'    DetachedArmClass=Class'KFChar.SeveredArmGorefast'    DetachedLegClass=Class'KFChar.SeveredLegGorefast'    DetachedHeadClass=Class'KFChar.SeveredHeadGorefast'    bLeftArmGibbed=True    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Pain'    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Death'    ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Challenge'    ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Challenge'    ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Challenge'    ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Challenge'    ControllerClass=Class'NicePack.NiceZombieGorefastController'    AmbientSound=Sound'KF_BaseGorefast.Gorefast_Idle'    Mesh=SkeletalMesh'KF_Freaks_Trip.GoreFast_Freak'    Skins(0)=Combiner'KF_Specimens_Trip_T.gorefast_cmb'
}
