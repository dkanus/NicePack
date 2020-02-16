class NiceDamTypeWinchester extends NiceDamageTypeVetSharpshooter
    abstract;

defaultproperties
{
    stunMultiplier=1.500000
    bIsProjectile=True
    HeadShotDamageMult=2.000000
    bSniperWeapon=True
    WeaponClass=Class'NicePack.NiceWinchester'
    DeathString="%k killed %o (Winchester)."
    FemaleSuicide="%o shot herself in the foot."
    MaleSuicide="%o shot himself in the foot."
    bRagdollBullet=True
    bBulletHit=True
    PawnDamageEmitter=Class'ROEffects.ROBloodPuff'
    LowGoreDamageEmitter=Class'ROEffects.ROBloodPuffNoGore'
    LowDetailEmitter=Class'ROEffects.ROBloodPuffSmall'
    FlashFog=(X=600.000000)
    KDamageImpulse=2250.000000
    KDeathVel=115.000000
    KDeathUpKick=5.000000
    VehicleDamageScaling=0.700000
}