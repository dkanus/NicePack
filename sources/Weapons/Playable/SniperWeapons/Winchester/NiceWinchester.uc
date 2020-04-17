class NiceWinchester extends NiceWeapon;
simulated function fillSubReloadStages(){
    // Loading 10 shells during 256 frames tops, with first shell loaded at frame 18, with 23 frames between load moments
    generateReloadStages(10, 256, 18, 23);
}

defaultproperties
{
     bChangeClipIcon=True
     hudClipTexture=Texture'KillingFloorHUD.HUD.Hud_Single_Bullet'
     reloadType=RTYPE_SINGLE
     MagCapacity=10
     ReloadRate=0.416667
     ReloadAnim="Reload"
     ReloadAnimRate=1.600000
     bHoldToReload=True
     WeaponReloadAnim="Reload_Winchester"
     Weight=6.000000
     bHasAimingMode=True
     IdleAimAnim="AimIdle"
     StandardDisplayFOV=70.000000
     SleeveNum=2
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Winchester'
     MeshRef="KF_Weapons_Trip.Winchester_Trip"
     SkinRefs(0)="KF_Weapons_Trip_T.Rifles.winchester_cmb"
     SelectSoundRef="KF_RifleSnd.Rifle_Select"
     HudImageRef="KillingFloorHUD.WeaponSelect.winchester_unselected"
     SelectedHudImageRef="KillingFloorHUD.WeaponSelect.Winchester"
     PlayerIronSightFOV=70.000000
     ZoomedDisplayFOV=50.000000
     FireModeClass(0)=Class'NicePack.NiceWinchesterFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     AIRating=0.560000
     CurrentRating=0.560000
     bShowChargingBar=True
     OldCenteredOffsetY=0.000000
     OldPlayerViewOffset=(X=-8.000000,Y=5.000000,Z=-6.000000)
     OldSmallViewOffset=(X=4.000000,Y=11.000000,Z=-12.000000)
     OldPlayerViewPivot=(Pitch=800)
     OldCenteredRoll=3000
     Description="A rugged and reliable single-shot rifle."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=70.000000
     Priority=85
     CenteredOffsetY=-5.000000
     CenteredRoll=3000
     CenteredYaw=-1500
     InventoryGroup=3
     GroupOffset=3
     PickupClass=Class'NicePack.NiceWinchesterPickup'
     PlayerViewOffset=(X=8.000000,Y=14.000000,Z=-8.000000)
     BobDamping=6.000000
     AttachmentClass=Class'NicePack.NiceWinchesterAttachment'
     ItemName="Winchester"
     bUseDynamicLights=True
     DrawScale=0.900000
     TransientSoundVolume=50.000000
}
