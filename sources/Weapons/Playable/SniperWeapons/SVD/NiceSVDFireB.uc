class NiceSVDFireB extends KFMeleeFire;

simulated function bool AllowFire()
{
    if(KFWeapon(Weapon).bIsReloading)
    if(KFPawn(Instigator).SecondaryItem!=none)
    if(KFPawn(Instigator).bThrowingNade)
    if ( KFWeapon(Weapon).bAimingRifle )
    return Super.AllowFire();
}
defaultproperties
{
}