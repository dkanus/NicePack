class NiceClaymore extends NiceMeleeWeapon;
defaultproperties
{
    weaponRange=100.000000
    BloodSkinSwitchArray=0
    BloodyMaterialRef="KF_Weapons4_Trip_T.Claymore_Bloody_cmb"
    bSpeedMeUp=True
    Weight=6.000000
    StandardDisplayFOV=75.000000
    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Claymore'
    bIsTier2Weapon=True
    MeshRef="KF_Wep_Claymore.Claymore_Trip"
    SkinRefs(0)="KF_Weapons4_Trip_T.Weapons.Claymore_cmb"
    SelectSoundRef="KF_ClaymoreSnd.WEP_Claymore_Foley_Select"
    HudImageRef="KillingFloor2HUD.WeaponSelect.Claymore_unselected"
    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Claymore"
    FireModeClass(0)=Class'NicePack.NiceClaymoreFire'
    FireModeClass(1)=Class'NicePack.NiceClaymoreFireB'
    AIRating=0.400000
    CurrentRating=0.600000
    Description="A medieval claymore sword."
    DisplayFOV=75.000000
    Priority=105
    GroupOffset=4
    PickupClass=Class'NicePack.NiceClaymorePickup'
    BobDamping=8.000000
    AttachmentClass=Class'NicePack.NiceClaymoreAttachment'
    IconCoords=(X1=246,Y1=80,X2=332,Y2=106)
    ItemName="Claymore Sword"
}
