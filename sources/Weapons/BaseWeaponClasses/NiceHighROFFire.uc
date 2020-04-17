class NiceHighROFFire extends NiceFire;
// sound
var sound   FireEndSound;           // The sound to play at the end of the ambient fire sound
var sound   FireEndStereoSound;     // The sound to play at the end of the ambient fire sound in first person stereo
var float   AmbientFireSoundRadius; // The sound radius for the ambient fire sound
var sound   AmbientFireSound;       // How loud to play the looping ambient fire sound
var byte    AmbientFireVolume;      // The ambient fire sound
var string  FireEndSoundRef;
var string  FireEndStereoSoundRef;
var string  AmbientFireSoundRef;
//MEANTODO
/*
static function PreloadAssets(LevelInfo LevelInfo, optional KFFire Spawned){
    super.PreloadAssets(LevelInfo, Spawned);
    if(default.FireEndSound != none && default.FireEndSoundRef != "")
       default.FireEndSound = sound(DynamicLoadObject(default.FireEndSoundRef, class'sound', true));
    if(default.FireEndStereoSound == none){
       if(default.FireEndStereoSoundRef != "")
           default.FireEndStereoSound = sound(DynamicLoadObject(default.FireEndStereoSoundRef, class'Sound', true));
       else
           default.FireEndStereoSound = default.FireEndSound;
    }
    if(default.AmbientFireSoundRef != "")
       default.AmbientFireSound = sound(DynamicLoadObject(default.AmbientFireSoundRef, class'sound', true));
    if(NiceHighROFFire(Spawned) != none){
       NiceHighROFFire(Spawned).FireEndSound = default.FireEndSound;
       NiceHighROFFire(Spawned).FireEndStereoSound = default.FireEndStereoSound;
       NiceHighROFFire(Spawned).AmbientFireSound = default.AmbientFireSound;
    }
}
static function bool UnloadAssets(){
    super.UnloadAssets();
    default.FireEndSound = none;
    default.FireEndStereoSound = none;
    default.AmbientFireSound = none;
    return true;
}
// Sends the fire class to the looping state
function StartFiring(){
    if(!bWaitForRelease && !currentContext.bIsBursting)
       GotoState('FireLoop');
    else
       Super.StartFiring();
}
// Handles toggling the weapon attachment's ambient sound on and off
function PlayAmbientSound(Sound aSound){
    local WeaponAttachment WA;
    WA = WeaponAttachment(Weapon.ThirdPersonActor);
    if(Weapon == none || (WA == none))
       return;
    if(aSound == none){
       WA.SoundVolume = WA.default.SoundVolume;
       WA.SoundRadius = WA.default.SoundRadius;
    }
    else{
       WA.SoundVolume = AmbientFireVolume;
       WA.SoundRadius = AmbientFireSoundRadius;
    }
    WA.AmbientSound = aSound;
}
// Make sure we are in the fire looping state when we fire
event ModeDoFire(){
    if(!bWaitForRelease && !currentContext.bIsBursting){
       if(AllowFire() && IsInState('FireLoop'))
           Super.ModeDoFire();
    }
    else
      Super.ModeDoFire();
}
state FireLoop
{
    function BeginState(){
       NextFireTime = Level.TimeSeconds - 0.1;
       if(KFWeap.bAimingRifle)
           Weapon.LoopAnim(FireLoopAimedAnim, FireLoopAnimRate, TweenTime);
       else
           Weapon.LoopAnim(FireLoopAnim, FireLoopAnimRate, TweenTime);
       PlayAmbientSound(AmbientFireSound);
    }
    function PlayFiring(){}
    function ServerPlayFiring(){}
    function EndState(){
       Weapon.AnimStopLooping();
       PlayAmbientSound(none);
       if(Weapon.Instigator != none && Weapon.Instigator.IsLocallyControlled() &&
           Weapon.Instigator.IsFirstPerson() && StereoFireSound != none)
           Weapon.PlayOwnedSound(FireEndStereoSound,SLOT_none,AmbientFireVolume/127,,AmbientFireSoundRadius,,false);
       else
           Weapon.PlayOwnedSound(FireEndSound,SLOT_none,AmbientFireVolume/127,,AmbientFireSoundRadius);
       Weapon.StopFire(ThisModeNum);
    }
    function StopFiring(){
       GotoState('');
    }
    function ModeTick(float dt){
       Super.ModeTick(dt);
       if(!bIsFiring || !AllowFire()){
           GotoState('');
           return;
       }
    }
}
function PlayFireEnd(){
    if(!bWaitForRelease)
       Super.PlayFireEnd();
}*/
defaultproperties
{
    AmbientFireSoundRadius=500.000000
    AmbientFireVolume=255
    FireAimedAnim="Fire_Iron"
    FireEndAimedAnim="Fire_Iron_End"
    FireLoopAimedAnim="Fire_Iron_Loop"
    bAccuracyBonusForSemiAuto=True
    bPawnRapidFireAnim=True
    TransientSoundVolume=1.800000
    FireLoopAnim="Fire_Loop"
    FireEndAnim="Fire_End"
    TweenTime=0.025000
    FireForce="AssaultRifleFire"
    BotRefireRate=0.100000
    aimerror=30.000000
}
