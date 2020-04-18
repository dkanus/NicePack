class NiceZombieFleshpoundController extends NiceMonsterController;
var     float       RageAnimTimeout;    // How long until the RageAnim is completed; Hack so the server doesn't get stuck in idle when its doing the Rage anim
var     bool        bDoneSpottedCheck;
var     float       RageFrustrationTimer;       // Tracks how long we have been walking toward a visible enemy
var     float       RageFrustrationThreshhold;  // Base value for how long the FP should walk torward an enemy without reaching them before getting frustrated and raging
simulated function PostBeginPlay(){
    super.PostBeginPlay();
    RageFrustrationTimer = 0;
}
function Tick(float Delta){
    local bool bSeesPlayers;
    local Controller PC;
    local KFHumanPawn Human;
    local NiceZombieFleshPound ZFP;
    super.Tick(Delta);
    bSeesPlayers = false;
    for(PC = Level.ControllerList;PC != none;PC = PC.NextController){
       Human = KFHumanPawn(PC.Pawn);
       if(Human != none && Human.Health > 0 && !Human.bPendingDelete && CanSee(Human)){
           bSeesPlayers = true;
           break;
       }
    }
    if(bSeesPlayers){
       if(RageFrustrationTimer < RageFrustrationThreshhold){
           RageFrustrationTimer += Delta;
           if(RageFrustrationTimer >= RageFrustrationThreshhold){
               ZFP = NiceZombieFleshPound(Pawn);
               if(ZFP != none && !ZFP.bChargingPlayer){
                   ZFP.StartChargingFP(Pawn(focus));
                   ZFP.bFrustrated = true;
               }
           }
       }
    }
    else
       RageFrustrationTimer = 0;
}
// Never do that, you too cool
function GetOutOfTheWayOfShot(vector ShotDirection, vector ShotOrigin){}
state ZombieHunt
{
    event SeePlayer(Pawn SeenPlayer)
    {
       if ( !bDoneSpottedCheck && PlayerController(SeenPlayer.Controller) != none )
       {
           // 25% chance of first player to see this Fleshpound saying something
           if ( !KFGameType(Level.Game).bDidSpottedFleshpoundMessage && FRand() < 0.25 )
           {
               PlayerController(SeenPlayer.Controller).Speech('AUTO', 12, "");
               KFGameType(Level.Game).bDidSpottedFleshpoundMessage = true;
           }

           bDoneSpottedCheck = true;
       }

       super.SeePlayer(SeenPlayer);
    }
}
function TimedFireWeaponAtEnemy()
{
    if ( (Enemy == none) || FireWeaponAt(Enemy) )
       SetCombatTimer();
    else
       SetTimer(0.01, True);
}
state SpinAttack
{
ignores EnemyNotVisible;
    // Don't do this in this state
    function GetOutOfTheWayOfShot(vector ShotDirection, vector ShotOrigin){}
    function DoSpinDamage()
    {
       local Actor A;

       //log("FLESHPOUND DOSPINDAMAGE!");
       foreach CollidingActors(class'actor', A, (NiceZombieFleshpound(pawn).MeleeRange * 1.5)+pawn.CollisionRadius, pawn.Location)
           NiceZombieFleshpound(pawn).SpinDamage(A);
    }
Begin:
WaitForAnim:
    While( KFM.bShotAnim )
    {
       Sleep(0.1);
       DoSpinDamage();
    }
    WhatToDoNext(152);
    if ( bSoaking )
       SoakStop("STUCK IN SPINATTACK!!!");
}
state ZombieCharge
{
    function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest)
    {
       return false;
    }
    // I suspect this function causes bloats to get confused
    function bool TryStrafe(vector sideDir)
    {
       return false;
    }
    function Timer()
    {
       Disable('NotifyBump');
       Target = Enemy;
       TimedFireWeaponAtEnemy();
    }
WaitForAnim:
    if ( Monster(Pawn).bShotAnim )
    {
       Goto('Moving');
    }
    if ( !FindBestPathToward(Enemy, false,true) )
       GotoState('ZombieRestFormation');
Moving:
    MoveToward(Enemy);
    WhatToDoNext(17);
    if ( bSoaking )
       SoakStop("STUCK IN CHARGING!");
}
// Used to set a timeout for the WaitForAnim state. This is a bit of a hack fix
// for the FleshPound getting stuck in its idle anim on a dedicated server when it
// is supposed to be raging. For some reason, on a dedicated server only, it
// never gets an animend call for the PoundRage anim, instead the anim gets
// interrupted by the PoundIdle anim. If we figure that bug out, we can
// probably take this out in the future. But for now the fix works - Ramm
function SetPoundRageTimout(float NewRageTimeOut)
{
    RageAnimTimeout = NewRageTimeOut;
}
state WaitForAnim
{
Ignores SeePlayer,HearNoise,Timer,EnemyNotVisible,NotifyBump;
    // Don't do this in this state
    function GetOutOfTheWayOfShot(vector ShotDirection, vector ShotOrigin){}
    function BeginState()
    {
       bUseFreezeHack = False;
    }
    // The rage anim has ended, clear the flags and let the AI do its thing
    function RageTimeout()
    {
       if( bUseFreezeHack )
       {
           if( Pawn!=none )
           {
               Pawn.AccelRate = Pawn.Default.AccelRate;
               Pawn.GroundSpeed = Pawn.Default.GroundSpeed;
           }
           bUseFreezeHack = False;
           AnimEnd(0);
       }
    }
    function Tick( float Delta )
    {
       Global.Tick(Delta);

       if( RageAnimTimeout > 0 )
       {
           RageAnimTimeout -= Delta;

           if( RageAnimTimeout <= 0 )
           {
               RageAnimTimeout = 0;
               RageTimeout();
           }
       }

       if( bUseFreezeHack )
       {
           MoveTarget = none;
           MoveTimer = -1;
           Pawn.Acceleration = vect(0,0,0);
           Pawn.GroundSpeed = 1;
           Pawn.AccelRate = 0;
       }
    }
    function EndState()
    {
       if( Pawn!=none )
       {
           Pawn.AccelRate = Pawn.Default.AccelRate;
           Pawn.GroundSpeed = Pawn.Default.GroundSpeed;
       }
       bUseFreezeHack = False;
    }
Begin:
    While( KFM.bShotAnim )
    {
       Sleep(0.15);
    }
    WhatToDoNext(99);
}
defaultproperties
{
    RageFrustrationThreshhold=10.000000
}
