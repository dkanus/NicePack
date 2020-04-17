class NiceSkillSharpshooterHardWork extends NiceSkill
    abstract;
var float zoomBonus;
var float zoomSpeedBonus;
var float reloadBonus;
var float fireRateBonus;
var float recoilMult;

defaultproperties
{
     zoomBonus=0.750000
     zoomSpeedBonus=0.500000
     ReloadBonus=0.500000
     fireRateBonus=0.300000
     recoilMult=0.500000
     SkillName="Hard work"
     SkillEffects="Reload up to 50% faster, shoot up to 30% faster and recoil only for half as much. Additionally, you can switch to/from iron sights twice as fast and zoom 25% further while crouched."
}
