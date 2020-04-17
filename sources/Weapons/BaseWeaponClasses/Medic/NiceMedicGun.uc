class NiceMedicGun extends NiceWeapon
    abstract;
var const float maxMedicCharge;
var float medicChargeRegenRate;
// This variable is dictated by client.
var float medicCharge;
// Medic charge is replicated on server via these periods
var float medicChargeUpdatePeriod;
// This variable is only relevant on a server, to predict current medic charge in-between new updates
var float lastMedicChargeServerUpdate;
// This variable is only relevant on a client, to predict current medic charge in-between weapon ticks
var float lastMedicChargeClientUpdate;
replication{
    reliable if(Role < ROLE_Authority)
       ServerSetMedicCharge;
    reliable if(Role == ROLE_Authority)
       ClientSetMedicCharge, ClientSuccessfulHeal;
}
function NicePlainData.Data GetNiceData(){
    local NicePlainData.Data transferData;
    transferData = super.GetNiceData();
    class'NicePlainData'.static.SetFloat(transferData, "MedicCharge", GetCurrentMedicCharge());
    class'NicePlainData'.static.SetFloat(transferData, "MedicChargeUpd", Level.TimeSeconds);
    return transferData;
}
function SetNiceData(NicePlainData.Data transferData, optional NiceHumanPawn newOwner){
    super.SetNiceData(transferData, newOwner);
    medicCharge = class'NicePlainData'.static.GetFloat(transferData, "MedicCharge", 0.0);
    lastMedicChargeServerUpdate = class'NicePlainData'.static.GetFloat(transferData, "MedicChargeUpd", -1.0);
    if(lastMedicChargeServerUpdate >= 0.0)
       medicCharge += (Level.TimeSeconds - lastMedicChargeServerUpdate) * medicChargeRegenRate;
    lastMedicChargeServerUpdate = Level.TimeSeconds;
    ClientSetMedicCharge(medicCharge);
}
function ServerSetMedicCharge(float newCharge){
    medicCharge = newCharge;
    lastMedicChargeServerUpdate = Level.TimeSeconds;
}
simulated function ClientSetMedicCharge(float newCharge){
    medicCharge = newCharge;
}
// Returns current medic charge
// Uses prediction a server
simulated function float GetCurrentMedicCharge(){
    if(Role < ROLE_Authority)
       return medicCharge;
    else
       return medicCharge + (Level.TimeSeconds - lastMedicChargeServerUpdate) * medicChargeRegenRate;
}
simulated function WeaponTick(float dt){
    local int prevPeriodsAmount;
    local bool bWasBelowMax;
    if(Role < ROLE_Authority){
       // Remember the old state
       bWasBelowMax = (medicCharge < maxMedicCharge);
       prevPeriodsAmount = Ceil(medicCharge / medicChargeUpdatePeriod);
       // Update medic charge
       medicCharge += (Level.TimeSeconds - lastMedicChargeClientUpdate) * medicChargeRegenRate;
       lastMedicChargeClientUpdate = Level.TimeSeconds;
       medicCharge = FMin(medicCharge, maxMedicCharge);
       secondaryCharge = Ceil(medicCharge);
       // Replicate to server when necessary
       if( (bWasBelowMax && medicCharge >= maxMedicCharge)
           || prevPeriodsAmount < Ceil(medicCharge / medicChargeUpdatePeriod) )
           ServerSetMedicCharge(medicCharge);
    }
    super.WeaponTick(dt);
}
simulated function ClientSuccessfulHeal(NiceHumanPawn healer, NiceHumanPawn healed){
    if(healed == none)
       return;
    if(instigator != none && PlayerController(instigator.controller) != none)
       PlayerController(instigator.controller).
           ClientMessage("You've healed"@healed.GetPlayerName(), 'CriticalEvent');
    if(NiceHumanPawn(instigator) != none && PlayerController(healed.controller) != none)
       PlayerController(healed.controller).
           ClientMessage("You've been healed by"@healer.GetPlayerName(), 'CriticalEvent');
}

defaultproperties
{
     maxMedicCharge=100.000000
     medicChargeRegenRate=10.000000
     medicChargeUpdatePeriod=10.000000
     bShowSecondaryCharge=True
     SecondaryCharge=0
     bChangeSecondaryIcon=True
     hudSecondaryTexture=Texture'KillingFloorHUD.HUD.Hud_Syringe'
     activeSlowdown=0.750000
     activeSpeedup=2.000000
}
