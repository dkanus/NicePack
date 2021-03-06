class NiceBullpup extends NiceAssaultRifle;
#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax
defaultproperties
{
    reloadPreEndFrame=0.333000
    reloadEndFrame=0.783000
    reloadChargeEndFrame=-1.000000
    reloadMagStartFrame=0.483000
    reloadChargeStartFrame=-1.000000
    MagCapacity=30
    ReloadRate=1.966667
    ReloadAnim="Reload"
    ReloadAnimRate=1.000000
    WeaponReloadAnim="Reload_BullPup"
    Weight=5.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=70.000000
    SleeveNum=2
    TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Bullpup'
    MeshRef="KF_Weapons_Trip.Bullpup_Trip"
    SkinRefs(0)="KF_Weapons_Trip_T.Rifles.bullpup_cmb"
    SkinRefs(1)="KF_Weapons_Trip_T.Rifles.reflex_sight_A_unlit"
    SelectSoundRef="KF_BullpupSnd.Bullpup_Select"
    HudImageRef="KillingFloorHUD.WeaponSelect.Bullpup_unselected"
    SelectedHudImageRef="KillingFloorHUD.WeaponSelect.Bullpup"
    PlayerIronSightFOV=65.000000
    ZoomedDisplayFOV=40.000000
    FireModeClass(0)=Class'NicePack.NiceBullpupFire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.550000
    CurrentRating=0.550000
    bShowChargingBar=True
    Description="A military grade automatic rifle. Can be fired in semi-auto or full auto firemodes and comes equipped with a scope for increased accuracy."
    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
    DisplayFOV=70.000000
    Priority=70
    CustomCrosshair=11
    CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
    InventoryGroup=3
    GroupOffset=1
    PickupClass=Class'NicePack.NiceBullpupPickup'
    PlayerViewOffset=(X=20.000000,Y=21.500000,Z=-9.000000)
    BobDamping=6.000000
    AttachmentClass=Class'NicePack.NiceBullpupAttachment'
    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
    ItemName="Bullpup"
    TransientSoundVolume=1.250000
}
