class NiceM14EBRAmmo extends NiceAmmo;
#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
defaultproperties
{
    WeaponPickupClass=Class'NicePack.NiceM14EBRPickup'
    AmmoPickupAmount=20
    MaxAmmo=160
    InitialAmount=40
    PickupClass=Class'NicePack.NiceM14EBRAmmoPickup'
    IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
    IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
    ItemName="M14EBR bullets"
}
