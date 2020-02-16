class NiceAvoidMarkerExplosive extends NiceAvoidMarker;
function bool RelevantTo(Pawn P){
    local NiceMonster niceZed;
    niceZed = NiceMonster(P);
    if(niceZed != none && niceZed.default.Health >= 1000 && NiceZombieFleshpound(P) == none)       return false;
    return super.RelevantTo(P);
}
defaultproperties
{
}
