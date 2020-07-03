class NiceM249Ammo extends NiceAmmo;
#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
defaultproperties
{
    WeaponPickupClass=Class'NicePack.NiceM249Pickup'
    AmmoPickupAmount=80
    MaxAmmo=160
    InitialAmount=80
    PickupClass=Class'NicePack.NiceM249AmmoPickup'
    IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
    IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
    ItemName="Rounds 5.56x45mm NATO"
}
