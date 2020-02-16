class NiceWinchester extends NiceWeapon;

simulated function fillSubReloadStages(){
    // Loading 10 shells during 256 frames tops, with first shell loaded at frame 18, with 23 frames between load moments
    generateReloadStages(10, 256, 18, 23);
}

static function FillInAppearance(){
    local WeaponVariant         variant;
    local WeaponModel           model;
    local WeaponSkin            skin, fancySkin;
    local WeaponSoundSet        soundSet;
    local WeaponAnimationSet    anims;
    local NiceAmmoType          ammoType;
    local NiceAmmoEffects       ammoEffects;
    soundSet.selectSoundRef = "KF_RifleSnd.Rifle_Select";
    soundSet.fireSoundRefs[0] = "KF_RifleSnd.Rifle_Fire";
    soundSet.stereoFireSoundRefs[0] = "KF_RifleSnd.Rifle_FireST";
    soundSet.noAmmoSoundRefs[0] = "KF_RifleSnd.Rifle_DryFire";
    skin.ID = "Lever Action Rifle";
    skin.paintRefs[0] = "KF_Weapons_Trip_T.Rifles.winchester_cmb";
    fancySkin.ID = "Winchester";
    fancySkin.paintRefs[0] = "NicePackT.Skins1st.OldLAR_cmb";
    model.ID = "Winchester";
    model.firstMeshRef = "KF_Weapons_Trip.Winchester_Trip";
    model.hudImageRef = "KillingFloorHUD.WeaponSelect.winchester_unselected";
    model.selectedHudImageRef = "KillingFloorHUD.WeaponSelect.Winchester";
    model.skins[0] = skin;
    model.skins[1] = fancySkin;
    model.soundSet = soundSet;
    anims.idleAnim = 'Idle';
    anims.idleAimedAnim = 'AimIdle';
    anims.selectAnim = 'Select';
    anims.putDownAnim = 'PutDown';
    anims.reloadAnim = 'Reload';
    anims.fireAnimSets[0].justFire.anim = 'Fire';
    anims.fireAnimSets[0].justFire.rate = 1.6;
    anims.fireAnimSets[0].aimed.anim = 'AimFire';
    anims.fireAnimSets[0].aimed.rate = 1.6;
    model.animations = anims;
    model.playerViewOffset = Vect(8.0, 14.0, -8.0);
    model.effectOffset = Vect(100.0, 25.0, -10.0);
    variant.models[0] = model;
    ammoEffects.ammoID = "regular";
    ammoEffects.fireTypeID = "crude";
    variant.ammoEffects[0] = ammoEffects;
    ammoEffects.ammoID = "irregular";
    ammoEffects.fireTypeID = "fine";
    variant.ammoEffects[1] = ammoEffects;
    default.variants[0] = variant;
    //  Ammo
    ammoType.ID = "regular";
    ammoType.spaceMult = 1.0;
    ammoType.amount = 20;
    default.availableAmmoTypes[0] = ammoType;
    ammoType.ID = "irregular";
    ammoType.spaceMult = 1.0;
    ammoType.amount = 20;
    default.availableAmmoTypes[1] = ammoType;
}

defaultproperties
{
    bChangeClipIcon=true
    hudClipTexture=Texture'KillingFloorHUD.HUD.Hud_Single_Bullet'
    reloadType=RTYPE_SINGLE
    MagCapacity=10
    ReloadRate=0.416667
    ReloadAnimRate=1.600000
    bHoldToReload=True
    Weight=6.000000
    bHasAimingMode=True
    StandardDisplayFOV=70.000000
    DisplayFOV=70.000000
    PlayerIronSightFOV=70.000000
    ZoomedDisplayFOV=50.000000
    SleeveNum=2
    TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Winchester'
    FireModeClass(0)=Class'NicePack.NiceWinchesterFire'
    FireModeClass(1)=Class'KFMod.NoFire'
    bShowChargingBar=True
    Description="A rugged and reliable single-shot rifle."
    Priority=85
    InventoryGroup=3
    GroupOffset=3
    PickupClass=Class'NicePack.NiceWinchesterPickup'
    AttachmentClass=Class'NicePack.NiceWinchesterAttachment'
    ItemName="Winchester"
    TransientSoundVolume=50.000000
    BobDamping=6.000000
}