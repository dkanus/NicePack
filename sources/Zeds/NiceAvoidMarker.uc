class NiceAvoidMarker extends AvoidMarker;
function bool RelevantTo(Pawn P){
    local NiceZombieFleshpound niceFP;
    niceFP = NiceZombieFleshpound(P);
    if(niceFP != none && niceFP.IsInState('RageCharging'))
       return false;
    return super.RelevantTo(P);
}
defaultproperties
{
}
