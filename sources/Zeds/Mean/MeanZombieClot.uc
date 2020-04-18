class MeanZombieClot extends NiceZombieClot;
#exec OBJ LOAD FILE=MeanZedSkins.utx
function int ModBodyDamage(out int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, KFPlayerReplicationInfo KFPRI, optional float lockonTime){
    local bool bDecreaseDamage;
    // Decrease damage if needed
    bDecreaseDamage = false;
    if(damageType != none)
       bDecreaseDamage = (headshotLevel <= 0.0) && damageType.default.bCheckForHeadShots;
    if(damageType != none && damageType.default.heatPart > 0)
       bDecreaseDamage = false;
    if(bDecreaseDamage && HeadHealth > 0)
       Damage *= 0.5;
    return super.ModBodyDamage(Damage, instigatedBy, hitlocation, momentum, damageType, headshotLevel, KFPRI, lockonTime);
}
defaultproperties
{
    MenuName="Mean Clot"
    Skins(0)=Combiner'MeanZedSkins.clot_cmb'
}
