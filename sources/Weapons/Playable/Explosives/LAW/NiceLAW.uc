class NiceLAW extends NiceWeapon;
simulated function ZoomIn(bool bAnimateTransition){
    if(Level.TimeSeconds < FireMode[0].NextFireTime)
    super.ZoomIn(bAnimateTransition);
    if(bAnimateTransition){
    }
}
simulated function ZoomOut(bool bAnimateTransition){
    super.ZoomOut(false);
    if(bAnimateTransition)
}
simulated function PostBeginPlay(){
    local AutoReloadAnimDesc reloadDesc;
    autoReloadsDescriptions.Length = 0;
    reloadDesc.canInterruptFrame    = 0.07;
    reloadDesc.trashStartFrame      = 0.601;
    reloadDesc.resumeFrame          = 0.07;
    reloadDesc.speedFrame           = 0.07;
    reloadDesc.animName = 'AimFire';
    autoReloadsDescriptions[0] = reloadDesc;
    super.PostBeginPlay();
}
defaultproperties
{
}