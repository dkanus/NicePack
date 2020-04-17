class NiceM4M203AssaultRifle extends NiceAssaultRifle;
#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax
simulated function PostBeginPlay(){
    local AutoReloadAnimDesc reloadDesc;
    autoReloadsDescriptions.Length = 0;
    reloadDesc.canInterruptFrame    = 0.217;
    reloadDesc.trashStartFrame      = 0.679;
    reloadDesc.resumeFrame          = 0.32;
    reloadDesc.speedFrame           = 0.019;
    reloadDesc.animName = 'Fire_Secondary';
    autoReloadsDescriptions[0] = reloadDesc;
    reloadDesc.animName = 'Fire_Iron_Secondary';
    autoReloadsDescriptions[1] = reloadDesc;
    super.PostBeginPlay();
}
defaultproperties
{
}