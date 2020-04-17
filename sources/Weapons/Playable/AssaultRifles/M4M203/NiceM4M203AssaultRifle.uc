class NiceM4M203AssaultRifle extends NiceAssaultRifle;
#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax
simulated function PostBeginPlay(){
    local AutoReloadAnimDesc reloadDesc;
    autoReloadsDescriptions.Length = 0;
    reloadDesc.canInterruptFrame    = 0.217;
    reloadDesc.trashStartFrame      = 0.679;
    reloadDesc.resumeFrame          = 0.32;
    reloadDesc.speedFrame           = 0.019;
    reloadDesc.animName = 'Fire_Secondary';
    autoReloadsDescriptions[0] = reloadDesc;
    reloadDesc.animName = 'Fire_Iron_Secondary';
    autoReloadsDescriptions[1] = reloadDesc;
    super.PostBeginPlay();
}
defaultproperties
{    bSemiAutoFireEnabled=False    reloadPreEndFrame=0.148000    reloadEndFrame=0.546000    reloadChargeEndFrame=0.778000    reloadMagStartFrame=0.306000    reloadChargeStartFrame=0.694000    autoReloadSpeedModifier=1.500000    ForceZoomOutOnAltFireTime=0.400000    MagCapacity=30    ReloadRate=3.633300    bHasSecondaryAmmo=True    bReduceMagAmmoOnSecondaryFire=False    ReloadAnim="Reload"    ReloadAnimRate=1.000000    WeaponReloadAnim="Reload_M4203"    Weight=6.000000    bHasAimingMode=True    IdleAimAnim="Idle_Iron"    StandardDisplayFOV=60.000000    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_M4_203'    bIsTier2Weapon=True    bIsTier3Weapon=True    MeshRef="KF_Wep_M4M203.M4M203_Trip"    SkinRefs(0)="KF_Weapons4_Trip_T.Weapons.m4_cmb"    SelectSoundRef="KF_M4RifleSnd.WEP_M4_Foley_Select"    HudImageRef="KillingFloor2HUD.WeaponSelect.M4_203_unselected"    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.M4_203"    PlayerIronSightFOV=65.000000    ZoomedDisplayFOV=45.000000    FireModeClass(0)=Class'NicePack.NiceM4M203Fire'    FireModeClass(1)=Class'NicePack.NiceM4M203NadeFire'    PutDownAnim="PutDown"    SelectForce="SwitchToAssaultRifle"    AIRating=0.550000    CurrentRating=0.550000    bShowChargingBar=True    Description="An assault rifle with an attached grenade launcher."    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)    DisplayFOV=60.000000    Priority=190    CustomCrosshair=11    CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"    InventoryGroup=3    GroupOffset=8    PickupClass=Class'NicePack.NiceM4M203Pickup'    PlayerViewOffset=(X=25.000000,Y=18.000000,Z=-6.000000)    BobDamping=6.000000    AttachmentClass=Class'NicePack.NiceM4M203Attachment'    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)    ItemName="M4 203"    TransientSoundVolume=1.250000
}
