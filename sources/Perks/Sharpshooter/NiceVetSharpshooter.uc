class NiceVetSharpshooter extends NiceVeterancyTypes
    dependson(NiceAbilityManager)
    abstract;
static function AddCustomStats(ClientPerkRepLink Other){
    Other.AddCustomValue(Class'NiceVetSharpshooterExp');
}
static function int GetStatValueInt(ClientPerkRepLink StatOther, byte ReqNum){
    return StatOther.GetCustomValueInt(Class'NiceVetSharpshooterExp');
}
static function array<int> GetProgressArray(byte ReqNum, optional out int DoubleScalingBase){
    return default.progressArray0;
}
static function float GetNiceHeadShotDamMulti(KFPlayerReplicationInfo KFPRI, NiceMonster zed, class<DamageType> DmgType){
    local float ret;
    local NicePlayerController nicePlayer;
    local NiceHumanPawn nicePawn;
    local float calibratedTalentBonus;
    local class<NiceWeaponPickup> pickupClass;
    if(class<DamTypeMelee>(DmgType) != none || class<NiceDamageTypeVetBerserker>(DmgType) != none)
       return 1.0;
    ret = 1.0;
    if(KFPRI != none)
       nicePlayer = NicePlayerController(KFPRI.Owner);
    pickupClass = GetPickupFromDamageType(DmgType);
   if(nicePlayer != none)
      nicePawn = NiceHumanPawn(nicePlayer.pawn);
   //if(IsPerkedPickup(pickupClass)){
   ret += 0.25;
   if(nicePawn != none && class'NiceVetSharpshooter'.static.hasSkill(nicePlayer, class'NiceSkillSharpshooterTalent')){
      calibratedTalentBonus = 0.1f * Min(nicePawn.calibrationScore, 3);
      ret *= (1.0 + calibratedTalentBonus);
   }
   //}
    return ret;
}
static function float GetReloadSpeedModifierStatic(KFPlayerReplicationInfo KFPRI, class<KFWeapon> Other){
    local float reloadMult;
    //local float reloadScale;
    local NicePlayerController nicePlayer;
    local NiceHumanPawn nicePawn;
    local float calibratedReloadBonus;
    local class<NiceWeaponPickup> pickupClass;
    pickupClass = GetPickupFromWeapon(Other);
    if(KFPRI != none)
       nicePlayer = NicePlayerController(KFPRI.Owner);
    reloadMult = 1.0;
   if(nicePlayer != none)
      nicePawn = NiceHumanPawn(nicePlayer.pawn);
    if(nicePlayer != none && nicePawn != none && class'NiceVetSharpshooter'.static.hasSkill(nicePlayer, class'NiceSkillSharpshooterHardWork')){
       //reloadScale = VSize(nicePlayer.pawn.velocity) / nicePlayer.pawn.groundSpeed;
       //reloadScale = 1.0 - reloadScale;
      if(nicePawn.calibrationScore >= 3)
         calibratedReloadBonus = class'NiceSkillSharpshooterHardWork'.default.reloadBonus;
      else if(nicePawn.calibrationScore == 2)
         calibratedReloadBonus = 0.5f * class'NiceSkillSharpshooterHardWork'.default.reloadBonus;
      else
         calibratedReloadBonus = 0.25f * class'NiceSkillSharpshooterHardWork'.default.reloadBonus;
      reloadMult *= 1.0 + calibratedReloadBonus;
    }
    if(     nicePlayer != none && nicePlayer.abilityManager != none
       &&  nicePlayer.abilityManager.IsAbilityActive(class'NiceSkillSharpshooterGunslingerA'.default.abilityID)){
       reloadMult *= class'NiceSkillSharpshooterGunslingerA'.default.reloadMult;
    }
    return reloadMult;
}
static function float GetFireSpeedModStatic(KFPlayerReplicationInfo KFPRI, class<Weapon> other){
    local float fireRateMult;
    local NicePlayerController nicePlayer;
    local NiceHumanPawn nicePawn;
    local float calibratedFireSpeedBonus;
    if(KFPRI != none)
       nicePlayer = NicePlayerController(KFPRI.Owner);
    fireRateMult = 1.0;
    if(nicePlayer != none)
      nicePawn = NiceHumanPawn(nicePlayer.pawn);
   if(nicePawn != none && class'NiceVetSharpshooter'.static.hasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillSharpshooterHardWork')){
      if(nicePawn.calibrationScore >= 3)
      calibratedFireSpeedBonus = class'NiceSkillSharpshooterHardWork'.default.fireRateBonus;
      else if(nicePawn.calibrationScore == 2)
      calibratedFireSpeedBonus = (2.0f/3.0f) * class'NiceSkillSharpshooterHardWork'.default.fireRateBonus;
      else
      calibratedFireSpeedBonus = (1.0f/3.0f) * class'NiceSkillSharpshooterHardWork'.default.fireRateBonus;
       fireRateMult *= 1.0f + calibratedFireSpeedBonus;
   }
    if(     nicePlayer != none && nicePlayer.abilityManager != none
       &&  nicePlayer.abilityManager.IsAbilityActive(class'NiceSkillSharpshooterGunslingerA'.default.abilityID)){
       fireRateMult *= class'NiceSkillSharpshooterGunslingerA'.default.fireRateMult;
    }
    return fireRateMult;
}
static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil){
    local NicePlayerController nicePlayer;
    if(KFPRI != none)
       nicePlayer = NicePlayerController(KFPRI.Owner);
    Recoil = 1.0;
    if(HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillSharpshooterHardWork'))
       Recoil = class'NiceSkillSharpshooterHardWork'.default.recoilMult;
    if(     nicePlayer != none && nicePlayer.abilityManager != none
       &&  nicePlayer.abilityManager.IsAbilityActive(class'NiceSkillSharpshooterGunslingerA'.default.abilityID))
       Recoil = 0;
    return Recoil;
}
static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
    local NicePlayerController nicePlayer;
    if(KFPRI != none)
       nicePlayer = NicePlayerController(KFPRI.Owner);
    if(     nicePlayer != none && nicePlayer.abilityManager != none
       &&  nicePlayer.abilityManager.IsAbilityActive(class'NiceSkillSharpshooterGunslingerA'.default.abilityID))
       return class'NiceSkillSharpshooterGunslingerA'.default.movementMult;
    return 1.0;
}
static function string GetCustomLevelInfo(byte Level){
    return default.CustomLevelInfo;
}
static function SetupAbilities(KFPlayerReplicationInfo KFPRI){
    local NicePlayerController                      nicePlayer;
    local NiceAbilityManager.NiceAbilityDescription calibration;
    if(KFPRI != none)
       nicePlayer = NicePlayerController(KFPRI.Owner);
    if(nicePlayer == none || nicePlayer.abilityManager == none)
       return;
    calibration.ID   = "Calibration";
    //gigaSlayer.icon = Texture'NicePackT.HudCounter.t4th';
    calibration.icon = Texture'NicePackT.HudCounter.zedHeadStreak';
    calibration.cooldownLength = 30.0;
    calibration.canBeCancelled = false;
    nicePlayer.abilityManager.AddAbility(calibration);
}
defaultproperties
{
    bNewTypePerk=True
    SkillGroupA(0)=Class'NicePack.NiceSkillSharpshooterKillConfirmed'
    SkillGroupA(1)=Class'NicePack.NiceSkillSharpshooterTalent'
    SkillGroupA(2)=Class'NicePack.NiceSkillSharpshooterDieAlready'
    SkillGroupA(3)=Class'NicePack.NiceSkillSharpshooterReaperA'
    SkillGroupA(4)=Class'NicePack.NiceSkillSharpshooterZEDAdrenaline'
    SkillGroupB(0)=Class'NicePack.NiceSkillSharpshooterSurgical'
    SkillGroupB(1)=Class'NicePack.NiceSkillSharpshooterHardWork'
    SkillGroupB(2)=Class'NicePack.NiceSkillSharpshooterArdour'
    SkillGroupB(3)=Class'NicePack.NiceSkillSharpshooterGunslingerA'
    SkillGroupB(4)=Class'NicePack.NiceSkillSharpshooterZEDHundredGauntlets'
    progressArray0(0)=100
    progressArray0(1)=1000
    progressArray0(2)=3000
    progressArray0(3)=10000
    progressArray0(4)=30000
    progressArray0(5)=100000
    progressArray0(6)=200000
    DefaultDamageType=Class'NicePack.NiceDamageTypeVetSharpshooter'
    OnHUDIcons(0)=(PerkIcon=Texture'KillingFloorHUD.Perks.Perk_SharpShooter',StarIcon=Texture'KillingFloorHUD.HUD.Hud_Perk_Star',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(1)=(PerkIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_SharpShooter_Gold',StarIcon=Texture'KillingFloor2HUD.Perk_Icons.Hud_Perk_Star_Gold',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(2)=(PerkIcon=Texture'ScrnTex.Perks.Perk_SharpShooter_Green',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Green',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(3)=(PerkIcon=Texture'ScrnTex.Perks.Perk_SharpShooter_Blue',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Blue',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(4)=(PerkIcon=Texture'ScrnTex.Perks.Perk_SharpShooter_Purple',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Purple',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(5)=(PerkIcon=Texture'ScrnTex.Perks.Perk_SharpShooter_Orange',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Orange',DrawColor=(B=255,G=255,R=255,A=255))
    CustomLevelInfo="Level up by doing headshots with perked weapons|+25% headshot damage"
    PerkIndex=2
    OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_SharpShooter'
    OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_SharpShooter_Gold'
    VeterancyName="Sharpshooter"
    Requirements(0)="Required experience for the next level: %x"
}
