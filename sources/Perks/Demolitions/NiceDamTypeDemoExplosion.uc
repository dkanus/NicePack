class NiceDamTypeDemoExplosion extends NiceDamageTypeVetDemolitions;
static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth){
    HitEffects[0] = class'HitSmoke';
    if(VictimHealth <= 0)
       HitEffects[1] = class'KFHitFlame';
    else if(FRand() < 0.8)
       HitEffects[1] = class'KFHitFlame';
}
defaultproperties
{
    stunMultiplier=0.600000
    bIsExplosive=True
    DeathString="%o filled %k's body with shrapnel."
    FemaleSuicide="%o blew up."
    MaleSuicide="%o blew up."
    bLocationalHit=False
    bThrowRagdoll=True
    bExtraMomentumZ=True
    DamageThreshold=1
    DeathOverlayMaterial=Combiner'Effects_Tex.GoreDecals.PlayerDeathOverlay'
    DeathOverlayTime=999.000000
    KDamageImpulse=3000.000000
    KDeathVel=300.000000
    KDeathUpKick=250.000000
    HumanObliterationThreshhold=150
}
