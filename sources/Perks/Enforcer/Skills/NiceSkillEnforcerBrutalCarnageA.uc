class NiceSkillEnforcerBrutalCarnageA extends NiceSkill
   abstract;
var string abilityID;
var float coolDown;
var float avoidRadius;

function static SkillSelected(NicePlayerController nicePlayer){
    local NiceAbilityManager.NiceAbilityDescription carnage;
    if(nicePlayer == none)                  return;
    if(nicePlayer.abilityManager == none)   return;
    carnage.ID   = default.abilityID;
    carnage.icon = Texture'NicePackT.HudCounter.demo';
    carnage.cooldownLength = default.cooldown;
    carnage.canBeCancelled = false;
    nicePlayer.abilityManager.AddAbility(carnage);
}
function static SkillDeSelected(NicePlayerController nicePlayer){
    if(nicePlayer == none)                  return;
    if(nicePlayer.abilityManager == none)   return;
    nicePlayer.abilityManager.RemoveAbility(default.abilityID);
}

defaultproperties
{
   abilityID="carnage"
   cooldown=60.000000
   avoidRadius=600.0
   SkillName="Brutal carnage"
   SkillEffects="Every zed killed withing next 10 seconds will cause other zeds to fear the killspot for 2.5 seconds."
}
