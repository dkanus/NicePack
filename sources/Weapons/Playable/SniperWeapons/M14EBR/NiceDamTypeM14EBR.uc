class NiceDamTypeM14EBR extends NiceDamageTypeVetCommando
    abstract;
static function ScoredHeadshot(KFSteamStatsAndAchievements KFStatsAndAchievements, class<KFMonster> MonsterClass, bool bLaserSightedM14EBRKill)
{
    super.ScoredHeadshot( KFStatsAndAchievements, MonsterClass, bLaserSightedM14EBRKill );
    if ( KFStatsAndAchievements != none )
    {
       KFStatsAndAchievements.AddHeadshotsWithSPSOrM14( MonsterClass );
    }
}
defaultproperties
{
    badDecapMod=0.6000
    bIsProjectile=True
    HeadShotDamageMult=2.250000
    bSniperWeapon=True
    WeaponClass=Class'NicePack.NiceM14EBRBattleRifle'
    DeathString="%k killed %o (M14 EBR)."
    FemaleSuicide="%o shot herself in the foot."
    MaleSuicide="%o shot himself in the foot."
    bRagdollBullet=True
    PawnDamageEmitter=Class'ROEffects.ROBloodPuff'
    LowGoreDamageEmitter=Class'ROEffects.ROBloodPuffNoGore'
    LowDetailEmitter=Class'ROEffects.ROBloodPuffSmall'
    KDamageImpulse=7500.000000
    KDeathVel=175.000000
    KDeathUpKick=25.000000
}
