class NiceSkillSharpshooterArdour extends NiceSkill
    abstract;

var float headshotKillReduction[5];
var float justHeadshotReduction;

defaultproperties
{
    justHeadshotReduction=0.250000
    headshotKillReduction(0)=0.5f
    headshotKillReduction(1)=1.0f
    headshotKillReduction(2)=1.25f
    headshotKillReduction(3)=1.5f
    headshotKillReduction(4)=2.0f
    SkillName="Ardour"
    SkillEffects="Head-shotting enemies reduces your cooldowns."
}
