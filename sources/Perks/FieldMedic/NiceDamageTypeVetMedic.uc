class NiceDamageTypeVetMedic extends NiceWeaponDamageType
    abstract;
static function AwardNiceDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount, int HL){
    if(SRStatsBase(KFStatsAndAchievements) != none && SRStatsBase(KFStatsAndAchievements).Rep != none)       SRStatsBase(KFStatsAndAchievements).Rep.ProgressCustomValue(Class'NiceVetFieldMedicExp', Int(Float(Amount) * class'NicePack'.default.vetFieldMedicDmgExpCost * getScale(HL)));
}
defaultproperties
{
}
