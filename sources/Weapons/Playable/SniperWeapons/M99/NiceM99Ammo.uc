class NiceM99Ammo extends NiceAmmo;
#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
defaultproperties
{
    WeaponPickupClass=Class'NicePack.NiceM99Pickup'
    AmmoPickupAmount=2
    MaxAmmo=20
    InitialAmount=5
    PickupClass=Class'NicePack.NiceM99AmmoPickup'
    IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
    IconCoords=(X1=4,Y1=350,X2=110,Y2=395)
    ItemName="50 Cal Bullets"
}
