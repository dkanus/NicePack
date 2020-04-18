class NiceSpasAmmo extends NiceAmmo;
#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
defaultproperties
{
    WeaponPickupClass=Class'NicePack.NiceSpasPickup'
    AmmoPickupAmount=8
    MaxAmmo=64
    InitialAmount=16
    PickupClass=Class'NicePack.NiceSpasAmmoPickup'
    IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
    IconCoords=(X1=451,Y1=445,X2=510,Y2=500)
}
