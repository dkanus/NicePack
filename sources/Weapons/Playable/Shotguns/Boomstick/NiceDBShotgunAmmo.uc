class NiceDBShotgunAmmo extends NiceAmmo;
#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
defaultproperties
{
    WeaponPickupClass=Class'NicePack.NiceBoomStickPickup'
    AmmoPickupAmount=6
    MaxAmmo=64
    InitialAmount=16
    PickupClass=Class'NicePack.NiceDBShotgunAmmoPickup'
    IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
    IconCoords=(X1=451,Y1=445,X2=510,Y2=500)
    ItemName="Shotgun Ammo"
}
