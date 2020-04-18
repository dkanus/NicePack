class NiceM32GrenadeLauncher extends NiceWeapon;
simulated function fillSubReloadStages(){
    // Loading 6 shells during 300 frames tops, with first shell loaded at frame 40, with 49 frames between load moments
    generateReloadStages(6, 300, 40, 49);
}
defaultproperties
{
    bChangeClipIcon=True
    bChangeBulletsIcon=True
    hudClipTexture=Texture'KillingFloor2HUD.HUD.Hud_M79'
    hudBulletsTexture=Texture'KillingFloor2HUD.HUD.Hud_M79'
    reloadType=RTYPE_SINGLE
    MagCapacity=6
    ReloadRate=1.634000
    ReloadAnim="Reload"
    ReloadAnimRate=1.000000
    bHoldToReload=True
    WeaponReloadAnim="Reload_M32_MGL"
    Weight=7.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=65.000000
    SleeveNum=2
    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_M32'
    bIsTier3Weapon=True
    MeshRef="KF_Weapons2_Trip.M32_MGL_Trip"
    SkinRefs(0)="KF_Weapons2_Trip_T.Special.M32_cmb"
    SkinRefs(1)="KF_Weapons2_Trip_T.Special.Aimpoint_sight_shdr"
    SelectSoundRef="KF_M79Snd.M79_Select"
    HudImageRef="KillingFloor2HUD.WeaponSelect.M32_unselected"
    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.M32"
    PlayerIronSightFOV=70.000000
    ZoomedDisplayFOV=40.000000
    FireModeClass(0)=Class'NicePack.NiceM32Fire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.650000
    CurrentRating=0.650000
    Description="An advanced semi automatic grenade launcher. Launches high explosive grenades."
    DisplayFOV=65.000000
    Priority=210
    InventoryGroup=4
    GroupOffset=6
    PickupClass=Class'NicePack.NiceM32Pickup'
    PlayerViewOffset=(X=18.000000,Y=20.000000,Z=-6.000000)
    BobDamping=6.000000
    AttachmentClass=Class'NicePack.NiceM32Attachment'
    IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
    ItemName="M32 Grenade Launcher"
    LightType=LT_None
    LightBrightness=0.000000
    LightRadius=0.000000
}
