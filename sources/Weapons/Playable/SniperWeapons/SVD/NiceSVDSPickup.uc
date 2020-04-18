class NiceSVDSPickup extends NiceWeaponPickup;
#exec OBJ LOAD FILE=ScrnWeaponPack_T.utx
#exec OBJ LOAD FILE=ScrnWeaponPack_A.ukx
defaultproperties
{
    Weight=7.000000
    cost=1500
    AmmoCost=10
    BuyClipSize=5
    PowerValue=80
    SpeedValue=40
    RangeValue=100
    Description="The Dragunov sniper rifle with folding stock (formally Russian: Snayperskaya Vintovka Dragunova Skladnaya, SVDS) is a compact variant of the SVD, which was developed in the early 1990s. It features a tubular metal stock that folds to the right side of the receiver and a synthetic pistol grip."
    ItemName="SVDS"
    ItemShortName="SVDS"
    AmmoItemName="7.64x54mm"
    CorrespondingPerkIndex=2
    EquipmentCategoryID=2
    InventoryType=Class'NicePack.NiceSVDS'
    PickupMessage="You've got the Dragunov Sniper Rifle (SVDS)"
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'ScrnWeaponPack_SM.svd_c'
    CollisionRadius=30.000000
    CollisionHeight=5.000000
}
