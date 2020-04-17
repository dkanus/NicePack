class NiceDamTypeHuskGunProjectileImpact extends NiceDamTypeFire;
static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth)
{
    HitEffects[0] = class'HitSmoke';
    if( VictimHealth <= 0 )
    else if ( FRand() < 0.8 )
}
static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
    KFStatsAndAchievements.AddFlameThrowerDamage(Amount);
}
defaultproperties
{
}