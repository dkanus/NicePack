class NiceM79GrenadeLauncher extends NiceWeapon;
simulated function PostBeginPlay(){
    local AutoReloadAnimDesc reloadDesc;
    autoReloadsDescriptions.Length = 0;
    reloadDesc.canInterruptFrame    = 0.101;
    reloadDesc.trashStartFrame      = 0.65;//0.869;
    reloadDesc.resumeFrame          = 0.101;
    reloadDesc.speedFrame           = 0.101;
    reloadDesc.animName = 'Fire';
    autoReloadsDescriptions[0] = reloadDesc;
    reloadDesc.animName = 'Iron_Fire';
    autoReloadsDescriptions[1] = reloadDesc;
    super.PostBeginPlay();
}
defaultproperties
{
    bChangeClipIcon=True
    bChangeBulletsIcon=True
    hudClipTexture=Texture'KillingFloor2HUD.HUD.Hud_M79'
    hudBulletsTexture=Texture'KillingFloor2HUD.HUD.Hud_M79'
    reloadType=RTYPE_AUTO
    ForceZoomOutOnFireTime=0.400000
    MagCapacity=1
    ReloadRate=0.010000
    ReloadAnimRate=1.000000
    bHoldToReload=True
    Weight=4.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=65.000000
    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_M79'
    bIsTier2Weapon=True
    MeshRef="KF_Weapons2_Trip.M79_Trip"
    SkinRefs(0)="KF_Weapons2_Trip_T.Special.M79_cmb"
    SelectSoundRef="KF_M79Snd.M79_Select"
    HudImageRef="KillingFloor2HUD.WeaponSelect.M79_unselected"
    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.M79"
    PlayerIronSightFOV=70.000000
    ZoomedDisplayFOV=45.000000
    FireModeClass(0)=Class'NicePack.NiceM79Fire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.650000
    CurrentRating=0.650000
    Description="A classic Vietnam era grenade launcher. Launches single high explosive grenades."
    DisplayFOV=65.000000
    Priority=162
    InventoryGroup=3
    GroupOffset=11
    PickupClass=Class'NicePack.NiceM79Pickup'
    PlayerViewOffset=(X=18.000000,Y=20.000000,Z=-6.000000)
    BobDamping=6.000000
    AttachmentClass=Class'NicePack.NiceM79Attachment'
    IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
    ItemName="M79 Grenade Launcher"
    LightType=LT_None
    LightBrightness=0.000000
    LightRadius=0.000000
}
