class NiceKSGFire extends NiceShotgunFire;
defaultproperties
{
    ProjPerFire=12
    maxVerticalRecoilAngle=1000
    maxHorizontalRecoilAngle=500
    ShellEjectClass=Class'KFMod.KSGShellEject'
    ShellEjectBoneName="Shell_eject"
    FireSoundRef="KF_KSGSnd.KSG_Fire_M"
    StereoFireSoundRef="KF_KSGSnd.KSG_Fire_S"
    NoAmmoSoundRef="KF_AA12Snd.AA12_DryFire"
    DamageType=Class'NicePack.NiceDamTypeKSGShotgun'
    DamageMax=25
    FireAnimRate=0.869565
    FireRate=0.943000
    AmmoClass=Class'NicePack.NiceKSGAmmo'
    BotRefireRate=0.250000
    Spread=1000.000000
}
