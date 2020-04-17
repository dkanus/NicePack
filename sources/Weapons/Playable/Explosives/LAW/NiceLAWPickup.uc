class NiceLAWPickup extends NiceWeaponPickup;
#exec OBJ LOAD FILE=KillingFloorWeapons.utx
defaultproperties
{    Weight=9.000000    cost=1250    AmmoCost=30    BuyClipSize=1    PowerValue=100    SpeedValue=20    RangeValue=64    Description="Light Anti Tank weapon. Designed to punch through armored vehicles."    ItemName="L.A.W"    ItemShortName="L.A.W"    AmmoItemName="L.A.W Rockets"    AmmoMesh=StaticMesh'KillingFloorStatics.LAWAmmo'    CorrespondingPerkIndex=6    EquipmentCategoryID=3    MaxDesireability=0.790000    InventoryType=Class'NicePack.NiceLAW'    RespawnTime=60.000000    PickupMessage="You got the L.A.W."    PickupSound=Sound'KF_LAWSnd.LAW_Pickup'    PickupForce="AssaultRiflePickup"    StaticMesh=StaticMesh'KF_pickups_Trip.Super.LAW_Pickup'    CollisionRadius=35.000000    CollisionHeight=10.000000
}
