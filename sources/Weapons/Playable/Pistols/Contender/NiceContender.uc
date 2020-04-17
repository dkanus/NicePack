class NiceContender extends NiceScopedWeapon;
simulated function PostBeginPlay(){
    local AutoReloadAnimDesc reloadDesc;
    autoReloadsDescriptions.Length = 0;
    reloadDesc.canInterruptFrame    = 3 / 37;
    reloadDesc.trashStartFrame      = 21 / 37;
    reloadDesc.resumeFrame          = 13 / 37;
    reloadDesc.speedFrame           = 3 / 37;
    reloadDesc.animName = 'Fire';
    autoReloadsDescriptions[0] = reloadDesc;
    super.PostBeginPlay();
}
defaultproperties
{
}