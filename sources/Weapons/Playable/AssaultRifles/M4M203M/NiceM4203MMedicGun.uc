class NiceM4203MMedicGun extends NiceM4203AssaultRifle
    config(user);
var localized   string  SuccessfulHealMessage;
var ScrnFakedHealingGrenade FakedNade;
replication
{
}
simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    if ( Level.NetMode != NM_DedicatedServer ) {

    }
}

simulated function Destroyed()
{
    if ( FakedNade != none )
    super.Destroyed();
}
// The server lets the client know they successfully healed someone
simulated function ClientSuccessfulHeal(int HealedPlayerCount, int HealedAmount)
{
    local string str;
    if( PlayerController(Instigator.Controller) != none ) {
    }
}
defaultproperties
{
}