class NiceJudgeBarrelSmoke extends SpeedTrail;
var float WaitCount;
simulated function Tick(float DeltaTime){
    super.Tick(DeltaTime);
    WaitCount += DeltaTime;
    if(WaitCount > 1.500000){
       mRegen = False;
       mRegenRange[0]=0.000000;
       mRegenRange[1]=0.000000;
    }
}
defaultproperties
{
    mLifeRange(0)=1.000000
    mLifeRange(1)=1.000000
    mRegenRange(0)=30.000000
    mRegenRange(1)=30.000000
    mDirDev=(X=0.100000,Y=0.100000,Z=0.010000)
    mPosDev=(X=0.000000,Y=0.000000,Z=0.000000)
    mSpeedRange(0)=50.000000
    mSpeedRange(1)=50.000000
    mSizeRange(0)=10.000000
    mSizeRange(1)=10.000000
    mGrowthRate=-10.000000
    mColorRange(0)=(A=128)
    mColorRange(1)=(A=128)
    LifeSpan=3.000000
}
