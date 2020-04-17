class NiceDualies extends NiceWeapon;
var class<NiceSingle> SingleClass;
var name altFlashBoneName;
var name altTPAnim;
var Actor altThirdPersonActor;
var name altWeaponAttach;
// Track ammo in each gun separately
var int MagAmmoRemLeft, MagAmmoRemLeftClient;
var int MagAmmoRemRight, MagAmmoRemRightClient;
// Variables for managing dual-pistols reload
var const string    leftEjectStr,   rightEjectStr;      // Event names that trigger when magazines ejected
var const string    leftInsertStr,  rightInsertStr;     // Event names that trigger when magazines inserted
var float           leftEject,      rightEject;         // Frame at which magazines ejected
var float           leftInsert,     rightInsert;        // Frame at which magazines inserted
// This weapon is currently switching and soon won't exist
var bool    bSwitching;
replication{
    reliable if(Role < ROLE_Authority)
       ServerUpdateWeaponMag, ServerSetDualMagSize, ServerReduceDualMag, ServerSwitchToSingle, ServerSwitchToGivenSingle;
    reliable if(Role == ROLE_Authority)
      MagAmmoRemLeft, MagAmmoRemRight, ClientSetDualMagSize;
    reliable if(bNetOwner && bNetDirty && (Role == ROLE_Authority))
       altThirdPersonActor;
}
simulated function PostBeginPlay(){
    super.PostBeginPlay();
    SetupDualReloadEvents();
    reloadPreEndFrame = FMin(leftEject, rightEject);
    reloadEndFrame = FMax(leftInsert, rightInsert);
    DemoReplacement = SingleClass;
}
simulated function SetupDualReloadEvents(){
    local EventRecord record;
    relEvents.Length = 0;
    record.eventName = leftEjectStr;
    record.eventFrame = leftEject;
    relEvents[relEvents.Length] = record;
    record.eventName = rightEjectStr;
    record.eventFrame = rightEject;
    relEvents[relEvents.Length] = record;
    record.eventName = leftInsertStr;
    record.eventFrame = leftInsert;
    relEvents[relEvents.Length] = record;
    record.eventName = rightInsertStr;
    record.eventFrame = rightInsert;
    relEvents[relEvents.Length] = record;
}
// Don't use that one for dualies
simulated function AddReloadedAmmo(){}
// Use this one
simulated function ReloadEvent(string eventName){
    local int halfMag;
    local int totalAvailableAmmo;
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);
    halfMag = GetSingleMagCapacity();
    totalAvailableAmmo = AmmoAmount(0);
    totalAvailableAmmo -= (MagAmmoRemLeftClient + MagAmmoRemRightClient);
    // Handle ejection
    if(eventName ~= leftEjectStr){
       MagAmmoRemLeftClient = 0;
       ServerSetDualMagSize(MagAmmoRemLeftClient, MagAmmoRemRightClient, Level.TimeSeconds);
       NiceDualies(Instigator.Weapon).GetMagazineAmmo();
       return;
    }
    else if(eventName ~= rightEjectStr){
       MagAmmoRemRightClient = 0;
       ServerSetDualMagSize(MagAmmoRemLeftClient, MagAmmoRemRightClient, Level.TimeSeconds);
       NiceDualies(Instigator.Weapon).GetMagazineAmmo();
       return;
    }
    // Handle reload
    if(totalAvailableAmmo < 0)
       return;
    if(eventName ~= leftInsertStr){
       MagAmmoRemLeftClient += totalAvailableAmmo;
       MagAmmoRemLeftClient = Min(MagAmmoRemLeftClient, halfMag);
    }
    else if(eventName ~= rightInsertStr){
       MagAmmoRemRightClient += totalAvailableAmmo;
       MagAmmoRemRightClient = Min(MagAmmoRemRightClient, halfMag);
    }
    NiceDualies(Instigator.Weapon).GetMagazineAmmo();
    ServerSetDualMagSize(MagAmmoRemLeftClient, MagAmmoRemRightClient, Level.TimeSeconds);
}
simulated function BringUp(optional Weapon PrevWeapon){
    super.BringUp(PrevWeapon);
    ApplyLaserState();
}
simulated function ApplyLaserState(){
    super.ApplyLaserState();
    if(NiceAttachment(altThirdPersonActor) != none)
       NiceAttachment(altThirdPersonActor).SetLaserType(LaserType);
}
simulated function ZoomIn(bool bAnimateTransition){
    super.ZoomIn(bAnimateTransition);
    if(bAnimateTransition){
       if(bZoomOutInterrupted)
           PlayAnim('GOTO_Iron',1.0,0.1);
       else
           PlayAnim('GOTO_Iron',1.0,0.1);
    }
}
simulated function ZoomOut(bool bAnimateTransition){
    local float AnimLength, AnimSpeed;
    super.ZoomOut(false);
    if(bAnimateTransition){
       AnimLength = GetAnimDuration('GOTO_Hip', 1.0);
       if(ZoomTime > 0 && AnimLength > 0)
           AnimSpeed = AnimLength/ZoomTime;
       else
           AnimSpeed = 1.0;
       PlayAnim('GOTO_Hip',AnimSpeed,0.1);
    }
}
function AttachToPawn(Pawn P){
    local name BoneName;
    Super.AttachToPawn(P);
    if(altThirdPersonActor == none){
       altThirdPersonActor = Spawn(AttachmentClass, Owner);
       InventoryAttachment(altThirdPersonActor).InitFor(self);
    }
    else
       altThirdPersonActor.NetUpdateTime = Level.TimeSeconds - 1;
    BoneName = P.GetOffhandBoneFor(self);
    if(BoneName == ''){
       altThirdPersonActor.SetLocation(P.Location);
       altThirdPersonActor.SetBase(P);
    }
    else
       P.AttachToBone(altThirdPersonActor, BoneName);
    if(altThirdPersonActor != none)
       NiceDualiesAttachment(altThirdPersonActor).bIsOffHand = true;
    if(altThirdPersonActor != none && ThirdPersonActor != none){
       NiceDualiesAttachment(altThirdPersonActor).brother = NiceDualiesAttachment(ThirdPersonActor);
       NiceDualiesAttachment(ThirdPersonActor).brother = NiceDualiesAttachment(altThirdPersonActor);
       altThirdPersonActor.LinkMesh(NiceDualiesAttachment(ThirdPersonActor).BrotherMesh);
    }
}
simulated function DetachFromPawn(Pawn P){
    super.DetachFromPawn(P);
    if(altThirdPersonActor != none){
       altThirdPersonActor.Destroy();
       altThirdPersonActor = none;
    }
}
simulated function Destroyed(){
    super.Destroyed();
    if(ThirdPersonActor != none)
       ThirdPersonActor.Destroy();
    if(altThirdPersonActor != none)
       altThirdPersonActor.Destroy();
}
simulated function vector GetEffectStart(){
    local Vector RightFlashLoc,LeftFlashLoc;
    RightFlashLoc = GetBoneCoords(default.FlashBoneName).Origin;
    LeftFlashLoc = GetBoneCoords(default.altFlashBoneName).Origin;
    if(Instigator.IsFirstPerson()){
       if(WeaponCentered())
           return CenteredEffectStart();
       if(bAimingRifle){
           if(KFFire(GetFireMode(0)).FireAimedAnim != 'FireLeft_Iron')
               return RightFlashLoc;
           else
               return LeftFlashLoc;
       }
       else{
           if(GetFireMode(0).FireAnim != 'FireLeft')
               return RightFlashLoc;
           else
               return LeftFlashLoc;
       }
    }
    else{
       return (Instigator.Location + Instigator.EyeHeight * Vect(0, 0, 0.5) + vector(Instigator.Rotation) * 40.0);
    }
}
function NicePlainData.Data GetNiceData(){
    local NicePlainData.Data transferData;
    transferData = super.GetNiceData();
    class'NicePlainData'.static.SetInt(transferData, "leftMag", MagAmmoRemLeft);
    class'NicePlainData'.static.SetInt(transferData, "rightMag", MagAmmoRemRight);
    return transferData;
}
function SetNiceData(NicePlainData.Data transferData, optional NiceHumanPawn newOwner){
    local int halfMag;
    super.SetNiceData(transferData, newOwner);
    if(newOwner != none)
       UpdateMagCapacity(newOwner.PlayerReplicationInfo);
    halfMag = GetSingleMagCapacity();
    MagAmmoRemLeft = class'NicePlainData'.static.GetInt(transferData, "leftMag", halfMag);
    MagAmmoRemRight = class'NicePlainData'.static.GetInt(transferData, "rightMag", halfMag);
    ClientSetDualMagSize(MagAmmoRemLeft, MagAmmoRemRight);
}
simulated function AltFire(float F){
    if(NicePlayerController(Instigator.Controller) != none)
       ClientForceInterruptReload(CANCEL_PASSIVESWITCH);
    if(!bIsReloading)
       ServerSwitchToSingle();
}
simulated function FireGivenGun(bool bFireLeft){
    local NiceDualiesFire niceFireMode;
    niceFireMode = NiceDualiesFire(FireMode[0]);
    if(niceFireMode != none){
       if(bFireLeft)
           niceFireMode.ModeDoFireLeft();
       else
           niceFireMode.ModeDoFireRight();
    }
}
function NiceSingle ServerSwitchToGivenSingle(bool bSwitchToLeft){
    local int m;
    local int origAmmo;
    local NiceHumanPawn nicePawn;
    local NiceSingle singlePistol;
    local NicePlainData.Data transferData;
    nicePawn = NiceHumanPawn(Instigator);
    if(nicePawn == none || SingleClass == none || nicePawn.Health <= 0)
       return none;
    nicePawn.CurrentWeight -= Weight;
    Weight = 0;
    bSwitching = true;
    origAmmo = AmmoAmount(0);
    for(m = 0; m < NUM_FIRE_MODES;m ++)
       if(FireMode[m].bIsFiring)
           StopFire(m);
    DetachFromPawn(nicePawn);
    singlePistol = nicePawn.Spawn(SingleClass);
    if(singlePistol != none){
       singlePistol.Weight = default.Weight;
       singlePistol.DemoReplacement = DemoReplacement;
       transferData = GetNiceData();
       singlePistol.GiveTo(nicePawn);
       singlePistol.SetNiceData(transferData, nicePawn);
       singlePistol.bIsDual = true;
       singlePistol.Weight = default.Weight;
       singlePistol.SellValue = SellValue;
       if(bSwitchToLeft){
           singlePistol.otherMagazine = MagAmmoRemRight;
           singlePistol.MagAmmoRemaining = MagAmmoRemLeft;
           singlePistol.Ammo[0].AmmoAmount = origAmmo - MagAmmoRemRight;
       }
       else{
           singlePistol.otherMagazine = MagAmmoRemLeft;
           singlePistol.MagAmmoRemaining = MagAmmoRemRight;
           singlePistol.Ammo[0].AmmoAmount = origAmmo - MagAmmoRemLeft;
       }
       singlePistol.ClientSetMagSize(singlePistol.MagAmmoRemaining, false);
       //nicePawn.ServerChangedWeapon(self, singlePistol);
       //nicePawn.ClientChangeWeapon(singlePistol);
    }
    Destroy();
    return singlePistol;
}
function NiceSingle ServerSwitchToSingle(){
    return ServerSwitchToGivenSingle(MagAmmoRemLeft > MagAmmoRemRight);
}
function DropFrom(vector StartLocation){
    local int m;
    local int magKeep, magGive;
    local NiceHumanPawn nicePawn;
    local KFWeaponPickup weapPickup;
    local NiceSingle singlePistol;
    local int AmmoThrown, OtherAmmo;
    nicePawn = NiceHumanPawn(Instigator);
    if(nicePawn == none || !bCanThrow || SingleClass == none)
       return;
    nicePawn.CurrentWeight -= Weight;
    Weight = 0;
    bSwitching = true;
    if(MagAmmoRemLeft > MagAmmoRemRight){
       magKeep = MagAmmoRemLeft;
       magGive = MagAmmoRemRight;
    }
    else{
       magKeep = MagAmmoRemRight;
       magGive = MagAmmoRemLeft;
    }
    OtherAmmo = AmmoAmount(0);
    ClientWeaponThrown();
    for(m = 0; m < NUM_FIRE_MODES;m ++)
       if(FireMode[m].bIsFiring)
           StopFire(m);
    DetachFromPawn(nicePawn);
    AmmoThrown = magGive;
    OtherAmmo = OtherAmmo - AmmoThrown;
    singlePistol = nicePawn.Spawn(SingleClass);
    if(singlePistol != none){
       singlePistol.DemoReplacement = none;
       singlePistol.GiveTo(nicePawn);
       singlePistol.Ammo[0].AmmoAmount = OtherAmmo;
       singlePistol.MagAmmoRemaining = magKeep;
       singlePistol.ClientSetMagSize(singlePistol.MagAmmoRemaining, false);
       MagAmmoRemaining = magGive;
       //nicePawn.ServerChangedWeapon(self, singlePistol);
       //nicePawn.ClientChangeWeapon(singlePistol);
    }
    weapPickup = KFWeaponPickup(nicePawn.Spawn(SingleClass.default.PickupClass,,, StartLocation));
    if(weapPickup != none){
       weapPickup.InitDroppedPickupFor(self);
       weapPickup.Weight = default.Weight;
       weapPickup.Velocity = Velocity;
       weapPickup.AmmoAmount[0] = AmmoThrown;
       weapPickup.SellValue = SellValue / 2;
       singlePistol.SellValue = weapPickup.SellValue;
       weapPickup.MagAmmoRemaining = magGive;
       if(nicePawn.Health > 0)
           weapPickup.bThrown = true;
    }
    Destroy();
    if(KFGameType(Level.Game) != none)
       KFGameType(Level.Game).WeaponDestroyed(class);
}
function bool HandlePickupQuery(pickup Item){
    if(Item.InventoryType == SingleClass){
       if(LastHasGunMsgTime < Level.TimeSeconds && PlayerController(Instigator.Controller) != none){
           LastHasGunMsgTime = Level.TimeSeconds + 0.5;
           PlayerController(Instigator.Controller).ReceiveLocalizedMessage(Class'KFMainMessages', 1);
       }
       return true;
    }
    return super.HandlePickupQuery(Item);
}
// Nice functions
simulated function int GetSingleMagCapacity(){
    return int(float(MagCapacity) * 0.5);
}
function UpdateWeaponMag(){
    ServerUpdateWeaponMag();
}
function ServerUpdateWeaponMag(){
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);
    MagAmmoRemLeft = Min(MagAmmoRemLeft, GetSingleMagCapacity());
    MagAmmoRemRight = Min(MagAmmoRemRight, GetSingleMagCapacity());
    ClientSetDualMagSize(MagAmmoRemLeft, MagAmmoRemRight);
}
simulated function ClientUpdateWeaponMag(){
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);
    MagAmmoRemLeftClient = Min(MagAmmoRemLeftClient, GetSingleMagCapacity());
    MagAmmoRemRightClient = Min(MagAmmoRemRightClient, GetSingleMagCapacity());
    ServerSetDualMagSize(MagAmmoRemLeftClient, MagAmmoRemRightClient, Level.TimeSeconds);
}
// Forces update for client's magazine ammo counter
// In case we are using client-side hit-detection, client itself manages remaining ammunition in magazine, but in some cases we want server to dictate current magazine amount
// This function sets client's mag size to a given value
simulated function ClientSetDualMagSize(int newLeftMag, int newRightMag){
    MagAmmoRemLeftClient = newLeftMag;
    MagAmmoRemRightClient = newRightMag;
    MagAmmoRemainingClient = MagAmmoRemLeftClient + MagAmmoRemRightClient;
}
// This function allows clients to change magazine size without altering total ammo amount
// It allows clients to provide time-stamps, so that older change won't override a newer one
function ServerSetDualMagSize(int newLeftMag, int newRightMag, float updateTime){
    MagAmmoRemLeft = newLeftMag;
    MagAmmoRemRight = newRightMag;
    magAmmoRemaining = MagAmmoRemLeft + MagAmmoRemRight;
    if(LastMagUpdateFromClient <= updateTime){
       LastMagUpdateFromClient = updateTime;
       if(magAmmoRemaining > 0)
           bServerFiredLastShot = false;
    }
}
// This function allows clients to change magazine size along with total ammo amount on the server (to update ammo counter in client-side mode)
// It allows clients to provide time-stamps, so that older change won't override a newer one
// Intended to be used for decreasing ammo count from shooting and cannot increase magazine size
function ServerReduceDualMag(int newLeftMag, int newRightMag, float updateTime, int Mode){
    local int delta;
    delta = MagAmmoRemLeft - newLeftMag;
    delta += MagAmmoRemRight - newRightMag;
    // Only update later changes that actually decrease magazine
    if(LastMagUpdateFromClient <= updateTime && delta > 0){
       LastMagUpdateFromClient = updateTime;
       MagAmmoRemLeft = newLeftMag;
       MagAmmoRemRight = newRightMag;
       ConsumeAmmo(Mode, delta);
       MagAmmoRemaining = MagAmmoRemLeft + MagAmmoRemRight;
    }
}
simulated function int GetMagazineAmmoLeft(){
    if(Role < ROLE_Authority)
       return MagAmmoRemLeftClient;
    else
       return MagAmmoRemLeft;
}
simulated function int GetMagazineAmmoRight(){
    if(Role < ROLE_Authority)
       return MagAmmoRemRightClient;
    else
       return MagAmmoRemRight;
}
simulated function bool AllowReload(){
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);
    if(FireMode[0].IsFiring() ||
       bIsReloading || (GetMagazineAmmoLeft() >= GetSingleMagCapacity() && GetMagazineAmmoRight() >= GetSingleMagCapacity()) ||
       ClientState == WS_BringUp ||
       AmmoAmount(0) <= GetMagazineAmmo())
       return false;
    return true;
}
simulated function WeaponTick(float dt){
    if(Role == Role_AUTHORITY)
       MagAmmoRemaining = MagAmmoRemLeft + MagAmmoRemRight;
    else
       MagAmmoRemainingClient = MagAmmoRemLeftClient + MagAmmoRemRightClient;
    super.WeaponTick(dt);
}
// Some functions reloaded to force update of magazine size on client's side
function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned){
    super.GiveAmmo(m, WP, bJustSpawned);
    ClientSetDualMagSize(MagAmmoRemLeft, MagAmmoRemRight);
}

