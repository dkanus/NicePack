class NiceFlareRevolverProjectile extends ScrnFlareRevolverProjectile;
//overrided to use alternate burning mechanism
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    local actor Victims;
    local float damageScale, dist;
    local vector dirs;
    local int NumKilled;
    local KFMonster KFMonsterVictim;
    local Pawn P;
    local KFPawn KFP;
    local array<Pawn> CheckedPawns;
    local int i;
    local bool bAlreadyChecked;
    if ( bHurtEntry )
    bHurtEntry = true;
    foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation) {











    }
    /*
    if ( (LastTouched != none) && (LastTouched != self) && (LastTouched != Instigator) &&
    {

    }
    */
    if( Role == ROLE_Authority )
    {
    }
    bHurtEntry = false;
}
defaultproperties
{
}