class NiceDamTypeKSGShotgun extends NiceDamageTypeVetEnforcer
    abstract;
defaultproperties
{
    MaxPenetrations=3
    BigZedPenDmgReduction=0.000000
    MediumZedPenDmgReduction=0.250000
    PenDmgReduction=0.900000
    bIsPowerWeapon=True
    WeaponClass=Class'NicePack.NiceKSGShotgun'
    DeathString="%k killed %o (HSG Shotgun)."
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
