class NiceMAC10Z extends NiceWeapon;
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax
simulated function AltFire(float F){
    DoToggle();
}
defaultproperties
{
    reloadPreEndFrame=0.115000
    reloadEndFrame=0.538000
    reloadChargeEndFrame=0.750000
    reloadMagStartFrame=0.288000
    reloadChargeStartFrame=0.644000
    MagazineBone="Mac11_Mag"
    MagCapacity=30
    ReloadRate=3.000000
    ReloadAnim="Reload"
    ReloadAnimRate=1.000000
    FlashBoneName="tipS"
    WeaponReloadAnim="Reload_Mac10"
    Weight=3.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=60.000000
    SleeveNum=2
    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Mac_10'
    bIsTier2Weapon=True
    MeshRef="KF_Weapons2_Trip.Mac10_Trip"
    SkinRefs(0)="KF_Weapons2_Trip_T.Special.MAC10_cmb"
    SkinRefs(1)="KF_Weapons2_Trip_T.Special.MAC10_SIL_cmb"
    SelectSoundRef="KF_MAC10MPSnd.MAC10_Select"
    HudImageRef="KillingFloor2HUD.WeaponSelect.Mac_10_Unselected"
    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Mac_10"
    PlayerIronSightFOV=65.000000
    ZoomedDisplayFOV=32.000000
    FireModeClass(0)=Class'NicePack.NiceMAC10Fire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.550000
    CurrentRating=0.550000
    bShowChargingBar=True
    Description="A highly compact machine pistol. Can be fired in semi or full auto."
    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
    DisplayFOV=55.000000
    Priority=75
    CustomCrosshair=11
    CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
    InventoryGroup=3
    GroupOffset=6
    PickupClass=Class'NicePack.NiceMAC10Pickup'
    PlayerViewOffset=(X=25.000000,Y=20.000000,Z=-6.000000)
    BobDamping=6.000000
    AttachmentClass=Class'KFMod.MAC10Attachment'
    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
    ItemName="MAC10"
    TransientSoundVolume=1.250000
}
