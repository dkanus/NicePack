class NiceSkillMedicInjection extends NiceSkill
    abstract;
var float boostTime, painTime;
var float withdrawalDamage, healthBoost;
var float bonusAccuracy, bonusMeleeDmg, bonusSpeed, bonusReload;
defaultproperties
{
    boostTime=30.000000
    painTime=60.000000
    withdrawalDamage=5.000000
    bonusAccuracy=3.000000
    bonusMeleeDmg=2.000000
    bonusSpeed=2.000000
    bonusReload=2.000000
    SkillName="Injection"
    SkillEffects="Once a wave your teammates can pickup a drug from you that will greatly boost their performance for 30 seconds, but suffer from withdrawal afterwards."
}
