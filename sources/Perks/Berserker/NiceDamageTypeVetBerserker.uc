class NiceDamageTypeVetBerserker extends NiceWeaponDamageType
    abstract;
static function AwardNiceDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount, int HL){
    if(SRStatsBase(KFStatsAndAchievements) != none && SRStatsBase(KFStatsAndAchievements).Rep != none)
       SRStatsBase(KFStatsAndAchievements).Rep.ProgressCustomValue(Class'NiceVetBerserkerExp', Int(Float(Amount) * class'NicePack'.default.vetZerkDamageExpCost * getScale(HL)));
}
defaultproperties
{
    HeadShotDamageMult=1.250000
    bIsMeleeDamage=True
    DeathString="%o was beat down by %k."
    FemaleSuicide="%o beat herself down."
    MaleSuicide="%o beat himself down."
    bRagdollBullet=True
    bBulletHit=True
    PawnDamageEmitter=Class'ROEffects.ROBloodPuff'
    LowGoreDamageEmitter=Class'ROEffects.ROBloodPuffNoGore'
    LowDetailEmitter=Class'ROEffects.ROBloodPuffSmall'
    FlashFog=(X=600.000000)
    KDamageImpulse=2000.000000
    KDeathVel=100.000000
    KDeathUpKick=25.000000
    VehicleDamageScaling=0.600000
}
