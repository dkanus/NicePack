class NiceBoomStick extends NiceWeapon;
#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
var float           glueTiming;
var float           firstShellTiming, secondShellTiming, jumpTiming;
var const string    firstShellStr, secondShellStr, jumpStr;
simulated function PostBeginPlay(){
    local EventRecord record;
    local AutoReloadAnimDesc reloadDesc;
    // Setup animation timings
    autoReloadsDescriptions.Length = 0;
    reloadDesc.canInterruptFrame    = 0.056;
    reloadDesc.trashStartFrame      = secondShellTiming;
    reloadDesc.resumeFrame          = 0.056;
    reloadDesc.speedFrame           = 0.056;
    // Setup all possible fire animations
    reloadDesc.animName = 'Fire_Both';
    autoReloadsDescriptions[0] = reloadDesc;
    reloadDesc.animName = 'Fire_Both_Iron';
    autoReloadsDescriptions[1] = reloadDesc;
    reloadDesc.animName = 'Fire_Last';
    autoReloadsDescriptions[2] = reloadDesc;
    reloadDesc.animName = 'Fire_Last_Iron';
    autoReloadsDescriptions[3] = reloadDesc;
    // Setup reload events
    record.eventName = jumpStr;
    record.eventFrame = jumpTiming;
    relEvents[relEvents.Length] = record;
    record.eventName = firstShellStr;
    record.eventFrame = firstShellTiming;
    relEvents[relEvents.Length] = record;
    record.eventName = secondShellStr;
    record.eventFrame = secondShellTiming;
    relEvents[relEvents.Length] = record;
    super.PostBeginPlay();
}
simulated function ReloadEvent(string eventName){
    if(eventName ~= jumpStr && GetMagazineAmmo() > 0)
       SetAnimFrame(glueTiming);
    if(eventName ~= firstShellStr)
       MagAmmoRemainingClient = Min(1, AmmoAmount(0));
    else if(eventName ~= secondShellStr)
       MagAmmoRemainingClient = Min(2, AmmoAmount(0));
    ServerSetMagSize(MagAmmoRemainingClient, bRoundInChamber, Level.TimeSeconds);
}
simulated function AddAutoReloadedAmmo(){
    MagAmmoRemainingClient = Min(2, AmmoAmount(0));
    ServerSetMagSize(MagAmmoRemainingClient, bRoundInChamber, Level.TimeSeconds);
}
simulated function bool AltFireCanForceInterruptReload(){
    return (GetMagazineAmmo() > 0);
}
defaultproperties
{
    glueTiming=0.633330
    firstShellTiming=0.555550
    secondShellTiming=0.733330
    jumpTiming=0.388880
    firstShellStr="firstShell"
    secondShellStr="secondShellStr"
    jumpStr="jumpStr"
    bChangeClipIcon=True
    hudClipTexture=Texture'KillingFloorHUD.HUD.Hud_Single_Bullet'
    reloadType=RTYPE_AUTO
    ForceZoomOutOnFireTime=0.010000
    ForceZoomOutOnAltFireTime=0.010000
    MagCapacity=2
    Weight=5.000000
    ReloadRate=2.250000
    ReloadAnim="Reload"
    ReloadAnimRate=1.100000
    bHoldToReload=True
    WeaponReloadAnim="Reload_HuntingShotgun"
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=55.000000
    TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Hunting_Shotgun'
    bIsTier2Weapon=True
    MeshRef="KF_Weapons_Trip.BoomStick_Trip"
    SkinRefs(0)="KF_Weapons_Trip_T.Shotguns.boomstick_cmb"
    SelectSoundRef="KF_DoubleSGSnd.2Barrel_Select"
    HudImageRef="KillingFloorHUD.WeaponSelect.BoomStic_unselected"
    SelectedHudImageRef="KillingFloorHUD.WeaponSelect.BoomStick"
    PlayerIronSightFOV=70.000000
    ZoomedDisplayFOV=40.000000
    FireModeClass(0)=Class'NicePack.NiceBoomStickAltFire'
    FireModeClass(1)=Class'NicePack.NiceBoomStickFire'
    PutDownAnim="PutDown"
    AIRating=0.900000
    CurrentRating=0.900000
    bSniping=False
    Description="A double barreled shotgun used by big game hunters. It fires two slugs simultaneously and can bring down even the largest targets, quickly."
    DisplayFOV=55.000000
    Priority=160
    InventoryGroup=4
    GroupOffset=2
    PickupClass=Class'NicePack.NiceBoomStickPickup'
    PlayerViewOffset=(X=8.000000,Y=14.000000,Z=-8.000000)
    BobDamping=6.000000
    AttachmentClass=Class'NicePack.NiceBoomStickAttachment'
    ItemName="Hunting Shotgun"
    bUseDynamicLights=True
    TransientSoundVolume=1.000000
}