class NiceSPShotgunAmmo extends NiceAmmo;
#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
defaultproperties
{
    WeaponPickupClass=Class'NicePack.NiceSPShotgunPickup'
    AmmoPickupAmount=10
    MaxAmmo=80
    InitialAmount=20
    PickupClass=Class'NicePack.NiceSPShotgunAmmoPickup'
    IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
    IconCoords=(X1=451,Y1=445,X2=510,Y2=500)
}
