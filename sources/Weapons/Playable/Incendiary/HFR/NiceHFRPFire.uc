class NiceHFRPFire extends KFFire;
defaultproperties
{
    FireAimedAnim="Fire_Iron"
    RecoilRate=0.120000
    maxVerticalRecoilAngle=500
    bAccuracyBonusForSemiAuto=True
    bRandomPitchFireSound=False
    FireSoundRef="KF_SP_LongmusketSnd.KFO_Sniper_Fire_M"
    StereoFireSoundRef="KF_SP_LongmusketSnd.KFO_Sniper_Fire_S"
    NoAmmoSoundRef="KF_AK47Snd.AK47_DryFire"
    DamageType=Class'NicePack.NiceDamTypeHFRAssaultRifle'
    DamageMax=50
    Momentum=8500.000000
    bWaitForRelease=True
    TransientSoundVolume=1.200000
    TransientSoundRadius=500.000000
    FireLoopAnim="Fire"
    FireAnimRate=0.909000
    TweenTime=0.025000
    FireForce="AssaultRifleFire"
    FireRate=0.600000
    AmmoClass=Class'NicePack.NiceHFRAmmo'
    AmmoPerFire=1
    ShakeRotMag=(X=50.000000,Y=50.000000,Z=350.000000)
    ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
    ShakeRotTime=0.750000
    ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=7.500000)
    ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
    ShakeOffsetTime=1.250000
    BotRefireRate=0.990000
    FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSPSniper'
    aimerror=42.000000
    Spread=0.015000
    SpreadStyle=SS_Random
}
