class NiceSkillDemoManiac extends NiceSkill
    abstract;
var float reloadBoostTime;
var float reloadSpeedup;
function static SkillSelected(NicePlayerController nicePlayer){
    local NicePack niceMutator;
    super.SkillSelected(nicePlayer);
    niceMutator = class'NicePack'.static.Myself(nicePlayer.Level);
    if(niceMutator == none || niceMutator.Role == Role_AUTHORITY)       return;
    niceMutator.AddCounter("npDemoManiac", Texture'NicePackT.HudCounter.demo', false, default.class);
}
function static SkillDeSelected(NicePlayerController nicePlayer){
    local NicePack niceMutator;
    super.SkillDeSelected(nicePlayer);
    niceMutator = class'NicePack'.static.Myself(nicePlayer.Level);
    if(niceMutator == none || niceMutator.Role == Role_AUTHORITY)       return;
    niceMutator.RemoveCounter("npDemoManiac");
}
function static int UpdateCounterValue(string counterName, NicePlayerController nicePlayer){
    local NiceHumanPawn nicePawn;
    if(nicePlayer == none || counterName != "npDemoManiac")       return 0;
    nicePawn = NiceHumanPawn(nicePlayer.pawn);
    if(nicePawn == none || nicePawn.maniacTimeout <= 0.0)       return 0;
    return Ceil(nicePawn.maniacTimeout);
}
defaultproperties
{    reloadBoostTime=5.000000    reloadSpeedup=1.500000    SkillName="Maniac"    SkillEffects="Reload 50% faster for 5 seconds after killing something."
}
