class NiceWinchesterAmmo extends NiceAmmo;
#EXEC OBJ LOAD FILE=InterfaceContent.utx

defaultproperties
{
     WeaponPickupClass=Class'NicePack.NiceWinchesterPickup'
     AmmoPickupAmount=10
     MaxAmmo=80
     InitialAmount=20
     PickupClass=Class'NicePack.NiceWinchesterAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=338,Y1=40,X2=393,Y2=79)
     ItemName="Winchester bullets"
}
