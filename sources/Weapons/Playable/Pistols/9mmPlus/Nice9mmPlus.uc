class Nice9mmPlus extends NiceSingle;
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
    if(LaserType == 0)       LaserType = 1;
    else       LaserType = 0;
    ApplyLaserState();
}
defaultproperties
{    DualClass=Class'NicePack.NiceDual9mmPlus'    bUseFlashlightToToggle=True    reloadPreEndFrame=0.117000    reloadEndFrame=0.617000    reloadChargeEndFrame=-1.000000    reloadMagStartFrame=0.167000    reloadChargeStartFrame=-1.000000    bTorchEnabled=True    SleeveNum=0    TraderInfoTexture=Texture'NicePackT.NinePP.HUD_Single_Trader'    MeshRef="NicePackA.NinePP.Single_1P"    SkinRefs(1)="ScrnWeaponPack_T.MedicPistol.Slide_cmb"    SkinRefs(2)="ScrnWeaponPack_T.MedicPistol.frame_cmb"    SkinRefs(3)="ScrnWeaponPack_T.MedicPistol.Slide_cmb"    SkinRefs(4)="ScrnWeaponPack_T.MedicPistol.Slide_cmb"    SelectSoundRef="KF_9MMSnd.9mm_Select"    HudImageRef="NicePackT.NinePP.HUD_Single_UnSelected"    SelectedHudImageRef="NicePackT.NinePP.HUD_Single_Selected"    FireModeClass(0)=Class'NicePack.Nice9mmPlusFire'    Description="A 9mm handgun, with a functional laser sight and flashlight. The barrel has been replaced with one that can chamber hotter ammunition loads, meaning faster bullets, meaning more damage!"    GroupOffset=3    PickupClass=Class'NicePack.Nice9mmPlusPickup'    AttachmentClass=Class'NicePack.Nice9mmPlusAttachment'    ItemName="Beretta"
}
