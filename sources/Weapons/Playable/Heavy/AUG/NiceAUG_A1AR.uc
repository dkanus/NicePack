class NiceAUG_A1AR extends NiceScopedWeapon;
#EXEC OBJ LOAD FILE=HMG_T.utx
#EXEC OBJ LOAD FILE=HMG_S.uax
#EXEC OBJ LOAD FILE=HMG_A.ukx
simulated function AltFire(float F){
    if(ReadyToFire(0))
}
exec function SwitchModes(){
    DoToggle();
}
defaultproperties
{
}