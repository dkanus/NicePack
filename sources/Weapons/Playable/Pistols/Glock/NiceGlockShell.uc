class NiceGlockShell extends KFShellEject;
simulated function Trigger(Actor Other, Pawn EventInstigator){
    Emitters[0].SpawnParticle(1);
    Emitters[1].SpawnParticle(3);
}
defaultproperties
{

}