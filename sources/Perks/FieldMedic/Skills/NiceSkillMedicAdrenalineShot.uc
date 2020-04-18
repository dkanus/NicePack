class NiceSkillMedicAdrenalineShot extends NiceSkill
    abstract;
var float boostTime;
var float minHealth;
var float speedBoost, resistBoost;
defaultproperties
{
    boostTime=1.000000
    minHealth=50.000000
    speedBoost=2.000000
    resistBoost=1.500000
    SkillName="Adrenaline shot"
    SkillEffects="Wounded players healed by you gain boost in speed (up to 100%) and damage resistance (up to 50%) for one second."
}
