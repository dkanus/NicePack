class NiceDual9mmPlus extends NiceDualies;
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
simulated function ApplyLaserState(){
    super(NiceWeapon).ApplyLaserState();
}
defaultproperties
{    SingleClass=Class'NicePack.Nice9mmPlus'    bUseFlashlightToToggle=True    Weight=1.000000    bTorchEnabled=True    SleeveNum=0    TraderInfoTexture=Texture'NicePackT.NinePP.HUD_Dual_Trader'    MeshRef="NicePackA.NinePP.Dual_1P"    SkinRefs(1)="ScrnWeaponPack_T.MedicPistol.NinePP.Frame_cmb"    SkinRefs(2)="ScrnWeaponPack_T.MedicPistol.Slide_cmb"    SkinRefs(3)="ScrnWeaponPack_T.MedicPistol.Slide_cmb"    SkinRefs(4)="ScrnWeaponPack_T.MedicPistol.Slide_cmb"    SelectSoundRef="KFPlayerSound.getweaponout"    HudImageRef="NicePackT.NinePP.HUD_Dual_UnSelected"    SelectedHudImageRef="NicePackT.NinePP.HUD_Dual_Selected"    FireModeClass(0)=Class'NicePack.NiceDual9mmPlusFire'    Description="A pair of custom 9mm +P+ handguns. These have been improved with a laser sight and more powerful ammunition"    GroupOffset=4    PickupClass=Class'NicePack.NiceDual9mmPickup'    AttachmentClass=Class'NicePack.NiceDual9mmPlusAttachment'    ItemName="Dual Berettas"
}
