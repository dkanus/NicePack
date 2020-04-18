class NiceAK12Ammo extends NiceAmmo;
#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
defaultproperties
{
    WeaponPickupClass=Class'NicePack.NiceAK12Pickup'
    AmmoPickupAmount=30
    MaxAmmo=270
    InitialAmount=60
    PickupClass=Class'NicePack.NiceAK12AmmoPickup'
    IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
    IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
    ItemName="5.45x39mm"
}
