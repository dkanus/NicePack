class NiceNailGunFire extends NiceShotgunFire;
simulated function bool ShouldBounce(){
    return true;
}
defaultproperties
{    ProjPerFire=1    KickMomentum=(X=-25.000000,Z=0.000000)    ProjectileSpeed=9260.0    bShouldBounce=True    bCausePain=True    bulletClass=Class'NicePack.NiceNail'    maxVerticalRecoilAngle=1250    maxHorizontalRecoilAngle=750    bRandomPitchFireSound=True    FireSoundRef="KF_NailShotgun.NailShotgun_Fire_Single_M"    StereoFireSoundRef="KF_NailShotgun.NailShotgun_Fire_Single_S"    NoAmmoSoundRef="KF_NailShotgun.KF_NailShotgun_Dryfire"    DamageType=Class'NicePack.NiceDamTypeNailGun'    DamageMax=66    FireAnimRate=1.250000    FireRate=0.400000    AmmoClass=Class'NicePack.NiceNailGunAmmo'    ShakeRotTime=3.000000    ShakeOffsetTime=2.000000    BotRefireRate=0.500000    FlashEmitterClass=Class'ROEffects.MuzzleFlash1stNailGun'    SpreadStyle=SS_None
}