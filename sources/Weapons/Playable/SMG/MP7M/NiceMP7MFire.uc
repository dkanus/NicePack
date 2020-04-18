class NiceMP7MFire extends NiceHighROFFire;
defaultproperties
{
    FireEndSoundRef="KF_MP7Snd.MP7_tail"
    FireEndStereoSoundRef="KF_MP7Snd.MP7_tailST"
    AmbientFireSoundRef="KF_MP7Snd.MP7_FireLoop"
    ProjectileSpeed=36750.000000
    RecoilRate=0.060000
    maxVerticalRecoilAngle=70
    maxHorizontalRecoilAngle=35
    RecoilVelocityScale=0.000000
    ShellEjectClass=Class'ROEffects.KFShellEjectMP'
    ShellEjectBoneName="Shell_eject"
    NoAmmoSoundRef="KF_MP7Snd.MP7_DryFire"
    DamageType=Class'NicePack.NiceDamTypeMP7M'
    DamageMin=20
    DamageMax=20
    Momentum=5500.000000
    FireRate=0.063000
    AmmoClass=Class'NicePack.NiceMP7MAmmo'
    ShakeRotMag=(X=25.000000,Y=25.000000,Z=125.000000)
    ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
    ShakeRotTime=3.000000
    ShakeOffsetMag=(X=4.000000,Y=2.500000,Z=5.000000)
    ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
    ShakeOffsetTime=1.250000
    FlashEmitterClass=Class'ROEffects.MuzzleFlash1stMP'
    Spread=0.012000
    SpreadStyle=SS_Random
}
