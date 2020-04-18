class NiceChainGun extends ChainGun;
// Don't use alt fire to toggle
simulated function AltFire(float F){}
// Don't switch fire mode
exec function SwitchModes(){}
defaultproperties
{
    MagCapacity=160
    Weight=12.000000
    FireModeClass(0)=Class'NicePack.NiceChainGunFire'
    FireModeClass(1)=Class'NicePack.NiceChainGunAltFire'
    PickupClass=Class'NicePack.NiceChainGunPickup'
    ItemName="Patriarch's Chaingun"
}
