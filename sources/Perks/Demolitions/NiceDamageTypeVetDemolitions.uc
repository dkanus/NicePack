class NiceDamageTypeVetDemolitions extends NiceWeaponDamageType
    abstract;
static function AwardNiceDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount, int HL){
    if(SRStatsBase(KFStatsAndAchievements) != none && SRStatsBase(KFStatsAndAchievements).Rep != none)       SRStatsBase(KFStatsAndAchievements).Rep.ProgressCustomValue(Class'NiceVetDemolitionsExp', Int(Float(Amount) * class'NicePack'.default.vetDemoDamageExpCost * getScale(HL)));
}
defaultproperties
{
}
