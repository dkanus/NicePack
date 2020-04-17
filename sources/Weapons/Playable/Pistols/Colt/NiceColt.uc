class NiceColt extends NiceWeapon;
simulated function fillSubReloadStages(){
    // Loading 6 shells during 132 frames tops, with first shell loaded at frame 36, with 11 frames between load moments
    generateReloadStages(6, 132, 36, 11);
}
defaultproperties
{
}