class NiceDamageTypeVetCommando extends NiceWeaponDamageType
    abstract;
static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed ){
    if(Killed.IsA('ZombieStalker'))       KFStatsAndAchievements.AddStalkerKill();
}
static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount){
    KFStatsAndAchievements.AddBullpupDamage(Amount);
}
static function AwardNiceDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount, int HL){
    if(SRStatsBase(KFStatsAndAchievements) != none && SRStatsBase(KFStatsAndAchievements).Rep != none)       SRStatsBase(KFStatsAndAchievements).Rep.ProgressCustomValue(Class'NiceVetCommandoExp', Int(Float(Amount) * class'NicePack'.default.vetCommandoDamageExpCost * getScale(HL)));
}
defaultproperties
{
}
