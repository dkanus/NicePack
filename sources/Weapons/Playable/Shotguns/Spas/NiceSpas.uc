class NiceSpas extends NiceWeapon;

simulated function fillSubReloadStages(){
    // Loading 8 shells during 173 frames tops, with first shell loaded at frame 17, with 18 frames between load moments
    generateReloadStages(8, 173, 17, 18);
}

defaultproperties
{
    bChangeClipIcon=True
    hudClipTexture=Texture'KillingFloorHUD.HUD.Hud_Single_Bullet'
    reloadType=RTYPE_SINGLE
    ForceZoomOutOnFireTime=0.010000
    MagCapacity=5
    ReloadRate=0.666667
    ReloadAnim="Reload"
    ReloadAnimRate=1.000000
    bHoldToReload=True
    Weight=6.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=65.000000
    TraderInfoTexture=Texture'ScrnWeaponPack_T.Spas.Spas_Unselected'
    MeshRef="ScrnWeaponPack_A.spas12_1st"
    SkinRefs(0)="ScrnWeaponPack_T.SPAS.shotgun_cmb"
    SelectSoundRef="KF_PumpSGSnd.SG_Select"
    HudImageRef="ScrnWeaponPack_T.SPAS.Spas_Unselected"
    SelectedHudImageRef="ScrnWeaponPack_T.SPAS.Spas_Selected"
    PlayerIronSightFOV=70.000000
    ZoomedDisplayFOV=40.000000
    FireModeClass(0)=Class'NicePack.NiceSpasFire'
    FireModeClass(1)=Class'NicePack.NiceSpasAltFire'
    PutDownAnim="PutDown"
    AIRating=0.600000
    CurrentRating=0.600000
    Description="The SPAS12 is a dual-mode shotgun, that can also be used for firing slugs."
    DisplayFOV=65.000000
    Priority=135
    InventoryGroup=3
    GroupOffset=2
    PickupClass=Class'NicePack.NiceSpasPickup'
    PlayerViewOffset=(X=20.000000,Y=18.750000,Z=-7.500000)
    BobDamping=7.000000
    AttachmentClass=Class'NicePack.NiceSpasAttachment'
    IconCoords=(X1=169,Y1=172,X2=245,Y2=208)
    ItemName="SPAS-12"
    TransientSoundVolume=1.000000
}