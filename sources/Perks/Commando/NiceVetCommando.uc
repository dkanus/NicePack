class NiceVetCommando extends NiceVeterancyTypes
    abstract;
static function AddCustomStats(ClientPerkRepLink Other){
    other.AddCustomValue(Class'NiceVetCommandoExp');
}
static function int GetStatValueInt(ClientPerkRepLink StatOther, byte ReqNum){
    return StatOther.GetCustomValueInt(Class'NiceVetCommandoExp');
}
static function array<int> GetProgressArray(byte ReqNum, optional out int DoubleScalingBase){
    return default.progressArray0;
}
static function float GetHealthBarsDistanceMulti(KFPlayerReplicationInfo KFPRI){
    if(KFPRI != none && SomeoneHasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillCommandoStrategist'))
       return class'NiceSkillCommandoStrategist'.default.visionRadius;
    return 0.0;
}
static function float GetStalkerViewDistanceMulti(KFPlayerReplicationInfo KFPRI){
    if(KFPRI != none && SomeoneHasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillCommandoStrategist'))
       return class'NiceSkillCommandoStrategist'.default.visionRadius;
    return 0.0;
}
static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other){
    local class<NiceWeaponPickup> pickupClass;
    pickupClass = GetPickupFromWeapon(other.class);
    if(IsPerkedPickup(pickupClass) && HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillCommandoLargerMags'))
       return class'NiceSkillCommandoLargerMags'.default.sizeBonus;
    return 1.0;
}
static function float GetReloadSpeedModifierStatic(KFPlayerReplicationInfo KFPRI, class<KFWeapon> Other){
    return 1.3;
}
static function int ZedTimeExtensions(KFPlayerReplicationInfo KFPRI){
    if(HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillCommandoTactitian'))
       return class'NiceSkillCommandoTactitian'.default.bonusExt + 3;
    return 3;
}
static function string GetCustomLevelInfo(byte Level){
    return default.CustomLevelInfo;
}
defaultproperties
{
    bNewTypePerk=True
    SkillGroupA(0)=Class'NicePack.NiceSkillCommandoTactitian'
    SkillGroupA(1)=Class'NicePack.NiceSkillCommandoCriticalFocus'
    SkillGroupA(2)=Class'NicePack.NiceSkillCommandoLargerMags'
    SkillGroupA(3)=Class'NicePack.NiceSkillCommandoPerfectExecution'
    SkillGroupA(4)=Class'NicePack.NiceSkillCommandoZEDProfessional'
    SkillGroupB(0)=Class'NicePack.NiceSkillCommandoStrategist'
    SkillGroupB(1)=Class'NicePack.NiceSkillCommandoTrashCleaner'
    SkillGroupB(2)=Class'NicePack.NiceSkillCommandoExplosivePower'
    SkillGroupB(3)=Class'NicePack.NiceSkillCommandoGiantSlayer'
    SkillGroupB(4)=Class'NicePack.NiceSkillCommandoZEDEvisceration'
    progressArray0(0)=100
    progressArray0(1)=1000
    progressArray0(2)=3000
    progressArray0(3)=10000
    progressArray0(4)=30000
    progressArray0(5)=100000
    progressArray0(6)=200000
    DefaultDamageType=Class'NicePack.NiceDamageTypeVetCommando'
    OnHUDIcons(0)=(PerkIcon=Texture'KillingFloorHUD.Perks.Perk_Commando',StarIcon=Texture'KillingFloorHUD.HUD.Hud_Perk_Star',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(1)=(PerkIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Commando_Gold',StarIcon=Texture'KillingFloor2HUD.Perk_Icons.Hud_Perk_Star_Gold',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(2)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Commando_Green',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Green',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(3)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Commando_Blue',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Blue',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(4)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Commando_Purple',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Purple',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(5)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Commando_Orange',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Orange',DrawColor=(B=255,G=255,R=255,A=255))
    CustomLevelInfo="Level up by doing damage with perked weapons|30% faster reload with all weapons|You get three additional Zed-Time Extensions"
    PerkIndex=3
    OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Commando'
    OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Commando_Gold'
    VeterancyName="Commando"
    Requirements(0)="Required experience for the next level: %x"
}
