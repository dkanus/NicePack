class NiceMedicDartFire extends NiceFire;
function DoFireEffect(){
    local float oldLoad;
    oldLoad = Load;
    Load = 1;
    super.DoFireEffect();
    Load = oldLoad;
}
simulated function bool AllowFire(){
    local KFPawn kfPwn;
    if(currentContext.sourceWeapon == none || Instigator == none)
       return false;
    if(currentContext.sourceWeapon.secondaryCharge < default.AmmoPerFire)
       return false;
    // Check reloading
    if(currentContext.sourceWeapon.bIsReloading)
       return false;
    // Check pawn actions
    kfPwn = KFPawn(Instigator);
    if(kfPwn == none || kfPwn.SecondaryItem != none || kfPwn.bThrowingNade)
       return false;
    return true;
}
simulated function ReduceAmmoClient(){
    local NiceMedicGun sourceMedGun;
    currentContext.sourceWeapon.secondaryCharge -= AmmoPerFire;
    sourceMedGun = NiceMedicGun(currentContext.sourceWeapon);
    if(sourceMedGun != none){
       sourceMedGun.ServerSetMedicCharge(currentContext.sourceWeapon.secondaryCharge);
       sourceMedGun.ClientSetMedicCharge(currentContext.sourceWeapon.secondaryCharge);
    }
}

defaultproperties
{
     ProjectileSpeed=12500.000000
     bulletClass=Class'NicePack.NiceMedicProjectile'
     FireAimedAnim="Fire_Iron"
     FireSoundRef="KF_MP7Snd.Medicgun_Fire"
     StereoFireSoundRef="KF_MP7Snd.Medicgun_FireST"
     NoAmmoSoundRef="KF_PumpSGSnd.SG_DryFire"
     DamageMax=30
     bWaitForRelease=True
     bAttachSmokeEmitter=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     AmmoPerFire=50
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=5.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     BotRefireRate=0.250000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stKar'
     aimerror=1.000000
}
