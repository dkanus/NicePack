class NiceMoss12Z extends NiceWeapon;
var()   float   ThrowGrenadeAnimRate;
var()   name    ThrowGrenadeAnim;
simulated function fillSubReloadStages(){
    // Loading 8 shells during 175 frames tops, with first shell loaded at frame 16, with 17 frames between load moments
    generateReloadStages(8, 175, 16, 17);
    reloadStages[3] = 69.0 / 175.0;
    reloadStages[4] = 87.0 / 175.0;
    reloadStages[5] = 105.0 / 175.0;
    reloadStages[6] = 123.0 / 175.0;
    reloadStages[7] = 140.0 / 175.0;
}
defaultproperties
{
}