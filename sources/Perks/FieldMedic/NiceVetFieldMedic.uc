class NiceVetFieldMedic extends NiceVeterancyTypes
    abstract;
static function AddCustomStats(ClientPerkRepLink Other){
    Other.AddCustomValue(Class'NiceVetFieldMedicExp');
}
static function int GetStatValueInt(ClientPerkRepLink StatOther, byte ReqNum){
    return StatOther.GetCustomValueInt(Class'NiceVetFieldMedicExp');
}
static function array<int> GetProgressArray(byte ReqNum, optional out int DoubleScalingBase){
    return default.progressArray0;
}
// Allows to increase head-shot check scale for some weapons.
static function float GetHeadshotCheckMultiplier(KFPlayerReplicationInfo KFPRI, class<DamageType> DmgType){
    if(KFPRI != none && class'NiceVetFieldMedic'.static.hasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillMedicAimAssistance'))       return class'NiceSkillMedicAimAssistance'.default.headIncrease;
    return 1.0;
}
// Give Medic normal hand nades again - he should buy medic nade lauchers for healing nades
static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI){
    if(KFPRI != none && class'NiceVetFieldMedic'.static.hasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillMedicArmament'))       return class'NicePack.NiceMedicNade';
    return class'NiceMedicNadePoison';
}
static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other){
    if(other != none && other.class == class'FragAmmo'       && KFPRI != none && class'NiceVetFieldMedic'.static.hasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillMedicArmament'))       return 0.0;
    return 1.0;
}
//can't cook medic nades
static function bool CanCookNade(KFPlayerReplicationInfo KFPRI, Weapon Weap){
    return GetNadeType(KFPRI) != class'NicePack.NiceMedicNade';
}
static function float GetSyringeChargeRate(KFPlayerReplicationInfo KFPRI){
    return 3.0;
}
static function float GetHealPotency(KFPlayerReplicationInfo KFPRI){
    local float potency, debuff;
    potency = 2.0;
    debuff = 0.0;
    if(KFPRI != none && class'NiceVetFieldMedic'.static.hasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillMedicTranquilizer'))       debuff += class'NiceSkillMedicTranquilizer'.default.healingDebuff;
    potency *= (1.0 - debuff);
    return potency;
}
static function float GetFireSpeedModStatic(KFPlayerReplicationInfo KFPRI, class<Weapon> Other){
    if(ClassIsChildOf(Other, class'Syringe'))       return 1.6;
    return 1.0;
}
static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI){
    return 1.2;
}
static function float SlowingModifier(KFPlayerReplicationInfo KFPRI){
    return 1.5;
}
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item){
    local class<NiceWeaponPickup> pickupClass;
    pickupClass = class<NiceWeaponPickup>(Item);
    if(IsPerkedPickup(class<NiceWeaponPickup>(Item)))       return 0.5;
    return 1.0;
}
static function string GetCustomLevelInfo(byte Level){
    return default.CustomLevelInfo;
}
defaultproperties
{    SkillGroupA(0)=Class'NicePack.NiceSkillMedicSymbioticHealth'    SkillGroupA(1)=Class'NicePack.NiceSkillMedicArmament'    SkillGroupA(2)=Class'NicePack.NiceSkillMedicAdrenalineShot'    SkillGroupA(3)=Class'NicePack.NiceSkillMedicInjection'    SkillGroupA(4)=Class'NicePack.NiceSkillMedicZEDHeavenCanceller'    SkillGroupB(0)=Class'NicePack.NiceSkillMedicAimAssistance'    SkillGroupB(1)=Class'NicePack.NiceSkillMedicPesticide'    SkillGroupB(2)=Class'NicePack.NiceSkillMedicRegeneration'    SkillGroupB(3)=Class'NicePack.NiceSkillMedicTranquilizer'    SkillGroupB(4)=Class'NicePack.NiceSkillMedicZEDFrenzy'    progressArray0(0)=100    progressArray0(1)=1000    progressArray0(2)=3000    progressArray0(3)=10000    progressArray0(4)=30000    progressArray0(5)=100000    progressArray0(6)=200000    OnHUDIcons(0)=(PerkIcon=Texture'KillingFloorHUD.Perks.Perk_Medic',StarIcon=Texture'KillingFloorHUD.HUD.Hud_Perk_Star',DrawColor=(B=255,G=255,R=255,A=255))    OnHUDIcons(1)=(PerkIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Medic_Gold',StarIcon=Texture'KillingFloor2HUD.Perk_Icons.Hud_Perk_Star_Gold',DrawColor=(B=255,G=255,R=255,A=255))    OnHUDIcons(2)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Medic_Green',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Green',DrawColor=(B=255,G=255,R=255,A=255))    OnHUDIcons(3)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Medic_Blue',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Blue',DrawColor=(B=255,G=255,R=255,A=255))    OnHUDIcons(4)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Medic_Purple',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Purple',DrawColor=(B=255,G=255,R=255,A=255))    OnHUDIcons(5)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Medic_Orange',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Orange',DrawColor=(B=255,G=255,R=255,A=255))    CustomLevelInfo="Level up by doing damage with perked weapons|50% discount on everything|100% more potent medical injections|20% faster movement speed|Better Syringe handling"    PerkIndex=0    OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Medic'    OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Medic_Gold'    VeterancyName="Field Medic"    Requirements(0)="Required experience for the next level: %x"
}
