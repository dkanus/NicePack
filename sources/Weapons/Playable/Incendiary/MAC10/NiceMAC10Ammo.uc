class NiceMAC10Ammo extends NiceAmmo;
#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
defaultproperties
{
    WeaponPickupClass=Class'NicePack.NiceMAC10Pickup'
    AmmoPickupAmount=30
    MaxAmmo=300
    InitialAmount=75
    PickupClass=Class'NicePack.NiceMAC10AmmoPickup'
    IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
    IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
    ItemName="MAC-10 bullets"
}
