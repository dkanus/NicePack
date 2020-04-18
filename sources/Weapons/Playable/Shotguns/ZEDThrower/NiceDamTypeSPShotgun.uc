class NiceDamTypeSPShotgun extends NiceDamageTypeVetEnforcer
    abstract;
defaultproperties
{
    MaxPenetrations=5
    PenDmgReduction=0.900000
    bIsPowerWeapon=True
    WeaponClass=Class'NicePack.NiceSPAutoShotgun'
    DeathString="%k killed %o (M.C.Z. Thrower)."
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
