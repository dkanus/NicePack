class NiceVeterancyTypes extends ScrnVeterancyTypes
    dependson(NicePlayerController)
    abstract;
// Temporarily needed variable to distinguish between new and old type perks
var bool bNewTypePerk;
// Skills
var class<NiceSkill> SkillGroupA[5];
var class<NiceSkill> SkillGroupB[5];
// Checks if player is can use given skill
static function bool CanUseSkill(NicePlayerController nicePlayer, class<NiceSkill> skill){
    local int i;
    local int currentLevel;
    local KFPlayerReplicationInfo KFPRI;
    local class<NiceVeterancyTypes> niceVet;
    // Get necessary variables
    KFPRI = KFPlayerReplicationInfo(nicePlayer.PlayerReplicationInfo);
    if(KFPRI == none)
       return false;
    niceVet = GetVeterancy(nicePlayer.PlayerReplicationInfo);
    currentLevel = GetClientVeteranSkillLevel(KFPRI);
    // Check if we have that skill at appropriate level
    for(i = 0;i < 5 && i < currentLevel;i ++)
       if(niceVet.default.SkillGroupA[i] == skill || niceVet.default.SkillGroupB[i] == skill)
           return true;
    return false;
}
// Checks if player is using given skill
static function bool HasSkill(NicePlayerController nicePlayer, class<NiceSkill> skill){
    local int i;
    local int currentLevel;
    local KFPlayerReplicationInfo KFPRI;
    local class<NiceVeterancyTypes> niceVet;
    local NicePlayerController.SkillChoices choices;
    // Get necessary variables
    if(nicePlayer == none || skill == none || !CanUseSkill(nicePlayer, skill))
       return false;
    KFPRI = KFPlayerReplicationInfo(nicePlayer.PlayerReplicationInfo);
    if(KFPRI == none)
       return false;
    currentLevel = GetClientVeteranSkillLevel(KFPRI);
    niceVet = GetVeterancy(nicePlayer.PlayerReplicationInfo);
    choices = nicePlayer.currentSkills[niceVet.default.PerkIndex];
    // Check our skill is chosen at some level; (since there shouldn't be any duplicates and it can be chosen at some level -> it's active)
    for(i = 0;i < 5 && i < currentLevel;i ++)
       if((niceVet.default.SkillGroupA[i] == skill && choices.isAltChoice[i] == 0)
           || (niceVet.default.SkillGroupB[i] == skill && choices.isAltChoice[i] > 0))
           return true;
    return false;
}
static function bool SomeoneHasSkill(NicePlayerController player, class<NiceSkill> skill){
    local int i;
    local Controller P;
    local NicePlayerController nicePlayer;
    if(player == none)
       return false;
    if(player.Pawn.Role == ROLE_Authority)
       for(P = player.Level.ControllerList; P != none; P = P.nextController){
           nicePlayer = NicePlayerController(P);
           if(nicePlayer != none && HasSkill(nicePlayer, skill) && nicePlayer.Pawn.Health > 0 && !nicePlayer.Pawn.bPendingDelete
               && nicePlayer.PlayerReplicationInfo.Team == player.PlayerReplicationInfo.Team)
               return true;
       }
    else for(i = 0;i < player.broadcastedSkills.Length;i ++)
           if(player.broadcastedSkills[i] == skill)
               return true;
    return false;
}
// Checks if player will automatically chose given skill at the next opportunity
static function bool IsSkillPending(NicePlayerController nicePlayer, class<NiceSkill> skill){
    local int i;
    local int currentLevel;
    local KFPlayerReplicationInfo KFPRI;
    local class<NiceVeterancyTypes> niceVet;
    local NicePlayerController.SkillChoices choices;
    // Get necessary variables
    if(nicePlayer == none || skill == none || !CanUseSkill(nicePlayer, skill))
       return false;
    KFPRI = KFPlayerReplicationInfo(nicePlayer.PlayerReplicationInfo);
    if(KFPRI == none)
       return false;
    currentLevel = GetClientVeteranSkillLevel(KFPRI);
    niceVet = GetVeterancy(nicePlayer.PlayerReplicationInfo);
    choices = nicePlayer.pendingSkills[niceVet.default.PerkIndex];
    // Check our skill is chosen at some level; (since there shouldn't be any duplicates and it can be chosen at some level -> it's active)
    for(i = 0;i < 5;i ++)
       if((niceVet.default.SkillGroupA[i] == skill && choices.isAltChoice[i] == 0)
           || (niceVet.default.SkillGroupB[i] == skill && choices.isAltChoice[i] > 0))
           return true;
    return false;
}
// Function that checks if given pickup class is marked as perked for current veterancy
static function bool IsPerkedPickup(class<NiceWeaponPickup> pickup){
    local int i;
    if(pickup == none)
       return false;
    if(pickup.default.CorrespondingPerkIndex == default.PerkIndex)
       return true;
    else for(i = 0;i < pickup.default.crossPerkIndecies.Length;i ++)
           if(pickup.default.crossPerkIndecies[i] == default.PerkIndex)
               return true;
    return false;
}
static function bool IsPickupLight(class<NiceWeaponPickup> pickup){
    if(pickup != none && pickup.default.Weight <= 8)
       return true;
    return false;
}
static function bool IsPickupBackup(class<NiceWeaponPickup> pickup){
    if(pickup != none && pickup.default.bBackupWeapon)
       return true;
    return false;
}

