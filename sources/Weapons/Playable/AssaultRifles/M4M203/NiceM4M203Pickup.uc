class NiceM4M203Pickup extends NiceWeaponPickup;
defaultproperties
{
    crossPerkIndecies(0)=3
    Weight=6.000000
    cost=750
    AmmoCost=40
    BuyClipSize=1
    PowerValue=30
    SpeedValue=90
    RangeValue=60
    Description="An assault rifle with an attached grenade launcher."
    ItemName="M4 203"
    ItemShortName="M4 203"
    AmmoItemName="5.56mm Ammo"
    AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
    SecondaryAmmoShortName="M4 203 Grenades"
    PrimaryWeaponPickup=Class'NicePack.NiceM4Pickup'
    CorrespondingPerkIndex=6
    EquipmentCategoryID=2
    InventoryType=Class'NicePack.NiceM4M203AssaultRifle'
    PickupMessage="You got the M4 203"
    PickupSound=Sound'KF_M4RifleSnd.foley.WEP_M4_Foley_Pickup'
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'KF_pickups3_Trip.Rifles.M4M203_Pickup'
    CollisionRadius=25.000000
    CollisionHeight=5.000000
}
