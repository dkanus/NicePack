class NiceColt extends NiceWeapon;
simulated function fillSubReloadStages(){
    // Loading 6 shells during 132 frames tops, with first shell loaded at frame 36, with 11 frames between load moments
    generateReloadStages(6, 132, 36, 11);
}
defaultproperties
{
    reloadType=RTYPE_SINGLE
    alwaysPlayAnimEnd=True
    FirstPersonFlashlightOffset=(X=-20.000000,Y=-22.000000,Z=8.000000)
    MagCapacity=6
    ReloadRate=6.100000
    ReloadAnim="Reload"
    ReloadAnimRate=1.200000
    bHoldToReload=True
    WeaponReloadAnim="Reload_Revolver"
    Weight=5.000000
    bHasAimingMode=True
    IdleAimAnim="IronIdle"
    StandardDisplayFOV=70.000000
    SleeveNum=0
    TraderInfoTexture=Texture'ScrnWeaponPack_T.Colt.Trader_WColt'
    MeshRef="ScrnWeaponPack_A.colt_weapon"
    SkinRefs(1)="ScrnWeaponPack_T.Colt.ColtV2_T"
    HudImageRef="ScrnWeaponPack_T.Colt.WColt_Unselected"
    SelectedHudImageRef="ScrnWeaponPack_T.Colt.WColt"
    ZoomedDisplayFOV=65.000000
    FireModeClass(0)=Class'NicePack.NiceColtFire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    SelectSound=Sound'KF_9MMSnd.9mm_Select'
    AIRating=0.250000
    CurrentRating=0.250000
    bShowChargingBar=True
    Description="The Colt Python is a double action handgun chambered for the .357 Magnum cartridge, built on Colt's large I-frame. Pythons have a reputation for accuracy, smooth trigger pull, and a tight cylinder lock-up."
    DisplayFOV=70.000000
    Priority=110
    InventoryGroup=2
    GroupOffset=15
    PickupClass=Class'NicePack.NiceColtPickup'
    PlayerViewOffset=(X=20.000000,Y=25.000000,Z=-10.000000)
    BobDamping=6.000000
    AttachmentClass=Class'NicePack.NiceColtAttachment'
    IconCoords=(X1=434,Y1=253,X2=506,Y2=292)
    ItemName="Colt Python"
}
