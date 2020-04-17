class NiceSinglePickup extends NiceWeaponPickup;
function Inventory SpawnCopy(Pawn other){
    local Inventory CurInv;
    local NiceWeapon PistolInInventory;
    for(CurInv = other.Inventory;CurInv != none;CurInv = CurInv.Inventory){
       PistolInInventory = NiceWeapon(CurInv);
       if(PistolInInventory != none && PistolInInventory.class == default.InventoryType){
           // Make dualies to cost twice of lowest value in case of PERKED+UNPERKED pistols
           SellValue = 2 * min(SellValue, PistolInInventory.SellValue);
           AmmoAmount[0] += PistolInInventory.AmmoAmount(0);
           class'NicePlainData'.static.SetInt(weaponData, "leftMag", MagAmmoRemaining);
           class'NicePlainData'.static.SetInt(weaponData, "rightMag", PistolInInventory.MagAmmoRemaining);
           // destroy the inventory to force parent SpawnCopy() to make a new instance of class
           // we specified below
           if(Inventory != none)
               Inventory.Destroy();
           // spawn dual guns instead of another instance of single
           if(class<NiceSingle>(default.InventoryType) != none)
               InventoryType = class<NiceSingle>(default.InventoryType).default.DualClass;
           if(CurInv != none){
               CurInv.Destroyed();
               CurInv.Destroy();
           }
           return super(KFWeaponPickup).SpawnCopy(other);
       }
    }
    InventoryType = default.InventoryType;
    return super(KFWeaponPickup).SpawnCopy(other);
}
function bool CheckCanCarry(KFHumanPawn Hm){
    local Inventory CurInv;
    local class<NiceWeapon> dualClass;
    local float AddWeight;
    AddWeight = class<KFWeapon>(default.InventoryType).default.Weight;
    if(class<NiceWeapon>(default.InventoryType) != none)
       dualClass = class<NiceSingle>(default.InventoryType).default.dualClass;
    for(CurInv = Hm.Inventory; CurInv != none; CurInv = CurInv.Inventory){
       if(CurInv.class == dualClass) {
           // Already have duals, can't carry a single
           if(LastCantCarryTime < Level.TimeSeconds && PlayerController(Hm.Controller) != none){
               LastCantCarryTime = Level.TimeSeconds + 0.5;
               PlayerController(Hm.Controller).ReceiveLocalizedMessage(Class'KFMainMessages', 2);
           }
           return false; 
       }
       else if(CurInv.class == default.InventoryType && dualClass != none){
           AddWeight = dualClass.default.Weight - AddWeight;
           break;
       }
    }
    if(!Hm.CanCarry(AddWeight)){
       if(LastCantCarryTime < Level.TimeSeconds && PlayerController(Hm.Controller) != none){
           LastCantCarryTime = Level.TimeSeconds + 0.5;
           PlayerController(Hm.Controller).ReceiveLocalizedMessage(Class'KFMainMessages', 2);
       }
       return false;
    }
    return true;
}

defaultproperties
{
     Weight=0.000000
     cost=150
     AmmoCost=10
     BuyClipSize=30
     PowerValue=20
     SpeedValue=50
     RangeValue=35
     Description="A 9mm handgun."
     ItemName="!!!"
     ItemShortName="!!!"
     AmmoItemName="9mm Rounds"
     AmmoMesh=StaticMesh'KillingFloorStatics.DualiesAmmo'
     CorrespondingPerkIndex=2
     EquipmentCategoryID=1
     InventoryType=Class'NicePack.NiceSingle'
     PickupMessage="You got the 9mm handgun"
     PickupSound=Sound'KF_9MMSnd.9mm_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.pistol.9mm_Pickup'
     CollisionHeight=5.000000
}
