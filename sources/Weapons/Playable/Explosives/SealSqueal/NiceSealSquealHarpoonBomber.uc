class NiceSealSquealHarpoonBomber extends NiceWeapon;
// Stuck projectiles, fired from this weapon
var array<int> stuckProjectiles;
/*simulated function ExplodeAllHarpoons(){
    local int i;
    for(i = 0;i < stuckProjectiles.Length;i ++){
       if(stuckProjectiles[i] < 0)
           continue;
       NicePlayerController(instigator.controller).ExplodeStuckBullet(stuckProjectiles[i]);
    }
    stuckProjectiles.Length = 0;
}
simulated function SetupReloadVars(optional bool bIsActive, optional int animationIndex){
    if(Role < ROLE_Authority)
       ExplodeAllHarpoons();
    super.SetupReloadVars(bIsActive, animationIndex);
}
simulated function AltFire(float f){
    ExplodeAllHarpoons();
}
simulated function Destroyed(){
    if(Role < ROLE_Authority)
       ExplodeAllHarpoons();
    super.Destroyed();
}*/
defaultproperties
{
    reloadPreEndFrame=0.195000
    reloadEndFrame=0.537000
    reloadChargeEndFrame=0.861000
    reloadMagStartFrame=0.325000
    reloadChargeStartFrame=0.724000
    MagCapacity=3
    ReloadRate=4.000000
    ReloadAnim="Reload"
    ReloadAnimRate=1.000000
    WeaponReloadAnim="Reload_IJC_SealSqueal"
    Weight=6.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=70.000000
    TraderInfoTexture=Texture'KF_IJC_HUD.Trader_Weapon_Icons.Trader_SealSqueal'
    bIsTier2Weapon=True
    MeshRef="KF_IJC_Halloween_Weps_2.SealSqueal"
    SkinRefs(0)="KF_IJC_Halloween_Weapons2.SealSqueal.SealSqueal_cmb"
    SelectSoundRef="KF_FY_SealSquealSND.WEP_Harpoon_Foley_Select"
    HudImageRef="KF_IJC_HUD.WeaponSelect.SealSqueal_unselected"
    SelectedHudImageRef="KF_IJC_HUD.WeaponSelect.SealSqueal"
    PlayerIronSightFOV=70.000000
    ZoomedDisplayFOV=60.000000
    FireModeClass(0)=Class'NicePack.NiceSealSquealFire'
    FireModeClass(1)=Class'KFMod.NoFire'
    PutDownAnim="PutDown"
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.650000
    CurrentRating=0.650000
    Description="Shoot the zeds with this harpoon gun and watch them squeal.. and then explode!"
    DisplayFOV=70.000000
    Priority=171
    InventoryGroup=4
    GroupOffset=22
    PickupClass=Class'NicePack.NiceSealSquealPickup'
    PlayerViewOffset=(X=15.000000,Y=20.000000,Z=-8.000000)
    BobDamping=6.000000
    AttachmentClass=Class'NicePack.NiceSealSquealAttachment'
    IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
    ItemName="SealSqueal Harpoon Bomber"
    LightType=LT_None
    LightBrightness=0.000000
    LightRadius=0.000000
}
