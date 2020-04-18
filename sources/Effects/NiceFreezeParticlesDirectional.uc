//  ScrN copy
class NiceFreezeParticlesDirectional extends NiceFreezeParticlesBase;
simulated function Trigger(Actor other, Pawn eventInstigator){
	emitters[0].SpawnParticle(1);
}
defaultproperties
{
    Style=STY_Additive
    bHardAttach=True
    bDirectional=True
}
