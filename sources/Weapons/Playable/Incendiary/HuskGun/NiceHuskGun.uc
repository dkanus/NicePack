/**
 * Attempt to make Husk Gun actually usefull.
 */
 
class NiceHuskGun extends ScrnHuskGun;
/*
// both fire modes share the same ammo pool, so don't give ammo twice
function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned)
{
    local bool bJustSpawnedAmmo;
    local int addAmount, InitialAmount;
    local float AddMultiplier;
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);
    if ( FireMode[m] != none && FireMode[m].AmmoClass != none )
    {










    }
}
*/
/*
simulated function bool ConsumeAmmo( int Mode, float Load, optional bool bAmountNeededIsMax )
{
  return super.ConsumeAmmo(0, Load, bAmountNeededIsMax);
}
simulated function int AmmoAmount(int mode)
{
    return super.AmmoAmount(0);
}
*/
/*
//v2.60: Reload speed bonus affects charge rate
simulated function bool StartFire(int Mode)
{
    local ScrnHuskGunFire f;
    local KFPlayerReplicationInfo KFPRI;
    if ( super.StartFire(Mode) ) {
    }
    return false;
}
*/
defaultproperties
{
}