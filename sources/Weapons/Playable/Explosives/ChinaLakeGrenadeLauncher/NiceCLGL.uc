class NiceCLGL extends NiceWeapon;
simulated function fillSubReloadStages(){
    // Loading 4 shells during 94 frames tops, with first shell loaded at frame 13, with 22 frames between load moments
    generateReloadStages(3, 94, 13, 22);
}
simulated function SetupReloadVars(optional bool bIsActive, optional int animationIndex){
    if(MagAmmoRemainingClient == 0){
       generateReloadStages(4, 145, 42, 22);
       reloadStages[0] = 0.2;
       ReloadAnim='ReloadLong';
    }
    else{
       generateReloadStages(3, 94, 13, 22);
       ReloadAnim='Reload';
    }
    UpdateSingleReloadVars();
    super.SetupReloadVars(bIsActive, animationIndex);
}
defaultproperties
{
    bChangeClipIcon=True
    bChangeBulletsIcon=True
    hudClipTexture=Texture'KillingFloor2HUD.HUD.Hud_M79'
    hudBulletsTexture=Texture'KillingFloor2HUD.HUD.Hud_M79'
    reloadType=RTYPE_SINGLE
    MagCapacity=4
    ReloadRate=0.850000
    ReloadAnim="Reload"
    ReloadAnimRate=1.000000
    bHoldToReload=True
    WeaponReloadAnim="Reload_Shotgun"
    Weight=6.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=65.000000
    SleeveNum=0
    TraderInfoTexture=Texture'NicePackT.CLGL.CLGL_HUD_Trader'
    bIsTier3Weapon=True
    MeshRef="NicePackA.CLGLMesh1st"
    SkinRefs(1)="NicePackT.CLGL.CLGL_CMB"
    SelectSoundRef="NicePackSnd.CLGL.CLGLSelect"
    HudImageRef="NicePackT.CLGL.CLGL_HUD_UnSelected"
    SelectedHudImageRef="NicePackT.CLGL.CLGL_HUD_Selected"
    PlayerIronSightFOV=70.000000
    ZoomedDisplayFOV=40.000000
    FireModeClass(0)=Class'NicePack.NiceCLGLFire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.650000
    CurrentRating=0.650000
    Description="A pump-action grenade launcher. Launches high-explosive grenades."
    DisplayFOV=65.000000
    Priority=210
    InventoryGroup=4
    GroupOffset=6
    PickupClass=Class'NicePack.NiceCLGLPickup'
    PlayerViewOffset=(X=25.000000,Y=20.000000,Z=-6.000000)
    BobDamping=6.000000
    AttachmentClass=Class'NicePack.NiceCLGLAttachment'
    IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
    ItemName="China Lake Grenade Launcher"
    LightType=LT_None
    LightBrightness=0.000000
    LightRadius=0.000000
}
