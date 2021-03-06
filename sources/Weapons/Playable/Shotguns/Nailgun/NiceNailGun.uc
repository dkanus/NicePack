class NiceNailGun extends NiceWeapon;
simulated function bool AltFireCanForceInterruptReload(){
    return GetMagazineAmmo() > 0;
}
defaultproperties
{
    reloadPreEndFrame=0.178000
    reloadEndFrame=0.700000
    reloadChargeEndFrame=-1.000000
    reloadMagStartFrame=0.278000
    reloadChargeStartFrame=-1.000000
    FirstPersonFlashlightOffset=(X=-20.000000,Y=-22.000000,Z=8.000000)
    MagCapacity=28
    ReloadRate=2.600000
    ReloadAnim="Reload"
    ReloadAnimRate=1.000000
    WeaponReloadAnim="Reload_Vlad9000"
    Weight=5.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=65.000000
    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Vlad9000'
    bIsTier2Weapon=True
    MeshRef="KF_Wep_Vlad9000.Vlad9000"
    SkinRefs(0)="KF_Weapons8_Trip_T.Weapons.Vlad_9000_cmb"
    SelectSoundRef="KF_NailShotgun.KF_NailShotgun_Pickup"
    HudImageRef="KillingFloor2HUD.WeaponSelect.Vlad9000_unselected"
    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Vlad9000"
    PlayerIronSightFOV=70.000000
    ZoomedDisplayFOV=40.000000
    FireModeClass(0)=Class'NicePack.NiceNailGunFire'
    FireModeClass(1)=Class'NicePack.NiceNailGunAltFire'
    PutDownAnim="PutDown"
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.550000
    CurrentRating=0.550000
    bShowChargingBar=True
    Description="The Black and Wrecker Vlad 9000 nail gun. Designed for putting barns together. Or nailing Zeds to them."
    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
    DisplayFOV=65.000000
    Priority=150
    InventoryGroup=3
    GroupOffset=15
    PickupClass=Class'NicePack.NiceNailGunPickup'
    PlayerViewOffset=(X=25.000000,Y=20.000000,Z=-10.000000)
    BobDamping=4.500000
    AttachmentClass=Class'NicePack.NiceNailGunAttachment'
    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
    ItemName="Vlad the Impaler"
    TransientSoundVolume=1.250000
}
