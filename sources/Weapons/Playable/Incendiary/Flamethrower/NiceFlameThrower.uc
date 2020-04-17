//=============================================================================
// FlameChucker
//=============================================================================
class NiceFlameThrower extends ScrnFlameThrower;
var bool bFiring;
simulated function bool StartFire(int Mode)
{
  if(MagAmmoRemaining >= 1 && FireMode[Mode].AllowFire())
    bFiring = true;
  return Super.StartFire(Mode);
}
simulated event StopFire(int Mode)
{
  if(MagAmmoRemaining < 1 || Mode != 0){
    bFiring = false;
    Super.StopFire(0);
  }
}
simulated function bool PutDown()
{
    if ( bFiring && Instigator != none && Instigator.PendingWeapon != none && AmmoAmount(0) > 0 ) {
    }
    return Super.PutDown();
}
function bool AllowReload()
{
    if ( bFiring )
}
simulated function WeaponTick(float dt)
{
  if(MagAmmoRemaining < 1 && bFiring)
    StartFire(0);
  Super.WeaponTick(dt);
//  if(FireMode[0].bIsFiring)
//    Skins[4] = Shader 'KillingFloorWeapons.FlameThrower.FTFireShader';
//  else
//    Skins[4] = default.Skins[4];
}
defaultproperties
{
}