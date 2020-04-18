class NiceBoomStickFire extends NiceShotgunFire;
var Emitter Flash2Emitter;
var name    MuzzleBoneLeft;
var name    MuzzleBoneRight;
simulated function InitEffects(){
    if((Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != none))
       return;
    if((FlashEmitterClass != none) && ((FlashEmitter == none) || FlashEmitter.bDeleteMe)){
       FlashEmitter = Weapon.Spawn(FlashEmitterClass);
       Weapon.AttachToBone(FlashEmitter, MuzzleBoneLeft);
    }
    if((FlashEmitterClass != none) && ((Flash2Emitter == none) || Flash2Emitter.bDeleteMe)){
       Flash2Emitter = Weapon.Spawn(FlashEmitterClass);
       Weapon.AttachToBone(Flash2Emitter, MuzzleBoneRight);
    }
    if((SmokeEmitterClass != none) && ((SmokeEmitter == none) || SmokeEmitter.bDeleteMe))
       SmokeEmitter = Weapon.Spawn(SmokeEmitterClass);
}
simulated function DestroyEffects(){
    super.DestroyEffects();
    if(Flash2Emitter != none)
       Flash2Emitter.Destroy();
}//MEANTODO
function FlashMuzzleFlash(){
    if(currentContext.sourceWeapon == none)
       return;
    if(currentContext.sourceWeapon.MagAmmoRemainingClient == 2){
       if(Flash2Emitter != none)
           Flash2Emitter.Trigger(Weapon, Instigator);
    }
    else if(FlashEmitter != none)
       FlashEmitter.Trigger(Weapon, Instigator);
}
defaultproperties
{
    MuzzleBoneLeft="Tip_Left"
    MuzzleBoneRight="Tip_Right"
    FireIncompleteAnim="Fire_Last"
    FireIncompleteAimedAnim="Fire_Last_Iron"
    bCanFireIncomplete=True
    ProjPerFire=10
    KickMomentum=(X=-105.000000,Z=55.000000)
    FireAimedAnim="Fire_Both_Iron"
    RecoilRate=0.070000
    maxVerticalRecoilAngle=3200
    FireSoundRef="KF_DoubleSGSnd.2Barrel_Fire_Dual"
    StereoFireSoundRef="KF_DoubleSGSnd.2Barrel_Fire_DualST"
    NoAmmoSoundRef="KF_DoubleSGSnd.2Barrel_DryFire"
    DamageType=Class'NicePack.NiceDamTypeDBShotgun'
    DamageMax=63
    TransientSoundVolume=1.900000
    FireAnim="Fire_Both"
    FireRate=0.000000
    AmmoClass=Class'NicePack.NiceDBShotgunAmmo'
    AmmoPerFire=2
    ShakeRotMag=(X=75.000000,Y=75.000000,Z=600.000000)
    ShakeRotTime=6.000000
    ShakeOffsetTime=3.500000
    BotRefireRate=2.500000
    aimerror=2.000000
    Spread=3000.000000
}