// Set of functions for obtaining a pickup class from various other classes, connected with it
static function class<NiceWeaponPickup> GetPickupFromWeapon(class<Weapon> inputClass){
    local class<NiceWeapon> niceWeaponClass;
    niceWeaponClass = class<NiceWeapon>(inputClass);
    if(niceWeaponClass == none)
       return none;
    return class<NiceWeaponPickup>(niceWeaponClass.default.PickupClass);
}
static function class<NiceWeaponPickup> GetPickupFromAmmo(Class<Ammunition> inputClass){
    local class<NiceAmmo> niceAmmoClass;
    niceAmmoClass = class<NiceAmmo>(inputClass);
    if(niceAmmoClass == none)
       return none;
    return niceAmmoClass.default.WeaponPickupClass;
}
static function class<NiceWeapon> GetWeaponFromAmmo(Class<Ammunition> inputClass){
    local class<NiceWeaponPickup> nicePickupClass;
    nicePickupClass = GetPickupFromAmmo(inputClass);
    if(nicePickupClass == none)
       return none;
    return class<NiceWeapon>(nicePickupClass.default.InventoryType);
}
static function class<NiceWeaponPickup> GetPickupFromDamageType(class<DamageType> inputClass){
    local class<NiceWeaponDamageType> niceDmgTypeClass;
    niceDmgTypeClass = class<NiceWeaponDamageType>(inputClass);
    if(niceDmgTypeClass == none)
       return none;
    return GetPickupFromWeapon(class<NiceWeapon>(niceDmgTypeClass.default.WeaponClass));
}
static function class<NiceWeaponPickup> GetPickupFromWeaponFire(WeaponFire fireInstance){
    local NiceFire niceFire;
    niceFire = NiceFire(fireInstance);
    if(niceFire == none)
       return none;
    return GetPickupFromAmmo(class<NiceAmmo>(niceFire.AmmoClass));
}
// Finds correct veterancy for a player
static function class<NiceVeterancyTypes> GetVeterancy(PlayerReplicationInfo PRI){
    local KFPlayerReplicationInfo KFPRI;
    KFPRI = KFPlayerReplicationInfo(PRI);
    if(KFPRI == none || KFPRI.ClientVeteranSkill == none)
       return none;
    return class<NiceVeterancyTypes>(KFPRI.ClientVeteranSkill);
}
// New perk progress function
static function int GetPerkProgressInt(ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum) {
    local int delta, highestFilled;
    local int filledLevels;
    local array<int> ProgressArray;
    local int DoubleScalingBase;
    if(!default.bNewTypePerk)
       return Super.GetPerkProgressInt(StatOther, FinalInt, CurLevel, ReqNum);
    else{
       ProgressArray = GetProgressArray(ReqNum, DoubleScalingBase);
       filledLevels = ProgressArray.Length;
       if(filledLevels > 1)
           delta = ProgressArray[filledLevels - 1] - ProgressArray[filledLevels - 2];
       else if(filledLevels == 1)
           delta = ProgressArray[0];
       else
           delta = 10;
       if(filledLevels > 0)
           highestFilled = ProgressArray[filledLevels - 1];
       else
           highestFilled = 10;
       if(CurLevel < filledLevels)
           FinalInt = ProgressArray[CurLevel];
       else
           FinalInt = highestFilled + (CurLevel - filledLevels) * delta;
    }
    return Min(GetStatValueInt(StatOther, ReqNum), FinalInt);
}
// Get head-shot multiplier function that passes zed as a parameter
static function float GetNiceHeadShotDamMulti(KFPlayerReplicationInfo KFPRI, NiceMonster zed, class<DamageType> DmgType){
    return 1.0;
}
// From which distance can we see enemy's health at given level?
static function float GetMaxHealthDistanceByLevel(int level){
    return 0;
}
// From which distance can we see enemy's health?
static function float GetMaxHealthDistance(KFPlayerReplicationInfo KFPRI){
    return GetMaxHealthDistanceByLevel(GetClientVeteranSkillLevel(KFPRI));
}
// Allows to increase head-shot check scale for some weapons.
static function float GetHeadshotCheckMultiplier(KFPlayerReplicationInfo KFPRI, class<DamageType> DmgType){
    return 1.0;
}
// Allows to buff only regular component of damage.
static function int AddRegDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<NiceWeaponDamageType> DmgType){
    return InDamage;
}
// Allows to buff only fire component of damage.
static function int AddFireDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<NiceWeaponDamageType> DmgType){
    if(DmgType != none)
       return InDamage * DmgType.default.heatPart;
    return InDamage;
}
static function float stunDurationMult(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, class<NiceWeaponDamageType> DmgType){
    return 1.0;
}
static function int AddStunScore(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InStunScore, class<NiceWeaponDamageType> DmgType){
    return InStunScore;
}
static function int AddFlinchScore(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InFlinchScore, class<NiceWeaponDamageType> DmgType){
    return InFlinchScore;
}
// If pawn suffers from slow down effect, how much should we boost/lower it?
// 1.0 = leave the same, >1.0 = boost, <1.0 = lower.
static function float SlowingModifier(KFPlayerReplicationInfo KFPRI){
    return 1.0;
}
// Can player with this perk be pulled by a siren?
static function bool CanBePulled(KFPlayerReplicationInfo KFPRI){
    return true;
}
// What weight value should be used when calculation Pawn's speed?
static function float GetPerceivedWeight(KFPlayerReplicationInfo KFPRI, KFWeapon other){
    if(other != none)
       return other.weight;
    return 0;
}
// A new, universal, penetration reduction function that is used by all 'NiceWeapon' subclasses
static function float GetPenetrationDamageMulti(KFPlayerReplicationInfo KFPRI, float DefaultPenDamageReduction, class<NiceWeaponDamageType> fireIntance){
    return DefaultPenDamageReduction;
}
// Universal cost scaling for all perks
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item){
    /*local class<NiceWeaponPickup> pickupClass;
    pickupClass = class<NiceWeaponPickup>(Item);
    if(IsPerkedPickup(pickupClass))
       return 0.5;*/
    return 1.0;
}
static function bool ShowStalkers(KFPlayerReplicationInfo KFPRI){
    return GetStalkerViewDistanceMulti(KFPRI) > 0;
}
static function float GetStalkerViewDistanceMulti(KFPlayerReplicationInfo KFPRI){
    if(SomeoneHasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillCommandoStrategist'))
       return class'NiceSkillCommandoStrategist'.default.visionRadius;
    return 0.0;
}
// Modify distance at which health bars can be seen; 1.0 = 800 units, max = 2000 units = 2.5
static function float GetHealthBarsDistanceMulti(KFPlayerReplicationInfo KFPRI){
    if(KFPRI != none && SomeoneHasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillCommandoStrategist'))
       return class'NiceSkillCommandoStrategist'.default.visionRadius;
    return 0.0;
}
static function int GetAdditionalPenetrationAmount(KFPlayerReplicationInfo KFPRI){
    return 0;
}
static function int GetInvincibilityExtentions(KFPlayerReplicationInfo KFPRI){
    return 0;
}
static function int GetInvincibilityDuration(KFPlayerReplicationInfo KFPRI){
    return 2.0;
}
static function int GetInvincibilitySafeMisses(KFPlayerReplicationInfo KFPRI){
    return 0;
}
static function SpecialHUDInfo(KFPlayerReplicationInfo KFPRI, Canvas C){
    local KFMonster KFEnemy;
    local HUDKillingFloor HKF;
    local float MaxDistanceSquared;
    MaxDistanceSquared = 640000;
    MaxDistanceSquared *= GetHealthBarsDistanceMulti(KFPRI)**2;
    HKF = HUDKillingFloor(C.ViewPort.Actor.myHUD);
    if(HKF == none || C.ViewPort.Actor.Pawn == none || MaxDistanceSquared <= 0)
       return;
    foreach C.ViewPort.Actor.DynamicActors(class'KFMonster', KFEnemy){
       if(KFEnemy.Health > 0 && (!KFEnemy.Cloaked() || KFEnemy.bZapped || KFEnemy.bSpotted) && VSizeSquared(KFEnemy.Location - C.ViewPort.Actor.Pawn.Location) < MaxDistanceSquared)
           HKF.DrawHealthBar(C, KFEnemy, KFEnemy.Health, KFEnemy.HealthMax , 50.0);
    }
}
// Is player standing still?
static function bool IsStandingStill(KFPlayerReplicationInfo KFPRI){
    if(KFPRI != none && PlayerController(KFPRI.Owner) != none && PlayerController(KFPRI.Owner).Pawn != none && VSize(PlayerController(KFPRI.Owner).Pawn.Velocity) > 0.0)
       return false;
    return true;
}
// Is player aiming?
static function bool IsAiming(KFPlayerReplicationInfo KFPRI){
    local KFWeapon kfWeap;
    if(KFPRI != none && PlayerController(KFPRI.Owner) != none && PlayerController(KFPRI.Owner).Pawn != none)
       kfWeap = KFWeapon(PlayerController(KFPRI.Owner).Pawn.weapon);
    if(kfWeap == none)
       return false;
    return kfWeap.bAimingRifle;
}
// Just display the same fixed bonuses for the new type perks
static function string GetVetInfoText(byte Level, byte Type, optional byte RequirementNum){
    if(Type == 1 && default.bNewTypePerk)
       return default.CustomLevelInfo;
    return Super.GetVetInfoText(Level, Type, RequirementNum);
}
static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI){
    return class'NicePack.NiceNade';
}
static function SetupAbilities(KFPlayerReplicationInfo KFPRI){}
defaultproperties
{
    SkillGroupA(0)=Class'NicePack.NiceSkill'
    SkillGroupA(1)=Class'NicePack.NiceSkill'
    SkillGroupA(2)=Class'NicePack.NiceSkill'
    SkillGroupA(3)=Class'NicePack.NiceSkill'
    SkillGroupA(4)=Class'NicePack.NiceSkill'
    SkillGroupB(0)=Class'NicePack.NiceSkill'
    SkillGroupB(1)=Class'NicePack.NiceSkill'
    SkillGroupB(2)=Class'NicePack.NiceSkill'
    SkillGroupB(3)=Class'NicePack.NiceSkill'
    SkillGroupB(4)=Class'NicePack.NiceSkill'
}
