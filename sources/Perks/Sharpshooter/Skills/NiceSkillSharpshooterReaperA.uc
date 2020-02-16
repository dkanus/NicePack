class NiceSkillSharpshooterReaperA extends NiceSkill
    abstract;
var string abilityID;
var float cooldown;
function static SkillSelected(NicePlayerController nicePlayer){
    local NiceAbilityManager.NiceAbilityDescription reaper;
    if(nicePlayer == none)                  return;
    if(nicePlayer.abilityManager == none)   return;
    reaper.ID   = default.abilityID;
    reaper.icon = Texture'NicePackT.HudCounter.t4th';
    reaper.cooldownLength = default.cooldown;
    reaper.canBeCancelled = true;
    nicePlayer.abilityManager.AddAbility(reaper);
}
function static SkillDeSelected(NicePlayerController nicePlayer){
    if(nicePlayer == none)                  return;
    if(nicePlayer.abilityManager == none)   return;
    nicePlayer.abilityManager.RemoveAbility(default.abilityID);
}
defaultproperties
{
    abilityID="Reaper"
    cooldown=24.000000
    SkillName="Reaper"
    SkillEffects="If it would take 2 head-shot to kill the zed, - it'll die from one."
}
