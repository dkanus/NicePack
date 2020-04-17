class NiceAA12AutoShotgun extends NiceWeapon;

// Use alt fire to switch fire modes
simulated function AltFire(float F){
    DoToggle();
}

exec function SwitchModes(){
    DoToggle();
}

defaultproperties
{    reloadPreEndFrame=0.473000    reloadEndFrame=0.828000    reloadChargeEndFrame=-1.000000    reloadMagStartFrame=0.591000    reloadChargeStartFrame=-1.000000    MagCapacity=20
    Weight=6.000000    ReloadRate=3.133000    ReloadAnim="Reload"    ReloadAnimRate=1.000000    WeaponReloadAnim="Reload_AA12"    bHasAimingMode=True    IdleAimAnim="Idle_Iron"    StandardDisplayFOV=65.000000    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_AA12'    bIsTier3Weapon=True    MeshRef="KF_Weapons2_Trip.AA12_Trip"    SkinRefs(0)="KF_Weapons2_Trip_T.Special.AA12_cmb"    SelectSoundRef="KF_AA12Snd.AA12_Select"    HudImageRef="KillingFloor2HUD.WeaponSelect.AA12_unselected"    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.AA12"    PlayerIronSightFOV=80.000000    ZoomedDisplayFOV=45.000000    FireModeClass(0)=Class'NicePack.NiceAA12Fire'    FireModeClass(1)=Class'KFMod.NoFire'    PutDownAnim="PutDown"    SelectForce="SwitchToAssaultRifle"    AIRating=0.550000    CurrentRating=0.550000    bShowChargingBar=True    Description="An advanced fully automatic shotgun."    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)    DisplayFOV=65.000000    Priority=200    InventoryGroup=4    GroupOffset=10    PickupClass=Class'NicePack.NiceAA12Pickup'    PlayerViewOffset=(X=25.000000,Y=20.000000,Z=-2.000000)    BobDamping=6.000000    AttachmentClass=Class'NicePack.NiceAA12Attachment'    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)    ItemName="AA12 Shotgun"    TransientSoundVolume=1.250000
}