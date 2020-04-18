class NiceSkillEnforcerFullCounter extends NiceSkill
    abstract;
var int layersAmount;
var float coolDown;
var float damageReduction;
var float damageReductionWeak;
function static SkillSelected(NicePlayerController nicePlayer){
    local NicePack niceMutator;
    local NiceHumanPawn nicePawn;
    super.SkillSelected(nicePlayer);
    niceMutator = class'NicePack'.static.Myself(nicePlayer.Level);
    if(nicePlayer != none)
       nicePawn = NiceHumanPawn(nicePlayer.pawn);
    if(nicePawn != none)
       nicePawn.hmgShieldLevel = default.layersAmount;
    if(niceMutator == none || niceMutator.Role == Role_AUTHORITY)
       return;
    niceMutator.AddCounter("npHMGFullCounter", Texture'NicePackT.HudCounter.fullCounter', true, default.class);
}
function static SkillDeSelected(NicePlayerController nicePlayer){
    local NicePack niceMutator;
    super.SkillDeSelected(nicePlayer);
    niceMutator = class'NicePack'.static.Myself(nicePlayer.Level);
    if(niceMutator == none || niceMutator.Role == Role_AUTHORITY)
       return;
    niceMutator.RemoveCounter("npHMGFullCounter");
}
function static int UpdateCounterValue(string counterName, NicePlayerController nicePlayer){
    local NiceHumanPawn nicePawn;
    if(nicePlayer == none || counterName != "npHMGFullCounter")
       return 0;
    nicePawn = NiceHumanPawn(nicePlayer.pawn);
    if(nicePawn == none)
       return 0;
    return nicePawn.hmgShieldLevel;
}
defaultproperties
{
    layersAmount=5
    cooldown=15.000000
    SkillName="Full counter"
    SkillEffects="Gives you 5 protection layers, each of which can block a weak hit. One layer restores 15 seconds after you've been hit. Can't withstand strong attacks or attacks of huge enough zeds."
}
