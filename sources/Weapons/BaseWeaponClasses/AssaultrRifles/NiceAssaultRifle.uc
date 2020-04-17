class NiceAssaultRifle extends NiceWeapon;
var bool    newStatesLoaded;
var bool    bAutoFireEnabled;
var bool    bSemiAutoFireEnabled;
var bool    bBurstFireEnabled;
var bool    bIsBursting;
var bool    bIsAltSwitches;
var bool    bMustSwitchMode;    // Switch between auto and semi-auto/burst modes as soon as possible
var Pawn    rememberedOwner;
enum EFireType{
    ETYPE_NONE,
    ETYPE_AUTO,
    ETYPE_SEMI,
    ETYPE_BURST
};
var EFireType   MainFire;
var EFireType   SndFire;
var EFireType   PendingFire;
replication
{
    reliable if(Role < ROLE_Authority)
       ServerForceBurst, ServerApplyFireModes, ServerChangeFireTypes;
    reliable if(Role == ROLE_Authority)
       MainFire, SndFire, PendingFire, ClientNiceChangeFireMode, ClientChangeBurstLength;
}
simulated function EFireType GetComplimentaryFire(EFireType type){
    if(type == ETYPE_AUTO || type == ETYPE_none)
       return ETYPE_AUTO;
    if(type == ETYPE_SEMI)
       return ETYPE_BURST;
    return ETYPE_SEMI;
}
simulated function int AmountOfActiveModes(){
    if(bAutoFireEnabled && bSemiAutoFireEnabled && bBurstFireEnabled)
       return 3;
    else if(!bAutoFireEnabled && !bSemiAutoFireEnabled && !bBurstFireEnabled)
       return 0;
    else if( (bAutoFireEnabled && bSemiAutoFireEnabled) || (bAutoFireEnabled && bBurstFireEnabled) || (bSemiAutoFireEnabled && bBurstFireEnabled) )
       return 2;
    return 1;
}
function ServerApplyFireModes(){
    local NiceFire niceRifleFire;
    local NicePlayerController nicePlayer;
    niceRifleFire = NiceFire(FireMode[0]);
    if(Instigator != none)
       nicePlayer = NicePlayerController(Instigator.Controller);
    if(niceRifleFire == none)
       return;
    if(MainFire == ETYPE_AUTO)
       niceRifleFire.bWaitForRelease = false;
    else if(MainFire == ETYPE_SEMI){
       niceRifleFire.bSemiMustBurst = false;
       niceRifleFire.bWaitForRelease = true;
    }
    else if(MainFire == ETYPE_BURST){
       niceRifleFire.bSemiMustBurst = true;
       niceRifleFire.bWaitForRelease = true;
       niceRifleFire.currentContext.burstLength = niceRifleFire.MaxBurstLength;
       if(SndFire == ETYPE_SEMI)
           SndFire = ETYPE_BURST;
    }
    if(nicePlayer != none && !nicePlayer.bFlagAltSwitchesModes){
       if(SndFire == ETYPE_SEMI)
           niceRifleFire.currentContext.burstLength = 1;
       else if(SndFire == ETYPE_BURST)
           niceRifleFire.currentContext.burstLength = niceRifleFire.MaxBurstLength;
    }
    if(!bIsReloading && IsFiring()){
       StopFire(0);
       StopFire(1);
    }
    ClientNiceChangeFireMode(niceRifleFire.bWaitForRelease, niceRifleFire.bSemiMustBurst);
    ClientChangeBurstLength(niceRifleFire.currentContext.burstLength);
}
simulated function ResetFireModes(){
    local int modesCount;
    local NicePlayerController nicePlayer;
    modesCount = AmountOfActiveModes();
    nicePlayer = NicePlayerController(Instigator.Controller);
    if(modesCount <= 0 || nicePlayer == none)
       return;
    if(nicePlayer.bFlagAltSwitchesModes){
       if(modesCount == 1){
           if(bAutoFireEnabled)
               MainFire = ETYPE_AUTO;
           else if(bSemiAutoFireEnabled)
               MainFire = ETYPE_SEMI;
           else if(bBurstFireEnabled)
               MainFire = ETYPE_BURST;
       }
       else if(modesCount == 2){
           if(bAutoFireEnabled){
               MainFire = ETYPE_AUTO;
               if(bSemiAutoFireEnabled)
                   PendingFire = ETYPE_SEMI;
               else if(bBurstFireEnabled)
                   PendingFire = ETYPE_BURST;
           }
           else{
               MainFire = ETYPE_SEMI;
               PendingFire = ETYPE_BURST;
           }
       }
       else{
           MainFire = ETYPE_AUTO;
           PendingFire = ETYPE_SEMI;
       }
    }
    else{
       if(modesCount == 1){
           if(bAutoFireEnabled)
               MainFire = ETYPE_AUTO;
           else if(bSemiAutoFireEnabled)
               MainFire = ETYPE_SEMI;
           else if(bBurstFireEnabled)
               MainFire = ETYPE_BURST;
           SndFire = ETYPE_none;
       }
       else if(modesCount == 2){
           if(bAutoFireEnabled){
               MainFire = ETYPE_AUTO;
               if(bSemiAutoFireEnabled)
                   SndFire = ETYPE_SEMI;
               else if(bBurstFireEnabled)
                   SndFire = ETYPE_BURST;
           }
           else{
               MainFire = ETYPE_SEMI;
               SndFire = ETYPE_BURST;
           }
       }
       else{
           MainFire = ETYPE_AUTO;
           SndFire = ETYPE_SEMI;
       }
    }
    ServerChangeFireTypes(MainFire, SndFire, PendingFire);
    ServerApplyFireModes();
}
function ServerChangeFireTypes(EFireType newMain, EFireType newSnd, EFireType newPending){
    MainFire = newMain;
    SndFire = newSnd;
    PendingFire = newPending;
}
function ServerForceBurst(){
    local NiceFire niceRifleFire;
    niceRifleFire = NiceFire(FireMode[0]);
    if(niceRifleFire != none)
       niceRifleFire.DoBurst();
}
// Use alt fire to switch fire modes
simulated function AltFire(float F){
    local NiceFire niceRifleFire;
    local NicePlayerController nicePlayer;
    niceRifleFire = NiceFire(FireMode[0]);
    nicePlayer = NicePlayerController(Instigator.Controller);
    if(nicePlayer != none && niceRifleFire != none && SndFire != ETYPE_NONE){
       if(FireModeClass[1] == class'KFMod.NoFire'){
           if(nicePlayer.bFlagAltSwitchesModes)
               SwitchModes();
           else{
               niceRifleFire.DoBurst();
               ServerForceBurst();
               super.AltFire(F);
           }
           return;
       }    
    }
    super.AltFire(F);
}
exec simulated function SwitchModes(){
    if(Role < ROLE_Authority && AmountOfActiveModes() > 1)
       bMustSwitchMode = !bMustSwitchMode;
}
simulated function DoToggle(){
    local EFireType tempType;
    local PlayerController player;
    if(IsFiring())
      return;
    player = Level.GetLocalPlayerController();
    if(player != none && AmountOfActiveModes() > 1){
       tempType = MainFire;
       MainFire = PendingFire;
       PendingFire = tempType;
       player.bFire = 0;
       player.bAltFire = 0;
       ServerChangeFireTypes(MainFire, SndFire, PendingFire);
       ServerApplyFireModes();
       PlayOwnedSound(ToggleSound, SLOT_none, 2.0,,,, false);
       if(MainFire == ETYPE_AUTO)
           player.ReceiveLocalizedMessage(class'NicePack.NiceAssaultRifleMessage', 1);
       else if(MainFire == ETYPE_SEMI)
           player.ReceiveLocalizedMessage(class'NicePack.NiceAssaultRifleMessage', 0);
       else if(MainFire == ETYPE_BURST)
           player.ReceiveLocalizedMessage(class'NicePack.NiceAssaultRifleMessage', 2);
    }
}
simulated function SecondDoToggle(){
    local EFireType choosenType;
    local NiceFire niceRifleFire;
    local NicePlayerController nicePlayer;
    if(FireModeClass[1] != class'KFMod.NoFire'){
       DoToggle();
       return;
    }
    niceRifleFire = NiceFire(FireMode[0]);
    nicePlayer = NicePlayerController(Instigator.Controller);
    if(IsFiring() || AmountOfActiveModes() < 3 || nicePlayer == none || niceRifleFire == none)
       return;
    if(nicePlayer.bFlagAltSwitchesModes){
       if(MainFire == ETYPE_AUTO){
           PendingFire = GetComplimentaryFire(PendingFire);
           choosenType = PendingFire;
       }
       else{
           MainFire = GetComplimentaryFire(MainFire);
           choosenType = MainFire;
       }
    }
    else{
       SndFire = GetComplimentaryFire(SndFire);
       choosenType = SndFire;
    }
    ServerChangeFireTypes(MainFire, SndFire, PendingFire);
    ServerApplyFireModes();
    PlayOwnedSound(ToggleSound, SLOT_none, 2.0,,,, false);
    if(choosenType == ETYPE_SEMI)
       nicePlayer.ReceiveLocalizedMessage(class'NicePack.NiceAssaultRifleMessage', 4);
    else
       nicePlayer.ReceiveLocalizedMessage(class'NicePack.NiceAssaultRifleMessage', 5);
}
simulated function ClientNiceChangeFireMode(bool bNewWaitForRelease, bool bNewSemiMustBurst){
    local NiceFire niceF;
    if(!bIsReloading && IsFiring()){
       StopFire(0);
       StopFire(1);
    }
    niceF = NiceFire(FireMode[0]);
    FireMode[0].bWaitForRelease = bNewWaitForRelease;
    FireMode[0].bNowWaiting = bNewWaitForRelease;
    if(niceF != none)
       niceF.bSemiMustBurst = bNewSemiMustBurst;
}
simulated function ClientChangeBurstLength(int newBurstLength){
    if(NiceFire(FireMode[0]) != none)
       NiceFire(FireMode[0]).currentContext.burstLength = newBurstLength;
}
simulated function bool AltFireCanForceInterruptReload(){
    local NicePlayerController nicePlayer;
    nicePlayer = NicePlayerController(Instigator.Controller);
    if(nicePlayer != none)
       return (!nicePlayer.bFlagAltSwitchesModes) && (GetMagazineAmmo() > 0);
    return false;
}
simulated function WeaponTick(float dt){
    local NicePlayerController nicePlayer;
    super.WeaponTick(dt);
    if(bMustSwitchMode && FireMode[0].NextFireTime /*+ 0.1*/ < Level.TimeSeconds && Role < ROLE_Authority){
       DoToggle();
       bMustSwitchMode = false;
    }
    nicePlayer = NicePlayerController(Instigator.Controller);
    if(Role == ROLE_Authority && nicePlayer != none && (bIsAltSwitches != nicePlayer.bFlagAltSwitchesModes || (rememberedOwner != Instigator))){
       if(newStatesLoaded)
           ServerApplyFireModes();
       else
           ResetFireModes();
       bIsAltSwitches = nicePlayer.bFlagAltSwitchesModes;
       rememberedOwner = Instigator;
    }
}
function NicePlainData.Data GetNiceData(){
    local NicePlainData.Data transferData;
    transferData = super.GetNiceData();
    class'NicePlainData'.static.SetInt(transferData, "MainFire", int(MainFire));
    class'NicePlainData'.static.SetInt(transferData, "SndFire", int(SndFire));
    class'NicePlainData'.static.SetInt(transferData, "PendingFire", int(PendingFire));
    return transferData;
}
function SetNiceData(NicePlainData.Data transferData, optional NiceHumanPawn newOwner){
    local EFireType newFireType;
    super.SetNiceData(transferData, newOwner);
    newStatesLoaded = false;
    if(class'NicePlainData'.static.LookupVar(transferData, "MainFire") < 0)
       ResetFireModes();
    else{
       newFireType = EFireType(class'NicePlainData'.static.GetInt(transferData, "MainFire"));
       MainFire = newFireType;
       newFireType = EFireType(class'NicePlainData'.static.GetInt(transferData, "SndFire"));
       SndFire = newFireType;
       newFireType = EFireType(class'NicePlainData'.static.GetInt(transferData, "PendingFire"));
       PendingFire = newFireType;
       newStatesLoaded = true;
    }
}

defaultproperties
{
     bAutoFireEnabled=True
     bSemiAutoFireEnabled=True
     MainFire=ETYPE_AUTO
     SndFire=ETYPE_SEMI
     PendingFire=ETYPE_BURST
     bUseFlashlightToToggle=True
}
