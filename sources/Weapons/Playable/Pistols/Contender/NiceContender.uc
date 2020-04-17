class NiceContender extends NiceScopedWeapon;
simulated function PostBeginPlay(){
    local AutoReloadAnimDesc reloadDesc;
    autoReloadsDescriptions.Length = 0;
    reloadDesc.canInterruptFrame    = 3 / 37;
    reloadDesc.trashStartFrame      = 21 / 37;
    reloadDesc.resumeFrame          = 13 / 37;
    reloadDesc.speedFrame           = 3 / 37;
    reloadDesc.animName = 'Fire';
    autoReloadsDescriptions[0] = reloadDesc;
    super.PostBeginPlay();
}
defaultproperties
{    lenseMaterialID=1    scopePortalFOVHigh=8.000000    scopePortalFOV=8.000000    tileSize=512    ZoomMatRef="NicePackT.Contender.gdcw_acog_FB"    ScriptedTextureFallbackRef="NicePackT.Contender.alpha_lens_64x64"    CrosshairTexRef="NicePackT.Contender.gdcw_acog"    bChangeClipIcon=True    hudClipTexture=Texture'KillingFloorHUD.HUD.Hud_Single_Bullet'    reloadType=RTYPE_AUTO    bHasScope=True    ZoomedDisplayFOVHigh=25.000000    MagCapacity=1    ReloadRate=1.376000    ReloadAnim="Reload"    ReloadAnimRate=1.000000    WeaponReloadAnim="Reload_HuntingShotgun"    Weight=3.000000    bHasAimingMode=True    IdleAimAnim="Iron_Idle"    StandardDisplayFOV=55.000000    SleeveNum=3    TraderInfoTexture=Texture'NicePackT.Contender.g2contender_trader'    bIsTier2Weapon=True    MeshRef="NicePackA.Contender.G2ContenderMesh"    SkinRefs(0)="NicePackT.Contender.Contender_diffuse_cmb"    SkinRefs(1)="NicePackT.Contender.alpha_lens_64x64"    SkinRefs(2)="NicePackT.Contender.uv1024_cmb"    SkinRefs(3)="KF_Weapons2_Trip_T.hands.BritishPara_Hands_1st_P"    SkinRefs(4)="NicePackT.Contender.Bullet_cmb"    SelectSoundRef="NicePackSnd.Contender.G2_Pickup"    HudImageRef="NicePackT.Contender.g2contender_unselected"    SelectedHudImageRef="NicePackT.Contender.g2contender_selected"    PlayerIronSightFOV=40.000000    ZoomTime=0.285000    ZoomedDisplayFOV=25.000000    FireModeClass(0)=Class'NicePack.NiceContenderFire'    FireModeClass(1)=Class'KFMod.NoFire'    PutDownAnim="PutDown"    PutDownAnimRate=1.000000    AIRating=0.550000    CurrentRating=0.550000    Description="Thompson G2 Contender - hinting pistol"    DisplayFOV=55.000000    Priority=120    InventoryGroup=2    GroupOffset=16    PickupClass=Class'NicePack.NiceContenderPickup'    PlayerViewOffset=(X=13.000000,Y=14.000000,Z=-5.500000)    BobDamping=4.500000    AttachmentClass=Class'NicePack.NiceContenderAttachment'    ItemName="Thompson Contender"
}
