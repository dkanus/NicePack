class NiceDualMK23Pistol extends NiceDualies;
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
{    SingleClass=Class'NicePack.NiceMK23Pistol'    leftEject=0.079000    rightEject=0.086000    leftInsert=0.329000    rightInsert=0.650000    bUseFlashlightToToggle=True    bAllowFreeDot=True    LaserAttachmentRotation=(Yaw=16384)    altLaserAttachmentRotation=(Yaw=16384)    LaserAttachmentBone="Tip_Right"    altLaserAttachmentBone="Tip_Left"    MagCapacity=24    ReloadRate=4.466700    Weight=4.000000    StandardDisplayFOV=60.000000    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Dual_MK23'    bIsTier2Weapon=True    MeshRef="KF_Wep_Dual_MK23.Dual_MK23"    SkinRefs(0)="KF_Weapons5_Trip_T.Weapons.MK23_SHDR"    SelectSoundRef="KF_MK23Snd.MK23_Select"    HudImageRef="KillingFloor2HUD.WeaponSelect.Dual_MK23_unselected"    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Dual_MK23"    ZoomedDisplayFOV=50.000000    FireModeClass(0)=Class'NicePack.NiceDualMK23Fire'    AIRating=0.450000    CurrentRating=0.450000    Description="Dual MK23 match grade pistols. Dual 45's is double the fun."    DisplayFOV=60.000000    Priority=90    GroupOffset=10    PickupClass=Class'NicePack.NiceDualMK23Pickup'    PlayerViewOffset=(X=25.000000)    BobDamping=3.800000    AttachmentClass=Class'NicePack.NiceDualMK23Attachment'    IconCoords=(X1=250,Y1=110,X2=330,Y2=145)    ItemName="Dual MK23s"    DrawScale=1.000000
}
