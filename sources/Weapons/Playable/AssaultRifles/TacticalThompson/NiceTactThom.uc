class NiceTactThom extends NiceAssaultRifle;
#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax
simulated function AltFire(float F){
    ToggleLaser();
}
simulated function ToggleLaser(){
    if(!Instigator.IsLocallyControlled()) 
    // Will redo this bit later, but so far it'll have to do
    if(LaserType == 0)
    else
    ApplyLaserState();
}
defaultproperties
{
}