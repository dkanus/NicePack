class NiceMP7MPickup extends NiceWeaponPickup;
defaultproperties
{
    bBackupWeapon=True
    Weight=3.000000
    cost=200
    AmmoCost=20
    BuyClipSize=40
    PowerValue=22
    SpeedValue=95
    RangeValue=45
    Description="Prototype sub machine gun. Modified to fire healing darts."
    ItemName="MP7M Medic Gun"
    ItemShortName="MP7M"
    AmmoItemName="4.6x30mm Ammo"
    AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
    EquipmentCategoryID=3
    CorrespondingPerkIndex=3
    InventoryType=Class'NicePack.NiceMP7MMedicGun'
    PickupMessage="You got the MP7M Medic Gun"
    PickupSound=Sound'KF_MP7Snd.MP7_Pickup'
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'KF_pickups2_Trip.Supers.MP7_Pickup'
    CollisionRadius=25.000000
    CollisionHeight=5.000000
}