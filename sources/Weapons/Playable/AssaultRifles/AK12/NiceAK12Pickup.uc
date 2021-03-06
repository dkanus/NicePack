class NiceAK12Pickup extends NiceWeaponPickup;
defaultproperties
{
    Weight=6.000000
    cost=750
    BuyClipSize=30
    PowerValue=55
    SpeedValue=80
    RangeValue=30
    Description="The Kalashnikov AK-12 (formerly AK-200) is the newest derivative of the Soviet/Russian AK-47 series of assault rifles and was proposed for possible general issue to the Russian Army. This version uses the 5.45x39mm ammo (the same as AK-74)"
    ItemName="AK12"
    ItemShortName="AK12"
    AmmoItemName="5.45x39mm"
    AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
    CorrespondingPerkIndex=3
    EquipmentCategoryID=2
    InventoryType=Class'NicePack.NiceAK12AssaultRifle'
    PickupMessage="You got the AK-12"
    PickupSound=Sound'ScrnWeaponPack_SND.AK12.AK12_select'
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'ScrnWeaponPack_SM.AK12_st'
    DrawScale=1.100000
    CollisionRadius=25.000000
    CollisionHeight=5.000000
}
