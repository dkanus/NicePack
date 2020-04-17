class NiceM99SniperRifle extends NiceScopedWeapon;
#exec OBJ LOAD FILE=..\Textures\KF_Weapons5_Scopes_Trip_T.utx
simulated function PostBeginPlay(){
    local AutoReloadAnimDesc reloadDesc;
    autoReloadsDescriptions.Length = 0;
    reloadDesc.canInterruptFrame    = 0.43;
    reloadDesc.trashStartFrame      = 0.882;
    reloadDesc.resumeFrame          = 0.473;
    reloadDesc.speedFrame           = 0.129;
    reloadDesc.animName = 'Fire';
    autoReloadsDescriptions[0] = reloadDesc;
    reloadDesc.animName = 'Fire_Iron';
    autoReloadsDescriptions[1] = reloadDesc;
    super.PostBeginPlay();
}
simulated function bool StartFire(int Mode){
    if(super.StartFire(Mode)){       if(Instigator != none && PlayerController(Instigator.Controller) != none &&           KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements) != none){           KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements).OnShotM99();       }       return true;
    }
    return false;
}
defaultproperties
{    lenseMaterialID=2    scopePortalFOVHigh=20.000000    scopePortalFOV=13.330000    ZoomMatRef="KF_Weapons5_Scopes_Trip_T.M99.MilDotFinalBlend"    ScriptedTextureFallbackRef="KF_Weapons_Trip_T.CBLens_cmb"    CrosshairTexRef="KF_Weapons5_Scopes_Trip_T.Scope.MilDot"    bChangeClipIcon=True    hudClipTexture=Texture'KillingFloorHUD.HUD.Hud_Single_Bullet'    reloadType=RTYPE_AUTO    bHasScope=True    ZoomedDisplayFOVHigh=18.000000    ForceZoomOutOnFireTime=0.400000    MagCapacity=1    ReloadRate=0.010000    ReloadAnim="Reload"    ReloadAnimRate=1.000000    bHasAimingMode=True    IdleAimAnim="Idle_Iron"    StandardDisplayFOV=55.000000    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_M99'    bIsTier3Weapon=True    MeshRef="KF_Wep_M99_Sniper.M99_Sniper"    SkinRefs(0)="KF_Weapons5_Trip_T.Weapons.M99_cmb"    SelectSoundRef="KF_M99Snd.M99_Select"    HudImageRef="KillingFloor2HUD.WeaponSelect.M99_unselected"    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.M99"    PlayerIronSightFOV=30.000000    ZoomTime=0.285000    ZoomedDisplayFOV=30.000000    FireModeClass(0)=Class'NicePack.NiceM99Fire'    FireModeClass(1)=Class'KFMod.NoFire'    PutDownAnim="PutDown"    PutDownAnimRate=2.000000    SelectForce="SwitchToAssaultRifle"    AIRating=0.550000    CurrentRating=0.550000    bShowChargingBar=True    Description="M99 50 Caliber Single Shot Sniper Rifle - The ultimate in long range accuracy and knock down power. But to land a proper shot with it one needs to be extra precise and aim at his target for at least a solid second."    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)    DisplayFOV=55.000000    Priority=190    CustomCrosshair=11    CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"    MinReloadPct=0.800000    InventoryGroup=4    GroupOffset=14    PickupClass=Class'NicePack.NiceM99Pickup'    PlayerViewOffset=(X=15.000000,Y=15.000000,Z=-2.500000)    BobDamping=4.500000    AttachmentClass=Class'NicePack.NiceM99Attachment'    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)    ItemName="M99AMR"    LightType=LT_None    LightBrightness=0.000000    LightRadius=0.000000    TransientSoundVolume=1.250000
}
