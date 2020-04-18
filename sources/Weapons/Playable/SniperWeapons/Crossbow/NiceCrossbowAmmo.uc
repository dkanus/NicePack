class NiceCrossbowAmmo extends NiceAmmo;
#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
defaultproperties
{
    WeaponPickupClass=Class'NicePack.NiceCrossbowPickup'
    AmmoPickupAmount=4
    MaxAmmo=40
    PickupClass=Class'NicePack.NiceCrossbowAmmoPickup'
    IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
    IconCoords=(X1=4,Y1=350,X2=110,Y2=395)
    ItemName="An arrow"
}
