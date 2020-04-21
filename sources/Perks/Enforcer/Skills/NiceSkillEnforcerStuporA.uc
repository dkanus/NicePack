class NiceSkillEnforcerStuporA extends NiceSkill
   abstract;
var string abilityID;
var float coolDown;
var float radius;
var float painScore;

function static SkillSelected(NicePlayerController nicePlayer){
    local NiceAbilityManager.NiceAbilityDescription stupor;
    if(nicePlayer == none)                  return;
    if(nicePlayer.abilityManager == none)   return;
    stupor.ID   = default.abilityID;
    stupor.icon = Texture'NicePackT.HudCounter.demo';
    stupor.cooldownLength = default.cooldown;
    stupor.canBeCancelled = false;
    nicePlayer.abilityManager.AddAbility(stupor);
}
function static SkillDeSelected(NicePlayerController nicePlayer){
    if(nicePlayer == none)                  return;
    if(nicePlayer.abilityManager == none)   return;
    nicePlayer.abilityManager.RemoveAbility(default.abilityID);
}

defaultproperties
{
   abilityID="stupor"
   cooldown=30.000000
   radius=800.000000 // ~16 meters, I think
   painScore=600.0
   SkillName="Stupor"
   SkillEffects="Stun or flinch small zeds in 16 meter radius around you."
}
