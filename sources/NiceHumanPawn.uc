class NiceHumanPawn extends ScrnHumanPawn
    dependson(NiceWeapon);
var bool    bReactiveArmorUsed;
var float   maniacTimeout;
var float   stationaryTime;
var float   forcedZedTimeCountDown;
var bool    bGotFreeJacket;
var float   lastHMGShieldUpdateTime;
var int     hmgShieldLevel;
var ScrnHUD scrnHUDInstance;
// Position value means it's a count down for how much invincibility is left,
// Negative value is for counting down a cool-down after a failed head-shot with a melee weapon
var float   invincibilityTimer;
var int     safeMeleeMisses;
var float   ffScale;
var float   medicAdrenaliteTime;
var float   regenTime;
var bool    bZedTimeInvincible;
enum ECalibrationState{
    //  Calibration isn't available due to lack of ability
    CALSTATE_NOABILITY,
    CALSTATE_ACTIVE,
    CALSTATE_FINISHED
};
var float gunslingerTimer;
var ECalibrationState currentCalibrationState;
var int calibrationScore;
var int calibrationHits, calibrationTotalShots;
var float calibrationRemainingTime;
var array<NiceMonster> calibrateUsedZeds;
var int                         nicePrevPerkLevel;
var class<NiceVeterancyTypes>   nicePrevPerkClass;
struct WeaponTimePair{
    var NiceWeapon  niceWeap;
    var float       reloadTime;
};
var array<WeaponTimePair> holsteredReloadList;
var float holsteredReloadCountDown;
var const float defaultInvincibilityDuration;
struct InvincExtentions{
    var NiceMonster zed;
    var bool        hadMiss;
    var int         extentionsDone;
};
var array<InvincExtentions> zedInvExtList;
var int headshotStack;
var float remainingFCArmor;
var float remainingFCTime;
var float brutalCranageTimer;
replication{
    reliable if(Role == ROLE_Authority)
       headshotStack, hmgShieldLevel, forcedZedTimeCountDown, maniacTimeout, invincibilityTimer, safeMeleeMisses, ffScale,
       currentCalibrationState, calibrationScore, gunslingerTimer;
    reliable if(Role == ROLE_Authority)
       ClientChangeWeapon;
    reliable if(Role < ROLE_AUTHORITY)
       ServerUpdateCalibration, ServerCooldownAbility;
}
simulated function bool IsZedExtentionsRecorded(NiceMonster niceZed){
    local int i;
    for(i = 0;i < zedInvExtList.length;i ++)
       if(zedInvExtList[i].zed == niceZed)
           return true;
    return false;
}
function ReplaceRequiredEquipment(){
    Super.ReplaceRequiredEquipment();
    RequiredEquipment[0] = String(class'NicePack.NiceKnife');
    RequiredEquipment[1] = String(class'NicePack.Nice9mmPlus');
    RequiredEquipment[2] = String(class'ScrnBalanceSrv.ScrnFrag');
    RequiredEquipment[3] = String(class'ScrnBalanceSrv.ScrnSyringe');
    RequiredEquipment[4] = String(class'KFMod.Welder');
}
simulated function int CalculateCalibrationScore(){
    local float accuracy;
    accuracy = (float(calibrationHits)) / (float(calibrationTotalShots));
    if(calibrationTotalShots <= 0)
        return 3;
    //  Very low accuracy (<60%) or not enough shots (<2) - 1 star
    if(accuracy < 0.6)
       return 1;
    //  Here we definitely have at least 60% accuracy and 2 shots.
    //  Low accuracy (<80%) or not enough shots (<5) - 2 stars.
    if(accuracy < 0.8)
       return 2;
    //  Here we definitely have at least 80% accuracy and 5 shots.
    //  If amount of shots is below 7 - it's 3 stars at most.
    if(calibrationTotalShots < 7)
       return 3;
    //  Here we definitely have at least 80% accuracy and 7 shots.
    //  Unless accuracy is 100% and player made 10 shots - it's 4 stars.
    if(accuracy < 1.0 || calibrationTotalShots < 10)
       return 4;
    //  Here we definitely have 100% accuracy and at least 10 shots.
    //  5 stars.
    return 5;
}
function ServerUpdateCalibration(bool isHit, NiceMonster targetMonster){
    local int i;
    if(isHit){
       for(i = 0;i < calibrateUsedZeds.length;i ++)
           if(calibrateUsedZeds[i] == targetMonster)
               return;
       calibrationHits += 1;
    }
    calibrationTotalShots += 1;
    calibrateUsedZeds[calibrateUsedZeds.length] = targetMonster;
}
simulated function int GetZedExtentionsIndex(NiceMonster niceZed){
    local int i;
    local int foundIndex;
    local InvincExtentions newRecord;
    local array<InvincExtentions> newList;
    if(niceZed == none || niceZed.health <= 0)
       return -1;
    foundIndex = -1;
    for(i = 0;i < zedInvExtList.Length;i ++)
       if(zedInvExtList[i].zed != none && zedInvExtList[i].zed.health > 0){
           newList[newList.Length] = zedInvExtList[i];
           if(zedInvExtList[i].zed == niceZed)
               foundIndex = newList.Length - 1;
       }
    if(foundIndex < 0){
       foundIndex = newList.Length;
       newRecord.zed = niceZed;
       newList[foundIndex] = newRecord;
    }
    zedInvExtList = newList;
    return foundIndex;
}
simulated function bool TryExtendingInv(NiceMonster niceZed,
                                       bool meleeAttempt, bool wasHeadshot){
    local class<NiceVeterancyTypes> niceVet;
    local int                       zedExtIndex;
    local bool                      success;
    if(niceZed == none) return false;
    niceVet = class'NiceVeterancyTypes'.static.
       GetVeterancy(PlayerReplicationInfo);
    if(niceVet == none)
       return false;
    zedExtIndex = GetZedExtentionsIndex(niceZed);
    if(zedExtIndex >= 0 && !wasHeadshot)
       zedInvExtList[zedExtIndex].hadMiss = true;
    if(zedExtIndex >= 0){
       success = zedInvExtList[zedExtIndex].extentionsDone
                   <= niceVet.static.GetInvincibilityExtentions(KFPRI);
       success = success && !zedInvExtList[zedExtIndex].hadMiss;
    }
    else
       success = wasHeadshot;
    if(invincibilityTimer < 0)
       success = false;
    if(success){
       if(zedExtIndex >= 0)
           zedInvExtList[zedExtIndex].extentionsDone ++;
       invincibilityTimer  = niceVet.static.GetInvincibilityDuration(KFPRI);
       safeMeleeMisses     = niceVet.static.GetInvincibilitySafeMisses(KFPRI);
       return true;
    }
    if(wasHeadshot)
       return false;
    if(meleeAttempt){
       safeMeleeMisses --;
       if(safeMeleeMisses < 0)
           ResetMeleeInvincibility();
       return false;
    }
    if(niceVet.static.hasSkill( NicePlayerController(controller),
                               class'NiceSkillZerkGunzerker')){
       invincibilityTimer = class'NiceSkillZerkGunzerker'.default.cooldown;
       return false;
    }
}
simulated function int FindInHolsteredList(NiceWeapon niceWeap){
    local int i;
    for(i = 0;i < holsteredReloadList.Length;i ++)
       if(holsteredReloadList[i].niceWeap == niceWeap)
           return i;
    return -1;
}
simulated function ProgressHeadshotStack(bool bIncrease, int minStack, int maxStack, int maxSoftLimit){
    if(bIncrease && headshotStack < maxStack)
       headshotStack ++;
    if(!bIncrease && headshotStack > minStack){
       if(headshotStack > maxSoftLimit)
           headshotStack = maxSoftLimit;
       else
           headshotStack --;
    }
    headshotStack = Max(minStack, headshotStack);
    headshotStack = Min(maxStack, headshotStack);
}
simulated function int GetHeadshotStack(int minStack, int maxStack){
    headshotStack = Max(minStack, headshotStack);
    headshotStack = Min(maxStack, headshotStack);
    return headshotStack;
}
simulated function int GetTimeDilationStage(float dilation){
    if(dilation <= 0.1)
       return 0;
    else if(dilation < 1.1)
       return 1;
    else
       return 2;
}
simulated function ResetMeleeInvincibility(){
    invincibilityTimer = 0.0;
    safeMeleeMisses = 0;
    ApplyWeaponStats(weapon);
}
function ServerCooldownAbility(string abilityID){
    local int                   index;
    local NicePlayerController  nicePlayer;
    nicePlayer = NicePlayerController(controller);
    if(nicePlayer == none || nicePlayer.abilityManager == none)
       return;
    index = nicePlayer.abilityManager.GetAbilityIndex(abilityID);
    if(index >= 0)
       nicePlayer.abilityManager.SetAbilityState(index, ASTATE_COOLDOWN);
}
simulated function Tick(float deltaTime){
    local int                   index;
    local Inventory             Item;
    local NiceWeapon            niceWeap;
    local WeaponTimePair        newPair;
    local array<WeaponTimePair> newWTPList;
    local NicePack              niceMutator;
    local NicePlayerController  nicePlayer;
    nicePlayer = NicePlayerController(Controller);
    if(Role == Role_AUTHORITY){
        //  Brutal carnage
        if (brutalCranageTimer > 0)
        {
            brutalCranageTimer -= deltaTime;
            if (brutalCranageTimer <= 0)
            {
                if(nicePlayer != none && nicePlayer.abilityManager != none)
                {
                    nicePlayer.abilityManager.SetAbilityState(1, ASTATE_COOLDOWN);
                }
            }
        }
        //  Full counter remainingFCTime
        if (remainingFCTime > 0)
        {
            remainingFCTime -= deltaTime;
            if (remainingFCTime <= 0)
            {
                remainingFCArmor = 0;
                if(nicePlayer != none && nicePlayer.abilityManager != none)
                {
                    nicePlayer.abilityManager.SetAbilityState(0, ASTATE_COOLDOWN);
                }
            }
        }
        //  Calibration
        if(     currentCalibrationState == CALSTATE_ACTIVE
            &&  calibrationRemainingTime > 0.0){
            calibrationScore = CalculateCalibrationScore();
            calibrationRemainingTime -= deltaTime;
            if(calibrationRemainingTime <= 0 || calibrationScore == 5){
                currentCalibrationState = CALSTATE_FINISHED;
                calibrateUsedZeds.length = 0;
                if(nicePlayer != none && nicePlayer.abilityManager != none)
                    nicePlayer.abilityManager.SetAbilityState(0, ASTATE_COOLDOWN);
            }
        }
        //  Gunslinger
        if(     gunslingerTimer > 0
            &&  nicePlayer != none && nicePlayer.abilityManager != none){
            gunslingerTimer -= deltaTime;
            if(gunslingerTimer <= 0)
                nicePlayer.abilityManager.SetAbilityState(1, ASTATE_COOLDOWN);
        }
       //  Regen
       if(class'NiceVeterancyTypes'.static.hasSkill(NicePlayerController(Controller), class'NiceSkillMedicRegeneration')){
           if(health < healthMax)
               regenTime += deltaTime;
           while(regenTime > class'NiceSkillMedicRegeneration'.default.regenFrequency){
               if(health < healthMax)
                   health += 1;
               else
                   regenTime = 0.0;
               regenTime -= class'NiceSkillMedicRegeneration'.default.regenFrequency;
           }
       }
       // Update adrenaline
       medicAdrenaliteTime -= deltaTime;
       // This needs updating
       if(Level.Game != none)
           ffScale = TeamGame(Level.Game).FriendlyFireScale;
       else
           ffScale = 0;
       // Manage melee-invincibility
       if(invincibilityTimer < 0){
           invincibilityTimer += deltaTime;
           if(invincibilityTimer > 0)
               ResetMeleeInvincibility();
       }
       if(invincibilityTimer > 0){
           invincibilityTimer -= deltaTime;
           if(invincibilityTimer < 0)
               ResetMeleeInvincibility();
       }
       // Manage demo's 'Maniac' skill
       maniacTimeout -= deltaTime;
    }
    super.Tick(deltaTime);
    // Restore icons
    if(Role < Role_AUTHORITY){
       if(scrnHUDInstance == none && nicePlayer != none)
           scrnHUDInstance = ScrnHUD(nicePlayer.myHUD);
       if(scrnHUDInstance != none && NiceWeapon(weapon) == none){
           scrnHUDInstance.ClipsIcon.WidgetTexture = Texture'KillingFloorHUD.HUD.Hud_Ammo_Clip';
           scrnHUDInstance.BulletsInClipIcon.WidgetTexture = Texture'KillingFloorHUD.HUD.Hud_Bullets';
           scrnHUDInstance.SecondaryClipsIcon.WidgetTexture = Texture'KillingFloor2HUD.HUD.Hud_M79';
       }
    }
    // Update stationary time
    if(bIsCrouched && VSize(Velocity) <= 0.0)
       stationaryTime += deltaTime;
    else
       stationaryTime = 0.0;
    // Update zed countdown time
    if(forcedZedTimeCountDown > 0)
       forcedZedTimeCountDown -= deltaTime;
    else
       forcedZedTimeCountDown = 0.0;
    niceMutator = class'NicePack'.static.Myself(Level);
    if(niceMutator != none)
       niceMutator.ClearWeapProgress();
    if(!class'NiceVeterancyTypes'.static.hasSkill(NicePlayerController(Controller), class'NiceSkillEnforcerMultitasker'))
       return;
    if(Role < ROLE_Authority  && nicePlayer != none && nicePlayer.bFlagDisplayWeaponProgress){
       // Update weapon progress for this skill
       if(niceMutator == none)
           return;
       for(Item = Inventory; Item != none; Item = Item.Inventory){
           niceWeap = NiceWeapon(Item);
           if(niceWeap != none && niceWeap != weapon && !niceWeap.IsMagazineFull()){
               niceMutator.AddWeapProgress(niceWeap.class, niceWeap.holsteredCompletition,
                   true, niceWeap.GetMagazineAmmo());
           }
       }
       return;
    }
    // Auto-reload holstered weapons
    holsteredReloadCountDown -= deltaTime;
    if(holsteredReloadCountDown <= 0.0){
       // Progress current list
       for(Item = Inventory; Item != none; Item = Item.Inventory){
           niceWeap = NiceWeapon(Item);
           if(niceWeap == none || niceWeap == weapon || niceWeap.IsMagazineFull())
               continue;
           index = FindInHolsteredList(niceWeap);
           if(index >= 0){
               // Detract time
               holsteredReloadList[index].reloadTime -=
                   0.25 / class'NiceSkillEnforcerMultitasker'.default.reloadSlowDown;
               // Add ammo if time is up
               if(holsteredReloadList[index].reloadTime < 0.0)
                   niceWeap.ClientReloadAmmo();
           }
       }
       // Make new list
       for(Item = Inventory; Item != none; Item = Item.Inventory){
           niceWeap = NiceWeapon(Item);
           if(niceWeap == none)
               continue;
           // Reset holstered completion timer
           if(niceWeap == weapon || niceWeap.IsMagazineFull()){
               niceWeap.holsteredCompletition = 0.0;
               continue;
           }
           // Update list
           index = FindInHolsteredList(niceWeap);
           if(index < 0 || holsteredReloadList[index].reloadTime <= 0.0){
               newPair.niceWeap    = niceWeap;
               newPair.reloadTime  = niceWeap.TimeUntillReload();
               newWTPList[newWTPList.Length] = newPair;
           }
           else
               newWTPList[newWTPList.Length] = holsteredReloadList[index];
           // Update holstered completion timer
           niceWeap.holsteredCompletition = newWTPList[newWTPList.Length - 1].reloadTime / niceWeap.TimeUntillReload();
           niceWeap.holsteredCompletition = 1.0 - niceWeap.holsteredCompletition;
       }
       holsteredReloadList = newWTPList;
       holsteredReloadCountDown = 0.25;
    }
}
function ServerBuyWeapon(class<Weapon> WClass, float ItemWeight){
    local Inventory I;
    local NiceSingle nicePistol;
    local class<NiceWeaponPickup> WP;
    local float Price, Weight, SellValue;
    nicePistol = NiceSingle(FindInventoryType(WClass));
    if(nicePistol != none && nicePistol.class != WClass)
       nicePistol = none;
    if((nicePistol != none && nicePistol.bIsDual))
       return;
    if(nicePistol == none)
       super.ServerBuyWeapon(WClass, ItemWeight);
    else{
       if(!CanBuyNow() || class<NiceWeapon>(WClass) == none)
           return;
       WP = class<NiceWeaponPickup>(WClass.Default.PickupClass);
       if(WP == none)
           return;
       if(PerkLink == none)
       PerkLink = FindStats();
       if(PerkLink != none && !PerkLink.CanBuyPickup(WP))
           return;
       Price = WP.Default.Cost;
       if(KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none){
           Price *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), WP);
           if(class'ScrnBalance'.default.Mut.bBuyPerkedWeaponsOnly 
                   && WP.default.CorrespondingPerkIndex != 7 
                   && WP.default.CorrespondingPerkIndex != KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.default.PerkIndex )
               return;    
       }
       SellValue = Price * 0.75;
       Price = int(Price);
       Weight = Class<KFWeapon>(WClass).default.Weight;
       if(nicePistol.default.DualClass != none)
           Weight = nicePistol.default.DualClass.default.Weight - Weight;
       if((Weight > 0 && !CanCarry(Weight)) || PlayerReplicationInfo.Score < Price)
           return;
       I = Spawn(WClass, self);
       if(I != none){
           if(KFGameType(Level.Game) != none)
               KFGameType(Level.Game).WeaponSpawned(I);
           KFWeapon(I).UpdateMagCapacity(PlayerReplicationInfo);
           KFWeapon(I).SellValue = SellValue;
           I.GiveTo(self);
           PlayerReplicationInfo.Score -= Price;
           UsedStartCash(Price);
       }
       else
           ClientMessage("Error: Weapon failed to spawn.");
       SetTraderUpdate();
    }
}
function ServerSellWeapon(class<Weapon> WClass){
    local NiceSingle nicePistol;
    local NiceDualies niceDual;
    nicePistol = NiceSingle(FindInventoryType(WClass));
    niceDual = NiceDualies(FindInventoryType(WClass));
    if(niceDual != none && niceDual.class != WClass)
       niceDual = none;
    if(niceDual == none){
       // If this a single pistol that is part of dual pistol weapon - double the cost, because it will be cut back by parent 'ServerSellWeapon'
       if(nicePistol != none && nicePistol.bIsDual)
           nicePistol.SellValue *= 2;
       super.ServerSellWeapon(WClass);
    }
    else{
       nicePistol = niceDual.ServerSwitchToSingle();
       if(nicePistol == none)
           return;
       else{
           nicePistol.RemoveDual(CurrentWeight);
           nicePistol.SellValue *= 0.5;
           PlayerReplicationInfo.Score += nicePistol.SellValue;
           SetTraderUpdate();
       }
    }
}
// NICETODO: do we even need this one?
simulated function ClientChangeWeapon(NiceWeapon newWeap){
    weapon = newWeap;
    PendingWeapon = newWeap;
    if(newWeap != none){
       newWeap.ClientState = WS_Hidden;
       ChangedWeapon();
    }
    PendingWeapon = none;
}

