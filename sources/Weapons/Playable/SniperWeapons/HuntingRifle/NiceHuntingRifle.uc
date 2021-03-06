class NiceHuntingRifle extends NiceScopedWeapon;
defaultproperties
{
    lenseMaterialID=2
    scopePortalFOVHigh=22.000000
    scopePortalFOV=12.000000
    ZoomMatRef="ScrnWeaponPack_T.BDHR.RifleCrossFinal"
    ScriptedTextureFallbackRef="KF_Weapons_Trip_T.Rifles.CBLens_cmb"
    CrosshairTexRef="ScrnWeaponPack_T.BDHR.BDHR.HRCross"
    reloadPreEndFrame=0.180000
    reloadEndFrame=0.590000
    reloadChargeEndFrame=0.930000
    reloadChargeStartFrame=0.610000
    bHasScope=True
    ZoomedDisplayFOVHigh=45.000000
    MagCapacity=5
    ReloadRate=3.200000
    ReloadAnim="Reload"
    ReloadAnimRate=1.400000
    WeaponReloadAnim="Reload_M14"
    Weight=6.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=65.000000
    TraderInfoTexture=Texture'ScrnWeaponPack_T.BDHR.huntingrifle_Trader'
    MeshRef="ScrnWeaponPack_A.hunt_rifle"
    SkinRefs(0)="ScrnWeaponPack_T.BDHR.HR_Final"
    SkinRefs(1)="KF_Weapons2_Trip_T.hands.BritishPara_Hands_1st_P"
    SkinRefs(2)="KF_Weapons_Trip_T.Rifles.CBLens_cmb"
    SelectSoundRef="KF_PumpSGSnd.SG_Select"
    HudImageRef="ScrnWeaponPack_T.BDHR.HR_Unselected"
    SelectedHudImageRef="ScrnWeaponPack_T.BDHR.HR_selected"
    PlayerIronSightFOV=32.000000
    ZoomedDisplayFOV=60.000000
    FireModeClass(0)=Class'NicePack.NiceHuntingRifleFire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.650000
    CurrentRating=0.650000
    Description="A rugged and reliable scoped rifle with great penetrative power."
    DisplayFOV=65.000000
    Priority=10
    CustomCrosshair=11
    CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
    InventoryGroup=4
    GroupOffset=3
    PickupClass=Class'NicePack.NiceHuntingRiflePickup'
    PlayerViewOffset=(X=15.000000,Y=16.000000,Z=-4.000000)
    BobDamping=6.000000
    AttachmentClass=Class'NicePack.NiceHuntingRifleAttachment'
    IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
    ItemName="Hunting Rifle"
}
