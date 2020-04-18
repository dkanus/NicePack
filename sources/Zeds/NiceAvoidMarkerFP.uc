class NiceAvoidMarkerFP extends NiceAvoidMarker;
var NiceZombieFleshpound niceFP;
state BigMeanAndScary
{
Begin:
    StartleBots();
    Sleep(1.0);
    GoTo('Begin');
}
function InitFor(NiceMonster V){
    if(V != none){
       niceFP = NiceZombieFleshpound(V);
       SetCollisionSize(niceFP.CollisionRadius * 3, niceFP.CollisionHeight + CollisionHeight);
       SetBase(niceFP);
       GoToState('BigMeanAndScary');
    }
}
function Touch( actor Other ){
    if((Pawn(Other) != none) && KFMonsterController(Pawn(Other).Controller) != none && RelevantTo(Pawn(Other)))
       KFMonsterController(Pawn(Other).Controller).AvoidThisMonster(niceFP);
}
function bool RelevantTo(Pawn P){
    local NiceMonster niceZed;
    niceZed = NiceMonster(P);
    if(niceZed != none && niceZed.default.Health >= 1500)
       return false;
    return (niceFP != none && VSizeSquared(niceFP.Velocity) >= 75 && Super.RelevantTo(P) && niceFP.Velocity dot (P.Location - niceFP.Location) > 0 );
}
function StartleBots(){
    local KFMonster P;
    if(niceFP != none)
       ForEach CollidingActors(class'KFMonster', P, CollisionRadius)
           if(RelevantTo(P))
               KFMonsterController(P.Controller).AvoidThisMonster(niceFP);
}
defaultproperties
{
}
