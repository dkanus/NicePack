class NiceMAC10Z extends NiceWeapon;
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax
simulated function AltFire(float F){
    DoToggle();
}
defaultproperties
{
}