class NiceBoomStick extends NiceWeapon;
#EXEC OBJ LOAD FILE=KillingFloorHUD.utx
var float           glueTiming;
var float           firstShellTiming, secondShellTiming, jumpTiming;
var const string    firstShellStr, secondShellStr, jumpStr;
simulated function PostBeginPlay(){
    local EventRecord record;
    local AutoReloadAnimDesc reloadDesc;
    // Setup animation timings
    autoReloadsDescriptions.Length = 0;
    reloadDesc.canInterruptFrame    = 0.056;
    reloadDesc.trashStartFrame      = secondShellTiming;
    reloadDesc.resumeFrame          = 0.056;
    reloadDesc.speedFrame           = 0.056;
    // Setup all possible fire animations
    reloadDesc.animName = 'Fire_Both';
    autoReloadsDescriptions[0] = reloadDesc;
    reloadDesc.animName = 'Fire_Both_Iron';
    autoReloadsDescriptions[1] = reloadDesc;
    reloadDesc.animName = 'Fire_Last';
    autoReloadsDescriptions[2] = reloadDesc;
    reloadDesc.animName = 'Fire_Last_Iron';
    autoReloadsDescriptions[3] = reloadDesc;
    // Setup reload events
    record.eventName = jumpStr;
    record.eventFrame = jumpTiming;
    relEvents[relEvents.Length] = record;
    record.eventName = firstShellStr;
    record.eventFrame = firstShellTiming;
    relEvents[relEvents.Length] = record;
    record.eventName = secondShellStr;
    record.eventFrame = secondShellTiming;
    relEvents[relEvents.Length] = record;
    super.PostBeginPlay();
}
simulated function ReloadEvent(string eventName){
    if(eventName ~= jumpStr && GetMagazineAmmo() > 0)
    if(eventName ~= firstShellStr)
    else if(eventName ~= secondShellStr)
    ServerSetMagSize(MagAmmoRemainingClient, bRoundInChamber, Level.TimeSeconds);
}
simulated function AddAutoReloadedAmmo(){
    MagAmmoRemainingClient = Min(2, AmmoAmount(0));
    ServerSetMagSize(MagAmmoRemainingClient, bRoundInChamber, Level.TimeSeconds);
}
simulated function bool AltFireCanForceInterruptReload(){
    return (GetMagazineAmmo() > 0);
}
defaultproperties
{
    Weight=6.000000
}