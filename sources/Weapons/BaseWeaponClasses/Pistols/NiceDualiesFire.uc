class NiceDualiesFire extends NiceFire;
var bool bWasInZedTime;
var Emitter Flash2Emitter;
var Emitter ShellEject2Emitter;
var name    ShellEject2BoneName;
var name    FireAnim2, FireAimedAnim2;
var bool    bIsLeftShot;
var float   leftNextFireTime;
var float   rightNextFireTime;
var bool    bLastFiredLeft;
simulated function ModeTick(float delta){
    local float timeCutScale;
    local NicePlayerController nicePlayer;
    if(instigator != none)
       nicePlayer = NicePlayerController(instigator.controller);
    if(nicePlayer != none && nicePlayer.IsZedTimeActive() != bWasInZedTime){
       bWasInZedTime = !bWasInZedTime;
       timeCutScale = 1.0;
       if(bWasInZedTime)
           timeCutScale = KFGameType(Level.Game).ZedTimeSlomoScale;
       niceNextFireTime = Level.TimeSeconds + (niceNextFireTime - Level.TimeSeconds) * timeCutScale;
       nextFireTime = niceNextFireTime;
       leftNextFireTime = Level.TimeSeconds + (leftNextFireTime - Level.TimeSeconds) * timeCutScale;
       rightNextFireTime = Level.TimeSeconds + (rightNextFireTime - Level.TimeSeconds) * timeCutScale;
    }
    super.ModeTick(delta);
}
simulated function InitEffects(){
    local NiceDualies dualWeapon;
    dualWeapon = NiceDualies(Weapon);
    if((Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != none) || dualWeapon == none)
       return;
    if((FlashEmitterClass != none) && ((FlashEmitter == none) || FlashEmitter.bDeleteMe)){
       FlashEmitter = Weapon.Spawn(FlashEmitterClass);
       Weapon.AttachToBone(FlashEmitter, dualWeapon.default.FlashBoneName);
    }
    if((FlashEmitterClass != none) && ((Flash2Emitter == none) || Flash2Emitter.bDeleteMe)){
       Flash2Emitter = Weapon.Spawn(FlashEmitterClass);
       Weapon.AttachToBone(Flash2Emitter, dualWeapon.default.altFlashBoneName);
    }
    if((SmokeEmitterClass != none) && ((SmokeEmitter == none) || SmokeEmitter.bDeleteMe))
       SmokeEmitter = Weapon.Spawn(SmokeEmitterClass);
    if((ShellEjectClass != none) && ((ShellEjectEmitter == none) || ShellEjectEmitter.bDeleteMe)){
       ShellEjectEmitter = Weapon.Spawn(ShellEjectClass);
       Weapon.AttachToBone(ShellEjectEmitter, ShellEjectBoneName);
    }
    if((ShellEjectClass != none) && ((ShellEject2Emitter == none) || ShellEject2Emitter.bDeleteMe)){
       ShellEject2Emitter = Weapon.Spawn(ShellEjectClass);
       Weapon.AttachToBone(ShellEject2Emitter, ShellEject2BoneName);
    }
}
simulated function DestroyEffects(){
    super.DestroyEffects();
    if(ShellEject2Emitter != none)
       ShellEject2Emitter.Destroy();
    if(Flash2Emitter != none)
       Flash2Emitter.Destroy();
}
function DrawMuzzleFlash(Canvas Canvas){
    super.DrawMuzzleFlash(Canvas);
    if(ShellEject2Emitter != none)
       Canvas.DrawActor( ShellEject2Emitter, false, false, Weapon.DisplayFOV );
}
function FlashMuzzleFlash(){
    if(Flash2Emitter == none || FlashEmitter == none)
       return;
    if(KFWeap.bAimingRifle){
       if(FireAimedAnim == 'FireLeft_Iron'){
           Flash2Emitter.Trigger(Weapon, Instigator);
           if(ShellEjectEmitter != none)
               ShellEjectEmitter.Trigger(Weapon, Instigator);
       }
       else{
           FlashEmitter.Trigger(Weapon, Instigator);
           if(ShellEject2Emitter != none)
               ShellEject2Emitter.Trigger(Weapon, Instigator);
       }
    }
    else{
       if(FireAnim == 'FireLeft'){
           Flash2Emitter.Trigger(Weapon, Instigator);
           if(ShellEjectEmitter != none)
               ShellEjectEmitter.Trigger(Weapon, Instigator);
       }
       else{
           FlashEmitter.Trigger(Weapon, Instigator);
           if(ShellEject2Emitter != none)
               ShellEject2Emitter.Trigger(Weapon, Instigator);
       }
    }
}
simulated function ModeDoFireLeft(){
    local NiceDualies           dualWeapon;
    local NiceDualiesAttachment dualAttach, dualAttachAlt;
    dualWeapon = NiceDualies(Weapon);
    dualAttach = NiceDualiesAttachment(dualWeapon.ThirdPersonActor);
    dualAttachAlt = NiceDualiesAttachment(dualWeapon.altThirdPersonActor);
    if(dualWeapon == none || !AllowLeftFire())
       return;
    // Set shine turn
    if(dualAttach != none)
       dualAttach.bMyFlashTurn = false;
    if(dualAttachAlt != none)
       dualAttachAlt.bMyFlashTurn = true;
    // Swap bones and animations
    dualWeapon.FlashBoneName = dualWeapon.default.altFlashBoneName;
    dualWeapon.altFlashBoneName = dualWeapon.default.FlashBoneName;
    FireAnim = default.FireAnim2;
    FireAnim2 = default.FireAnim;
    FireAimedAnim = default.FireAimedAnim2;
    FireAimedAnim2 = default.FireAimedAnim;
    // Do left shot
    bIsLeftShot = true;
    super.ModeDoFire();
    leftNextFireTime = UpdateNextFireTimeSingle(leftNextFireTime);
    InitEffects();
    bLastFiredLeft = true;
}
simulated function ModeDoFireRight(){
    local NiceDualies           dualWeapon;
    local NiceDualiesAttachment dualAttach, dualAttachAlt;
    dualWeapon = NiceDualies(Weapon);
    dualAttach = NiceDualiesAttachment(dualWeapon.ThirdPersonActor);
    dualAttachAlt = NiceDualiesAttachment(dualWeapon.altThirdPersonActor);
    if(dualWeapon == none || !AllowRightFire())
       return;
    // Set shine turn
    if(dualAttach != none)
       dualAttach.bMyFlashTurn = true;
    if(dualAttachAlt != none)
       dualAttachAlt.bMyFlashTurn = false;
    // Default bones and animations
    dualWeapon.FlashBoneName = dualWeapon.default.FlashBoneName;
    dualWeapon.altFlashBoneName = dualWeapon.default.altFlashBoneName;
    FireAnim = default.FireAnim;
    FireAnim2 = default.FireAnim2;
    FireAimedAnim = default.FireAimedAnim;
    FireAimedAnim2 = default.FireAimedAnim2;
    // Do right shot
    bIsLeftShot = false;
    super.ModeDoFire();
    rightNextFireTime = UpdateNextFireTimeSingle(rightNextFireTime);
    InitEffects();
    bLastFiredLeft = false;
}
simulated function bool AllowLeftFire(){
    local NiceDualies niceDualWeap;
    niceDualWeap = NiceDualies(currentContext.sourceWeapon);
    if(niceDualWeap == none)
       return false;
    if(niceDualWeap.GetMagazineAmmoLeft() < default.AmmoPerFire && !bCanFireIncomplete)
       return false;
    return true;
}
simulated function bool AllowRightFire(){
    local NiceDualies niceDualWeap;
    niceDualWeap = NiceDualies(currentContext.sourceWeapon);
    if(niceDualWeap == none)
       return false;
    if(niceDualWeap.GetMagazineAmmoRight() < default.AmmoPerFire && !bCanFireIncomplete)
       return false;
    return true;
}
simulated function bool AllowFire(){
    return super.AllowFire() && (AllowLeftFire() || AllowRightFire());
}
event ModeDoFire(){
    local NiceDualies dualWeap;
    dualWeap = NiceDualies(Instigator.Weapon);
    if(dualWeap == none || niceNextFireTime > Level.TimeSeconds || !AllowFire())
       return;
    if(niceNextFireTime + FireRate < Level.TimeSeconds)
       bResetRecoil = true;
    // Choose correct pistol to fire
    if(Level.TimeSeconds > leftNextFireTime && Level.TimeSeconds > rightNextFireTime && AllowLeftFire() && AllowRightFire()){
       if(dualWeap.GetMagazineAmmoLeft() > dualWeap.GetMagazineAmmoRight())
           ModeDoFireLeft();
       else if(dualWeap.GetMagazineAmmoLeft() < dualWeap.GetMagazineAmmoRight())
           ModeDoFireRight();
       else if(bLastFiredLeft)
           ModeDoFireRight();
       else
           ModeDoFireLeft();
    }
    else if(Level.TimeSeconds > leftNextFireTime && AllowLeftFire())
       ModeDoFireLeft();
    else if(Level.TimeSeconds > rightNextFireTime && AllowRightFire())
       ModeDoFireRight();
}
simulated function ReduceAmmoClient(){
    local NiceDualies dualWeap;
    dualWeap = NiceDualies(currentContext.sourceWeapon);
    if(dualWeap == none)
       return;
    if(bIsLeftShot)
       dualWeap.MagAmmoRemLeftClient -= Load;
    else
       dualWeap.MagAmmoRemRightClient -= Load;
    if(dualWeap.MagAmmoRemLeftClient < 0)
       dualWeap.MagAmmoRemLeftClient = 0;
    if(dualWeap.MagAmmoRemRightClient < 0)
       dualWeap.MagAmmoRemRightClient = 0;
    // Force server's magazine size
    dualWeap.ServerReduceDualMag(dualWeap.MagAmmoRemLeftClient, dualWeap.MagAmmoRemRightClient, Level.TimeSeconds, ThisModeNum);
}
simulated function float UpdateNextFireTimeSingle(float fireTimeVar){
    FireRate *= 2;
    fireTimeVar = UpdateNextFireTime(fireTimeVar);
    FireRate = default.FireRate;
    return fireTimeVar;
}

defaultproperties
{
     ShellEject2BoneName="Shell_eject_right"
     FireAnim2="FireLeft"
     FireAimedAnim2="FireLeft_Iron"
     FireAimedAnim="FireRight_Iron"
     RecoilRate=0.070000
     maxVerticalRecoilAngle=450
     maxHorizontalRecoilAngle=50
     ShellEjectClass=Class'ROEffects.KFShellEject9mm'
     ShellEjectBoneName="Shell_eject_left"
     DamageMin=35
     DamageMax=35
     Momentum=10500.000000
     bPawnRapidFireAnim=True
     bWaitForRelease=True
     bAttachSmokeEmitter=True
     TransientSoundVolume=1.800000
     FireAnim="FireRight"
     FireLoopAnim=
     FireEndAnim=
     TweenTime=0.025000
     FireForce="AssaultRifleFire"
     FireRate=0.087500
     AmmoClass=Class'NicePack.NiceSingleAmmo'
     ShakeRotMag=(X=75.000000,Y=75.000000,Z=250.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.250000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stMP'
     aimerror=30.000000
}
