class NiceSVDFireB extends KFMeleeFire;

simulated function bool AllowFire()
{
    if(KFWeapon(Weapon).bIsReloading)       return false;
    if(KFPawn(Instigator).SecondaryItem!=none)       return false;
    if(KFPawn(Instigator).bThrowingNade)       return false;
    if ( KFWeapon(Weapon).bAimingRifle )       return false;
    return Super.AllowFire();
}
defaultproperties
{    MeleeDamage=65    ProxySize=0.150000    weaponRange=90.000000    DamagedelayMin=0.160000    DamagedelayMax=0.160000    hitDamageClass=Class'NicePack.NiceDamTypeSVDm'    MeleeHitSounds(0)=Sound'KF_AxeSnd.AxeImpactBase.Axe_HitFlesh4'    HitEffectClass=Class'ScrnWeaponPack.SVDHitEffect'    bWaitForRelease=True    FireAnim="MeleeAttack"    FireRate=1.100000    BotRefireRate=1.100000
}
