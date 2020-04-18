class NiceCrossbowPickup extends NiceWeaponPickup;
#exec OBJ LOAD FILE=KillingFloorWeapons.utx
defaultproperties
{
    Weight=9.000000
    AmmoCost=10
    BuyClipSize=1
    PowerValue=64
    SpeedValue=50
    RangeValue=100
    Description="Recreational hunting weapon, equipped with powerful scope and firing trigger. Comes with special ammunition, designed to tear through low-resistance materials."
    ItemName="Crossbow"
    ItemShortName="Crossbow"
    AmmoItemName="Crossbow Bolts"
    AmmoMesh=StaticMesh'KillingFloorStatics.XbowAmmo'
    CorrespondingPerkIndex=2
    EquipmentCategoryID=3
    MaxDesireability=0.790000
    InventoryType=Class'NicePack.NiceCrossbow'
    PickupMessage="You got the Crossbow"
    PickupSound=Sound'KF_XbowSnd.Xbow_Pickup'
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'KF_pickups_Trip.Rifle.crossbow_pickup'
    CollisionRadius=25.000000
    CollisionHeight=5.000000
}
