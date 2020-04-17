class NiceM79GrenadeLauncher extends NiceWeapon;
simulated function PostBeginPlay(){
    local AutoReloadAnimDesc reloadDesc;
    autoReloadsDescriptions.Length = 0;
    reloadDesc.canInterruptFrame    = 0.101;
    reloadDesc.trashStartFrame      = 0.65;//0.869;
    reloadDesc.resumeFrame          = 0.101;
    reloadDesc.speedFrame           = 0.101;
    reloadDesc.animName = 'Fire';
    autoReloadsDescriptions[0] = reloadDesc;
    reloadDesc.animName = 'Iron_Fire';
    autoReloadsDescriptions[1] = reloadDesc;
    super.PostBeginPlay();
}
defaultproperties
{
}