class NiceMK23Pistol extends NiceSingle;
simulated function AltFire(float F){
    if(bIsDual)
    else
}
simulated function SecondDoToggle(){
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