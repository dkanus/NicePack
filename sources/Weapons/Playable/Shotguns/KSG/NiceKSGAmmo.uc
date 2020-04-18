class NiceKSGAmmo extends NiceAmmo;
#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
defaultproperties
{
    WeaponPickupClass=Class'NicePack.NiceKSGPickup'
    AmmoPickupAmount=12
    MaxAmmo=84
    InitialAmount=15
    PickupClass=Class'NicePack.NiceKSGAmmoPickup'
    IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
    IconCoords=(X1=451,Y1=445,X2=510,Y2=500)
}
