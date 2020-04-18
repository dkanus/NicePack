class NiceDamTypeHFRAssaultRifle extends NiceDamTypeFire
    abstract;
defaultproperties
{
    heatPart=0.500000
    HeadShotDamageMult=6.000000
    bCheckForHeadShots=True
    WeaponClass=Class'NicePack.NiceHFR'
    DeathString="%k killed %o (Horzine Flame Rifle)."
    FemaleSuicide="%o shot herself in the foot."
    MaleSuicide="%o shot himself in the foot."
    bRagdollBullet=True
    PawnDamageEmitter=Class'ROEffects.ROBloodPuff'
    LowGoreDamageEmitter=Class'ROEffects.ROBloodPuffNoGore'
    LowDetailEmitter=Class'ROEffects.ROBloodPuffSmall'
    KDamageImpulse=5500.000000
    KDeathVel=175.000000
    KDeathUpKick=15.000000
}
