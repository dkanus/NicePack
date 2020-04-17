class NiceSkillSharpshooterGunslingerA extends NiceSkillAbility
    abstract;
var string abilityID;
var float cooldown, duration;
var float reloadMult, movementMult, fireRateMult;
function static SkillSelected(NicePlayerController nicePlayer){
    local NiceAbilityManager.NiceAbilityDescription reaper;
    if(nicePlayer == none)                  return;
    if(nicePlayer.abilityManager == none)   return;
    reaper.ID   = default.abilityID;
    reaper.icon = Texture'NicePackT.HudCounter.playful';
    reaper.cooldownLength = default.cooldown;
    reaper.canBeCancelled = false;
    nicePlayer.abilityManager.AddAbility(reaper);
}
function static SkillDeSelected(NicePlayerController nicePlayer){
    if(nicePlayer == none)                  return;
    if(nicePlayer.abilityManager == none)   return;
    nicePlayer.abilityManager.RemoveAbility(default.abilityID);
}

defaultproperties
{
     abilityID="Gunslinger"
     cooldown=80.000000
     Duration=15.000000
     reloadMult=1.500000
     movementMult=1.250000
     fireRateMult=1.300000
     SkillName="Gunslinger"
     SkillEffects="Reload, fire and move faster. All with no recoil."
}
