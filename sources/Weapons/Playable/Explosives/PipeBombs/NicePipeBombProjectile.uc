class NicePipeBombProjectile extends ScrnPipeBombProjectile;
function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex){
    local bool bIsFakePlayer;
    if(KFMonster(instigatedBy) != none && KFMonster(instigatedBy).Health <= 0)
    if(damageType == class'NiceDamTypePipeBomb' || Damage < 5 || (Damage < 25 && damageType.IsA('SirenScreamDamage')))
    bIsFakePlayer = (KFPawn(instigatedBy) != none || FakePlayerPawn(instigatedBy) != none) && (instigatedBy.PlayerReplicationInfo == none || instigatedBy.PlayerReplicationInfo.bOnlySpectator);
    bIsFakePlayer = bIsFakePlayer || (instigatedBy == none && !DamageType.default.bCausedByWorld);
    // Don't let our own explosives blow this up!!!
    if(bIsFakePlayer || (KFPawn(instigatedBy) != none && Instigator != none && Instigator != instigatedBy))
    if(damageType == class'SirenScreamDamage')
    else
}
defaultproperties
{
}