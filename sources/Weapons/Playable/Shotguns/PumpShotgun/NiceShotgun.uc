class NiceShotgun extends NiceWeapon;

simulated function fillSubReloadStages(){
    // Loading 8 shells during 173 frames tops, with first shell loaded at frame 15, with 18 frames between load moments
    generateReloadStages(8, 173, 15, 18);
    // Make corrections, based on notify sound positioning
    reloadStages[0] = 16.0 / 173.0;
    reloadStages[2] = 50.0 / 173.0;
    reloadStages[7] = 140.0 / 173.0;
}

defaultproperties
{
    bChangeClipIcon=True
    hudClipTexture=Texture'KillingFloorHUD.HUD.Hud_Single_Bullet'
    reloadType=RTYPE_SINGLE
    FirstPersonFlashlightOffset=(X=-25.000000,Y=-18.000000,Z=8.000000)
    ForceZoomOutOnFireTime=0.010000
    MagCapacity=8
    ReloadRate=0.666667
    ReloadAnim="Reload"
    ReloadAnimRate=1.000000
    bHoldToReload=True
    WeaponReloadAnim="Reload_Shotgun"
    Weight=4.000000
    bTorchEnabled=True
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=65.000000
    TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Combat_Shotgun'
    MeshRef="KF_Weapons_Trip.Shotgun_Trip"
    SkinRefs(0)="KF_Weapons_Trip_T.Shotguns.shotgun_cmb"
    SelectSoundRef="KF_PumpSGSnd.SG_Select"
    HudImageRef="KillingFloorHUD.WeaponSelect.combat_shotgun_unselected"
    SelectedHudImageRef="KillingFloorHUD.WeaponSelect.combat_shotgun"
    PlayerIronSightFOV=70.000000
    ZoomedDisplayFOV=40.000000
    FireModeClass(0)=Class'NicePack.NiceShotgunFire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    AIRating=0.600000
    CurrentRating=0.600000
    bShowChargingBar=True
    Description="A rugged tactical pump action shotgun common to police divisions the world over. It accepts a maximum of 8 shells and can fire in rapid succession."
    DisplayFOV=65.000000
    Priority=135
    InventoryGroup=3
    GroupOffset=2
    PickupClass=Class'NicePack.NiceShotgunPickup'
    PlayerViewOffset=(X=20.000000,Y=18.750000,Z=-7.500000)
    BobDamping=7.000000
    AttachmentClass=Class'NicePack.NiceShotgunAttachment'
    IconCoords=(X1=169,Y1=172,X2=245,Y2=208)
    ItemName="Shotgun"
    TransientSoundVolume=1.000000
}