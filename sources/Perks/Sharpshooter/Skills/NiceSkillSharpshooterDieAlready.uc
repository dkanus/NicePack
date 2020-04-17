class NiceSkillSharpshooterDieAlready extends NiceSkill
    abstract;
var float bleedOutTime[5];

defaultproperties
{
     BleedOutTime(0)=2.000000
     BleedOutTime(1)=1.500000
     BleedOutTime(2)=1.250000
     BleedOutTime(3)=1.000000
     BleedOutTime(4)=0.250000
     SkillName="Die already"
     SkillEffects="All zeds decapitated by you drop faster."
}
