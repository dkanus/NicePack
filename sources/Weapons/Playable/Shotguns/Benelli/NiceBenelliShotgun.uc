class NiceBenelliShotgun extends NiceWeapon;
simulated function fillSubReloadStages(){
    // Loading 6 shells during 174 frames tops, with first shell loaded at frame 22, with 24 frames between load moments
    generateReloadStages(6, 174, 22, 24);
}
defaultproperties
{
}