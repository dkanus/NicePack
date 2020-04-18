class NiceCrossbow extends NiceScopedWeapon;
simulated function PostBeginPlay(){
    local AutoReloadAnimDesc reloadDesc;
    autoReloadsDescriptions.Length = 0;
    reloadDesc.canInterruptFrame    = 0.349;
    reloadDesc.trashStartFrame      = 0.857;
    reloadDesc.resumeFrame          = 0.349;
    reloadDesc.speedFrame           = 0.143;
    reloadDesc.animName = 'Fire';
    autoReloadsDescriptions[0] = reloadDesc;
    reloadDesc.animName = 'Fire_Iron';
    autoReloadsDescriptions[1] = reloadDesc;
    super.PostBeginPlay();
}
// Adjust a single FOV based on the current aspect ratio. Adjust FOV is the default NON-aspect ratio adjusted FOV to adjust
simulated function float CalcAspectRatioAdjustedFOV(float AdjustFOV){
    local KFPlayerController KFPC;
    local float ResX, ResY;
    local float AspectRatio;
    KFPC = KFPlayerController(Level.GetLocalPlayerController());
    if(KFPC == none)
       return AdjustFOV;
    ResX = float(GUIController(KFPC.Player.GUIController).ResX);
    ResY = float(GUIController(KFPC.Player.GUIController).ResY);
    AspectRatio = ResX / ResY;
    if(KFPC.bUseTrueWideScreenFOV && AspectRatio >= 1.60)
       return CalcFOVForAspectRatio(AdjustFOV);
    else
       return AdjustFOV;
}
simulated event Destroyed(){
    PreTravelCleanUp();
    Super.Destroyed();
}
defaultproperties
{
    lenseMaterialID=2
    scopePortalFOVHigh=22.000000
    scopePortalFOV=12.000000
    ZoomMatRef="KillingFloorWeapons.Xbow.CommandoCrossFinalBlend"
    ScriptedTextureFallbackRef="KF_Weapons_Trip_T.CBLens_cmb"
    CrosshairTexRef="KillingFloorWeapons.CommandoCross"
    reloadType=RTYPE_AUTO
    bHasScope=True
    ZoomedDisplayFOVHigh=35.000000
    ForceZoomOutOnFireTime=0.400000
    MagCapacity=1
    ReloadRate=0.010000
    ReloadAnimRate=1.000000
    WeaponReloadAnim="Reload_Crossbow"
    Weight=9.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=65.000000
    TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_CrossBow'
    bIsTier2Weapon=True
    MeshRef="KF_Weapons_Trip.Crossbow_Trip"
    SkinRefs(0)="KF_Weapons_Trip_T.Rifles.crossbow_cmb"
    SelectSoundRef="KF_XbowSnd.Xbow_Select"
    HudImageRef="KillingFloorHUD.WeaponSelect.Crossbow_unselected"
    SelectedHudImageRef="KillingFloorHUD.WeaponSelect.Crossbow"
    PlayerIronSightFOV=32.000000
    ZoomedDisplayFOV=60.000000
    FireModeClass(0)=Class'NicePack.NiceCrossbowFire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.650000
    CurrentRating=0.650000
    Description="Recreational hunting weapon, equipped with powerful scope and firing trigger. Comes with special ammunition, designed to tear through low-resistance materials."
    DisplayFOV=65.000000
    Priority=140
    CustomCrosshair=11
    CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
    InventoryGroup=4
    GroupOffset=1
    PickupClass=Class'NicePack.NiceCrossbowPickup'
    PlayerViewOffset=(X=15.000000,Y=16.000000,Z=-12.000000)
    BobDamping=6.000000
    AttachmentClass=Class'NicePack.NiceCrossbowAttachment'
    IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
    ItemName="Compound Crossbow"
    LightType=LT_None
    LightBrightness=0.000000
    LightRadius=0.000000
}
