class NiceSingle extends NiceWeapon;
var bool bIsDual;
var int otherMagazine;
var class<NiceDualies> DualClass;
replication{
    reliable if(Role < ROLE_Authority)
       ServerSwitchToOtherSingle, ServerSwitchToDual;
    reliable if(Role == ROLE_Authority)
       bIsDual, otherMagazine;
}
function bool HandlePickupQuery(Pickup Item){
    local float AddWeight;
    if(Item.InventoryType == class){
       AddWeight = Weight;
       if(DualClass != none)
           AddWeight = dualClass.default.Weight - AddWeight;
       if(bIsDual || KFHumanPawn(Owner) != none && !KFHumanPawn(Owner).CanCarry(AddWeight)){
           PlayerController(Instigator.Controller).ReceiveLocalizedMessage(Class'KFMainMessages', 2);
           return true;
       }
       return false;
    }
    return super.HandlePickupQuery(Item);
}
simulated function bool AltFireCanForceInterruptReload(){
    return true;
}
simulated function Fire(float F){
    if(!bIsReloading && GetMagazineAmmo() <= 0 && otherMagazine > 0)
       ServerSwitchToOtherSingle();
    else
       super.Fire(F);
}
simulated function AltFire(float F){
    if(bIsDual && NicePlayerController(Instigator.Controller) != none)
       ClientForceInterruptReload(CANCEL_PASSIVESWITCH);
    if(!bIsReloading && bIsDual)
       ServerSwitchToDual();
    else
       super.AltFire(F);
}
function ServerSwitchToOtherSingle(){
    local int swap;
    local NiceHumanPawn nicePawn;
    nicePawn = NiceHumanPawn(Instigator);
    if(!bIsDual || nicePawn == none || nicePawn.Health <= 0)
       return;
    Ammo[0].AmmoAmount += otherMagazine - MagAmmoRemaining;
    swap = MagAmmoRemaining;
    MagAmmoRemaining = otherMagazine;
    otherMagazine = swap;
    ClientSetMagSize(MagAmmoRemaining, bRoundInChamber);
    //nicePawn.ClientChangeWeapon(self);
}
function ServerSwitchToDual(){
    local int m;
    local int origAmmo;
    local NiceHumanPawn nicePawn;
    local NiceDualies dualPistols;
    local NicePlainData.Data transferData;
    nicePawn = NiceHumanPawn(Instigator);
    if(!bIsDual || DualClass == none || nicePawn == none || nicePawn.Health <= 0)
       return;
    nicePawn.CurrentWeight -= Weight;
    Weight = 0;
    origAmmo = AmmoAmount(0);
    for(m = 0; m < NUM_FIRE_MODES;m ++)
       if(FireMode[m].bIsFiring)
           StopFire(m);
    DetachFromPawn(nicePawn);
    dualPistols = nicePawn.Spawn(DualClass);
    if(dualPistols != none){
       dualPistols.DemoReplacement = class;
       transferData = GetNiceData();
       dualPistols.GiveTo(nicePawn);
       dualPistols.SetNiceData(transferData, nicePawn);
       dualPistols.MagAmmoRemRight = MagAmmoRemaining;
       dualPistols.MagAmmoRemLeft = otherMagazine;
       dualPistols.MagAmmoRemaining = dualPistols.MagAmmoRemLeft + dualPistols.MagAmmoRemRight;
       dualPistols.SellValue = SellValue;
       dualPistols.Ammo[0].AmmoAmount = origAmmo + otherMagazine;
       dualPistols.ClientSetDualMagSize(dualPistols.MagAmmoRemLeft, dualPistols.MagAmmoRemRight);
       //nicePawn.ClientChangeWeapon(dualPistols);
       //nicePawn.ServerChangedWeapon(self, dualPistols);
    }
    Destroy();
}
function DropFrom(vector StartLocation){
    local int m;
    local int magKeep, magGive;
    local KFWeaponPickup weapPickup;
    local int weightBeforeThrow;
    local int AmmoThrown, OtherAmmo;
    local NiceHumanPawn nicePawn;
    nicePawn = NiceHumanPawn(Instigator);
    if(nicePawn == none)
       return;
    if(!bIsDual){
       super.DropFrom(StartLocation);
       return;
    }
    weightBeforeThrow = nicePawn.CurrentWeight;
    magKeep = otherMagazine;
    magGive = MagAmmoRemaining;
    OtherAmmo = AmmoAmount(0) - magKeep;
    ClientWeaponThrown();
    for(m = 0; m < NUM_FIRE_MODES;m ++)
       if(FireMode[m].bIsFiring)
           StopFire(m);
    if(nicePawn != none)
    DetachFromPawn(nicePawn);
    AmmoThrown = OtherAmmo / 2;
    OtherAmmo = OtherAmmo - AmmoThrown;
    Ammo[0].AmmoAmount = OtherAmmo + magKeep;
    MagAmmoRemaining = magKeep;
    ClientSetMagSize(MagAmmoRemaining, bRoundInChamber);
    weapPickup = KFWeaponPickup(nicePawn.Spawn(default.PickupClass,,, StartLocation));
    if(weapPickup != none){
       weapPickup.InitDroppedPickupFor(self);
       weapPickup.Velocity = Velocity;
       weapPickup.AmmoAmount[0] = AmmoThrown + magGive;
       weapPickup.SellValue = SellValue * 0.5;
       SellValue *= 0.5;
       weapPickup.MagAmmoRemaining = magGive;
       if(nicePawn.Health > 0)
           weapPickup.bThrown = true;
       nicePawn.ClientChangeWeapon(self);
    }
    RemoveDual(weightBeforeThrow);
}
function RemoveDual(int pawnWeight){
    local NiceHumanPawn nicePawn;
    nicePawn = NiceHumanPawn(Instigator);
    if(!bIsDual || nicePawn == none)
       return;
    bIsDual = false;
    DemoReplacement = none;
    nicePawn.CurrentWeight = pawnWeight - (Weight - default.Weight);
    Weight = default.Weight;
    otherMagazine = 0;
}
//SellValue
function GiveTo(Pawn other, optional Pickup Pickup){
    local int m;
    local int initAmmo, initMag;
    local bool bDestroy;
    local NiceSingle nicePistol;
    local NiceDualies niceDual;
    if(other != none){
       nicePistol = NiceSingle(other.FindInventoryType(class));
       niceDual = NiceDualies(other.FindInventoryType(DualClass));
    }
    bDestroy = false;
    if(nicePistol == none || (niceDual != none && niceDual.bSwitching))
       super.GiveTo(other, Pickup);
    else if((nicePistol != none && nicePistol.bIsDual) || niceDual != none)
       bDestroy = true;
    else{
       nicePistol.UpdateMagCapacity(other.PlayerReplicationInfo);
       initAmmo = nicePistol.FireMode[0].AmmoClass.default.InitialAmount;
       initMag = nicePistol.MagCapacity;
       initMag = Min(initMag, initAmmo);
       initAmmo -= initMag;
       if(nicePistol.Ammo[0] != none){
           nicePistol.Ammo[0].AmmoAmount += initAmmo;
           nicePistol.Ammo[0].AmmoAmount = Min(nicePistol.Ammo[0].AmmoAmount, nicePistol.Ammo[0].MaxAmmo);
       }
       nicePistol.bIsDual = true;
       nicePistol.otherMagazine = initMag;
       nicePistol.SellValue = 2 * min(SellValue, nicePistol.SellValue);
       nicePistol.ServerSwitchToDual();
       bDestroy = true;
    }
    if(bDestroy){
       for(m = 0; m < NUM_FIRE_MODES;m ++)
           Ammo[m] = none;
       Destroy();
    }
}

defaultproperties
{
     DualClass=Class'NicePack.NiceDualies'
     bHasChargePhase=False
     FirstPersonFlashlightOffset=(X=-20.000000,Y=-22.000000,Z=8.000000)
     MagCapacity=15
     ReloadRate=2.000000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_Single9mm"
     ModeSwitchAnim="LightOn"
     Weight=0.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=70.000000
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_9mm'
     ZoomedDisplayFOV=65.000000
     FireModeClass(0)=Class'NicePack.NiceSingleFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     AIRating=0.250000
     CurrentRating=0.250000
     bShowChargingBar=True
     Description="A 9mm Pistol"
     DisplayFOV=70.000000
     Priority=60
     InventoryGroup=2
     GroupOffset=1
     PickupClass=Class'NicePack.NiceSinglePickup'
     PlayerViewOffset=(X=20.000000,Y=25.000000,Z=-10.000000)
     BobDamping=6.000000
     AttachmentClass=Class'NicePack.NiceSingleAttachment'
     IconCoords=(X1=434,Y1=253,X2=506,Y2=292)
     ItemName="Just a single pistol"
}
