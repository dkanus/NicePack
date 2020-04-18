class NiceSkillCommandoCriticalFocus extends NiceSkill
    abstract;
var float cooldown;
var float healthBoundary;
function static SkillSelected(NicePlayerController nicePlayer){
    local NicePack niceMutator;
    super.SkillSelected(nicePlayer);
    niceMutator = class'NicePack'.static.Myself(nicePlayer.Level);
    if(niceMutator == none || niceMutator.Role == Role_AUTHORITY)
       return;
    niceMutator.AddCounter("npCommandoCriticalFocus", Texture'NicePackT.HudCounter.commandoCounter', false, default.class);
}
function static SkillDeSelected(NicePlayerController nicePlayer){
    local NicePack niceMutator;
    super.SkillDeSelected(nicePlayer);
    niceMutator = class'NicePack'.static.Myself(nicePlayer.Level);
    if(niceMutator == none || niceMutator.Role == Role_AUTHORITY)
       return;
    niceMutator.RemoveCounter("npCommandoCriticalFocus");
}
function static int UpdateCounterValue(string counterName, NicePlayerController nicePlayer){
    local NiceHumanPawn nicePawn;
    if(nicePlayer == none || counterName != "npCommandoCriticalFocus")
       return 0;
    nicePawn = NiceHumanPawn(nicePlayer.pawn);
    if(nicePawn == none)
       return 0;
    return Ceil(nicePawn.forcedZedTimeCountDown);
}
defaultproperties
{
    cooldown=30.000000
    healthBoundary=50.000000
    SkillName="Critical focus"
    SkillEffects="Activates zed time once you fall below 50% health. Has a cooldown of 30 seconds."
}
