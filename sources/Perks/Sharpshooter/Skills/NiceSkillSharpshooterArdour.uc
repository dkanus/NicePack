class NiceSkillSharpshooterArdour extends NiceSkill
    abstract;

var float headshotKillReduction[5];
var float justHeadshotReduction;

defaultproperties
{
     headshotKillReduction(0)=0.500000
     headshotKillReduction(1)=1.000000
     headshotKillReduction(2)=1.250000
     headshotKillReduction(3)=1.500000
     headshotKillReduction(4)=2.000000
     justHeadshotReduction=0.250000
     SkillName="Ardour"
     SkillEffects="Head-shotting enemies reduces your cooldowns."
}
