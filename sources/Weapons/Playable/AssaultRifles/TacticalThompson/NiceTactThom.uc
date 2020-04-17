class NiceTactThom extends NiceAssaultRifle;
#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax
simulated function AltFire(float F){
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
{    LaserAttachmentBone="bone_laser"    reloadPreEndFrame=0.110000    reloadEndFrame=0.380000    reloadChargeEndFrame=0.650000    reloadMagStartFrame=0.260000    reloadChargeStartFrame=0.460000    MagazineBone="thomson-mag"    MagCapacity=30    ReloadRate=2.880000    ReloadAnim="Reload"    ReloadAnimRate=1.000000    WeaponReloadAnim="Reload_M4"    SelectedHudImage=Texture'NicePackT.TactThompson.tact_sel'    Weight=4.000000    bHasAimingMode=True    IdleAimAnim="Idle_Iron"    StandardDisplayFOV=70.000000    SleeveNum=2    TraderInfoTexture=Texture'NicePackT.TactThompson.tact_trader'    bIsTier2Weapon=True    MeshRef="NicePackA.tact_tom"    SkinRefs(0)="NicePackT.TactThompson.EOTECH"    SkinRefs(1)="NicePackT.TactThompson.holosight_fb"    SelectSoundRef="NicePackSnd.TactThompson.tact_deploy"    HudImageRef="NicePackT.TactThompson.tact_unsel"    PlayerIronSightFOV=65.000000    ZoomedDisplayFOV=40.000000    FireModeClass(0)=Class'NicePack.NiceTactThomFire'    FireModeClass(1)=Class'KFMod.NoFire'    PutDownAnim="PutDown"    SelectForce="SwitchToAssaultRifle"    AIRating=0.550000    CurrentRating=0.550000    bShowChargingBar=True    Description="An excellent tactical Thompson. Not much better than a bullpup, but has lots of ammo and some penetration."    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)    DisplayFOV=70.000000    Priority=70    CustomCrosshair=11    CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"    InventoryGroup=3    GroupOffset=1    PickupClass=Class'NicePack.NiceTactThomPickup'    PlayerViewOffset=(X=20.000000,Y=21.500000,Z=-9.000000)    BobDamping=6.000000    AttachmentClass=Class'NicePack.NiceTactThomAttachment'    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)    ItemName="Tactical Thompson"    TransientSoundVolume=1.250000
}
