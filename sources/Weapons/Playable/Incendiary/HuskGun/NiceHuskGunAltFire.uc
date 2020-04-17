// NAPALM THROWER
class NiceHuskGunAltFire extends ScrnHuskGunAltFire;
/*
//instant shot, without holding
function ModeHoldFire() { }
function Charge() { }
function PlayPreFire() { }
function Timer() { }
function class<Projectile> GetDesiredProjectileClass()
{
    return ProjectileClass;
}
function PostSpawnProjectile(Projectile P)
{
    super(KFShotgunFire).PostSpawnProjectile(P); // bypass HuskGunFire
}
simulated function bool AllowFire()
{
    return (Weapon.AmmoAmount(ThisModeNum) >= MaxChargeAmmo);
}
function ModeDoFire()
{
    if (!AllowFire())       return;       Weapon.ConsumeAmmo(ThisModeNum, MaxChargeAmmo-1); // +1 will be consumed in parent function
    super(KFShotgunFire).ModeDoFire();
}
*/
defaultproperties
{    MaxChargeAmmo=30    ProjectileClass=Class'NicePack.NiceHuskGunProjectile_Alt'
}
