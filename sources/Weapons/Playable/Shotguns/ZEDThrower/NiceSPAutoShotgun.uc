class NiceSPAutoShotgun extends NiceWeapon;
// Toggle semi/auto fire
simulated function DoToggle (){}
// Set the new fire mode on the server
function ServerChangeFireMode(bool bNewWaitForRelease){}
exec function SwitchModes(){}
simulated function WeaponTick(float dt)
{
    local float SteamCharge;
    local rotator DialRot;
    super.WeaponTick(dt);
    if(Level.NetMode!=NM_DedicatedServer){       if(FireMode[1].NextFireTime >= Level.TimeSeconds)           SteamCharge = 1.0 - ((FireMode[1].NextFireTime - Level.TimeSeconds)/FireMode[1].FireRate);       else           SteamCharge = 1.0;
       if(SteamCharge > 0.1 && FireMode[0].NextFireTime >= Level.TimeSeconds)           SteamCharge -= 0.1 * ((FireMode[0].NextFireTime - Level.TimeSeconds)/FireMode[0].FireRate);
       DialRot.roll = 26500 - ( 53000 * SteamCharge );       SetBoneRotation('Dail2',DialRot,1.0);
    }
}
defaultproperties
{    reloadPreEndFrame=0.143000    reloadEndFrame=0.633000    reloadChargeEndFrame=-1.000000    reloadMagStartFrame=0.276000    reloadChargeStartFrame=-1.000000    MagCapacity=10    ReloadRate=2.640000    ReloadAnim="Reload"    ReloadAnimRate=1.250000    WeaponReloadAnim="Reload_IJC_spJackHammer"    Weight=7.000000    bHasAimingMode=True    IdleAimAnim="Idle_Iron"    StandardDisplayFOV=65.000000    SleeveNum=0    TraderInfoTexture=Texture'KF_IJC_HUD.Trader_Weapon_Icons.Trader_Jackhammer'    MeshRef="KF_IJC_Summer_Weps1.Jackhammer"    SkinRefs(0)="KF_Weapons_Trip_T.hands.hands_1stP_military_cmb"    SkinRefs(1)="KF_IJC_Summer_Weapons.Jackhammer.jackhammer_cmb"    SkinRefs(2)="KF_Weapons_Trip_T.Rifles.crossbow_cmb"    SelectSoundRef="KF_SP_ZEDThrowerSnd.KFO_Shotgun_Select"    HudImageRef="KF_IJC_HUD.WeaponSelect.Jackhammer_unselected"    SelectedHudImageRef="KF_IJC_HUD.WeaponSelect.Jackhammer"    PlayerIronSightFOV=80.000000    ZoomedDisplayFOV=45.000000    FireModeClass(0)=Class'NicePack.NiceSPShotgunFire'    FireModeClass(1)=Class'NicePack.NiceSPShotgunAltFire'    PutDownAnim="PutDown"    SelectForce="SwitchToAssaultRifle"    AIRating=0.550000    CurrentRating=0.550000    bShowChargingBar=True    Description="A device for throwing lead and getting sodding enemies out of your face."    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)    DisplayFOV=65.000000    Priority=167    InventoryGroup=4    GroupOffset=15    PickupClass=Class'NicePack.NiceSPShotgunPickup'    PlayerViewOffset=(X=20.000000,Y=23.000000,Z=-2.000000)    BobDamping=6.000000    AttachmentClass=Class'NicePack.NiceSPShotgunAttachment'    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)    ItemName="Multichamber ZED Thrower"    TransientSoundVolume=1.250000
}
