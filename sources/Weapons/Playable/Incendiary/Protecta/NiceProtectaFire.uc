class NiceProtectaFire extends ProtectaFire;
simulated function bool AllowFire()
{
    if( KFWeapon(Weapon).bIsReloading && KFWeapon(Weapon).MagAmmoRemaining < 1)       return false;
    if(KFPawn(Instigator).SecondaryItem!=none)       return false;
    if( KFPawn(Instigator).bThrowingNade )       return false;
    if( Level.TimeSeconds - LastClickTime>FireRate )
    {       LastClickTime = Level.TimeSeconds;
    }
    if( KFWeapon(Weapon).MagAmmoRemaining<1 )       return false;
    return super(WeaponFire).AllowFire();
}
defaultproperties
{    maxVerticalRecoilAngle=1000    maxHorizontalRecoilAngle=300    AmmoClass=Class'NicePack.NiceProtectaAmmo'    ProjectileClass=Class'NicePack.NiceProtectaFlare'
}
