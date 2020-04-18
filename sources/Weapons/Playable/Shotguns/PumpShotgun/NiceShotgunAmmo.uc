class NiceShotgunAmmo extends NiceAmmo;
#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
defaultproperties
{
    WeaponPickupClass=Class'NicePack.NiceShotgunPickup'
    AmmoPickupAmount=4
    MaxAmmo=32
    InitialAmount=8
    PickupClass=Class'NicePack.NiceShotgunAmmoPickup'
    IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
    IconCoords=(X1=451,Y1=445,X2=510,Y2=500)
}