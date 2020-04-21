class NiceAvoidMarkerCarnage extends NiceAvoidMarker;

var float healthLevel;

function bool RelevantTo(Pawn P){
    local NiceMonster niceZed;
    niceZed = NiceMonster(P);
    if (niceZed != none && niceZed.default.health <= healthLevel)
    {
        return true;
    }
    return false;
}
defaultproperties
{
    lifespan = 2.5
}