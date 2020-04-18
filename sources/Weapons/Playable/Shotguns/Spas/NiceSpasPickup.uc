class NiceSpasPickup extends NiceWeaponPickup;

defaultproperties
{
    cost=750
    Weight=8.000000
    BuyClipSize=10
    PowerValue=55
    SpeedValue=40
    RangeValue=17
    Description="The SPAS12 is a dual-mode shotgun, that can also be used for firing slugs."
    ItemName="SPAS-12"
    ItemShortName="SPAS-12"
    AmmoItemName="12-gauge shells"
    CorrespondingPerkIndex=1
    EquipmentCategoryID=2
    InventoryType=Class'NicePack.NiceSpas'
    PickupMessage="You got the SPAS-12"
    PickupSound=Sound'KF_PumpSGSnd.SG_Pickup'
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'ScrnWeaponPack_SM.spas12_pickup'
    CollisionRadius=35.000000
    CollisionHeight=5.000000
}