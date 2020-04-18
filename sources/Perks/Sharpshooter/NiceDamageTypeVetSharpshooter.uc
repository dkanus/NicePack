class NiceDamageTypeVetSharpshooter extends NiceWeaponDamageType
    abstract;
static function ScoredNiceHeadshot(KFSteamStatsAndAchievements KFStatsAndAchievements, class<KFMonster> monsterClass, int HL){
    if(SRStatsBase(KFStatsAndAchievements) != none && SRStatsBase(KFStatsAndAchievements).Rep != none)
       SRStatsBase(KFStatsAndAchievements).Rep.ProgressCustomValue(Class'NiceVetSharpshooterExp', Int(class'NicePack'.default.vetSharpHeadshotExpCost * getScale(HL)));
    super.ScoredNiceHeadshot(KFStatsAndAchievements, monsterClass, HL);
}
defaultproperties
{
}
