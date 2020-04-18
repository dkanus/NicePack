class NiceM4AssaultRifle extends NiceAssaultRifle;
#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax
defaultproperties
{
    reloadPreEndFrame=0.148000
    reloadEndFrame=0.546000
    reloadChargeEndFrame=0.778000
    reloadMagStartFrame=0.306000
    reloadChargeStartFrame=0.694000
    MagCapacity=30
    ReloadRate=3.633300
    ReloadAnim="Reload"
    ReloadAnimRate=1.000000
    WeaponReloadAnim="Reload_M4"
    Weight=5.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=60.000000
    SleeveNum=2
    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_M4'
    bIsTier2Weapon=True
    MeshRef="KF_Wep_M4.M4_Trip"
    SkinRefs(0)="KF_Weapons4_Trip_T.Weapons.m4_cmb"
    SkinRefs(1)="KF_Weapons2_Trip_T.Special.Aimpoint_sight_shdr"
    SelectSoundRef="KF_M4RifleSnd.WEP_M4_Foley_Select"
    HudImageRef="KillingFloor2HUD.WeaponSelect.M4_unselected"
    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.M4"
    PlayerIronSightFOV=65.000000
    ZoomedDisplayFOV=45.000000
    FireModeClass(0)=Class'NicePack.NiceM4Fire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.550000
    CurrentRating=0.550000
    bShowChargingBar=True
    Description="A compact assault rifle. Can be fired in semi or full auto with good damage and good accuracy."
    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
    DisplayFOV=60.000000
    Priority=130
    CustomCrosshair=11
    CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
    InventoryGroup=3
    GroupOffset=10
    PickupClass=Class'NicePack.NiceM4Pickup'
    PlayerViewOffset=(X=25.000000,Y=18.000000,Z=-6.000000)
    BobDamping=6.000000
    AttachmentClass=Class'NicePack.NiceM4Attachment'
    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
    ItemName="M4"
    TransientSoundVolume=1.250000
}
