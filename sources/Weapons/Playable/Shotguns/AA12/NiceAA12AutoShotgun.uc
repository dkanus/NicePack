class NiceAA12AutoShotgun extends NiceWeapon;

// Use alt fire to switch fire modes
simulated function AltFire(float F){
    DoToggle();
}

exec function SwitchModes(){
    DoToggle();
}

defaultproperties
{
    Weight=6.000000
}