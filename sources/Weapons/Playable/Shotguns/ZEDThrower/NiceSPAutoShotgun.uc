class NiceSPAutoShotgun extends NiceWeapon;
// Toggle semi/auto fire
simulated function DoToggle (){}
// Set the new fire mode on the server
function ServerChangeFireMode(bool bNewWaitForRelease){}
exec function SwitchModes(){}
simulated function WeaponTick(float dt)
{
    local float SteamCharge;
    local rotator DialRot;
    super.WeaponTick(dt);
    if(Level.NetMode!=NM_DedicatedServer){


    }
}
defaultproperties
{
}