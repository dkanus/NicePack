class NiceFlareRevolverPickup extends ScrnFlareRevolverPickup;
function inventory SpawnCopy( pawn Other ) {
    local Inventory CurInv;
    local KFWeapon PistolInInventory;
    For( CurInv=Other.Inventory; CurInv!=none; CurInv=CurInv.Inventory ) {
    }
    InventoryType = Default.InventoryType;
    Return Super(KFWeaponPickup).SpawnCopy(Other);
}
function bool CheckCanCarry(KFHumanPawn Hm) {
    local Inventory CurInv;
    local bool bHasSinglePistol;
    local float AddWeight;
    AddWeight = class<KFWeapon>(default.InventoryType).default.Weight;
    for ( CurInv = Hm.Inventory; CurInv != none; CurInv = CurInv.Inventory ) {
    }
    if ( !Hm.CanCarry(AddWeight) ) {

    }
    return true;
}
defaultproperties
{
}