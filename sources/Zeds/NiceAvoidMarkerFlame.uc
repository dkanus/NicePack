class NiceAvoidMarkerFlame extends NiceAvoidMarker;
function bool RelevantTo(Pawn P){
    local NiceMonster niceZed;
    niceZed = NiceMonster(P);
    if(niceZed != none && niceZed.bFireImmune)
       return false;
    return super.RelevantTo(P);
}
defaultproperties
{
}
