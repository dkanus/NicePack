class NiceHFRFlame extends HitFlame;
var float LastFlameSpawnTime;
var () float FlameSpawnInterval;
var Emitter SecondaryFlame;
state Ticking
{
    simulated function Tick( float dt )
    {

    }
}
simulated function Destroyed()
{
    if( SecondaryFlame != none )
    {
    }
}
defaultproperties
{
}