class NiceZombieBruteController extends NiceMonsterController;
var     float       RageAnimTimeout;            // How long until the RageAnim is completed; Hack so the server doesn't get stuck in idle when its doing the Rage anim
var        bool        bDoneSpottedCheck;
var     float       RageFrustrationTimer;       // Tracks how long we have been walking toward a visible enemy
var     float       RageFrustrationThreshhold;  // Base value for how long the FP should walk torward an enemy without reaching them before getting frustrated and raging
function TimedFireWeaponAtEnemy()
{
    if ( (Enemy == none) || FireWeaponAt(Enemy) )       SetCombatTimer();
    else       SetTimer(0.01, True);
}
state ZombieCharge
{
    function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest)
    {       return false;
    }
    function bool TryStrafe(vector sideDir)
    {       return false;
    }
    function Timer()
    {       Disable('NotifyBump');       Target = Enemy;       TimedFireWeaponAtEnemy();
    }
    function BeginState()
    {       super.BeginState();
       RageFrustrationThreshhold = default.RageFrustrationThreshhold + (Frand() * 5);
    }
}
defaultproperties
{    RageFrustrationThreshhold=10.000000
}
