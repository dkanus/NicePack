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
    {       Ammo[m] = Ammunition(Instigator.FindInventoryType(FireMode[m].AmmoClass));       bJustSpawnedAmmo = false;
       if ( bNoAmmoInstances )       {           if ( (FireMode[m].AmmoClass == none) || ((m != 0) && (FireMode[m].AmmoClass == FireMode[0].AmmoClass)) )               return;
           InitialAmount = FireMode[m].AmmoClass.Default.InitialAmount;
           if(WP!=none && WP.bThrown==true)               InitialAmount = WP.AmmoAmount[m];           else           {               // Other change - if not thrown, give the gun a full clip               MagAmmoRemaining = MagCapacity;           }
           if ( Ammo[m] != none )           {               addamount = InitialAmount + Ammo[m].AmmoAmount;               Ammo[m].Destroy();           }           else               addAmount = InitialAmount;
           AddAmmo(addAmount,m);       }       else       {           if ( (Ammo[m] == none) && (FireMode[m].AmmoClass != none) )           {               Ammo[m] = Spawn(FireMode[m].AmmoClass, Instigator);               Instigator.AddInventory(Ammo[m]);               bJustSpawnedAmmo = true;           }           else if ( (m == 0) || (FireMode[m].AmmoClass != FireMode[0].AmmoClass) )               bJustSpawnedAmmo = ( bJustSpawned || ((WP != none) && !WP.bWeaponStay) );
               // and here is the modification for instanced ammo actors
           if(WP!=none && WP.bThrown==true)           {               addAmount = WP.AmmoAmount[m];           }           else if ( bJustSpawnedAmmo )           {               if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )               {                   AddMultiplier = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.AddExtraAmmoFor(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), FireMode[m].AmmoClass);               }               else               {                   AddMultiplier = 1.0;               }
               if (default.MagCapacity == 0)                   addAmount = 0;  // prevent division by zero.               else                   addAmount = Ammo[m].InitialAmount * (float(MagCapacity) / float(default.MagCapacity)) * AddMultiplier;           }
           //removed: WP.Class == class'BoomstickPickup' -- (c) PooSH           if ( WP != none  && m > 0 )           {               return;           }
           Ammo[m].AddAmmo(addAmount);           Ammo[m].GotoState('');       }
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
    if ( super.StartFire(Mode) ) {       f = ScrnHuskGunFire(FireMode[Mode]);       if ( Mode == 0 && f != none ) {           f.MaxChargeTime = f.default.MaxChargeTime;           KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);           if ( KFPRI != none && KFPRI.ClientVeteranSkill != none)               f.MaxChargeTime /= KFPRI.ClientVeteranSkill.static.GetReloadSpeedModifier(KFPRI, self);       }       return true;
    }
    return false;
}
*/
defaultproperties
{    Weight=8.000000    FireModeClass(0)=Class'NicePack.NiceHuskGunFire'    FireModeClass(1)=Class'NicePack.NiceHuskGunAltFire'    PickupClass=Class'NicePack.NiceHuskGunPickup'    ItemName="Husk Gun / Napalm Launcher NW"
}
