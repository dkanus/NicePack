class NiceDamTypeM14EBR extends NiceDamageTypeVetCommando
    abstract;
static function ScoredHeadshot(KFSteamStatsAndAchievements KFStatsAndAchievements, class<KFMonster> MonsterClass, bool bLaserSightedM14EBRKill)
{
    super.ScoredHeadshot( KFStatsAndAchievements, MonsterClass, bLaserSightedM14EBRKill );
    if ( KFStatsAndAchievements != none )
    {
    }
}
defaultproperties
{
    badDecapMod=0.6000
}