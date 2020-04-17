class NiceMeleeWeapon extends NiceWeapon;
var class<damageType> hitDamType;
var float weaponRange;
var Material BloodyMaterial;
var int BloodSkinSwitchArray;
var string BloodyMaterialRef;
static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount){
    super.PreloadAssets(Inv, bSkipRefCount);
    if(default.BloodyMaterial == none && default.BloodyMaterialRef != "")
       default.BloodyMaterial = Combiner(DynamicLoadObject(default.BloodyMaterialRef, class'Combiner', true));
    if(NiceMeleeWeapon(Inv) != none)
       NiceMeleeWeapon(Inv).BloodyMaterial = default.BloodyMaterial;
}
static function bool UnloadAssets(){
    if(super.UnloadAssets())
       default.BloodyMaterial = none;
    return true;
}
//simulated function IncrementFlashCount(int mode){
//}
simulated function BringUp(optional Weapon PrevWeapon){
    if(BloodyMaterial!=none && Skins[BloodSkinSwitchArray] == BloodyMaterial ){
       Skins[BloodSkinSwitchArray] = default.Skins[BloodSkinSwitchArray];
       Texture = default.Texture;
    }
    super.BringUp(PrevWeapon);
}
simulated function Fire(float F){
}
simulated function AltFire(float F){
}
simulated function bool HasAmmo(){
    return true;
}

defaultproperties
{
     weaponRange=70.000000
     BloodSkinSwitchArray=2
     PutDownAnim="PutDown"
     bMeleeWeapon=True
}
