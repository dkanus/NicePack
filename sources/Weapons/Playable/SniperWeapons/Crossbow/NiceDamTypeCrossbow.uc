class NiceDamTypeCrossbow extends NiceDamageTypeVetSharpshooter;
static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
    local NiceMonster niceKilled;
    niceKilled = NiceMonster(Killed);
    if(KFStatsAndAchievements!=none && (Killed.BurnDown > 0 || (niceKilled != none && niceKilled.bOnFire == true) ))
}
defaultproperties
{
}