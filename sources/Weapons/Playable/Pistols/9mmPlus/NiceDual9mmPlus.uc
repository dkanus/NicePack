class NiceDual9mmPlus extends NiceDualies;
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
simulated function ApplyLaserState(){
    super(NiceWeapon).ApplyLaserState();
}
defaultproperties
{
}