defaultproperties
{
     SingleClass=Class'NicePack.NiceSingle'
     altFlashBoneName="Tip_Left"
     altTPAnim="DualiesAttackLeft"
     altWeaponAttach="Bone_weapon2"
     leftEjectStr="LEFT_EJECT"
     rightEjectStr="RIGHT_EJECT"
     leftInsertStr="LEFT_INSERT"
     rightInsertStr="RIGHT_INSERT"
     leftEject=0.130000
     rightEject=0.102000
     leftInsert=0.444000
     rightInsert=0.787000
     reloadChargeEndFrame=-1.000000
     reloadMagStartFrame=-1.000000
     reloadChargeStartFrame=-1.000000
     MagazineBone=
     bHasChargePhase=False
     FirstPersonFlashlightOffset=(X=-15.000000,Z=5.000000)
     MagCapacity=30
     ReloadRate=3.500000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     FlashBoneName="Tip_Right"
     WeaponReloadAnim="Reload_Dual9mm"
     Weight=4.000000
     bDualWeapon=True
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=70.000000
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Dual_9mm'
     ZoomInRotation=(Pitch=0,Roll=0)
     ZoomedDisplayFOV=65.000000
     FireModeClass(0)=Class'NicePack.NiceDualiesFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     AIRating=0.440000
     CurrentRating=0.440000
     bShowChargingBar=True
     Description="A pair of custom 9mm pistols. What they lack in stopping power, they compensate for with a quick refire."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=70.000000
     Priority=65
     InventoryGroup=2
     GroupOffset=2
     PickupClass=Class'NicePack.NiceDualiesPickup'
     PlayerViewOffset=(X=20.000000,Z=-7.000000)
     BobDamping=7.000000
     AttachmentClass=Class'NicePack.NiceDualiesAttachment'
     IconCoords=(X1=229,Y1=258,X2=296,Y2=307)
     ItemName="!!!Dual something"
     DrawScale=0.900000
     TransientSoundVolume=1.000000
}
