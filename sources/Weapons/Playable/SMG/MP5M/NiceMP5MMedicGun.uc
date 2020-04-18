class NiceMP5MMedicGun extends NiceMedicGun;
var bool            chargerOpen;
var float           chargerStartOpeningTiming, chargerOpenedTiming, chargeCloseTiming;
var const string    chargerStartOpeningTimeStr, chargerOpenedTimeStr, chargeCloseTimeStr;
function NicePlainData.Data GetNiceData(){
    local NicePlainData.Data transferData;
    transferData = super.GetNiceData();
    class'NicePlainData'.static.SetBool(transferData, "MP5MChargerOpen", chargerOpen);
    return transferData;
}
function SetNiceData(NicePlainData.Data transferData, optional NiceHumanPawn newOwner){
    super.SetNiceData(transferData, newOwner);
    chargerOpen = class'NicePlainData'.static.GetBool(transferData, "MP5MChargerOpen", false);
}
simulated function PostBeginPlay(){
    local EventRecord record;
    // Setup reload events
    record.eventName = chargerStartOpeningTimeStr;
    record.eventFrame = chargerStartOpeningTiming;
    relEvents[relEvents.Length] = record;
    record.eventName = chargerOpenedTimeStr;
    record.eventFrame = chargerOpenedTiming;
    relEvents[relEvents.Length] = record;
    record.eventName = chargeCloseTimeStr;
    record.eventFrame = chargeCloseTiming;
    relEvents[relEvents.Length] = record;
    super.PostBeginPlay();
}
simulated function ReloadEvent(string eventName){
    local float magStart;
    // Calculate the point from which we should resume the magazine part
    if(bMagazineOut)
       magStart = 0.605;
    else if(IsMagazineFull())
       magStart = 0.868;
    else
       magStart = 0.351;
    // Jump if needed
    if(eventName ~= chargerStartOpeningTimeStr && (bRoundInChamber || chargerOpen)){
       ScrollAnim(magStart);
       lastEventCheckFrame = magStart;
    }
    // Flag changes
    if(eventName ~= chargerOpenedTimeStr){
       chargerOpen = true;
       if(bMagazineOut || !IsMagazineFull()){
           ScrollAnim(magStart);
           lastEventCheckFrame = magStart;
       }
    }
    if(eventName ~= chargeCloseTimeStr)
       chargerOpen = false;
}
defaultproperties
{
    chargerOpen=True
    chargerStartOpeningTiming=0.010000
    chargerOpenedTiming=0.175000
    chargeCloseTiming=0.895000
    chargerStartOpeningTimeStr="openChargerS"
    chargerOpenedTimeStr="openChargerE"
    chargeCloseTimeStr="closeCharger"
    reloadPreEndFrame=0.544000
    reloadEndFrame=0.728000
    reloadChargeEndFrame=0.895000
    MagazineBone="Empty_Magazine"
    MagCapacity=30
    ReloadRate=3.040000
    ReloadAnim="Reload"
    ReloadAnimRate=1.250000
    WeaponReloadAnim="Reload_MP5"
    Weight=4.000000
    bHasAimingMode=True
    IdleAimAnim="Idle_Iron"
    StandardDisplayFOV=55.000000
    SleeveNum=2
    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Mp5Medic'
    bIsTier2Weapon=True
    MeshRef="KF_Wep_MP5.MP5_Trip"
    SkinRefs(0)="KF_Weapons4_Trip_T.Weapons.MP5_cmb"
    SkinRefs(1)="KF_Weapons2_Trip_T.Special.Aimpoint_sight_shdr"
    SelectSoundRef="KF_MP5Snd.WEP_MP5_Foley_Select"
    HudImageRef="KillingFloor2HUD.WeaponSelect.Mp5Medic_unselected"
    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Mp5Medic"
    PlayerIronSightFOV=65.000000
    ZoomedDisplayFOV=45.000000
    FireModeClass(0)=Class'NicePack.NiceMP5MFire'
    FireModeClass(1)=Class'NicePack.NiceMP5MAltFire'
    PutDownAnim="PutDown"
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.550000
    CurrentRating=0.550000
    bShowChargingBar=True
    Description="MP5 sub machine gun. Modified to fire healing darts. Better damage and healing than MP7M with a larger mag."
    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
    DisplayFOV=55.000000
    Priority=80
    InventoryGroup=3
    GroupOffset=4
    PickupClass=Class'NicePack.NiceMP5MPickup'
    PlayerViewOffset=(X=25.000000,Y=20.000000,Z=-6.000000)
    BobDamping=6.000000
    AttachmentClass=Class'NicePack.NiceMP5MAttachment'
    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
    ItemName="MP5M Medic Gun"
    TransientSoundVolume=1.250000
}
