class NiceM79Fire extends NiceFire;
defaultproperties
{
    ProjSpawnOffset=(X=5.000000)
    EffectiveRange=2500.000000
    ProjectileSpeed=3800.000000
    bulletClass=Class'NicePack.NiceBallisticNade'
    ExplosionDamageType=Class'NicePack.NiceDamTypeM79Explosion'
    ExplosionDamage=360
    ExplosionRadius=400.000000
    explosionExponent=1.000000
    ExplosionMomentum=75000.000000
    explodeOnPawnHit=True
    explodeOnWallHit=True
    projAffectedByScream=True
    FireAimedAnim="Iron_Fire"
    RecoilRate=0.100000
    maxVerticalRecoilAngle=200
    maxHorizontalRecoilAngle=50
    FireSoundRef="KF_M79Snd.M79_Fire"
    StereoFireSoundRef="KF_M79Snd.M79_FireST"
    NoAmmoSoundRef="KF_M79Snd.M79_DryFire"
    DamageType=Class'NicePack.NiceDamTypeM79Blunt'
    DamageMax=175
    bWaitForRelease=True
    TransientSoundVolume=1.800000
    FireForce="AssaultRifleFire"
    FireRate=0.000000
    AmmoClass=Class'NicePack.NiceM79Ammo'
    ShakeRotMag=(X=3.000000,Y=4.000000,Z=2.000000)
    ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
    ShakeOffsetMag=(X=3.000000,Y=3.000000,Z=3.000000)
    BotRefireRate=1.800000
    FlashEmitterClass=Class'ROEffects.MuzzleFlash1stNadeL'
    aimerror=42.000000
}
