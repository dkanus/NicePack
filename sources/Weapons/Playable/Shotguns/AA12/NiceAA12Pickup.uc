class NiceAA12Pickup extends NiceWeaponPickup;
defaultproperties
{
    cost=1250
    AmmoCost=80
    BuyClipSize=20
    PowerValue=85
    SpeedValue=65
    RangeValue=20
    Description="An advanced fully automatic shotgun."
    ItemName="AA12 Shotgun"
    ItemShortName="AA12 Shotgun"
    AmmoItemName="12-gauge drum"
    CorrespondingPerkIndex=1
    EquipmentCategoryID=3
    VariantClasses(0)=Class'KFMod.GoldenAA12Pickup'
    InventoryType=Class'NicePack.NiceAA12AutoShotgun'
    PickupMessage="You got the AA12 auto shotgun."
    PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'KF_pickups2_Trip.Shotguns.AA12_Pickup'
    CollisionRadius=35.000000
    CollisionHeight=5.000000
}