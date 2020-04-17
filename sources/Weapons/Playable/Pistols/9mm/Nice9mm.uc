class Nice9mm extends NiceSingle;
static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount){
    super.PreloadAssets(Inv, bSkipRefCount);
    // A bit of a temporary hack.
    // There's currently no nice way to call preload assets function for a grenade, so just always load nails' resources
    //class'NicePack.NiceNail'.static.PreloadAssets();
}
defaultproperties
{
    DualClass=Class'NicePack.NiceDual9mm'
    reloadPreEndFrame=0.117000
    reloadEndFrame=0.617000
    reloadChargeEndFrame=-1.000000
    reloadMagStartFrame=0.167000
    reloadChargeStartFrame=-1.000000
    HudImage=Texture'KillingFloorHUD.WeaponSelect.single_9mm_unselected'
    SelectedHudImage=Texture'KillingFloorHUD.WeaponSelect.single_9mm'
    FireModeClass(0)=Class'NicePack.Nice9mmFire'
    SelectSound=Sound'KF_9MMSnd.9mm_Select'
    Description="A 9mm Pistol. What it lacks in stopping power, it compensates for with a quick refire."
    PickupClass=Class'NicePack.Nice9mmPickup'
    AttachmentClass=Class'NicePack.Nice9mmAttachment'
    ItemName="Beretta"
    Mesh=SkeletalMesh'KF_Weapons_Trip.9mm_Trip'
    Skins(0)=Combiner'KF_Weapons_Trip_T.Pistols.Ninemm_cmb'
}
