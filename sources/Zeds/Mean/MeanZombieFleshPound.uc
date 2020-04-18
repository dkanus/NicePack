class MeanZombieFleshPound extends NiceZombieFleshPound;
#exec OBJ LOAD FILE=MeanZedSkins.utx
state RageCharging
{
Ignores StartChargingFP;
    function bool CanGetOutOfWay()
    {
       return false;
    }
    // Don't override speed in this state
    function bool CanSpeedAdjust()
    {
       return false;
    }
    function BeginState()
    {
       bChargingPlayer = true;
       if( Level.NetMode!=NM_DedicatedServer )
           ClientChargingAnims();

       RageEndTime = (Level.TimeSeconds + 15) + (FRand() * 18);
       NetUpdateTime = Level.TimeSeconds - 1;
    }
    function EndState()
    {
       bChargingPlayer = false;
       bFrustrated = false;
       if(Controller != none)
           NiceZombieFleshPoundController(Controller).RageFrustrationTimer = 0;
       if( Health>0 && !bZapped )
       {
           SetGroundSpeed(GetOriginalGroundSpeed());
       }

       if( Level.NetMode!=NM_DedicatedServer )
           ClientChargingAnims();

       NetUpdateTime = Level.TimeSeconds - 1;
    }
    function Tick( float Delta )
    {
       if( !bShotAnim )
       {
           SetGroundSpeed(OriginalGroundSpeed * 2.3);//2.0;
       }

       // Keep the flesh pound moving toward its target when attacking
       if( Role == ROLE_Authority && bShotAnim)
       {
           if( LookTarget!=none )
           {
               Acceleration = AccelRate * Normal(LookTarget.Location - Location);
           }
       }

       global.Tick(Delta);
    }
    function Bump( Actor Other )
    {
       local float RageBumpDamage;
       local KFMonster KFMonst;

       KFMonst = KFMonster(Other);

       // Hurt/Kill enemies that we run into while raging
       if( !bShotAnim && KFMonst!=none && NiceZombieFleshPound(Other)==none && Pawn(Other).Health>0 )
       {
           // Random chance of doing obliteration damage
           if( FRand() < 0.4 )
           {
                RageBumpDamage = 501;
           }
           else
           {
                RageBumpDamage = 450;
           }

           RageBumpDamage *= KFMonst.PoundRageBumpDamScale;

           Other.TakeDamage(RageBumpDamage, self, Other.Location, Velocity * Other.Mass, class'NiceDamTypePoundCrushed');
       }
       else Global.Bump(Other);
    }
    // If fleshie hits his target on a charge, then he should settle down for abit.
    function bool MeleeDamageTarget(int hitdamage, vector pushdir)
    {
       local bool RetVal,bWasEnemy;

       bWasEnemy = (Controller.Target==Controller.Enemy);
       RetVal = Super(NiceMonster).MeleeDamageTarget(hitdamage*1.75, pushdir*3);
           // Only stop if you've successfully killed your target
       if(Pawn(Controller.Target) == none)
           return RetVal;
       if( KFPawn(Controller.Target) != none && Pawn(Controller.Target).Health <= 0 && RetVal && bWasEnemy ){
           GoToState('');
       }
       return RetVal;
    }
}
defaultproperties
{
    MenuName="Mean FleshPound"
    Skins(0)=Combiner'MeanZedSkins.fleshpound_cmb'
}
