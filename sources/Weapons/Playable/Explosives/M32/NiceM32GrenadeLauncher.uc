class NiceM32GrenadeLauncher extends NiceWeapon;
simulated function fillSubReloadStages(){
    // Loading 6 shells during 300 frames tops, with first shell loaded at frame 40, with 49 frames between load moments
    generateReloadStages(6, 300, 40, 49);
}
defaultproperties
{
}