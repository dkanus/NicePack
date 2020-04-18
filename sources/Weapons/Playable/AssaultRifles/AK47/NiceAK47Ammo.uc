class NiceAK47Ammo extends NiceAmmo;
#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
defaultproperties
{
    WeaponPickupClass=Class'NicePack.NiceAK47Pickup'
    AmmoPickupAmount=30
    MaxAmmo=270
    InitialAmount=90
    PickupClass=Class'NicePack.NiceAK47AmmoPickup'
    IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
    IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
    ItemName="AK47 bullets"
}
