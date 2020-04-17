class NiceSpas extends NiceWeapon;

simulated function fillSubReloadStages(){
    // Loading 8 shells during 173 frames tops, with first shell loaded at frame 17, with 18 frames between load moments
    generateReloadStages(8, 173, 17, 18);
}

defaultproperties
{
}