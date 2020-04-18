class NiceDamTypeNailGun extends NiceDamageTypeVetEnforcer
    abstract;
defaultproperties
{
    MaxPenetrations=3
    bIsPowerWeapon=True
    WeaponClass=Class'NicePack.NiceNailGun'
    DeathString="%k killed %o (Nail)."
    FemaleSuicide="%o shot herself in the foot."
    MaleSuicide="%o shot himself in the foot."
    bRagdollBullet=True
    bBulletHit=True
    FlashFog=(X=600.000000)
    KDamageImpulse=10000.000000
    KDeathVel=300.000000
    KDeathUpKick=100.000000
    VehicleDamageScaling=0.700000
}
