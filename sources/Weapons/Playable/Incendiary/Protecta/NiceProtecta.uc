class NiceProtecta extends Protecta;
// Use alt fire to switch fire modes
simulated function AltFire(float F)
{
    if(ReadyToFire(0))
    {
    }
}
exec function SwitchModes()
{
    DoToggle();
}
defaultproperties
{
}