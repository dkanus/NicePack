class NiceNailGun extends NiceWeapon;
simulated function bool AltFireCanForceInterruptReload(){
    return GetMagazineAmmo() > 0;
}
defaultproperties
{
}