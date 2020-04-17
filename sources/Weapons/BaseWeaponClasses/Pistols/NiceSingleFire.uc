class NiceSingleFire extends NiceFire;
var bool bWasInZedTime;
simulated function ModeTick(float delta){
    local NicePlayerController nicePlayer;
    if(instigator != none)
       nicePlayer = NicePlayerController(instigator.controller);
    if(nicePlayer != none && nicePlayer.IsZedTimeActive() != bWasInZedTime){
       bWasInZedTime = !bWasInZedTime;
       if(bWasInZedTime)
           niceNextFireTime = Level.TimeSeconds + (niceNextFireTime - Level.TimeSeconds) * KFGameType(Level.Game).ZedTimeSlomoScale;
       nextFireTime = niceNextFireTime;
    }
    super.ModeTick(delta);
}

defaultproperties
{
     FireAimedAnim="Fire_Iron"
     RecoilRate=0.070000
     maxVerticalRecoilAngle=300
     maxHorizontalRecoilAngle=50
     ShellEjectClass=Class'ROEffects.KFShellEject9mm'
     ShellEjectBoneName="Shell_eject"
     bRandomPitchFireSound=False
     DamageMin=35
     DamageMax=35
     Momentum=10000.000000
     bPawnRapidFireAnim=True
     bWaitForRelease=True
     bAttachSmokeEmitter=True
     TransientSoundVolume=1.800000
     FireAnimRate=1.500000
     TweenTime=0.025000
     FireForce="AssaultRifleFire"
     FireRate=0.175000
     AmmoClass=Class'NicePack.NiceSingleAmmo'
     ShakeRotMag=(X=75.000000,Y=75.000000,Z=250.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.350000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stMP'
     aimerror=30.000000
}
