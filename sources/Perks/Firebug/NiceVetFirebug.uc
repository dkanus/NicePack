class NiceVetFirebug extends NiceVeterancyTypes
    abstract;
static function int GetStatValueInt(ClientPerkRepLink StatOther, byte ReqNum)
{
  return StatOther.RFlameThrowerDamageStat;
}
/*
static function int AddFireDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<NiceWeaponDamageType> DmgType){
    if(class<NiceDamTypeFire>(DmgType) != none){
       if(GetClientVeteranSkillLevel(KFPRI) == 0)
           return float(InDamage) * 1.2;
       if(GetClientVeteranSkillLevel(KFPRI) <= 6)
           return float(InDamage) * (1.2 + (0.2 * float(GetClientVeteranSkillLevel(KFPRI)))); //  Up to 140% extra damage
       return float(InDamage) * 2.4;
    }
    return 0.0;
}
static function float GetMagCapacityModStatic(KFPlayerReplicationInfo KFPRI, class<KFWeapon> Other)
{
    if ( GetClientVeteranSkillLevel(KFPRI) > 0 ) {
       if (    ClassIsChildOf(Other, class'NiceMAC10Z')
           ||  ClassIsChildOf(Other, class'NiceThompsonInc')
           ||  ClassIsChildOf(Other, class'NiceProtecta')
           ||  ClassIsChildOf(Other, class'NiceHFR')
           ||  ClassIsChildOf(Other, class'NiceFlameThrower')
           ||  ClassIsChildOf(Other, class'NiceHuskGun')
           || ClassIsInArray(default.PerkedAmmo, Other.default.FiremodeClass[0].default.AmmoClass)  //v3 - custom weapon support
           )
       return 1.0 + (0.10 * fmin(6, GetClientVeteranSkillLevel(KFPRI))); // Up to 60% larger fuel canister
    }
    return 1.0;
}
// more ammo from ammo boxes
static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
    return AddExtraAmmoFor(KFPRI, Other.class);
}
static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{   
    if ( GetClientVeteranSkillLevel(KFPRI) > 0 ) {
       if ( ClassIsChildOf(AmmoType,  class'NiceMAC10Ammo') 
               || ClassIsChildOf(AmmoType, class'NiceThompsonIncAmmo') 
               || ClassIsChildOf(AmmoType, class'NiceFlareRevolverAmmo') 
               || ClassIsChildOf(AmmoType, class'NiceDualFlareRevolverAmmo')
               || ClassIsChildOf(AmmoType, class'TrenchgunAmmo')
               || ClassIsChildOf(AmmoType, class'NiceProtectaAmmo')
               || ClassIsChildOf(AmmoType, class'NiceHFRAmmo')
               || ClassIsChildOf(AmmoType, class'NiceFlameAmmo')
               || ClassIsChildOf(AmmoType, class'NiceHuskGunAmmo')
               || ClassIsInArray(default.PerkedAmmo, AmmoType)  //v3 - custom weapon support
           ) {
           if ( GetClientVeteranSkillLevel(KFPRI) <= 6 )
               return 1.0 + (0.10 * float(GetClientVeteranSkillLevel(KFPRI))); // Up to 60% larger fuel canister
           return 1.6 + (0.05 * float(GetClientVeteranSkillLevel(KFPRI)-6)); // 5% more total fuel per each perk level above 6
       }
       else if ( GetClientVeteranSkillLevel(KFPRI) >= 4 
               && AmmoType == class'FragAmmo' ) {
           return 1.0 + (0.20 * float(GetClientVeteranSkillLevel(KFPRI) - 3)); // 1 extra nade per level starting with level 4
       }
       else if ( GetClientVeteranSkillLevel(KFPRI) > 6 && ClassIsChildOf(AmmoType,  class'ScrnM79IncAmmo') ) {
           return 1.0 + (0.083334 * float(GetClientVeteranSkillLevel(KFPRI)-6)); //+2 M79Inc nades post level 6
       }
    }    return 1.0;
}
static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
    return InDamage;
}
// Change effective range on FlameThrower
static function int ExtraRange(KFPlayerReplicationInfo KFPRI)
{
    if ( GetClientVeteranSkillLevel(KFPRI) <= 2 )
       return 0;
    else if ( GetClientVeteranSkillLevel(KFPRI) <= 4 )
       return 1; // 50% Longer Range
    return 2; // 100% Longer Range
}
static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
    if ( class<KFWeaponDamageType>(DmgType) != none && class<KFWeaponDamageType>(DmgType).default.bDealBurningDamage ) 
    {
       if ( GetClientVeteranSkillLevel(KFPRI) <= 4 )
           return max(1, float(InDamage) * (0.50 - (0.10 * float(GetClientVeteranSkillLevel(KFPRI)))));

       return 0; // 100% reduction in damage from fire
    }
    return InDamage;
}
static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
    if ( GetClientVeteranSkillLevel(KFPRI) >= 3 ) {
       return class'NicePack.NiceFlameNade';
    }
    return super.GetNadeType(KFPRI);
}
//can't cook fire nades
static function bool CanCookNade(KFPlayerReplicationInfo KFPRI, Weapon Weap)
{
    return GetNadeType(KFPRI) != class'ScrnBalanceSrv.ScrnFlameNade';
}
//v2.60: +60% faster charge with Husk Gun
static function float GetReloadSpeedModifierStatic(KFPlayerReplicationInfo KFPRI, class<KFWeapon> Other)
{
    if ( GetClientVeteranSkillLevel(KFPRI) > 0 ) {
       if (    ClassIsChildOf(Other, class'NiceMAC10Z')
           ||  ClassIsChildOf(Other, class'NiceThompsonInc')
           ||  ClassIsChildOf(Other, class'NiceFlareRevolver')
           ||  ClassIsChildOf(Other, class'NiceDualFlareRevolver')
           ||  ClassIsChildOf(Other, class'NiceM79Inc')
           ||  ClassIsChildOf(Other, class'NiceTrenchgun')
           ||  ClassIsChildOf(Other, class'NiceProtecta')
           ||  ClassIsChildOf(Other, class'NiceHFR')
           ||  ClassIsChildOf(Other, class'NiceFlameThrower')
           ||  ClassIsChildOf(Other, class'NiceHuskGun')
           ||  ClassIsChildOf(Other, class'HuskGun')
           ||  ClassIsChildOf(Other, class'HuskGun')
           ||  ClassIsChildOf(Other, class'HuskGun')
           || ClassIsInArray(default.PerkedWeapons, Other) //v3 - custom weapon support
           )
           return 1.0 + (0.10 * fmin(6, GetClientVeteranSkillLevel(KFPRI))); // Up to 60% faster reload with Flame weapons / Husk Gun charging
    }
    return 1.0;
}
// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
    //add discount on class descenders as well, e.g. ScrnHuskGun
    if ( ClassIsChildOf(Item,  class'NiceThompsonIncPickup') 
           || ClassIsChildOf(Item,  class'NiceFlareRevolverPickup')
           || ClassIsChildOf(Item,  class'NiceDualFlareRevolverPickup')
           || ClassIsChildOf(Item,  class'NiceM79IncPickup')
           || ClassIsChildOf(Item,  class'NiceTrenchgunPickup')
           || ClassIsChildOf(Item,  class'NiceProtectaPickup')
           || ClassIsChildOf(Item,  class'NiceHFRPickup')
           || ClassIsChildOf(Item,  class'NiceFlameThrowerPickup')
           || ClassIsChildOf(Item,  class'NiceHuskGunPickup')
           || ClassIsInArray(default.PerkedPickups, Item) ) //v3 - custom weapon support
    {
       if ( GetClientVeteranSkillLevel(KFPRI) <= 6 )
           return 0.9 - 0.10 * float(GetClientVeteranSkillLevel(KFPRI)); // 10% perk level up to 6
       else
           return FMax(0.1, 0.3 - (0.05 * float(GetClientVeteranSkillLevel(KFPRI)-6))); // 5% post level 6
    }
    return 1.0;
}
static function class<DamageType> GetMAC10DamageType(KFPlayerReplicationInfo KFPRI)
{
    return class'DamTypeMAC10MPInc';
}
static function string GetCustomLevelInfo( byte Level )
{
    local string S;
    local byte BonusLevel;
    S = Default.CustomLevelInfo;
    BonusLevel = GetBonusLevel(Level)-6;
    ReplaceText(S,"%L",string(BonusLevel+6));
    ReplaceText(S,"%m",GetPercentStr(0.6 + 0.10*BonusLevel));
    ReplaceText(S,"%d",GetPercentStr(0.7 + fmin(0.2, 0.05*BonusLevel)));
    return S;
}*/
defaultproperties
{
    DefaultDamageType=Class'NicePack.NiceDamTypeFire'
    DefaultDamageTypeNoBonus=Class'KFMod.DamTypeMAC10MPInc'
    OnHUDIcons(0)=(PerkIcon=Texture'KillingFloorHUD.Perks.Perk_Firebug',StarIcon=Texture'KillingFloorHUD.HUD.Hud_Perk_Star',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(1)=(PerkIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Firebug_Gold',StarIcon=Texture'KillingFloor2HUD.Perk_Icons.Hud_Perk_Star_Gold',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(2)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Firebug_Green',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Green',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(3)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Firebug_Blue',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Blue',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(4)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Firebug_Purple',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Purple',DrawColor=(B=255,G=255,R=255,A=255))
    OnHUDIcons(5)=(PerkIcon=Texture'ScrnTex.Perks.Perk_Firebug_Orange',StarIcon=Texture'ScrnTex.Perks.Hud_Perk_Star_Orange',DrawColor=(B=255,G=255,R=255,A=255))
    CustomLevelInfo="*** BONUS LEVEL %L|140% extra flame weapon damage|%m faster fire weapon reload|%m faster Husk Gun charging|%s more flame weapon ammo|100% resistance to fire|100% extra Flamethrower range|Grenades set enemies on fire|%d discount on flame weapons|Spawn with an Incendiary Thompson"
    SRLevelEffects(0)="*** BONUS LEVEL 0|20% extra flame weapon damage|50% resistance to fire|10% discount on the flame weapons"
    SRLevelEffects(1)="*** BONUS LEVEL 1|40% extra flame weapon damage|10% faster fire weapon reload|10% faster Husk Gun charging|10% more flame weapon ammo|60% resistance to fire|20% discount on flame weapons"
    SRLevelEffects(2)="*** BONUS LEVEL 2|60% extra flame weapon damage|20% faster fire weapon reload|20% faster Husk Gun charging|20% more flame weapon ammo|70% resistance to fire|30% discount on flame weapons"
    SRLevelEffects(3)="*** BONUS LEVEL 3|80% extra flame weapon damage|30% faster fire weapon reload|30% faster Husk Gun charging|30% more flame weapon ammo|80% resistance to fire|50% extra Flamethrower range|Grenades set enemies on fire|40% discount on flame weapons"
    SRLevelEffects(4)="*** BONUS LEVEL 4|100% extra flame weapon damage|40% faster fire weapon reload|40% faster Husk Gun charging|40% more flame weapon ammo|90% resistance to fire|50% extra Flamethrower range|Grenades set enemies on fire|50% discount on flame weapons"
    SRLevelEffects(5)="*** BONUS LEVEL 5|120% extra flame weapon damage|50% faster fire weapon reload|50% faster Husk Gun charging|50% more flame weapon ammo|100% resistance to fire|100% extra Flamethrower range|Grenades set enemies on fire|60% discount on flame weapons|Spawn with a MAC10"
    SRLevelEffects(6)="*** BONUS LEVEL 6|140% extra flame weapon damage|60% faster fire weapon reload|60% faster Husk Gun charging|60% more flame weapon ammo|100% resistance to fire|100% extra Flamethrower range|Grenades set enemies on fire|70% discount on flame weapons|Spawn with an Incendiary Thompson"
    PerkIndex=5
    OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Firebug'
    OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Firebug_Gold'
    VeterancyName="[Legacy]Firebug"
    Requirements(0)="Deal %x damage with the Flamethrower"
}
