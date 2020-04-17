class NiceCrossbow extends NiceScopedWeapon;
simulated function PostBeginPlay(){
    local AutoReloadAnimDesc reloadDesc;
    autoReloadsDescriptions.Length = 0;
    reloadDesc.canInterruptFrame    = 0.349;
    reloadDesc.trashStartFrame      = 0.857;
    reloadDesc.resumeFrame          = 0.349;
    reloadDesc.speedFrame           = 0.143;
    reloadDesc.animName = 'Fire';
    autoReloadsDescriptions[0] = reloadDesc;
    reloadDesc.animName = 'Fire_Iron';
    autoReloadsDescriptions[1] = reloadDesc;
    super.PostBeginPlay();
}
// Adjust a single FOV based on the current aspect ratio. Adjust FOV is the default NON-aspect ratio adjusted FOV to adjust
simulated function float CalcAspectRatioAdjustedFOV(float AdjustFOV){
    local KFPlayerController KFPC;
    local float ResX, ResY;
    local float AspectRatio;
    KFPC = KFPlayerController(Level.GetLocalPlayerController());
    if(KFPC == none)
    ResX = float(GUIController(KFPC.Player.GUIController).ResX);
    ResY = float(GUIController(KFPC.Player.GUIController).ResY);
    AspectRatio = ResX / ResY;
    if(KFPC.bUseTrueWideScreenFOV && AspectRatio >= 1.60)
    else
}
simulated event Destroyed(){
    PreTravelCleanUp();
    Super.Destroyed();
}
defaultproperties
{
}