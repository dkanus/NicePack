class NiceSaiga12cFire extends NiceShotgunFire;
function InitEffects()
{
    Super.InitEffects();
    if(FlashEmitter != none)       Weapon.AttachToBone(FlashEmitter, 'tip');
}
defaultproperties
{    ProjPerFire=4    KickMomentum=(X=-95.000000,Z=25.000000)    ProjectileSpeed=3500.000000    FireAimedAnim="Fire"    maxVerticalRecoilAngle=1300    maxHorizontalRecoilAngle=700    FireSoundRef="ScrnWeaponPack_SND.saiga.shot_mono"    StereoFireSoundRef="ScrnWeaponPack_SND.saiga.shot_stereo"    NoAmmoSoundRef="ScrnWeaponPack_SND.saiga.Saiga_empty"    DamageType=Class'NicePack.NiceDamTypeSaiga12c'    DamageMax=66    Momentum=60000.000000    bModeExclusive=False    FireRate=0.600000    AmmoClass=Class'NicePack.NiceSaiga12cAmmo'    BotRefireRate=0.250000    Spread=825.000000
}
