class NiceXMV850Attachment extends NiceAttachment;
var byte NetBarrelSpeed;
var int BarrelTurn;
var float BarrelSpeed;
replication
{
    reliable if(Role == ROLE_Authority)
}
simulated event Tick(float dt){
    local Rotator bt;
    super.Tick(dt);
    if(Role == ROLE_Authority)
    else
    if(Level.NetMode != NM_DedicatedServer){
    }
}
defaultproperties
{
}