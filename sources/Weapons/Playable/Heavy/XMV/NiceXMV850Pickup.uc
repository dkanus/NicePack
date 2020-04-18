class NiceXMV850Pickup extends NiceWeaponPickup;

#EXEC OBJ LOAD FILE=HMG_T.utx
#EXEC OBJ LOAD FILE=HMG_S.uax
#EXEC OBJ LOAD FILE=HMG_A.ukx

defaultproperties
{
    Weight=7.000000
    cost=1000
    AmmoCost=100
    BuyClipSize=80
    PowerValue=40
    SpeedValue=100
    RangeValue=50
    Description="Minigun with reduced fire rate down to 950RPM. But still badass and has laser sight."
    ItemName="XMV850 Minigun"
    ItemShortName="XMV850 Minigun"
    AmmoItemName="7.62x51mm Ammo"
    AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
    CorrespondingPerkIndex=1
    EquipmentCategoryID=3
    InventoryType=Class'NicePack.NiceXMV850M'
    PickupMessage="You got the XMV850 Minigun."
    PickupSound=Sound'HMG_S.XMV.XMV-Pullout'
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'HMG_A.XMV850Pickup'
    CollisionRadius=25.000000
    CollisionHeight=5.000000
}