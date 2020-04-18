class NiceSkillSupportDiversity extends NiceSkill
    abstract;
var int bonusWeight;
static function UpdateWeight(NicePlayerController nicePlayer){
    local NiceHumanPawn nicePawn;
    if(nicePawn == none || nicePawn.KFPRI == none) return;
    nicePawn.maxCarryWeight = nicePawn.default.maxCarryWeight;
	if(nicePawn.KFPRI.clientVeteranSkill != none)
       nicePawn.maxCarryWeight += nicePawn.KFPRI.clientVeteranSkill.static.AddCarryMaxWeight(nicePawn.KFPRI);
}
function static SkillSelected(NicePlayerController nicePlayer){
    UpdateWeight(nicePlayer);
}
function static SkillDeSelected(NicePlayerController nicePlayer){
    UpdateWeight(nicePlayer);
}
defaultproperties
{
    bonusWeight=5
    SkillName="Diversity"
    SkillEffects="Gain +5 weight slots."
}
