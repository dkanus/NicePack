class MeanPoisonInventory extends Inventory;
var float poisonStartTime, maxSpeedPenaltyTime, poisonSpeedDown;
simulated function Tick(float DeltaTime) {
    if(Level.TimeSeconds - poisonStartTime > maxSpeedPenaltyTime)       Destroy();
}
simulated function float GetMovementModifierFor(Pawn InPawn){
    local float actualSpeedDown;
    local class<NiceVeterancyTypes> niceVet;
    
    niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(InPawn.PlayerReplicationInfo);
    if(niceVet != none){       actualSpeedDown = 1.0 - (1.0 - poisonSpeedDown) * niceVet.static.SlowingModifier(KFPlayerReplicationInfo(InPawn.PlayerReplicationInfo));       actualSpeedDown = FMax(0.0, FMin(1.0, actualSpeedDown));       return actualSpeedDown;
    }
    // If something went wrong - ignore slowdown altogether
    return 1.0;
}
defaultproperties
{    maxSpeedPenaltyTime=5.000000    poisonSpeedDown=0.600000
}
