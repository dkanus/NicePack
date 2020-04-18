class NiceM41APrimaryPickup extends NiceWeaponPickup;
defaultproperties
{
    cost=750
    Weight=7.000000
    AmmoCost=66
    BuyClipSize=66
    PowerValue=70
    SpeedValue=100
    RangeValue=80
    Description="M41A Pulse Rifle. Designed to kill Aliens. Looks especially cool in Sigourney Weaver's hands."
    ItemName="M41A Pulse Rifle"
    ItemShortName="Pulse Rifle"
    AmmoItemName="M41A 10 mm caseless ammunition"
    AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
    CorrespondingPerkIndex=1
    EquipmentCategoryID=3
    InventoryType=Class'NicePack.NiceM41AAssaultRifle'
    PickupMessage="You got the M41A"
    PickupSound=Sound'HMG_S.M41A.Pickup'
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'HMG_A.M41APickup'
    CollisionRadius=25.000000
    CollisionHeight=5.000000
}