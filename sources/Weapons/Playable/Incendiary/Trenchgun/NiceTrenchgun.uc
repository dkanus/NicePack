class NiceTrenchgun extends NiceWeapon;
simulated function fillSubReloadStages(){
    // Loading 6 shells during 143 frames tops, with first shell loaded at frame 14, with 18 frames between load moments
    generateReloadStages(6, 143, 14, 18);
}
defaultproperties
{
}