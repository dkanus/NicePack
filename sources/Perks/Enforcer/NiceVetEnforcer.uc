class NiceVetEnforcer extends NiceVeterancyTypes
    abstract;

static function AddCustomStats(ClientPerkRepLink Other){
    Other.AddCustomValue(Class'NiceVetSupportExp');
}

static function int GetStatValueInt(ClientPerkRepLink StatOther, byte ReqNum){
    return StatOther.GetCustomValueInt(Class'NiceVetSupportExp');
}

static function array<int> GetProgressArray(byte ReqNum, optional out int DoubleScalingBase){
    return default.progressArray0;
}

// Other bonuses

static function float GetPenetrationDamageMulti(KFPlayerReplicationInfo KFPRI, float DefaultPenDamageReduction, class<NiceWeaponDamageType> fireIntance){
    local float bonusReduction;
    local float PenDamageInverse;
    bonusReduction = 0.0;
    if(class<NiceDamageTypeVetEnforcerBullets>(fireIntance) != none)
        return DefaultPenDamageReduction;
    if(HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillSupportStubbornness'))
       bonusReduction = class'NiceSkillSupportStubbornness'.default.penLossRed;
    PenDamageInverse = (1.0 - FMax(0, DefaultPenDamageReduction)); 
    return DefaultPenDamageReduction + PenDamageInverse * (0.6 + 0.4 * bonusReduction);  // 60% better penetrations + bonus
}

static function int AddStunScore(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InStunScore, class<NiceWeaponDamageType> DmgType){
    local class<NiceWeaponPickup> pickupClass;
    pickupClass = GetPickupFromDamageType(DmgType);
    if(KFPRI != none && IsPerkedPickup(pickupClass) && HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillEnforcerBombard'))
       return InStunScore * class'NiceSkillEnforcerBombard'.default.stunMult;
    return InStunScore;
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI){
    /*if(HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillSupportCautious'))
       return class'NicePack.NiceDelayedNade';
    return class'NicePack.NiceNailNade';*/
    return class'NicePack.NiceCryoNade';
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType){
    local float bonusNades;
    // Default bonus
    bonusNades = 2;
    if(AmmoType == class'FragAmmo')
       return 1.0 + 0.2 * bonusNades;
    return 1.0;
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType){
    if(HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillEnforcerDetermination') && Injured.Health < class'NiceSkillEnforcerDetermination'.default.healthBound)
       InDamage *= (1 - class'NiceSkillEnforcerDetermination'.default.addedResist);
    if(HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillEnforcerUnshakable'))
       InDamage *= (1 - class'NiceSkillEnforcerUnshakable'.default.skillResist);
    if(HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillEnforcerCoating') && Injured.ShieldStrength > 0){
       if( class<KFWeaponDamageType>(DmgType) != none
           && ((class<KFWeaponDamageType>(DmgType).default.bDealBurningDamage && KFMonster(Instigator) != none)
           || DmgType == class'NiceZombieTeslaHusk'.default.MyDamageType) )
           InDamage *= (1 - class'NiceSkillEnforcerCoating'.default.huskResist);
    }
    return InDamage;
}

static function float GetFireSpeedModStatic(KFPlayerReplicationInfo KFPRI, class<Weapon> other){
    local float                     fireSpeed;
    local NicePlayerController      nicePlayer;
    local class<NiceWeaponPickup>   pickupClass;
    pickupClass = GetPickupFromWeapon(other);
    if(KFPRI.Owner == none)
       return 1.0;
    if(IsPerkedPickup(pickupClass) && HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillHeavyOverclocking'))
       fireSpeed = class'NiceSkillHeavyOverclocking'.default.fireSpeedMult;
    else
       fireSpeed = 1.0;
    nicePlayer = NicePlayerController(KFPRI.Owner);
    /*if(nicePlayer != none && HasSkill(nicePlayer, class'NiceSkillEnforcerZEDBarrage'))
       fireSpeed /= (KFPRI.Owner.Level.TimeDilation / 1.1);*/
    return fireSpeed;
}

static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire other, out float Recoil){
    local class<NiceWeaponPickup>   pickupClass;
    pickupClass = GetPickupFromWeaponFire(other);
    if(IsPerkedPickup(pickupClass) && HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillHeavyOverclocking'))
       Recoil = class'NiceSkillHeavyOverclocking'.default.fireSpeedMult;
    else
       Recoil = 1.0;
    return Recoil;
}

/*static function float GetMagCapacityModStatic(KFPlayerReplicationInfo KFPRI, class<KFWeapon> other){
    local class<NiceWeapon> niceWeap;
    niceWeap = class<NiceWeapon>(other);
    if(niceWeap != none && niceWeap.default.reloadType == RTYPE_MAG)
       return 1.5;
    if(other == class'NicePack.NiceM41AAssaultRifle' || other == class'NicePack.NiceChainGun' || other == class'NicePack.NiceStinger' )
       return 1.5;
    return 1.0;
}*/

static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI){
    if(HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillEnforcerUnstoppable'))
       return class'NiceSkillEnforcerUnstoppable'.default.speedMult;
    return 1.0;
}

static function bool CanBePulled(KFPlayerReplicationInfo KFPRI){
    if(HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillEnforcerUnstoppable'))
       return false;
    return super.CanBePulled(KFPRI);
}

static function float SlowingModifier(KFPlayerReplicationInfo KFPRI){
    if(HasSkill(NicePlayerController(KFPRI.Owner), class'NiceSkillEnforcerUnstoppable'))
       return 0.0;
    return 1.0;
}

static function string GetCustomLevelInfo(byte Level){
    return default.CustomLevelInfo;
}
static function SetupAbilities(KFPlayerReplicationInfo KFPRI){
    local NicePlayerController                      nicePlayer;
    local NiceAbilityManager.NiceAbilityDescription fullcounter;
    if(KFPRI != none)
       nicePlayer = NicePlayerController(KFPRI.Owner);
    if(nicePlayer == none || nicePlayer.abilityManager == none)
       return;
    fullcounter.ID   = "fullcounter";
    fullcounter.icon = Texture'NicePackT.HudCounter.fullCounter';
    fullcounter.cooldownLength = 30.0;
    fullcounter.canBeCancelled = false;
    nicePlayer.abilityManager.AddAbility(fullcounter);
}

defaultproperties
{
    bNewTypePerk=True
    SkillGroupA(0)=Class'NicePack.NiceSkillEnforcerUnstoppable'
    SkillGroupA(1)=Class'NicePack.NiceSkillEnforcerBombard'
    SkillGroupA(2)=Class'NicePack.NiceSkillEnforcerCoating'
    SkillGroupA(3)=Class'NicePack.NiceSkillEnforcerStuporA'
    SkillGroupA(4)=Class'NicePack.NiceSkillEnforcerZEDBarrage'
    SkillGroupB(0)=Class'NicePack.NiceSkillEnforcerUnshakable'
    SkillGroupB(1)=Class'NicePack.NiceSkillEnforcerMultitasker'
    SkillGroupB(2)=Class'NicePack.NiceSkillEnforcerDetermination'
    SkillGroupB(3)=Class'NicePack.NiceSkillEnforcerBrutalCarnageA'
    SkillGroupB(4)=Class'NicePack.NiceSkillEnforcerZEDJuggernaut'
    progressArray0(0)=100
    progressArray0(1)=1000
    progressArray0(2)=3000
    progressArray0(3)=10000
    progressArray0(4)=30000
    progressArray0(5)=100000
    progressArray0(6)=200000
    DefaultDamageType=Class'NicePack.NiceDamageTypeVetEnforcer'
    OnHUDIcons(0)=(PerkIcon=Texture'KillingFloorHUD.Perks.Perk_Support',StarIcon=Texture'KillingFloorHUD.HUD.Hud_Perk_Star',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(1)=(PerkIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Support_Gold',StarIcon=Texture'KillingFloor2HUD.Perk_Icons.Hud_Perk_Star_Gold',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(2)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Support_Green',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Green',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(3)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Support_Blue',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Blue',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(4)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Support_Purple',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Purple',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(5)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Support_Orange',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Orange',DrawColor=(B=255,G=255,R=255,A=255))
    CustomLevelInfo="Level up by doing damage with perked weapons|60% better penetration with all weapons|+2 grenades"
    PerkIndex=1
    OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Support'
    OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Support_Gold'
    VeterancyName="Enforcer"
    Requirements(0)="Required experience for the next level: %x"
}