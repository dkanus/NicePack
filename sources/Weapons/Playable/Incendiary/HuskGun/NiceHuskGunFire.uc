class NiceHuskGunFire extends ScrnHuskGunFire;
/*
var int         AmmoInCharge;     //current charged amount  var() int       MaxChargeAmmo;    //maximum charge

function Timer()
{
    //local PlayerController Player;
    //consume ammo while charging
    if ( HoldTime > 0.0  && !bNowWaiting && AmmoInCharge < MaxChargeAmmo && Weapon.AmmoAmount(ThisModeNum) > 0 ) {   
    }
    super.Timer();
}
function Charge()
{
    local int AmmoShouldConsumed;
    if( HoldTime < MaxChargeTime)
    else
    if (AmmoShouldConsumed != AmmoInCharge) {
    }
}
function float GetChargeAmount()
{
  return float(AmmoInCharge) / float(MaxChargeAmmo);
}
simulated function bool AllowFire()
{
    return (Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire);
}
*/
//overrided to restore old damage radius
//(c) PooSH
function PostSpawnProjectile(Projectile P)
{
    local HuskGunProjectile HGP;
    super(KFShotgunFire).PostSpawnProjectile(P);
    HGP = HuskGunProjectile(p);
    if ( HGP != none ) {
    }
}
/*
//copy pasted and cutted out ammo consuming, because we did it in time
function ModeDoFire()
{
    local float Rec;
    if (!AllowFire() && HoldTime ~= 0)
    Spread = Default.Spread;
    Rec = 1;
  
    if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
    {
    }
    if( !bFiringDoesntAffectMovement )
    {
    }
    if (!AllowFire() && HoldTime ~= 0)
    if (MaxHoldTime > 0.0)
    // server
    if (Weapon.Role == ROLE_Authority)
    {



    }
    // client
    if (Instigator.IsLocallyControlled())
    {
    }
    else // server
    {
    }
    Weapon.IncrementFlashCount(ThisModeNum);
    // set the next firing time. must be careful here so client and server do not get out of sync
    if (bFireOnRelease)
    {
    }
    else
    {
    }
    Load = AmmoPerFire;
    HoldTime = 0;
    AmmoInCharge = 0;
    if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != none)
    {
    }
    // client
    if (Instigator.IsLocallyControlled())
    {
    }
}
*/
defaultproperties
{
}