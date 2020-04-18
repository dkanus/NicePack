class NiceBenelliShotgun extends NiceWeapon;
simulated function fillSubReloadStages(){
    // Loading 6 shells during 174 frames tops, with first shell loaded at frame 22, with 24 frames between load moments
    generateReloadStages(6, 174, 22, 24);
}
defaultproperties
{
    bChangeClipIcon=True
    hudClipTexture=Texture'KillingFloorHUD.HUD.Hud_Single_Bullet'
    reloadType=RTYPE_SINGLE
    FirstPersonFlashlightOffset=(X=-25.000000,Y=-18.000000,Z=8.000000)
    MagCapacity=6
    ReloadRate=0.750000
    ReloadAnim="Reload"
    ReloadAnimRate=1.200000
    bHoldToReload=True
    WeaponReloadAnim="Reload_Shotgun"
    Weight=5.000000
    bTorchEnabled=True
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=65.000000
    SleeveNum=2
    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Beneli'
    bIsTier2Weapon=True
    MeshRef="KF_Wep_Benelli.Benelli_Trip"
    SkinRefs(0)="KF_Weapons4_Trip_T.Weapons.Benelli_M4_cmb"
    SkinRefs(1)="KF_Weapons2_Trip_T.Special.Aimpoint_sight_shdr"
    SelectSoundRef="KF_M4ShotgunSnd.WEP_Benelli_Foley_Select"
    HudImageRef="KillingFloor2HUD.WeaponSelect.Beneli_unselected"
    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Beneli"
    PlayerIronSightFOV=70.000000
    ZoomedDisplayFOV=40.000000
    FireModeClass(0)=Class'NicePack.NiceBenelliFire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    AIRating=0.600000
    CurrentRating=0.600000
    bShowChargingBar=True
    Description="A military tactical shotgun with semi automatic fire capability. Holds up to 6 shells. "
    DisplayFOV=65.000000
    Priority=170
    InventoryGroup=3
    GroupOffset=9
    PickupClass=Class'NicePack.NiceBenelliPickup'
    PlayerViewOffset=(X=20.000000,Y=18.750000,Z=-7.500000)
    BobDamping=7.000000
    AttachmentClass=Class'NicePack.NiceBenelliAttachment'
    IconCoords=(X1=169,Y1=172,X2=245,Y2=208)
    ItemName="Benelli shotgun"
    TransientSoundVolume=1.000000
}
