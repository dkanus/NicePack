class NiceMachete extends NiceMeleeWeapon;
defaultproperties
{
    weaponRange=80.000000
    BloodSkinSwitchArray=0
    BloodyMaterialRef="KF_Weapons_Trip_T.melee.machete_bloody_cmb"
    bSpeedMeUp=True
    Weight=1.000000
    StandardDisplayFOV=70.000000
    TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Machete'
    bIsTier2Weapon=True
    MeshRef="KF_Weapons_Trip.Machete_Trip"
    SkinRefs(0)="KF_Weapons_Trip_T.melee.Machete_cmb"
    SkinRefs(1)="KF_Weapons_Trip_T.hands.hands_1stP_military_cmb"
    SelectSoundRef="KF_MacheteSnd.Machete_Select"
    HudImageRef="KillingFloorHUD.WeaponSelect.machette_unselected"
    SelectedHudImageRef="KillingFloorHUD.WeaponSelect.machette"
    FireModeClass(0)=Class'NicePack.NiceMacheteFire'
    FireModeClass(1)=Class'NicePack.NiceMacheteFireB'
    AIRating=0.400000
    CurrentRating=0.400000
    Description="A machete - commonly used for hacking through brush, or the limbs of ZEDs."
    DisplayFOV=70.000000
    Priority=50
    GroupOffset=2
    PickupClass=Class'NicePack.NiceMachetePickup'
    BobDamping=8.000000
    AttachmentClass=Class'NicePack.NiceMacheteAttachment'
    IconCoords=(Y1=407,X2=118,Y2=442)
    ItemName="Machete"
}
