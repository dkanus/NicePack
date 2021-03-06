class NiceShotgunPickup extends NiceWeaponPickup;

defaultproperties
{
    bBackupWeapon=True
    Weight=6.000000
    cost=200
    AmmoCost=15
    BuyClipSize=8
    PowerValue=70
    SpeedValue=40
    RangeValue=15
    Description="A rugged tactical pump action shotgun common to police divisions the world over. It accepts a maximum of 8 shells and can fire in rapid succession."
    ItemName="Shotgun"
    ItemShortName="Shotgun"
    AmmoItemName="12-gauge shells"
    CorrespondingPerkIndex=1
    EquipmentCategoryID=2
    VariantClasses(0)=Class'KFMod.CamoShotgunPickup'
    InventoryType=Class'NicePack.NiceShotgun'
    PickupMessage="You got the Shotgun"
    PickupSound=Sound'KF_PumpSGSnd.SG_Pickup'
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'KF_pickups_Trip.Shotgun.shotgun_pickup'
    CollisionRadius=35.000000
    CollisionHeight=5.000000
}