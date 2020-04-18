class NiceKrissMPickup extends NiceWeaponPickup;
defaultproperties
{
    Weight=4.000000
    cost=750
    BuyClipSize=33
    PowerValue=50
    SpeedValue=90
    RangeValue=40
    Description="The KRISS Vector has a very high rate of fire and is equipped with the attachment for the Horzine medical darts."
    ItemName="KRISS Vector Medic Gun"
    ItemShortName="KRISS Vector"
    AmmoItemName="45. ACP Ammo"
    AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
    EquipmentCategoryID=3
    VariantClasses(0)=Class'KFMod.NeonKrissMPickup'
    InventoryType=Class'NicePack.NiceKrissMMedicGun'
    PickupMessage="You got the KRISS Vector Medic Gun"
    PickupSound=Sound'KF_KrissSND.Handling.KF_WEP_KRISS_Handling_Pickup'
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'KF_pickups6_Trip.Rifles.Kriss_Pickup'
    CollisionRadius=25.000000
    CollisionHeight=5.000000
}
