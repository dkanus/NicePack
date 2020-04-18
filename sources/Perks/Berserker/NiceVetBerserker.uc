class NiceVetBerserker extends NiceVeterancyTypes
    abstract;
static function AddCustomStats(ClientPerkRepLink Other){
    other.AddCustomValue(Class'NiceVetBerserkerExp');
}
static function int GetStatValueInt(ClientPerkRepLink StatOther, byte ReqNum){
    return StatOther.GetCustomValueInt(Class'NiceVetBerserkerExp');
}
static function array<int> GetProgressArray(byte ReqNum, optional out int DoubleScalingBase){
    return default.progressArray0;
}
static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType){
    local float perkDamage;
    local class<NiceWeaponPickup> pickupClass;
    pickupClass = GetPickupFromDamageType(DmgType);
    perkDamage = float(InDamage);
    if(IsPerkedPickup(pickupClass))
       perkDamage *= 2;
    return perkDamage;
}
static function float GetFireSpeedModStatic(KFPlayerReplicationInfo KFPRI, class<Weapon> other){
    local float bonus;
    local class<NiceWeaponPickup> pickupClass;
    local NiceHumanPawn nicePawn;
    local NicePlayerController nicePlayer;
    pickupClass = GetPickupFromWeapon(other);
    bonus = 1.0;
    nicePlayer = NicePlayerController(KFPRI.Owner);
    if(IsPerkedPickup(pickupClass))
       bonus *= 1.25;
    nicePawn = NiceHumanPawn(nicePlayer.Pawn);
    if(nicePlayer != none && nicePawn != none && HasSkill(nicePlayer, class'NiceSkillZerkFury') && IsPerkedPickup(pickupClass)){
       if(nicePawn != none && nicePawn.invincibilityTimer > 0.0)
           bonus *= class'NiceSkillZerkFury'.default.attackSpeedBonus;
    }
    if(nicePlayer != none && nicePawn != none && nicePlayer.IsZedTimeActive() && IsPerkedPickup(pickupClass)
       && HasSkill(nicePlayer, class'NiceSkillZerkZEDAccelerate'))
       bonus /= (nicePawn.Level.TimeDilation / 1.1);
    return bonus;
}
static function float GetMeleeMovementSpeedModifier(KFPlayerReplicationInfo KFPRI){
    return 0.2;
}
static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
    local NicePlayerController nicePlayer;
    nicePlayer = NicePlayerController(KFPRI.Owner);
    if(nicePlayer != none && nicePlayer.IsZedTimeActive()
       && HasSkill(nicePlayer, class'NiceSkillZerkZEDAccelerate'))
       return 1.0 / fmin(1.0, (KFGRI.Level.TimeDilation / 1.1));
    return 1.0;
}
static function float GetWeaponMovementSpeedBonus(KFPlayerReplicationInfo KFPRI, Weapon Weap){
    local float bonus;
    local NicePlayerController nicePlayer;
    local NiceHumanPawn nicePawn;
    bonus = 0.0;
    nicePlayer = NicePlayerController(KFPRI.Owner);
    if(nicePlayer != none)
       nicePawn = NiceHumanPawn(nicePlayer.Pawn);
    if(nicePlayer != none && nicePawn != none && HasSkill(nicePlayer, class'NiceSkillZerkWhirlwind')){
       if(nicePawn != none && nicePawn.invincibilityTimer > 0.0)
           bonus = 1.0;
    }
    return bonus;
}
static function bool CanBeGrabbed(KFPlayerReplicationInfo KFPRI, KFMonster Other){
    return false;
}
// Set number times Zed Time can be extended
static function int ZedTimeExtensions(KFPlayerReplicationInfo KFPRI){
    return 4;
}
static function int GetInvincibilityExtentions(KFPlayerReplicationInfo KFPRI){
    return 3;
}
static function int GetInvincibilityDuration(KFPlayerReplicationInfo KFPRI){
    local NicePlayerController nicePlayer;
    nicePlayer = NicePlayerController(KFPRI.Owner);
    if(     nicePlayer != none
       &&  HasSkill(nicePlayer, class'NiceSkillZerkColossus')){
       return 3.0 + class'NiceSkillZerkColossus'.default.timeBonus;
    }
    return 3.0;
}
static function int GetInvincibilitySafeMisses(KFPlayerReplicationInfo KFPRI){
    local NicePlayerController nicePlayer;
    nicePlayer = NicePlayerController(KFPRI.Owner);
    if(     nicePlayer != none
       &&  HasSkill(nicePlayer, class'NiceSkillZerkUndead')){
       return 1 + class'NiceSkillZerkUndead'.default.addedSafeMisses;
    }
    return 1;
}
static function string GetCustomLevelInfo(byte Level){
    return default.CustomLevelInfo;
}
defaultproperties
{
    bNewTypePerk=True
    SkillGroupA(0)=Class'NicePack.NiceSkillZerkWindCutter'
    SkillGroupA(1)=Class'NicePack.NiceSkillZerkWhirlwind'
    SkillGroupA(2)=Class'NicePack.NiceSkillZerkColossus'
    SkillGroupA(3)=Class'NicePack.NiceSkillZerkUndead'
    SkillGroupA(4)=Class'NicePack.NiceSkillZerkZEDAccelerate'
    SkillGroupB(0)=Class'NicePack.NiceSkillZerkCleave'
    SkillGroupB(1)=Class'NicePack.NiceSkillZerkFury'
    SkillGroupB(2)=Class'NicePack.NiceSkillZerkGunzerker'
    SkillGroupB(3)=Class'NicePack.NiceSkillZerkVorpalBlade'
    SkillGroupB(4)=Class'NicePack.NiceSkillZerkZEDUnbreakable'
    progressArray0(0)=100
    progressArray0(1)=1000
    progressArray0(2)=3000
    progressArray0(3)=10000
    progressArray0(4)=30000
    progressArray0(5)=100000
    progressArray0(6)=200000
    DefaultDamageType=Class'NicePack.NiceDamageTypeVetBerserker'
    OnHUDIcons(0)=(PerkIcon=Texture'KillingFloorHUD.Perks.Perk_Berserker',StarIcon=Texture'KillingFloorHUD.HUD.Hud_Perk_Star',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(1)=(PerkIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Berserker_Gold',StarIcon=Texture'KillingFloor2HUD.Perk_Icons.Hud_Perk_Star_Gold',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(2)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Berserker_Green',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Green',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(3)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Berserker_Blue',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Blue',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(4)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Berserker_Purple',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Purple',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(5)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Berserker_Orange',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Orange',DrawColor=(B=255,G=255,R=255,A=255))
    CustomLevelInfo="Level up by doing damage with perked weapons|100% extra melee damage|25% faster melee attacks|20% faster melee movement|Melee invincibility lasts 3 seconds|Melee invincibility doesn't reset on your first miss|Up to 4 Zed-Time Extensions|Can't be grabbed by clots|Can activate melee-invincibility with non-decapitating head-shots up to 3 times"
    PerkIndex=4
    OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Berserker'
    OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Berserker_Gold'
    VeterancyName="Berserker"
    Requirements(0)="Required experience for the next level: %x"
}
