class NiceWinchesterFire extends NiceFire;

simulated function FillFireType(){
    local NWFireType fireType;
    fireType.fireTypeName = "crude";
    fireType.weapon.bulletsAmount = 1;
    fireType.weapon.ammoPerFire = 1;
    fireType.weapon.bCanFireIncomplete = false;
    fireType.weapon.fireRate = 0.562500;
    fireType.movement.bulletClass = class'NiceBullet';
    fireType.movement.speed = 37950.0;
    fireType.rebound.recoilVertical = 150;
    fireType.rebound.recoilHorizontal = 64;
    fireType.bullet.damage = 136;
    fireType.bullet.momentum = 18000;
    fireType.bullet.shotDamageType = class'NicePack.NiceDamTypeWinchester';
    fireTypes[0] = fireType;
    fireType.fireTypeName = "fine";
    fireType.bullet.damage = 10;
    fireType.bullet.shotDamageType = class'NicePack.NiceDamTypeWinGun';
    fireTypes[1] = fireType;
}

defaultproperties
{
    DamageType=Class'NicePack.NiceDamTypeWinchester'
    bPawnRapidFireAnim=true
    bWaitForRelease=false
    bModeExclusive=False
    bAttachSmokeEmitter=True
    TransientSoundVolume=1.800000
    AmmoClass=Class'NicePack.NiceWinchesterAmmo'
    ShakeRotMag=(X=100.000000,Y=100.000000,Z=500.000000)
    ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
    ShakeRotTime=2.000000
    ShakeOffsetMag=(X=10.000000,Y=3.000000,Z=12.000000)
    ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
    ShakeOffsetTime=2.000000
    FlashEmitterClass=Class'ROEffects.MuzzleFlash1stKar'
}