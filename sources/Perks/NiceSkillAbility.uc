class NiceSkillAbility extends NiceSkill
    dependson(NiceAbilityManager)
    abstract;
var NiceAbilityManager.NiceAbilityDescription skillAbility;
// Functions that are called when skills becomes active / deactivated
function static SkillSelected(NicePlayerController nicePlayer){
    if(nicePlayer != none && nicePlayer.abilityManager != none)
       nicePlayer.abilityManager.AddAbility(default.skillAbility);
    super.SkillSelected(nicePlayer);
}
function static SkillDeSelected(NicePlayerController nicePlayer){
    if(nicePlayer != none && nicePlayer.abilityManager != none)
       nicePlayer.abilityManager.RemoveAbility(default.skillAbility.ID);
    super.SkillDeSelected(nicePlayer);
}
defaultproperties
{
}
