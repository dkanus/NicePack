class NiceProtecta extends Protecta;
// Use alt fire to switch fire modes
simulated function AltFire(float F)
{
    if(ReadyToFire(0))
    {
       DoToggle();
    }
}
exec function SwitchModes()
{
    DoToggle();
}
defaultproperties
{
    FireModeClass(0)=Class'NicePack.NiceProtectaFire'
    PickupClass=Class'NicePack.NiceProtectaPickup'
    ItemName="Flare Shotgun 'Protecta' NW"
}
