class NiceCLGL extends NiceWeapon;
simulated function fillSubReloadStages(){
    // Loading 4 shells during 94 frames tops, with first shell loaded at frame 13, with 22 frames between load moments
    generateReloadStages(3, 94, 13, 22);
}
simulated function SetupReloadVars(optional bool bIsActive, optional int animationIndex){
    if(MagAmmoRemainingClient == 0){
    }
    else{
    }
    UpdateSingleReloadVars();
    super.SetupReloadVars(bIsActive, animationIndex);
}
defaultproperties
{
}