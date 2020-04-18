class NiceBoomStickAltFire extends NiceBoomStickFire;
// Overload to force last shot to have a different animation with reload
// NICETODO: uncomment this
function name GetCorrectAnim(bool bLoop, bool bAimed){
    if(currentContext.sourceWeapon != none && currentContext.sourceWeapon.MagAmmoRemainingClient > 0)
       return super.GetCorrectAnim(bLoop, bAimed);
    if(bAimed)
       return 'Fire_Last_Iron';
    else
       return 'Fire_Last';
    return FireAnim;
}
defaultproperties
{
    KickMomentum=(X=-50.000000,Z=22.000000)
    FireAimedAnim="Fire_Iron"
    maxVerticalRecoilAngle=1500
    FireSoundRef="KF_DoubleSGSnd.2Barrel_Fire"
    StereoFireSoundRef="KF_DoubleSGSnd.2Barrel_FireST"
    TransientSoundVolume=1.800000
    FireAnim="Fire"
    AmmoPerFire=1
    ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
    ShakeRotTime=5.000000
    ShakeOffsetTime=3.000000
}
