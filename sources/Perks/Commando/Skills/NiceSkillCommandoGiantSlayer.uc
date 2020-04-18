class NiceSkillCommandoGiantSlayer extends NiceSkill
    abstract;
var float bonusDamageMult;
var float healthStep;
defaultproperties
{
    healthStep=1000.000000
    bonusDamageMult=0.05000
    SkillName="Giant slayer"
    SkillEffects="For every 1000 of health zed currently has, you deal additional 5% damage."
}
