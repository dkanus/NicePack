//=============================================================================
// Flame
//=============================================================================
class NiceFlameTendril extends ScrnFlameTendril;
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    local actor Victims;
    local float damageScale, dist;
    local vector dir;
    local KFMonster KFMonsterVictim;

    if ( bHurtEntry )
    bHurtEntry = true;
    foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
    {


    }
    /*
    if ( (LastTouched != none) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
    {
    }
    */
    bHurtEntry = false;
}
defaultproperties
{
}