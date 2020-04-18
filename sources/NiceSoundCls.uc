class NiceSoundCls extends Effects;
var Sound   effectSound;
var float   effectVolume;
simulated function PostBeginPlay(){
    if(effectSound != none)
       PlaySound(effectSound,, effectVolume);
}
defaultproperties
{
    DrawType=DT_None
    LifeSpan=0.100000
}
