class NiceAUG_A1AR extends NiceScopedWeapon;
#EXEC OBJ LOAD FILE=HMG_T.utx
#EXEC OBJ LOAD FILE=HMG_S.uax
#EXEC OBJ LOAD FILE=HMG_A.ukx
simulated function AltFire(float F){
    if(ReadyToFire(0))       DoToggle();
}
exec function SwitchModes(){
    DoToggle();
}
defaultproperties
{    lenseMaterialID=4    scopePortalFOVHigh=17.000000    scopePortalFOV=17.000000    ZoomMatRef="HMG_T.AUG.AUG-A1_scope_FB"    ScriptedTextureFallbackRef="HMG_T.AUG.alpha_lens_64x64"    CrosshairTexRef="HMG_T.AUG.AUG-A1_scope"    reloadPreEndFrame=0.400000    reloadEndFrame=0.645000    reloadChargeEndFrame=0.805000    reloadMagStartFrame=0.500000    reloadChargeStartFrame=0.700000    MagazineBone="clip"    bHasScope=True    ZoomedDisplayFOVHigh=70.000000    MagCapacity=30    ReloadRate=3.500000    ReloadAnim="Reload"    ReloadAnimRate=1.000000    WeaponReloadAnim="Reload_BullPup"    Weight=9.000000    bHasAimingMode=True    IdleAimAnim="Idle_Iron"    StandardDisplayFOV=65.000000    SleeveNum=0    TraderInfoTexture=Texture'HMG_T.AUG.trader_AUG_A1'    bIsTier2Weapon=True    MeshRef="HMG_A.AUG_A1_mesh"    SkinRefs(0)="KF_Weapons3_Trip_T.hands.Priest_Hands_1st_P"    SkinRefs(1)="HMG_T.AUG.body"    SkinRefs(2)="HMG_T.AUG.mag"    SkinRefs(3)="HMG_T.AUG.Rec"    SkinRefs(4)="HMG_T.AUG.alpha_lens_64x64"    SelectSoundRef="HMG_S.AUGND.aug_draw"    HudImageRef="HMG_T.AUG.AUG_A1_Unselected"    SelectedHudImageRef="HMG_T.AUG.AUG_A1_Selected"    PlayerIronSightFOV=32.000000    ZoomedDisplayFOV=70.000000    FireModeClass(0)=Class'NicePack.NiceAUG_A1ARFire'    FireModeClass(1)=Class'KFMod.NoFire'    PutDownAnim="PutDown"    SelectForce="SwitchToAssaultRifle"    AIRating=0.650000    CurrentRating=0.650000    Description="Steyr AUG  1977 Steyr-Daimler-Puch AG & Co KG"    DisplayFOV=65.000000    Priority=170    CustomCrosshair=11    CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"    InventoryGroup=4    GroupOffset=3    PickupClass=Class'NicePack.NiceAUG_A1ARPickup'    PlayerViewOffset=(X=15.000000,Y=12.000000,Z=-2.000000)    BobDamping=5.000000    AttachmentClass=Class'NicePack.NiceAUG_A1ARAttachment'    IconCoords=(X1=253,Y1=146,X2=333,Y2=181)    ItemName="Steyr AUG A1"
}
