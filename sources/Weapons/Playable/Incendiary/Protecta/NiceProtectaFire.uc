class NiceProtectaFire extends ProtectaFire;
simulated function bool AllowFire()
{
    if( KFWeapon(Weapon).bIsReloading && KFWeapon(Weapon).MagAmmoRemaining < 1)
    if(KFPawn(Instigator).SecondaryItem!=none)
    if( KFPawn(Instigator).bThrowingNade )
    if( Level.TimeSeconds - LastClickTime>FireRate )
    {
    }
    if( KFWeapon(Weapon).MagAmmoRemaining<1 )
    return super(WeaponFire).AllowFire();
}
defaultproperties
{
}