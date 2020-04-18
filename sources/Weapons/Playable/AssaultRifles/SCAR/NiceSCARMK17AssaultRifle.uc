class NiceSCARMK17AssaultRifle extends NiceAK47AssaultRifle;
defaultproperties
{
    bSemiAutoFireEnabled=True
    bBurstFireEnabled=False
    reloadPreEndFrame=0.175000
    reloadEndFrame=0.737500
    reloadChargeEndFrame=-1.000000
    reloadMagStartFrame=0.300000
    reloadChargeStartFrame=-1.000000
    MagazineBone="Magazine"
    MagCapacity=20
    ReloadRate=2.966000
    WeaponReloadAnim="Reload_SCAR"
    Weight=8.000000
    StandardDisplayFOV=55.000000
    SleeveNum=2
    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Scar'
    bIsTier3Weapon=True
    MeshRef="KF_Weapons2_Trip.SCAR_Trip"
    SkinRefs(0)="KF_Weapons2_Trip_T.Rifle.Scar_cmb"
    SkinRefs(1)="KF_Weapons2_Trip_T.Special.Aimpoint_sight_shdr"
    SelectSoundRef="KF_SCARSnd.SCAR_Select"
    HudImageRef="KillingFloor2HUD.WeaponSelect.Scar_unselected"
    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Scar"
    ZoomedDisplayFOV=20.000000
    FireModeClass(0)=Class'NicePack.NiceSCARMK17Fire'
    Description="An advanced tactical assault rifle. Equipped with an aimpoint sight. Fires in semi or full auto with great power and accuracy."
    DisplayFOV=55.000000
    Priority=175
    InventoryGroup=4
    GroupOffset=4
    PickupClass=Class'NicePack.NiceSCARMK17Pickup'
    PlayerViewOffset=(X=25.000000,Y=20.000000)
    AttachmentClass=Class'NicePack.NiceSCARMK17Attachment'
    ItemName="SCAR MK17"
}