// Validate that client is not hacking.
function bool CanBuyNow(){
    local NicePlayerController niceController;
    niceController = NicePlayerController(Controller);
    if(niceController == none)
       return false;
    if(NiceGameType(Level.Game) != none && NiceGameType(Level.Game).NicePackMutator != none
       && NiceGameType(Level.Game).NicePackMutator.bIsPreGame)
       return true;
    if(NiceTSCGame(Level.Game) != none && NiceTSCGame(Level.Game).NicePackMutator != none
       && NiceTSCGame(Level.Game).NicePackMutator.bIsPreGame)
       return true;
    return Super.CanBuyNow();
}
// Overridden to not modify dual pistols' weapon group
function bool AddInventory(inventory NewItem){
    local KFWeapon weap;
    local bool GroupChanged;
    weap = KFWeapon(NewItem);
    if(weap != none){
       if(Dualies(weap) != none){
           if((DualDeagle(weap) != none || Dual44Magnum(weap) != none || DualMK23Pistol(weap) != none)
                 && weap.InventoryGroup != 4 ) { 
               if(KFPRI != none &&
                   ClassIsChildOf(KFPRI.ClientVeteranSkill, class'ScrnBalanceSrv.ScrnVetGunslinger'))
                   weap.InventoryGroup = 3;
               else 
                   weap.InventoryGroup = 2;
               GroupChanged = true;
           }
       }
       else if(weap.class == class'Single'){
           weap.bKFNeverThrow = false;
       }
           weap.bIsTier3Weapon = true;
    }
    if(GroupChanged) 
       ClientSetInventoryGroup(NewItem.class, NewItem.InventoryGroup);
    if(super(SRHumanPawn).AddInventory(NewItem)){
       if(weap != none && weap.bTorchEnabled)
           AddToFlashlightArray(weap.class);
       return true;
    }
    return false;
}
simulated function CookGrenade(){
    local ScrnFrag      aFrag;
    local NiceWeapon    niceWeap;
    niceWeap = NiceWeapon(Weapon);
    if(niceWeap != none)
       niceWeap.ClientForceInterruptReload(CANCEL_COOKEDNADE);
    if(secondaryItem != none)
       return;
    if(scrnPerk == none || !scrnPerk.static.CanCookNade(KFPRI, Weapon))
       return;
    aFrag = ScrnFrag(FindPlayerGrenade());
    if(aFrag == none)
       return;
    if(     !aFrag.HasAmmo() || bThrowingNade
       ||  aFrag.bCooking || aFrag.bThrowingCooked
       ||  level.timeSeconds - aFrag.cookExplodeTimer <= 0.1)
       return;
    if(     niceWeap == none
       ||  (niceWeap.bIsReloading && !niceWeap.InterruptReload()))
       return;
    aFrag.CookNade();
    niceWeap.ClientGrenadeState = GN_TempDown;
    niceWeap.PutDown();
}
simulated function ThrowGrenade(){
    local NiceWeapon niceWeap;
    niceWeap = NiceWeapon(Weapon);
    if(niceWeap != none)
       niceWeap.ClientForceInterruptReload(CANCEL_NADE);
    if(bThrowingNade || SecondaryItem != none)
       return;
    if(     niceWeap == none
       ||  (niceWeap.bIsReloading && !niceWeap.InterruptReload()))
       return;
    if(playerGrenade == none)
       playerGrenade = FindPlayerGrenade();
    if(playerGrenade != none && playerGrenade.HasAmmo()){
       niceWeap.clientGrenadeState = GN_TempDown;
       niceWeap.PutDown();
    }
}
simulated function HandleNadeThrowAnim()
{
    if(NiceM14EBRBattleRifle(Weapon) != none || NiceMaulerRifle(Weapon) != none)
       SetAnimAction('Frag_M14');
    else if(NiceWinchester(Weapon) != none)
       SetAnimAction('Frag_Winchester');
    else if(Crossbow(Weapon) != none)
       SetAnimAction('Frag_Crossbow');
    else if(NiceM99SniperRifle(Weapon) != none)
       SetAnimAction('Frag_M4203');
    else if(NiceAK47AssaultRifle(Weapon) != none)
       SetAnimAction('Frag_AK47');
    else if(NiceBullpup(Weapon) != none || NiceNailGun(Weapon) != none)
       SetAnimAction('Frag_Bullpup');
    else if(NiceBoomStick(Weapon) != none)
       SetAnimAction('Frag_HuntingShotgun');
    else if(NiceShotgun(Weapon) != none || NiceBenelliShotgun(Weapon) != none || NiceTrenchgun(Weapon) != none)
       SetAnimAction('Frag_Shotgun');
    else if(NiceSCARMK17AssaultRifle(Weapon) != none)
       SetAnimAction('Frag_SCAR');
    else if(NiceAA12AutoShotgun(Weapon) != none || NiceFNFAL_ACOG_AssaultRifle(Weapon) != none || NiceSPAutoShotgun(Weapon) != none)
       SetAnimAction('Frag_AA12');
    else if(NiceM4AssaultRifle(Weapon) != none || NiceMKb42AssaultRifle(Weapon) != none)
       SetAnimAction('Frag_M4');
    else if(NiceThompsonDrumSMG(Weapon) != none)
       SetAnimAction('Frag_IJC_spThompson_Drum');
    Super.HandleNadeThrowAnim();
}
// Remove blur for sharpshooter with a right skill
function bool ShouldBlur(){
    local class<NiceVeterancyTypes> niceVet;
    niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(PlayerReplicationInfo);
    if(niceVet != none && niceVet.static.hasSkill(NicePlayerController(Controller), class'NiceSkillEnforcerUnshakable'))
       return false;
    return true;
}
simulated function AddBlur(Float BlurDuration, float Intensity){
    if(shouldBlur())
       Super.AddBlur(BlurDuration, Intensity);
}
simulated exec function ToggleFlashlight(){
    local NiceWeapon niceWeap;
    niceWeap = NiceWeapon(Weapon);
    if(niceWeap != none && niceWeap.bUseFlashlightToToggle)
       niceWeap.SecondDoToggle();
}
simulated function ApplyWeaponStats(Weapon NewWeapon){
    local KFWeapon Weap;
    local float weaponWeight;
    local class<NiceVeterancyTypes> niceVet;
    BaseMeleeIncrease = default.BaseMeleeIncrease;
    InventorySpeedModifier = 0;
    Weap = KFWeapon(NewWeapon);
    SetAmmoStatus();
    if(KFPRI != none && Weap != none){
       Weap.bIsTier3Weapon = Weap.default.bIsTier3Weapon;
       if(Weap.bSpeedMeUp){
           if(KFPRI.ClientVeteranSkill != none)
               BaseMeleeIncrease += KFPRI.ClientVeteranSkill.Static.GetMeleeMovementSpeedModifier(KFPRI);
           InventorySpeedModifier = (default.GroundSpeed * BaseMeleeIncrease);
       }
       if ( ScrnPerk != none ) {
           InventorySpeedModifier +=
               default.GroundSpeed * ScrnPerk.static.GetWeaponMovementSpeedBonus(KFPRI, NewWeapon);
       }
       // Mod speed depending on current weapon's weight
       niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(PlayerReplicationInfo);
       if(niceVet != none)
           weaponWeight = niceVet.static.GetPerceivedWeight(KFPlayerReplicationInfo(PlayerReplicationInfo), Weap);
       else
           weaponWeight = Weap.weight;
       InventorySpeedModifier += default.GroundSpeed * (8 - weaponWeight) * 0.025;
       // ScrN Armor can slow down players (or even boost) -- PooSH
       InventorySpeedModifier -= default.GroundSpeed * GetCurrentVestClass().default.SpeedModifier;
    } 
}
simulated function ModifyVelocity(float DeltaTime, vector OldVelocity){
    local NicePack NicePackMutator;
    local NicePlayerController nicePlayer;
    local float MovementMod;
    local float WeightMod, HealthMod, TempMod;
    local float EncumbrancePercentage;
    local Inventory Inv;
    local KF_StoryInventoryItem StoryInv;
    local bool bAllowSlowDown;
    local float adrSpeedBonus;
    bAllowSlowDown = true;
    nicePlayer = NicePlayerController(Controller);
    if(class'NiceVeterancyTypes'.static.HasSkill(nicePlayer, class'NiceSkillEnforcerUnstoppable'))
       bAllowSlowDown = false;
    super(KFPawn).ModifyVelocity(DeltaTime, OldVelocity);
    if(Controller != none)
    {
       // Calculate encumbrance, but cap it to the maxcarryweight so when we use dev weapon cheats we don't move mega slow
       EncumbrancePercentage = (FMin(CurrentWeight, MaxCarryWeight) / default.MaxCarryWeight); //changed MaxCarryWeight to default.MaxCarryWeight
       // Calculate the weight modifier to speed
       WeightMod = (1.0 - (EncumbrancePercentage * WeightSpeedModifier));
       // Calculate the health modifier to speed
       HealthMod = ((Health/HealthMax) * HealthSpeedModifier) + (1.0 - HealthSpeedModifier);

       // Apply all the modifiers
       GroundSpeed = default.GroundSpeed;
       MovementMod = 1.0;
       if(bAllowSlowDown || HealthMod > 1.0)
           MovementMod *= HealthMod;
       if(bAllowSlowDown || WeightMod > 1.0)
           MovementMod *= WeightMod;

       if(KFPRI != none && KFPRI.ClientVeteranSkill != none){
           MovementMod *= KFPRI.ClientVeteranSkill.static.GetMovementSpeedModifier(KFPRI, KFGameReplicationInfo(Level.GRI));
       }

       for(Inv = Inventory;Inv != none;Inv = Inv.Inventory){
           TempMod = Inv.GetMovementModifierFor(self);
           if(bAllowSlowDown || TempMod > 1.0)
               MovementMod *= TempMod;

           StoryInv = KF_StoryInventoryItem(Inv);
           if(StoryInv != none && StoryInv.bUseForcedGroundSpeed)
           {
               GroundSpeed = StoryInv.ForcedGroundSpeed;
               return;
           }
       }    
       if(bTraderSpeedBoost && !KFGameReplicationInfo(Level.GRI).bWaveInProgress)
           MovementMod *= TraderSpeedBoost;
       if(Health < HealthMax && medicAdrenaliteTime > 0){
           // Calulate boos from adrenaline
           adrSpeedBonus = Health * (1 - class'NiceSkillCommandoAdrenalineShot'.default.speedBoost) +
               (100 * class'NiceSkillCommandoAdrenalineShot'.default.speedBoost - class'NiceSkillCommandoAdrenalineShot'.default.minHealth);
           adrSpeedBonus /= (100 - class'NiceSkillCommandoAdrenalineShot'.default.minHealth);
           adrSpeedBonus = FMin(adrSpeedBonus, class'NiceSkillCommandoAdrenalineShot'.default.speedBoost);
           adrSpeedBonus = FMax(adrSpeedBonus, 1.0);
           MovementMod *= adrSpeedBonus;
       }
       GroundSpeed = default.GroundSpeed * MovementMod;
       AccelRate   = default.AccelRate * MovementMod;
       if(bAllowSlowDown || InventorySpeedModifier > 0)
           GroundSpeed += InventorySpeedModifier;
       if(nicePlayer != none && nicePlayer.IsZedTimeActive() && class'NiceVeterancyTypes'.static.HasSkill(nicePlayer, class'NiceSkillZerkZEDAccelerate'))
           AccelRate *= 100;
    }
    NicePackMutator = class'NicePack'.static.Myself(Level);
    if(NicePackMutator != none && NicePackMutator.bIsPreGame && NicePackMutator.bInitialTrader && NicePackMutator.bStillDuringInitTrader)
       GroundSpeed = 1;
}
function getFreeJacket(){
    if(!bGotFreeJacket && ShieldStrength < LightVestClass.default.ShieldCapacity && class'NiceVeterancyTypes'.static.SomeoneHasSkill(NicePlayerController(Controller), class'NiceSkillSupportArmory')){
       if(SetVestClass(LightVestClass)){
           ShieldStrength = LightVestClass.default.ShieldCapacity;
           bGotFreeJacket = true;
       }
    }
}
simulated function TakeDamage(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex){
    local float FCArmorAbsorb;
    local int needArmor;
    local int healAmount;
    local float healPotency;
    local bool bOldArmorStops;
    local float adrResistance;
    local NicePlayerController nicePlayer;
    ApplyWeaponStats(Weapon);
    if(invincibilityTimer > 0)
       return;
    nicePlayer = NicePlayerController(Controller);
    if(bZedTimeInvincible){
       if(nicePlayer != none && nicePlayer.IsZedTimeActive())
           return;
       else
           bZedTimeInvincible = false;
    }
    // Adrenaline damage decrease
    if(medicAdrenaliteTime > 0){
       adrResistance = Health * (1 - class'NiceSkillCommandoAdrenalineShot'.default.resistBoost) +
               (100 * class'NiceSkillCommandoAdrenalineShot'.default.resistBoost - class'NiceSkillCommandoAdrenalineShot'.default.minHealth);
       adrResistance /= (100 - class'NiceSkillCommandoAdrenalineShot'.default.minHealth);
       adrResistance = FMin(adrResistance, class'NiceSkillCommandoAdrenalineShot'.default.resistBoost);
       adrResistance = FMax(adrResistance, 1.0);
       Damage *= adrResistance;
    }
    if(nicePlayer != none && nicePlayer.IsZedTimeActive()
       && class'NiceVeterancyTypes'.static.HasSkill(nicePlayer, class'NiceSkillZerkZEDUnbreakable'))
       return;
    lastHMGShieldUpdateTime = Level.TimeSeconds;
    if(damageType != none && class<NiceDamTypeDrug>(damageType) == none){
       bOldArmorStops = damageType.default.bArmorStops;
       if(class'NiceVeterancyTypes'.static.HasSkill(nicePlayer, class'NiceSkillEnforcerCoating'))
           damageType.default.bArmorStops = true;
    }
    lastExplosionDistance = 0.0;    // hack, but scrn fucks with usotherwise
    if (remainingFCArmor > 0 && remainingFCTime > 0)
    {
        FCArmorAbsorb = FMin(Damage, remainingFCArmor);
        Damage -= FCArmorAbsorb;
        remainingFCArmor -= FCArmorAbsorb;
        if(remainingFCArmor <= 0 && nicePlayer != none && nicePlayer.abilityManager != none)
        {
            nicePlayer.abilityManager.SetAbilityState(0, ASTATE_COOLDOWN);
        }
    }
    super.TakeDamage(Damage, InstigatedBy, hitLocation, Momentum, damageType, HitIndex);
    // Commando's zed time
    if( forcedZedTimeCountDown <= 0.0
       && health < class'NiceSkillCommandoCriticalFocus'.default.healthBoundary && KFGameType(Level.Game) != none
       && class'NiceVeterancyTypes'.static.HasSkill(nicePlayer, class'NiceSkillCommandoCriticalFocus') ){
       KFGameType(Level.Game).DramaticEvent(1.0);
       forcedZedTimeCountDown = class'NiceSkillCommandoCriticalFocus'.default.cooldown;
    }
    if(damageType != none)
       damageType.default.bArmorStops = bOldArmorStops;
    // Do heavy mg's armor healing
    if(class'NiceVeterancyTypes'.static.HasSkill(nicePlayer, class'NiceSkillHeavySafeguard') && health < HealthMax * 0.5 && ShieldStrength > 0){
       healAmount = HealthMax - health;
       healPotency = 1.0;
       if(health < HealthMax * 0.25)
           healPotency = 2.0;
       else if(health < HealthMax * 0.1)
           healPotency = 10.0;
       needArmor = float(healAmount) * healPotency * class'NiceSkillHeavySafeguard'.default.healingCost;
       ShieldStrength -= needArmor;
       if(ShieldStrength < 0)
           ShieldStrength = 0;
       health += HealAmount * 0.5;
       TakeHealing(self, HealAmount * 0.5, HealPotency);
    }
    if(ShieldStrength <= 0)
       getFreeJacket();
}
function int ShieldAbsorb(int damage){
    if(ShieldStrength > 0 && class'NiceVeterancyTypes'.static.HasSkill(NicePlayerController(Controller), class'NiceSkillHeavySafeguard'))
       return damage;
    return super.ShieldAbsorb(damage);
}
function Timer(){
    if(BurnDown > 0 && BurnInstigator != self && KFPawn(BurnInstigator) != none)
       LastBurnDamage *= 1.8;
    super(SRHumanPawn).Timer();
    // tick down health if it's greater than max
    if(Health > HealthMax){
       if(Health > 100)
           Health -= 5;
       if(Health < HealthMax)
           Health = HealthMax;
    }
    SetAmmoStatus();
    ApplyWeaponFlashlight(true);
}
simulated function Fire(optional float F){
    local bool bRecManualReload;
    local NiceSingle singleWeap;
    local ScrnPlayerController PC;
    singleWeap = NiceSingle(weapon);
    PC = ScrnPlayerController(Controller);
    if(PC != none && singleWeap != none && singleWeap.bIsDual && singleWeap.otherMagazine > 0){
       bRecManualReload = PC.bManualReload;
       PC.bManualReload = false;
       super.Fire(F);
       PC.bManualReload = bRecManualReload;
    }
    else
       super.Fire(F);
}
function  float AssessThreatTo(KFMonsterController  Monster, optional bool CheckDistance){
    return super(SRHumanPawn).AssessThreatTo(Monster, CheckDistance);
}
function VeterancyChanged(){
    local NicePlayerController nicePlayer;
    if(KFPRI == none)
       return;
    nicePlayer = NicePlayerController(Controller);
    nicePrevPerkLevel = KFPRI.ClientVeteranSkillLevel;
    nicePrevPerkClass = class<NiceVeterancyTypes>(KFPRI.ClientVeteranSkill);
    if(nicePlayer != none && nicePlayer.abilityManager != none)
       nicePlayer.abilityManager.ClearAbilities();
    if(nicePrevPerkClass != none && Role == Role_AUTHORITY)
       nicePrevPerkClass.static.SetupAbilities(KFPRI);
    if(nicePlayer != none){
       nicePlayer.TriggerSelectEventOnPerkChange(nicePrevPerkClass,
           class<NiceVeterancyTypes>(KFPRI.ClientVeteranSkill));
    }
    
    super.VeterancyChanged();
}
simulated function AltFire(optional float F){
    if(NiceMedicGun(Weapon) != none)
       super(SRHumanPawn).AltFire(F);
    else
       super.AltFire(F);
}

defaultproperties
{
     defaultInvincibilityDuration=2.000000
     BaseMeleeIncrease=0.000000
}
