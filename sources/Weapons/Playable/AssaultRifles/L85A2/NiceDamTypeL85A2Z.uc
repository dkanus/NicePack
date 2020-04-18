class NiceDamTypeL85A2Z extends NiceDamageTypeVetCommando
    abstract;
defaultproperties
{
    badDecapMod=0.8000
    HeadShotDamageMult=1.400000
    bSniperWeapon=True
    WeaponClass=Class'NicePack.NiceL85A2Z'
    DeathString="%k killed %o."
    FemaleSuicide="%o shot herself in the foot."
    MaleSuicide="%o shot himself in the foot."
    bRagdollBullet=True
    bBulletHit=True
    PawnDamageEmitter=Class'ROEffects.ROBloodPuff'
    LowGoreDamageEmitter=Class'ROEffects.ROBloodPuffNoGore'
    LowDetailEmitter=Class'ROEffects.ROBloodPuffSmall'
    FlashFog=(X=600.000000)
    KDamageImpulse=4500.000000
    KDeathVel=200.000000
    KDeathUpKick=20.000000
    VehicleDamageScaling=0.800000
}
