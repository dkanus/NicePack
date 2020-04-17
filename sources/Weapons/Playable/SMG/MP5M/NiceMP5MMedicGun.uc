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
    else if(IsMagazineFull())
    else
    // Jump if needed
    if(eventName ~= chargerStartOpeningTimeStr && (bRoundInChamber || chargerOpen)){
    }
    // Flag changes
    if(eventName ~= chargerOpenedTimeStr){
    }
    if(eventName ~= chargeCloseTimeStr)
}
defaultproperties
{
}