class NiceM99SniperRifle extends NiceScopedWeapon;
#exec OBJ LOAD FILE=..\Textures\KF_Weapons5_Scopes_Trip_T.utx
simulated function PostBeginPlay(){
    local AutoReloadAnimDesc reloadDesc;
    autoReloadsDescriptions.Length = 0;
    reloadDesc.canInterruptFrame    = 0.43;
    reloadDesc.trashStartFrame      = 0.882;
    reloadDesc.resumeFrame          = 0.473;
    reloadDesc.speedFrame           = 0.129;
    reloadDesc.animName = 'Fire';
    autoReloadsDescriptions[0] = reloadDesc;
    reloadDesc.animName = 'Fire_Iron';
    autoReloadsDescriptions[1] = reloadDesc;
    super.PostBeginPlay();
}
simulated function bool StartFire(int Mode){
    if(super.StartFire(Mode)){
    }
    return false;
}
defaultproperties
{
}