class NiceJudgePistolFlash extends ROMuzzleFlash1st;
simulated function Trigger(Actor Other, Pawn EventInstigator){
    Emitters[0].SpawnParticle(2);
    Emitters[1].SpawnParticle(1);
}
defaultproperties
{

}