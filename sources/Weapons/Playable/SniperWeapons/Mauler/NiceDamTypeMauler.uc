class NiceDamTypeMauler extends NiceDamageTypeVetSharpshooter
    abstract;
static function ScoredNiceHeadshot(KFSteamStatsAndAchievements KFStatsAndAchievements, class<KFMonster> MonsterClass, int HL){
    super.ScoredNiceHeadshot(KFStatsAndAchievements, MonsterClass, HL);
    if(KFStatsAndAchievements != none)       KFStatsAndAchievements.AddHeadshotsWithSPSOrM14(MonsterClass);
}
defaultproperties
{    stunMultiplier=1.250000    HeadShotDamageMult=4.000000    bSniperWeapon=True    WeaponClass=Class'NicePack.NiceMaulerRifle'    DeathString="%k killed %o (S.P. Mauler)."    FemaleSuicide="%o shot herself in the foot."    MaleSuicide="%o shot himself in the foot."    bRagdollBullet=True    PawnDamageEmitter=Class'ROEffects.ROBloodPuff'    LowGoreDamageEmitter=Class'ROEffects.ROBloodPuffNoGore'    LowDetailEmitter=Class'ROEffects.ROBloodPuffSmall'    KDamageImpulse=7500.000000    KDeathVel=175.000000    KDeathUpKick=25.000000
}
