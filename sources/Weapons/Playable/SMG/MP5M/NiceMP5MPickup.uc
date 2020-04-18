class NiceMP5MPickup extends NiceWeaponPickup;
defaultproperties
{
    Weight=4.000000
    cost=250
    AmmoCost=10
    BuyClipSize=30
    PowerValue=30
    SpeedValue=85
    RangeValue=45
    Description="MP5 sub machine gun. Modified to fire healing darts. Better damage and healing than MP7M with a larger mag."
    ItemName="MP5M Medic Gun"
    ItemShortName="MP5M"
    AmmoItemName="9x19mm Ammo"
    AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
    EquipmentCategoryID=3
    VariantClasses(0)=Class'KFMod.CamoMP5MPickup'
    InventoryType=Class'NicePack.NiceMP5MMedicGun'
    PickupMessage="You got the MP5M Medic Gun"
    PickupSound=Sound'KF_MP5Snd.foley.WEP_MP5_Foley_Pickup'
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'KF_pickups3_Trip.Rifles.Mp5_Pickup'
    CollisionRadius=25.000000
    CollisionHeight=5.000000
}
