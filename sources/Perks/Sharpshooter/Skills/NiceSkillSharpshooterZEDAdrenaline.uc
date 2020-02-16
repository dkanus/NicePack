class NiceSkillSharpshooterZEDAdrenaline extends NiceSkill
    abstract;
function static SkillSelected(NicePlayerController nicePlayer){
    local NicePack niceMutator;
    super.SkillSelected(nicePlayer);
    niceMutator = class'NicePack'.static.Myself(nicePlayer.Level);
    if(niceMutator == none || niceMutator.Role == Role_AUTHORITY)       return;
    niceMutator.AddCounter("npGunsAdrenaline", Texture'NicePackT.HudCounter.variant', false, default.class);
}
function static SkillDeSelected(NicePlayerController nicePlayer){
    local NicePack niceMutator;
    super.SkillDeSelected(nicePlayer);
    niceMutator = class'NicePack'.static.Myself(nicePlayer.Level);
    if(niceMutator == none || niceMutator.Role == Role_AUTHORITY)       return;
    niceMutator.RemoveCounter("npGunsAdrenaline");
}
function static int UpdateCounterValue(string counterName, NicePlayerController nicePlayer){
    local NicePack niceMutator;
    if(nicePlayer == none || counterName != "npGunsAdrenaline" || !nicePlayer.IsZedTimeActive())       return 0;
    if(nicePlayer.bJunkieExtFailed)       return 0;
    if(nicePlayer.Pawn != none)       niceMutator = class'NicePack'.static.Myself(nicePlayer.Pawn.Level);
    if(niceMutator == none)       return 0;
    return niceMutator.junkieNextGoal - niceMutator.junkieDoneHeadshots;
}
defaultproperties
{    SkillName="Adrenaline junkie"    SkillEffects="Prolong zed-time by making head-shots. Each consecutive extension requires 1 more head-shot than a previous one. Body-shotting removes your ability to prolong zed-time."
}
