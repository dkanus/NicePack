class NiceDamageTypeVetEnforcer extends NiceWeaponDamageType
    abstract;

static function AwardNiceDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount, int HL){
    if(SRStatsBase(KFStatsAndAchievements) != none && SRStatsBase(KFStatsAndAchievements).Rep != none)
       SRStatsBase(KFStatsAndAchievements).Rep.ProgressCustomValue(Class'NiceVetSupportExp', Int(Float(Amount) * class'NicePack'.default.vetSupportDamageExpCost * getScale(HL)));
}

defaultproperties
{
    badDecapMod=1.000000
    bIsProjectile=True
    HeadShotDamageMult=1.500000
}