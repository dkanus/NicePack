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

    if ( bHurtEntry )       return;
    bHurtEntry = true;
    foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
    {       KFMonsterVictim = none; //tbs       // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag       if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )       {           dir = Victims.Location - HitLocation;           dist = FMax(1,VSize(dir));           dir = dir/dist;           damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);           if ( Instigator == none || Instigator.Controller == none )               Victims.SetDelayedDamageInstigatorController( InstigatorController );           if ( Victims == LastTouched )               LastTouched = none;                       KFMonsterVictim = KFMonster(Victims);
           if( KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )           {               KFMonsterVictim = none;           }                Victims.TakeDamage           (               damageScale * DamageAmount,               Instigator,               Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,               (damageScale * Momentum * dir),               DamageType           );           if (Vehicle(Victims) != none && Vehicle(Victims).Health > 0)               Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
       }
    }
    /*
    if ( (LastTouched != none) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
    {       Victims = LastTouched;       LastTouched = none;       dir = Victims.Location - HitLocation;       dist = FMax(1,VSize(dir));       dir = dir/dist;       damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));       if ( Instigator == none || Instigator.Controller == none )           Victims.SetDelayedDamageInstigatorController(InstigatorController);       Victims.TakeDamage       (           damageScale * DamageAmount,           Instigator,           Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,           (damageScale * Momentum * dir),           DamageType       );       if (Vehicle(Victims) != none && Vehicle(Victims).Health > 0)           Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
    }
    */
    bHurtEntry = false;
}
defaultproperties
{    Damage=16.000000    MyDamageType=Class'NicePack.NiceDamTypeFT'
}
