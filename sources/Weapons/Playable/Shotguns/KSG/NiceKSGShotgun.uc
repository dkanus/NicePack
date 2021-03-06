class NiceKSGShotgun extends NiceWeapon;
defaultproperties
{
    reloadPreEndFrame=0.126000
    reloadEndFrame=0.650000
    reloadChargeEndFrame=0.850000
    reloadMagStartFrame=0.316000
    reloadChargeStartFrame=0.820000
    activeSlowdown=0.800000
    activeSpeedup=1.300000
    ForceZoomOutOnFireTime=0.010000
    MagCapacity=12
    ReloadRate=3.160000
    ReloadAnim="Reload"
    ReloadAnimRate=1.000000
    WeaponReloadAnim="Reload_KSG"
    Weight=7.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=65.000000
    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_KSG'
    bIsTier2Weapon=True
    MeshRef="KF_Wep_KSG_Shotgun.KSG_Shotgun"
    SkinRefs(0)="KF_Weapons5_Trip_T.Weapons.KSG_SHDR"
    SelectSoundRef="KF_KSGSnd.KSG_Select"
    HudImageRef="KillingFloor2HUD.WeaponSelect.KSG_unselected"
    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.KSG"
    PlayerIronSightFOV=70.000000
    ZoomedDisplayFOV=40.000000
    FireModeClass(0)=Class'NicePack.NiceKSGFire'
    FireModeClass(1)=Class'NicePack.NiceKSGAltFire'
    PutDownAnim="PutDown"
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.550000
    CurrentRating=0.550000
    bShowChargingBar=True
    Description="An advanced Horzine prototype tactical shotgun. Features a large capacity ammo magazine and selectable tight/wide spread fire modes."
    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
    DisplayFOV=65.000000
    Priority=100
    InventoryGroup=3
    GroupOffset=12
    PickupClass=Class'NicePack.NiceKSGPickup'
    PlayerViewOffset=(X=15.000000,Y=20.000000,Z=-7.000000)
    BobDamping=4.500000
    AttachmentClass=Class'NicePack.NiceKSGAttachment'
    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
    ItemName="HSG-1 Shotgun"
    TransientSoundVolume=1.250000
}
