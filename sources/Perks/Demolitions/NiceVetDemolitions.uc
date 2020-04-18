class NiceVetDemolitions extends NiceVeterancyTypes
    abstract;
static function AddCustomStats(ClientPerkRepLink Other){
    other.AddCustomValue(Class'NiceVetDemolitionsExp');
}
static function int GetStatValueInt(ClientPerkRepLink StatOther, byte ReqNum){
    return StatOther.GetCustomValueInt(Class'NiceVetDemolitionsExp');
}
static function array<int> GetProgressArray(byte ReqNum, optional out int DoubleScalingBase){
    return default.progressArray0;
}
static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType){
    local NicePlayerController nicePlayer;
    if(class<NiceDamTypeDemoSafeExplosion>(DmgType) != none)
       return 0;
    nicePlayer = NicePlayerController(KFPRI.Owner);
    if(nicePlayer != none && Instigator == nicePlayer.pawn && nicePlayer.IsZedTimeActive()
       && HasSkill(nicePlayer, class'NiceSkillDemoZEDDuckAndCover'))
       return 0.0;
    if((class<KFWeaponDamageType>(DmgType) != none && class<KFWeaponDamageType>(DmgType).default.bIsExplosive))
       return float(InDamage) * 0.5;
    return InDamage;
}
static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType){
    local float bonusNades, bonusPipes;
    // Default bonus
    bonusNades = 5;
    bonusPipes = 6;
    if(AmmoType == class'FragAmmo')
       return 1.0 + 0.2 * bonusNades;
    if(ClassIsChildOf(AmmoType, class'PipeBombAmmo'))
       return 1.0 + 0.5 * bonusPipes;
    return 1.0;
}
static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType){
    local float perkDamage;
    local class<NiceWeaponPickup> pickupClass;
    pickupClass = GetPickupFromDamageType(DmgType);
    perkDamage = float(InDamage);
    if(DmgType == class'NicePack.NiceDamTypeDemoExplosion')
       return 1.6 * perkDamage;
    if(IsPerkedPickup(pickupClass))
       perkDamage *= 1.25;
    else if( pickupClass != none && pickupClass.default.weight <= class'NiceSkillDemoOffperk'.default.weightBound
       && HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillDemoOffperk') )
       perkDamage *= class'NiceSkillDemoOffperk'.default.damageBonus;
    if( KFPRI != none && class<NiceDamTypeDemoBlunt>(DmgType) != none
       && SomeoneHasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillDemoOnperk') )
       perkDamage *= class'NiceSkillDemoOnperk'.default.damageBonus;
    return perkDamage;
}
static function float GetReloadSpeedModifierStatic(KFPlayerReplicationInfo KFPRI, class<KFWeapon> other){
    local NiceHumanPawn nicePawn;
    local class<NiceWeaponPickup> pickupClass;
    // Pistols reload
    if( other != none && other.default.weight <= class'NiceSkillDemoOffperk'.default.weightBound
       && HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillDemoOffperk') )
       return class'NiceSkillDemoOffperk'.default.reloadBonus;
    // Maniac reload
    pickupClass = GetPickupFromWeapon(other);
    if(KFPRI != none && PlayerController(KFPRI.Owner) != none)
       nicePawn = NiceHumanPawn(PlayerController(KFPRI.Owner).Pawn);
    if(nicePawn != none && nicePawn.maniacTimeout >= 0.0 && IsPerkedPickup(pickupClass))
       return class'NiceSkillDemoManiac'.default.reloadSpeedup;
    return 1.0;
}
static function float stunDurationMult(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, class<NiceWeaponDamageType> DmgType){
    if(HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillDemoConcussion'))
       return class'NiceSkillDemoConcussion'.default.durationMult;
    return 1.0;
}
static function int AddStunScore(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InStunScore, class<NiceWeaponDamageType> DmgType){
    return int(float(InStunScore) * 1.5);
}
static function int AddFlinchScore(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InFlinchScore, class<NiceWeaponDamageType> DmgType){
    return int(float(InFlinchScore) * 1.5);
}
static function string GetCustomLevelInfo(byte Level){
    return default.CustomLevelInfo;
}
defaultproperties
{
    bNewTypePerk=True
    SkillGroupA(0)=Class'NicePack.NiceSkillDemoOnperk'
    SkillGroupA(1)=Class'NicePack.NiceSkillDemoDirectApproach'
    SkillGroupA(2)=Class'NicePack.NiceSkillDemoConcussion'
    SkillGroupA(3)=Class'NicePack.NiceSkillDemoAPShot'
    SkillGroupA(4)=Class'NicePack.NiceSkillDemoZEDDuckAndCover'
    SkillGroupB(0)=Class'NicePack.NiceSkillDemoOffperk'
    SkillGroupB(1)=Class'NicePack.NiceSkillDemoVolatile'
    SkillGroupB(2)=Class'NicePack.NiceSkillDemoReactiveArmor'
    SkillGroupB(3)=Class'NicePack.NiceSkillDemoManiac'
    SkillGroupB(4)=Class'NicePack.NiceSkillDemoZEDFullBlast'
    progressArray0(0)=100
    progressArray0(1)=1000
    progressArray0(2)=3000
    progressArray0(3)=10000
    progressArray0(4)=30000
    progressArray0(5)=100000
    progressArray0(6)=200000
    DefaultDamageType=Class'NicePack.NiceDamageTypeVetDemolitions'
    OnHUDIcons(0)=(PerkIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Demolition',StarIcon=Texture'KillingFloorHUD.HUD.Hud_Perk_Star',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(1)=(PerkIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Demolition_Gold',StarIcon=Texture'KillingFloor2HUD.Perk_Icons.Hud_Perk_Star_Gold',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(2)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Demolition_Green',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Green',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(3)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Demolition_Blue',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Blue',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(4)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Demolition_Purple',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Purple',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(5)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Demolition_Orange',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Orange',DrawColor=(B=255,G=255,R=255,A=255))
    CustomLevelInfo="Level up by doing damage with perked weapons|25% extra explosives damage|50% better stun and flinch ability for all weapons|50% resistance to explosives|+5 grenades|+6 pipe bombs"
    PerkIndex=6
    OnHUDIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Demolition'
    OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Demolition_Gold'
    VeterancyName="Demolitions"
    Requirements(0)="Required experience for the next level: %x"
}
