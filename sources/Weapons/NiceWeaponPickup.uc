class NiceWeaponPickup extends KFWeaponPickup
    dependson(NicePlainData)
    placeable;

var bool        bBackupWeapon;
var array<int>  crossPerkIndecies;  // List of indices for perks that also should recive bonuses from this weapon
// Data that should be transferred between various instances of 'NiceWeapon' classes, corresponding to this pickup class
var NicePlainData.Data weaponData;
simulated function NicePlainData.Data GetNiceData(){
    return weaponData;
}
simulated function SetNiceData(NicePlainData.Data newData){
    weaponData = newData;
}
simulated function InitDroppedPickupFor(Inventory Inv){
    local NiceWeapon niceWeap;
    niceWeap = NiceWeapon(Inv);
    if(niceWeap != none)
       SetNiceData(niceWeap.GetNiceData());
    // Do as usual
    if(Role == ROLE_Authority)
       super.InitDroppedPickupFor(Inv);
}
function Destroyed(){
    if(bDropped && Inventory != none && class<Weapon>(Inventory.Class) != none && KFGameType(Level.Game) != none)
       KFGameType(Level.Game).WeaponDestroyed(class<Weapon>(Inventory.Class));
    super(WeaponPickup).Destroyed();
}

defaultproperties
{
     cost=1000
}
