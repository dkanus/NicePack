class NiceJudgeBarrelSmoke extends SpeedTrail;
var float WaitCount;
simulated function Tick(float DeltaTime){
    super.Tick(DeltaTime);
    WaitCount += DeltaTime;
    if(WaitCount > 1.500000){
    }
}
defaultproperties
{
}