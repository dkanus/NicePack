class NiceSeekerSixSeekingRocketProjectile extends NiceSeekerSixRocketProjectile;
var Actor Seeking;
var vector InitialDir;
replication
{
    reliable if( bNetInitial && (Role==ROLE_Authority) )
}
simulated function Timer()
{
    local vector ForceDir;
    local float VelMag;
    if ( InitialDir == vect(0,0,0) )
    Acceleration = vect(0,0,0);
    Super.Timer();
    if ( (Seeking != none) && (Seeking != Instigator) )
    {

    }
}
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(0.1, true);
}
defaultproperties
{
}