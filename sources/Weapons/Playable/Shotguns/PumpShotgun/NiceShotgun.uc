class NiceShotgun extends NiceWeapon;

simulated function fillSubReloadStages(){
    // Loading 8 shells during 173 frames tops, with first shell loaded at frame 15, with 18 frames between load moments
    generateReloadStages(8, 173, 15, 18);
    // Make corrections, based on notify sound positioning
    /*reloadStages[0] = 16.0 / 173.0;
    reloadStages[2] = 50.0 / 173.0;
    reloadStages[7] = 140.0 / 173.0;*/
}

defaultproperties
{
}