class NiceSkillHeavyStablePosition extends NiceSkill
    abstract;
var float recoilDampeningBonus;
function static SkillSelected(NicePlayerController nicePlayer){
    local NicePack niceMutator;
    super.SkillSelected(nicePlayer);
    niceMutator = class'NicePack'.static.Myself(nicePlayer.Level);
    if(niceMutator == none || niceMutator.Role == Role_AUTHORITY)
       return;
    niceMutator.AddCounter("npHMGStablePosition", Texture'NicePackT.HudCounter.stability', false, default.class);
}
function static SkillDeSelected(NicePlayerController nicePlayer){
    local NicePack niceMutator;
    super.SkillDeSelected(nicePlayer);
    niceMutator = class'NicePack'.static.Myself(nicePlayer.Level);
    if(niceMutator == none || niceMutator.Role == Role_AUTHORITY)
       return;
    niceMutator.RemoveCounter("npHMGStablePosition");
}
function static int UpdateCounterValue(string counterName, NicePlayerController nicePlayer){
    local NiceHumanPawn nicePawn;
    if(nicePlayer == none || counterName != "npHMGStablePosition")
       return 0;
    nicePawn = NiceHumanPawn(nicePlayer.pawn);
    if(nicePawn == none || nicePawn.stationaryTime <= 0.0)
       return 0;
    return Min(10, Ceil(2 * nicePawn.stationaryTime) - 1);
}
defaultproperties
{
    recoilDampeningBonus=0.100000
    SkillName="Stable position"
    SkillEffects="Each half-second you're crouching and now moving - you gain 10% recoil dampening bonus."
}
