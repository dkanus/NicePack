class NiceMK23Pistol extends NiceSingle;
simulated function AltFire(float F){
    if(bIsDual)       super.AltFire(F);
    else       ToggleLaser();
}
simulated function SecondDoToggle(){
    ToggleLaser();
}
simulated function ToggleLaser(){
    if(!Instigator.IsLocallyControlled())        return;
    // Will redo this bit later, but so far it'll have to do
    if(LaserType == 0)       LaserType = 2;
    else       LaserType = 0;
    ApplyLaserState();
}
defaultproperties
{    DualClass=Class'NicePack.NiceDualMK23Pistol'    bUseFlashlightToToggle=True    LaserAttachmentRotation=(Yaw=16384)    LaserAttachmentBone="tip"    reloadPreEndFrame=0.156000    reloadEndFrame=0.636000    reloadChargeEndFrame=-1.000000    reloadMagStartFrame=0.286000    reloadChargeStartFrame=-1.000000    MagCapacity=12    ReloadRate=2.600000    Weight=2.000000    StandardDisplayFOV=60.000000    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_MK23'    bIsTier2Weapon=True    MeshRef="KF_Wep_MK23.MK23"    SkinRefs(0)="KF_Weapons5_Trip_T.Weapons.MK23_SHDR"    SelectSoundRef="KF_MK23Snd.MK23_Select"    HudImageRef="KillingFloor2HUD.WeaponSelect.MK23_unselected"    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.MK23"    ZoomedDisplayFOV=50.000000    FireModeClass(0)=Class'NicePack.NiceMK23Fire'    AIRating=0.450000    CurrentRating=0.450000    Description="Match grade 45 caliber pistol. Good balance between power, ammo count and rate of fire."    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)    DisplayFOV=60.000000    Priority=65    GroupOffset=9    PickupClass=Class'NicePack.NiceMK23Pickup'    PlayerViewOffset=(X=10.000000,Y=18.750000,Z=-7.000000)    BobDamping=4.500000    AttachmentClass=Class'NicePack.NiceMK23Attachment'    IconCoords=(X1=250,Y1=110,X2=330,Y2=145)    ItemName="MK23"    bUseDynamicLights=True    TransientSoundVolume=1.000000
}
