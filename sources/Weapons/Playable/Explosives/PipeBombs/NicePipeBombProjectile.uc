class NicePipeBombProjectile extends ScrnPipeBombProjectile;
function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex){
    local bool bIsFakePlayer;
    if(KFMonster(instigatedBy) != none && KFMonster(instigatedBy).Health <= 0)       return;
    if(damageType == class'NiceDamTypePipeBomb' || Damage < 5 || (Damage < 25 && damageType.IsA('SirenScreamDamage')))       return;
    bIsFakePlayer = (KFPawn(instigatedBy) != none || FakePlayerPawn(instigatedBy) != none) && (instigatedBy.PlayerReplicationInfo == none || instigatedBy.PlayerReplicationInfo.bOnlySpectator);
    bIsFakePlayer = bIsFakePlayer || (instigatedBy == none && !DamageType.default.bCausedByWorld);
    // Don't let our own explosives blow this up!!!
    if(bIsFakePlayer || (KFPawn(instigatedBy) != none && Instigator != none && Instigator != instigatedBy))       return;
    if(damageType == class'SirenScreamDamage')       Disintegrate(HitLocation, vect(0,0,1));
    else       Explode(HitLocation, vect(0,0,1));
}
defaultproperties
{    Damage=2000.000000    MyDamageType=Class'NicePack.NiceDamTypePipeBomb'
}
