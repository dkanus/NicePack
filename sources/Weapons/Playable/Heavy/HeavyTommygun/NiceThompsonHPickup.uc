class NiceThompsonHPickup extends NiceWeaponPickup;
defaultproperties
{
    Weight=6.000000
    cost=500
    AmmoCost=30
    BuyClipSize=40
    PowerValue=30
    SpeedValue=90
    RangeValue=50
    Description="Alternative, heavier version of the Thompson gun. Uses different type of ammunition, the one more suited for straight-up destroying zed, rather than quickly dispatching them."
    ItemName="Heavy Tommy Gun"
    ItemShortName="Heavy Tommy"
    AmmoItemName=".45 ACP"
    AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
    CorrespondingPerkIndex=1
    EquipmentCategoryID=2
    InventoryType=Class'NicePack.NiceThompsonH'
    PickupMessage="You've got the Thompson Submachine Gun"
    PickupSound=Sound'KF_IJC_HalloweenSnd.Handling.Thompson_Handling_Bolt_Back'
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'HMG_A.thompson_st'
    CollisionRadius=25.000000
    CollisionHeight=5.000000
}
