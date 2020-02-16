class NiceSkillSharpshooterDieAlready extends NiceSkill
    abstract;
var float bleedOutTime[5];
defaultproperties
{
    BleedOutTime(0)=2.0f
    BleedOutTime(1)=1.5f
    BleedOutTime(2)=1.25f
    BleedOutTime(3)=1.0f
    BleedOutTime(4)=0.25f
    SkillName="Die already"
    SkillEffects="All zeds decapitated by you drop faster."
}
