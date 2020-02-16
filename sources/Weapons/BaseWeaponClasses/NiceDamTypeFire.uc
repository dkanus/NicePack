class NiceDamTypeFire extends NiceWeaponDamageType
    abstract;
static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
    KFStatsAndAchievements.AddFlameThrowerDamage(Amount * default.heatPart);
}
defaultproperties
{
    heatPart=1.000000
    bDealBurningDamage=True
    bCheckForHeadShots=False
    //WeaponClass=Class'NicePack.NiceFlame9mm'
    DeathString="%k incinerated %o."
    FemaleSuicide="%o roasted herself alive."
    MaleSuicide="%o roasted himself alive."
}