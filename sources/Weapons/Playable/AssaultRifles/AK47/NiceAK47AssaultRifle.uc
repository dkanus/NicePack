class NiceAK47AssaultRifle extends NiceAssaultRifle;
#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax
defaultproperties
{
    bSemiAutoFireEnabled=False
    bBurstFireEnabled=True
    reloadPreEndFrame=0.167000
    reloadEndFrame=0.578000
    reloadChargeEndFrame=0.800000
    reloadMagStartFrame=0.433000
    reloadChargeStartFrame=0.711000
    MagazineBone="MagazineAK"
    MagCapacity=30
    ReloadRate=3.000000
    ReloadAnim="Reload"
    ReloadAnimRate=1.000000
    WeaponReloadAnim="Reload_AK47"
    Weight=6.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=60.000000
    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_AK_47'
    bIsTier2Weapon=True
    MeshRef="KF_Weapons2_Trip.AK47_Trip"
    SkinRefs(0)="KF_Weapons2_Trip_T.Rifles.AK47_cmb"
    SelectSoundRef="KF_AK47Snd.AK47_Select"
    HudImageRef="KillingFloor2HUD.WeaponSelect.Ak_47_unselected"
    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Ak_47"
    PlayerIronSightFOV=65.000000
    ZoomedDisplayFOV=32.000000
    FireModeClass(0)=Class'NicePack.NiceAK47Fire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.550000
    CurrentRating=0.550000
    bShowChargingBar=True
    Description="A classic Russian assault rifle. Can be fired in semi or full auto with nice knock down power but not great accuracy."
    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
    DisplayFOV=60.000000
    Priority=95
    CustomCrosshair=11
    CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
    InventoryGroup=3
    GroupOffset=7
    PickupClass=Class'NicePack.NiceAK47Pickup'
    PlayerViewOffset=(X=18.000000,Y=22.000000,Z=-6.000000)
    BobDamping=6.000000
    AttachmentClass=Class'NicePack.NiceAK47Attachment'
    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
    ItemName="AK47"
    TransientSoundVolume=1.250000
}
