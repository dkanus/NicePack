class NiceDamTypePipeBomb extends NiceWeaponDamageType;
static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth)
{
	HitEffects[0] = class'HitSmoke';
	if(VictimHealth <= 0)
		HitEffects[1] = class'KFHitFlame';
	else if (FRand() < 0.8)
		HitEffects[1] = class'KFHitFlame';
}
defaultproperties
{
}