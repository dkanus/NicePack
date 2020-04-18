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
    reloadType=RTYPE_SINGLE
    FirstPersonFlashlightOffset=(X=-25.000000,Y=-18.000000,Z=8.000000)
    MagCapacity=6
    ReloadRate=0.444444
    ReloadAnim="Reload"
    ReloadAnimRate=1.200000
    bHoldToReload=True
    WeaponReloadAnim="Reload_Shotgun"
    Weight=6.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=65.000000
    SleeveNum=0
    TraderInfoTexture=Texture'NicePackT.Moss12.Trader_Moss12'
    MeshRef="NicePackA.Moss12Weapon"
    SkinRefs(0)="NicePackT.Moss12.Moss12_2048x2048"
    SelectSoundRef="NicePackSnd.SG_Select"
    HudImageRef="NicePackT.Moss12.Trader_Moss12_unselected"
    SelectedHudImageRef="NicePackT.Moss12.Trader_Moss12_selected"
    PlayerIronSightFOV=70.000000
    ZoomedDisplayFOV=40.000000
    FireModeClass(0)=Class'NicePack.NiceMoss12Fire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    AIRating=0.600000
    CurrentRating=0.600000
    Description="Lightened pump shotgun model. Shoots weaker rounds, but is easy to reload."
    DisplayFOV=65.000000
    Priority=15
    InventoryGroup=3
    GroupOffset=1
    PickupClass=Class'NicePack.NiceMoss12Pickup'
    PlayerViewOffset=(X=20.000000,Y=18.750000,Z=-7.500000)
    BobDamping=7.000000
    AttachmentClass=Class'NicePack.NiceMoss12Attachment'
    IconCoords=(X1=169,Y1=172,X2=245,Y2=208)
    ItemName="Moss 12"
    TransientSoundVolume=1.000000
}
