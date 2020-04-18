class NiceBoomStickPickup extends NiceWeaponPickup;
var int SingleShotCount;
defaultproperties
{
    cost=500
    BuyClipSize=2
    PowerValue=90
    SpeedValue=30
    RangeValue=12
    Description="A double barreled shotgun used by big game hunters."
    ItemName="Hunting Shotgun"
    ItemShortName="Hunting Shotgun"
    AmmoItemName="12-gauge Hunting shells"
    CorrespondingPerkIndex=1
    EquipmentCategoryID=3
    InventoryType=Class'NicePack.NiceBoomStick'
    PickupMessage="You got the Hunting Shotgun"
    PickupSound=Sound'KF_DoubleSGSnd.2Barrel_Pickup'
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'KF_pickups_Trip.Shotgun.boomstick_pickup'
    CollisionRadius=35.000000
    CollisionHeight=5.000000
}