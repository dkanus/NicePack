//  Weapon class for NicePack that supports:
//  1. Client-side ammo management
//      When using client-side hit detection we don't want to wait for server to send us an update on current ammunition amount.
//      So we try and keep track of it on the client instead. 
//      This is especially important for high fire rate weapons.
//      No protection against cheating implemented.
//  2. Client-side multistage reload
//      Reloading process is now handled on the client and is tightly tied to the animation. Server only receives updates on ammo amount after reload.
//      Reloading now also consists of several stages, which allows to update ammo amount at certain points of the animation and, coupled with reload cancellation, allows for partial completion of reload.
//      Stages must be manually set for each weapon by specifying animation frame at which each stage should begin. Also a name of the bone, corresponding to the weapon's magazine must be provided.
//      1) Magazine weapons
//      Magazine weapons have up to 4 reload stages:
//          - First is a 'prestage', when magazine hasn't yet been removed,
//          - Second is a main stage during which old magazine was removed, but new one wasn't yet inserted,
//          - Third is weapon charging stage that happens after magazine insertion,
//          - Fourth stage contains all the useless animation left-overs.
//      2) Shell-by-shell reload ('single') doesn't really has stages.
//      The only "feature" for this type of reload is playing the end of the reload animation in case we're reloading from 0 ammo
//      3) Auto reload
//      This describes the type of reload that is a part of a shooting animation for 1-shot weapons (and hunting shotgun).
//      It consists of 3 stages:
//          - First is unskippable part, usually the shot itself,
//          - Second is actual reloading part,
//          - Third is a trash part, that contains all the useless animation left-overs.
//      Introduced functionality allows to force reload by skipping straight to stage 2.
//      Unlike 2 previous reloads includes a stage that cannot (at least shouldn't) be interrupted by any means.
//  3. Reload cancellation
//      Initially this functionality was just a copy-paste of a1eat0r's 'Reload options' mutator.
//      Now functionality was altered to use introduced stages of reload process.
class NiceWeapon extends KFWeapon
    dependson(NicePlainData)
    abstract;
var float   lastHeadshotTime;
var float   stdFireRate;
var float   holsteredCompletition;
var bool    bLoadResourcesAsMaterial;       // Force to load all graphic resources as just materials
var bool    bUseFlashlightToToggle;
var int     MagAmmoRemainingClient;         // Tracks magazine size on client
var bool    bRoundInChamber;                // Indicates that bullet was loaded in a chamber
var float   LastMagUpdateFromClient;        // Time of the most recent magazine update, received from the client
var float   ReloadDeadLine;                 // Time, after which server should speed-up reload
var float   lastRecordedReloadRate;
var float   recordedZoomTime;
// Weapon secondary charge counter
var bool    bShowSecondaryCharge;
var int     secondaryCharge;
// HUD icons changes
var bool    bChangeClipIcon;
var bool    bChangeBulletsIcon;
var bool    bChangeSecondaryIcon;
var Texture hudClipTexture;
var Texture hudBulletsTexture;
var Texture hudSecondaryTexture;
// Laser-related variables
var         bool                        bLaserActive;               // The laser site is active
var         bool                        bAllowFreeDot;              // Allows dot from the laser to freely follow movements of the bone (the same way as it usually does during reload)
var()       class<InventoryAttachment>  LaserAttachmentClass;       // First person laser attachment class
var         Actor                       LaserAttachment;            // First person laser attachment
var         Actor                       altLaserAttachment;         // Alternative laser attachment
var()       byte                        LaserType;                  // current laser type
var         Vector                      LaserAttachmentOffset;      // relative offset from attachment bone
var         Vector                      altLaserAttachmentOffset;   // relative offset from alternative attachment bone
var         Rotator                     LaserAttachmentRotation;    // How should we rotate the bone, our laser is attached to?
var         Rotator                     altLaserAttachmentRotation; // How should we rotate the bone, our alternative laser is attached to?
var const   class<ScrnLocalLaserDot>    LaserDotClass;
var         ScrnLocalLaserDot           LaserDot;
var         ScrnLocalLaserDot           altLaserDot;
var         name                        LaserAttachmentBone;
var         name                        altLaserAttachmentBone;
// Prossible reasons for reload cancel
enum ERelCancelCause{
    CANCEL_FIRE,
    CANCEL_ALTFIRE,
    CANCEL_NADE,
    CANCEL_COOKEDNADE,
    CANCEL_SWITCH,
    CANCEL_PASSIVESWITCH,
    CANCEL_AIM,
    CANCEL_RELOAD
};
// Possible reload types for main reload (forced by 'ReloadMeNow()' function)
// Note that weapons with two fire-modes can have 'RTYPE_MAG' or 'RTYPE_SINGLE' for main reload and still use auto reload (e.g. for secondary fire of M4 203)
enum ERelType{
    RTYPE_MAG,      // Magazine-type reload (like for commando rifles or M14 EBR)
    RTYPE_SINGLE,   // Single-shell reload (like lar or shotgun)
    RTYPE_AUTO      // Means that auto reload is a main reload for this weapon (hunting shotgun and 1-shot weapons such as M79, M99, xbow, etc)
};
var ERelType reloadType;
// Possible stages of a magazine reload
enum ERelStage{
    RSTAGE_NONE,    // Weapon isn't being reloaded
    RSTAGE_PREREL,  // Magazine wasn't yet removed, reload can be safely interrupted
    RSTAGE_MAINREL, // Magazine was already removed, reload cannot be interrupted without penalties
    RSTAGE_POSTREL, // Magazine was replaced, reload can be safely interrupted, but post-reload stage (weapon charging) will have to be redone
    RSTAGE_TRASH    // Non-functioning frames of animation after inserting magazine and charging weapon
};
var bool        bServerFiredLastShot;
var bool        bGiveObsessiveBonus;
// Magazine reload-related variables
var float       reloadPreEndFrame;      // Frame number, after which magazine is removed, so interrupting reload will result in zero magazine ammo
var float       reloadEndFrame;         // Frame number, after which new magazine is inserted, but gun wasn't yet charged, so if reload is interrupted after this stage, - charging would need to be redone later
var float       reloadChargeEndFrame;   // Frame number, after which weapon's reload can be interrupted without any penalties
var float       reloadMagStartFrame;    // Frame number, from which to start animation magazine insertion; don't confuse it with a point at which magazine removal starts in a full reload animation
var float       reloadChargeStartFrame; // Frame number, from which to start animating weapon charging; don't confuse it with a point at which charging starts in a full reload animation
var bool        bMagazineOut;           // Indicates if magazine is currently removed from the weapon
var name        magazineBone;           // Bone that we need to hide when magazine is out
var bool        bHasChargePhase;        // Weapon needs to be charged at some point
var bool        bNeedToCharge;          // This flag marks the need to finish post-stage of reload (gun charging stage)
var ERelStage   currentRelStage;        // Current stage of the magazine reload
// Following variables are a result of poor initial design of this system that didn't account for the need to do reloads of dual weapons
// The whole thing will be rewritten from the ground up, but for now that's far from priority goal
// What I'm adding with these is an event system that would call a 'ReloadEvent' function when reload passes a certain point
// Only magazine reload supports these
struct EventRecord{
    var string  eventName;
    var float   eventFrame;
};
var array<EventRecord>  relEvents;
var float               lastEventCheckFrame;
// Single reload-related variables
var int             subReloadStage;     // Substage is part of animation between two consecutive shell loadings; they're numbered starting from zero
var bool            alwaysPlayAnimEnd;  // Should we always force playing end of the reload animation?
var array<float>    reloadStages;       // Array of frame numbers that indicate moments when ammo should be added
// Auto reload-related structure, enum and variables
// Auto reload activates by itself whenever appropriate animation starts to play; structure object below must be provided for each such animation
struct AutoReloadAnimDesc{
    var name    animName;           // Name of the animation for which instance of this struct is prepared
    var float   canInterruptFrame;  // Frame, starting from which reload can be interrupted
    var float   trashStartFrame;    // Frame from which starts useless part of animation
    var float   resumeFrame;        // Frame from which we must resume reload if it was previously interrupted
    var float   speedFrame;         // Frame from which we must apply reload speed bonus (so that initial, shooting part remains unaffected)
};
// Array that contains information about all possible animations that can treated as auto-reload
var array<AutoReloadAnimDesc> autoReloadsDescriptions;
enum EAutoRelStage{
    RAUTOSTAGE_NONE,            // Auto reload is inactive
    RAUTOSTAGE_UNINTERRUPTIBLE, // Auto reload is active and it's currently uninterruptible (usually that's the shooting part of animation)
    RAUTOSTAGE_INTERRUPTIBLE    // Auto reload is active and can be interrupted; ammo is reloaded at the end of this state (it will be skipped in case there's no more ammunition)
};
var bool            bAllowAutoReloadSkip;   // Indicates if switching to another weapon should allow player to skip interruptible part of auto reload completely
var int             currentAutoReload;      // Active auto reload always corresponds to a certain animation; this is index of it's corresponding data in 'autoReloadsDescriptions'
var EAutoRelStage   currentAutoReloadStage;
var bool            bAutoReload;            // Indicates that current reload is the auto reload
var bool            bAutoReloadInterrupted; // Indicates if auto reload was interrupted (and must be repeated as soon as possible)
var bool            bAutoReloadPaused;      // This is used to 'pause' auto reload in case we need to interrupt it for a moment (and then immediately continue from where we left), i.e. when throwing a grenade
var float           autoReloadPauseFrame;   // Frame at which current pause began
var bool            bAutoReloadRateApplied; // Flag that remembers whether or not we've already applied reload speed up for current auto reload (to avoid constant animation's speed updates)
var float           autoReloadSpeedModifier;
// Acrtive reload-related variables
// Active reload state
enum EActiveReloadState{
    ACTR_NONE,      // Activation wasn't yet attempted during current reload
    ACTR_FAIL,      // Activation failed
    ACTR_SUCCESS    // Activation succeeded
};
var bool                bCanActiveReload;   // Can we even use active reload with this weapon?
var float               activeSlowdown;     // How much should we slow down the speed of reload if player has failed?
var float               activeSpeedup;      // How much should we speedup active reload if player succeeded?
var EActiveReloadState  activeReloadState;  // Current state of active reload, only applicable during reload
var float               activeWindow;       // How long (0.0 is zero long, 1.0 is all animation) must be a time window during which you can activate active reload
replication{
    reliable if(Role < ROLE_Authority)
       ServerReduceMag, ServerSetMagSize, ServerSetSndCharge, ServerReload, ServerShiftReloadTime, ServerStopReload,
           ServerSetCharging, ServerSetLaserType;
    reliable if(Role == ROLE_Authority)
       ClientForceInterruptReload, ClientReloadMeNow, ClientSetMagSize, ClientSetSndCharge, ClientPutDown,
           ClientThrowGrenade, ClientCookGrenade, ClientTryPendingWeapon, ClientUpdateWeaponMag, ClientSetLaserType,
           ClientReloadAmmo;
    reliable if(Role == ROLE_Authority)
       holsteredCompletition;
}
static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount){
    local int i;
    if(!bSkipRefCount)
       default.ReferenceCount ++;
    if(default.Mesh == none && default.MeshRef != "")
       UpdateDefaultMesh(SkeletalMesh(DynamicLoadObject(default.MeshRef, class'SkeletalMesh')));
    if(default.HudImage == none && default.HudImageRef != "")
       default.HudImage = texture(DynamicLoadObject(default.HudImageRef, class'texture'));
    if(default.SelectedHudImage == none && default.SelectedHudImageRef != "")
       default.SelectedHudImage = texture(DynamicLoadObject(default.SelectedHudImageRef, class'texture'));
    if(default.SelectSound == none && default.SelectSoundRef != "")
       default.SelectSound = sound(DynamicLoadObject(default.SelectSoundRef, class'sound'));
    for(i = 0;i < default.SkinRefs.Length;i ++)
       if(default.SkinRefs[i] != "" && (default.Skins.Length < i + 1 || default.Skins[i] == none)){
           default.Skins[i] = none;
           if(default.bLoadResourcesAsMaterial)
               default.Skins[i] = Material(DynamicLoadObject(default.SkinRefs[i], class'Material'));
           // Try to load as various types of materials
           if(default.Skins[i] == none)
               default.Skins[i] = Combiner(DynamicLoadObject(default.SkinRefs[i], class'Combiner', true));
           if(default.Skins[i] == none)
               default.Skins[i] = FinalBlend(DynamicLoadObject(default.SkinRefs[i], class'FinalBlend', true));
           if(default.Skins[i] == none)
               default.Skins[i] = Shader(DynamicLoadObject(default.SkinRefs[i], class'Shader', true));
           if(default.Skins[i] == none)
               default.Skins[i] = Texture(DynamicLoadObject(default.SkinRefs[i], class'Texture', true));
           if(default.Skins[i] == none)
               default.Skins[i] = Material(DynamicLoadObject(default.SkinRefs[i], class'Material'));
       }
    if(NiceWeapon(Inv) != none){
       Inv.LinkMesh(default.Mesh);
       NiceWeapon(Inv).HudImage = default.HudImage;
       NiceWeapon(Inv).SelectedHudImage = default.SelectedHudImage;
       NiceWeapon(Inv).SelectSound = default.SelectSound;
       for(i = 0; i < default.SkinRefs.Length;i ++)
           Inv.Skins[i] = default.Skins[i];
    }
}
static function bool UnloadAssets(){
    local int i;
    default.ReferenceCount--;
    UpdateDefaultMesh(none);
    default.HudImage = none;
    default.SelectedHudImage = none;
    default.SelectSound = none;
    for(i = 0;i < default.SkinRefs.Length; i ++)
       default.Skins[i] = none;
    return default.ReferenceCount == 0;
}
simulated function PostBeginPlay(){
    if(default.recordedZoomTime < 0)
       default.recordedZoomTime = ZoomTime;
    recordedZoomTime = default.recordedZoomTime;
    // Default variables
    LastMagUpdateFromClient = 0.0;
    bNeedToCharge           = false;
    bMagazineOut            = false;
    currentRelStage         = RSTAGE_NONE;
    lastEventCheckFrame     = -1.0;
    // Fill sub reload stages
    fillSubReloadStages();
    // Auto fill reload stages for 'RTYPE_SINGLE' reload
    if(reloadType == RTYPE_SINGLE)
       UpdateSingleReloadVars();
    if(reloadType == RTYPE_AUTO)
       bHasChargePhase = false;
    if(reloadChargeStartFrame < 0.0 || reloadChargeEndFrame < 0.0)
       bHasChargePhase = false;
    if(FireModeClass[0] != none)
       stdFireRate = FireModeClass[0].default.fireRate;
    super.PostBeginPlay();
}

// Allows to prevent leaving iron sights unwillingly
function bool ShouldLeaveIronsight(){
    local class<NiceVeterancyTypes> niceVet;
    niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(Instigator.PlayerReplicationInfo);
    if(niceVet != none && niceVet.static.hasSkill(NicePlayerController(Instigator.Controller), class'NiceSkillEnforcerUnshakable'))
       return false;
    return true;
}
// Updates max value for this weapon's ammunition
simulated function UpdateWeaponAmmunition(){
    local int i;
    for(i = 0;i < NUM_FIRE_MODES;i ++){
       if(Ammo[i] == none)
           continue;
       if(NiceAmmo(Ammo[i]) != none)
           NiceAmmo(Ammo[i]).UpdateAmmoAmount();
    }
}
function UpdateWeaponMag(){
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);
    MagAmmoRemaining = Min(MagAmmoRemaining, MagCapacity);
    ClientSetMagSize(MagAmmoRemaining, bRoundInChamber);
}
simulated function ClientUpdateWeaponMag(){
    local int actualMag;
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);
    actualMag = MagAmmoRemainingClient;
    if(bHasChargePhase && bRoundInChamber && actualMag > 0)
       actualMag --;
    MagAmmoRemainingClient = Min(MagAmmoRemainingClient, MagCapacity);
    if(bHasChargePhase && bRoundInChamber)
       actualMag ++;
    ServerSetMagSize(MagAmmoRemainingClient, bRoundInChamber, Level.TimeSeconds);
}
// Overloaded to properly reduce magazine's size
simulated function bool ConsumeAmmo(int Mode, float Load, optional bool bAmountNeededIsMax){
    local Inventory Inv;
    local bool bOutOfAmmo;
    local KFWeapon KFWeap;
    if(super(Weapon).ConsumeAmmo(Mode, Load, bAmountNeededIsMax)){
       if(Load > 0 && (Mode == 0 || bReduceMagAmmoOnSecondaryFire)){
           MagAmmoRemaining -= Load;
           if(MagAmmoRemaining < 0)
               MagAmmoRemaining = 0;
           if(MagAmmoRemaining <= 0)
               bRoundInChamber = false;
       }

       NetUpdateTime = Level.TimeSeconds - 1;

       if(FireMode[Mode].AmmoPerFire > 0 && InventoryGroup > 0 && !bMeleeWeapon && bConsumesPhysicalAmmo &&
           (Ammo[0] == none || FireMode[0] == none || FireMode[0].AmmoPerFire <= 0 || Ammo[0].AmmoAmount < FireMode[0].AmmoPerFire) &&
           (Ammo[1] == none || FireMode[1] == none || FireMode[1].AmmoPerFire <= 0 || Ammo[1].AmmoAmount < FireMode[1].AmmoPerFire)){
           bOutOfAmmo = true;

           for(Inv = Instigator.Inventory;Inv != none; Inv = Inv.Inventory){
               KFWeap = KFWeapon(Inv);

               if(Inv.InventoryGroup > 0 && KFWeap != none && !KFWeap.bMeleeWeapon && KFWeap.bConsumesPhysicalAmmo &&
                    ((KFWeap.Ammo[0] != none && KFWeap.FireMode[0] != none && KFWeap.FireMode[0].AmmoPerFire > 0 &&KFWeap.Ammo[0].AmmoAmount >= KFWeap.FireMode[0].AmmoPerFire) ||
                    (KFWeap.Ammo[1] != none && KFWeap.FireMode[1] != none && KFWeap.FireMode[1].AmmoPerFire > 0 && KFWeap.Ammo[1].AmmoAmount >= KFWeap.FireMode[1].AmmoPerFire))){
                   bOutOfAmmo = false;
                   break;
               }
           }

           if(bOutOfAmmo)
               PlayerController(Instigator.Controller).Speech('AUTO', 3, "");
       }
       return true;
    }
    return false;
}
// Forces update for client's magazine ammo counter
// In case we are using client-side hit-detection, client itself manages remaining ammunition in magazine, but in some cases we want server to dictate current magazine amount
// This function sets client's mag size to a given value
simulated function ClientSetMagSize(int newMag, bool bChambered){
    MagAmmoRemainingClient = newMag;
    bRoundInChamber = bChambered;
    if(MagAmmoRemainingClient > 0 && bHasChargePhase && !bRoundInChamber)
       bNeedToCharge = true;
}
// This function allows clients to change magazine size without altering total ammo amount
// It allows clients to provide time-stamps, so that older change won't override a newer one
function ServerSetMagSize(int newMag, bool bChambered, float updateTime){
    magAmmoRemaining = newMag;
    bRoundInChamber = bChambered;
    if(LastMagUpdateFromClient <= updateTime){
       LastMagUpdateFromClient = updateTime;
       if(newMag > 0)
           bServerFiredLastShot = false;
    }
}
// This function allows clients to change magazine size along with total ammo amount on the server (to update ammo counter in client-side mode)
// It allows clients to provide time-stamps, so that older change won't override a newer one
// Intended to be used for decreasing ammo count from shooting and cannot increase magazine size
simulated function ServerReduceMag(int newMag, float updateTime, int Mode){
    local int delta;
    if(Mode == 0 || !bHasSecondaryAmmo){
       delta = magAmmoRemaining - newMag;
       // Only update later changes that actually decrease magazine
       if(LastMagUpdateFromClient <= updateTime && delta > 0){
           LastMagUpdateFromClient = updateTime;
           ConsumeAmmo(Mode, delta);
       }
    }
    else
       ConsumeAmmo(Mode, 1);
}
// Forces either 'AddReloadedAmmo' or 'AddAutoReloadedAmmo' (depending on which one is appropriate) function on client
// Somewhat of a hack to allow server force-add ammo to the weapon
simulated function ClientReloadAmmo(){
    if(reloadType == RTYPE_AUTO)
       AddAutoReloadedAmmo();
    else
       AddReloadedAmmo();
    bNeedToCharge   = false;
    bMagazineOut    = false;
    if(bHasChargePhase)
       bRoundInChamber = true;
    ResetReloadVars();
}
// Adds appropriate amount of ammo during reload.
// Up to full mag for magazine reload, 1 ammo per call for single reload.
// Isn't called in case of auto reload, use 'AddAutoReloadedAmmo' for that.
simulated function AddReloadedAmmo(){
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);
    if(reloadType == RTYPE_MAG){
       if(AmmoAmount(0) >= MagCapacity){
           MagAmmoRemainingClient = MagCapacity;
           if(bRoundInChamber)
               MagAmmoRemainingClient ++;
       }
       else
           MagAmmoRemainingClient = AmmoAmount(0);
    }
    else if(reloadType == RTYPE_SINGLE){
       if(AmmoAmount(0) - MagAmmoRemainingClient > 0 && MagAmmoRemainingClient < MagCapacity)
           MagAmmoRemainingClient ++;
    }
    ServerSetMagSize(MagAmmoRemainingClient, bRoundInChamber, Level.TimeSeconds);
    if(PlayerController(Instigator.Controller) != none && KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements) != none)
       KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements).OnWeaponReloaded();
}
// Function that manages ammo replenishing for auto reload
simulated function AddAutoReloadedAmmo(){
    if(reloadType != RTYPE_AUTO){
       secondaryCharge = 1;
       ServerSetSndCharge(secondaryCharge);
    }
    else{
       if(AmmoAmount(0) > 0)
           MagAmmoRemainingClient = 1;
       else
           MagAmmoRemainingClient = 0;
       ServerSetMagSize(MagAmmoRemainingClient, bRoundInChamber, Level.TimeSeconds);
    }
}
simulated function float TimeUntillReload(){
    if(reloadType == RTYPE_MAG)
       return FMax(reloadChargeEndFrame, reloadEndFrame) * GetAnimDuration(ReloadAnim);
    else if(reloadType == RTYPE_SINGLE && reloadStages.Length > 0)
       return reloadStages[0] * GetAnimDuration(ReloadAnim);
    else if(reloadType == RTYPE_AUTO && autoReloadsDescriptions.Length > 0)
       return autoReloadsDescriptions[0].trashStartFrame * GetAnimDuration(autoReloadsDescriptions[0].animName);
    return 60.0;
}
// Interrupt the reloading animation, which may reset the weapon's magAmmoRemaining;
// Don't allow Fire() and AltFire() to interrupt by shooting with empty magazine.
simulated function ClientForceInterruptReload(ERelCancelCause cause){
    local bool bActualAllowAutoReloadSkip;
    local bool bCauseFire, bCauseAltFire, bCauseNade, bCauseAim, bCauseSwitch;
    local HUDKillingFloor HUD;
    local NiceHumanPawn nicePawn;
    local NicePlayerController nicePlayer;
    local bool bDisplayInventory, bWeReallyShould;
    // Determine causes flags
    bCauseFire =        cause == CANCEL_FIRE;
    bCauseAltFire =     cause == CANCEL_ALTFIRE;
    bCauseNade =        (cause == CANCEL_NADE) || (cause == CANCEL_COOKEDNADE);
    bCauseAim =         cause == CANCEL_AIM;
    bCauseSwitch =      cause == CANCEL_SWITCH || cause == CANCEL_PASSIVESWITCH;
    // Is player looking at inventory?
    nicePlayer = NicePlayerController(Instigator.Controller);
    if(nicePlayer == none || !bIsReloading)
       return;
    HUD = HUDKillingFloor(nicePlayer.MyHUD);
    bDisplayInventory = HUD != none && HUD.bDisplayInventory;
    // General checks: is there any meaning to reset reload for provided cause?
    if(bCauseFire)
       bWeReallyShould = !bNeedToCharge && (bDisplayInventory || magAmmoRemainingClient >= GetFireMode(0).ammoPerFire);
    else if(bCauseAltFire)
       bWeReallyShould = !bNeedToCharge && AltFireCanForceInterruptReload()
           && (reloadType == RTYPE_AUTO || !bAutoReload);
    else if(bCauseNade){
       bWeReallyShould = true;
       nicePawn = NiceHumanPawn(nicePlayer.Pawn);
       if(nicePawn == none)
           bWeReallyShould = false;
       else{
           if(nicePawn.PlayerGrenade == none)
               nicePawn.PlayerGrenade = nicePawn.FindPlayerGrenade();
           if(nicePawn.PlayerGrenade == none || !nicePawn.PlayerGrenade.HasAmmo())
               bWeReallyShould = false;
       }
    }
    else if(bCauseAim)
       bWeReallyShould = magAmmoRemainingClient >= GetFireMode(0).ammoPerFire && GetReloadStage() != RSTAGE_POSTREL;
    else
       bWeReallyShould = true;
    // If this is a magazine type reload - check player's preferences
    if(reloadType == RTYPE_MAG){
       if(GetReloadStage() == RSTAGE_TRASH)
           bWeReallyShould = true;
       else if(bCauseFire || bCauseAltFire)
           bWeReallyShould = bWeReallyShould && nicePlayer.bRelCancelByFire;
       else if(bCauseSwitch)
           bWeReallyShould = bWeReallyShould && nicePlayer.bRelCancelBySwitching;
       else if(cause == CANCEL_NADE)
           bWeReallyShould = bWeReallyShould && nicePlayer.bRelCancelByNades;
       else if(bCauseAim)
           bWeReallyShould = bWeReallyShould && nicePlayer.bRelCancelByAiming;
    }
    // Allow interrupting auto reload (by pausing) to throw a grenade
    if(bAutoReload){
       if(cause == CANCEL_NADE && bWeReallyShould){
           bAutoReloadPaused = true;
           autoReloadPauseFrame = GetCurrentAnimFrame();
       }
       else if(currentAutoReloadStage == RAUTOSTAGE_UNINTERRUPTIBLE)
           bWeReallyShould = false;
    }
    // Interrupt if we really should
    if(bIsReloading && bWeReallyShould){
       HideMagazine(bMagazineOut);
       if(bAutoReload){
           bActualAllowAutoReloadSkip = bAllowAutoReloadSkip;
           if(KFGameType(Level.Game) != none)
               bActualAllowAutoReloadSkip = bAllowAutoReloadSkip
                   || KFGameType(Level.Game).WaveNum == KFGameType(Level.Game).FinalWave;
           if(bActualAllowAutoReloadSkip && bCauseSwitch && !bAutoReloadPaused){
               AddAutoReloadedAmmo();
               bAutoReloadRateApplied = false;
           }
           else if(bCauseSwitch || bCauseNade)
               bAutoReloadInterrupted = true;
       }
       ServerStopReload();
       bIsReloading = false;
       bAutoReload = false;
       lastEventCheckFrame = -1.0;
       currentAutoReloadStage = RAUTOSTAGE_NONE;
       PlayIdle();

       if(bCauseNade){
           if(cause == CANCEL_NADE && KFHumanPawn(Instigator) != none)
               ClientThrowGrenade();
           else if(cause == CANCEL_COOKEDNADE && ScrnHumanPawn(Instigator) != none)
               ClientCookGrenade();
       }
       else if(cause == CANCEL_SWITCH)
           ClientPutDown();
    }
}
// Indicates if alt. fire should also interrupt reload
simulated function bool AltFireCanForceInterruptReload(){
    if(FireModeClass[1] != none && FireModeClass[1] != class'KFMod.NoFire' && (NiceFire(FireMode[1]) == none || !NiceFire(FireMode[1]).bDisabled))
       return true;
    return false;
}
// Auxiliary functions to force certain function on client-side
simulated function bool ClientPutDown(){
    return PutDown();
}
simulated function ClientThrowGrenade(){
    if(KFHumanPawn(Instigator) != none)
       KFHumanPawn(Instigator).ThrowGrenade();
}
simulated function ClientCookGrenade(){
    if(ScrnHumanPawn(Instigator) != none)
       ScrnHumanPawn(Instigator).CookGrenade();
}
// Functions that we need to reload in order to allow reload interruption on certain actions
simulated function bool PutDown(){
    if(NicePlayerController(Instigator.Controller) != none)
       ClientForceInterruptReload(CANCEL_SWITCH);
    if(!bIsReloading)
       HideMagazine(bMagazineOut);
    TurnOffLaser();
    return super.PutDown();
}
simulated function Fire(float F){
    if(NicePlayerController(Instigator.Controller) != none)
       ClientForceInterruptReload(CANCEL_FIRE);
    super.Fire(F);
}
simulated function AltFire(float F){
    if(NicePlayerController(Instigator.Controller) != none)
       ClientForceInterruptReload(CANCEL_ALTFIRE);
    Super.AltFire(F);
    // Also request auto reload on alt. fire
    if(!bHasSecondaryAmmo && AltFireCanForceInterruptReload() && magAmmoRemainingClient <= 0)
       ServerRequestAutoReload();
    else if(bHasSecondaryAmmo && !bAutoReload && FireModeClass[1] != class'KFMod.NoFire' && secondaryCharge <= 0)
       ResumeAutoReload(autoReloadsDescriptions[currentAutoReload].resumeFrame);
}
simulated exec function ToggleIronSights(){
    if(NicePlayerController(Instigator.Controller) != none)
       ClientForceInterruptReload(CANCEL_AIM);
    Super.ToggleIronSights();
}
simulated exec function IronSightZoomIn(){
    if(NicePlayerController(Instigator.Controller) != none)
       ClientForceInterruptReload(CANCEL_AIM);
    Super.IronSightZoomIn();
}
// Function for filling-up reload stages in a single reload
simulated function FillSubReloadStages(){}
simulated function UpdateSingleReloadVars(){
    reloadPreEndFrame = 0.0;
    if(reloadStages.Length > 0)
       reloadEndFrame = reloadStages[reloadStages.Length - 1];
    else
       reloadEndFrame = 0.0;
    reloadChargeStartFrame = -1.0;
    reloadChargeEndFrame = -1.0;
    bHasChargePhase = false;
}
// Function that setups all the variable for next reload; this DOES NOT start reload animation or reload itself
simulated function SetupReloadVars(optional bool bIsActive, optional int animationIndex){
    if(Role == ROLE_Authority)
       return;
    bIsReloading = true;
    bAutoReloadRateApplied = false;
    bAutoReloadInterrupted = false;
    bAutoReloadPaused = false;
    currentAutoReloadStage = RAUTOSTAGE_UNINTERRUPTIBLE;
    autoReloadPauseFrame = 0.0;
    currentAutoReload = 0;
    activeReloadState = ACTR_NONE;
    if(bIsActive){
       bAutoReload = true;
       currentAutoReload = Clamp(animationIndex, 0, autoReloadsDescriptions.Length - 1);
    }
}
// Reset all the necessary variables after reloading
simulated function ResetReloadVars(){
    if(Role == ROLE_Authority)
       return;
    ServerStopReload();
    bIsReloading = false;
    bAutoReload = false;
    bAutoReloadInterrupted = false;
    currentAutoReloadStage = RAUTOSTAGE_NONE;
    currentAutoReload = 0;
    activeReloadState = ACTR_NONE;
    ClientTryPendingWeapon();
}
// Does what 'SetAnimFrame' does + updates 'lastEventCheckFrame' for correct event handling
// Use this instead of 'SetAnimFrame', unless you have a very specific need and know what you're doing
simulated function ScrollAnim(float newFrame){
    SetAnimFrame(newFrame);
    lastEventCheckFrame = newFrame;
}
// Starts reload at given rate from given stage.
// If specified stage is either 'RSTAGE_NONE' or 'RSTAGE_PREREL', - start reload from the beginning
simulated function PlayReloadAnimation(float rate, ERelStage stage){
    if(!HasAnim(ReloadAnim))
       return;
    PlayAnim(ReloadAnim, rate, 0.0);
    if(stage != RSTAGE_NONE && stage != RSTAGE_PREREL){
       if(stage == RSTAGE_MAINREL){
           ScrollAnim(reloadMagStartFrame);
           HideMagazine(false);
       }
       else if(stage == RSTAGE_POSTREL)
           ScrollAnim(reloadChargeStartFrame);
       else if(stage == RSTAGE_TRASH)
           ScrollAnim(reloadChargeEndFrame);
    }
}
// Resumes previously interrupted auto reload.
// Doesn't do any check for whether or not interruption took place
simulated function ResumeAutoReload(float startFrame){
    local float ReloadMulti;
    if(!HasAnim(autoReloadsDescriptions[currentAutoReload].animName))
       return;
    ReloadMulti = GetCurrentReloadMult();
    PlayAnim(autoReloadsDescriptions[currentAutoReload].animName, AutoReloadBaseRate() * ReloadMulti, 0.0);
    if(startFrame <= 0)
       startFrame = 0.0;
    ScrollAnim(startFrame);
    ServerReload((1 - startFrame) * AutoReloadBaseRate() / ReloadMulti);
    SetupReloadVars(true, currentAutoReload);
}
// Returns reload speed that weapon should have at the moment
simulated function float GetFittingReloadSpeed(){
    return default.ReloadAnimRate * GetCurrentReloadMult();
}
// Updates current reload rate
simulated function UpdateReloadRate(){
    lastRecordedReloadRate = GetFittingReloadSpeed();
    if(bIsReloading)
       ChangeReloadRate(lastRecordedReloadRate);
}
// Changes rate of current animation, allowing it to continue from the same frame
simulated function ChangeReloadRate(float newRate){
    local name SeqName;
    local float AnimFrame, AnimRate;
    GetAnimParams(0, SeqName, AnimFrame, AnimRate);
    if(AnimFrame < 0)
       AnimFrame = 0;
    if(!bAutoReload && SeqName != ReloadAnim)
       return;
    if(bAutoReload)
       PlayAnim(SeqName, newRate, 0.0);
    else
       PlayReloadAnimation(newRate, RSTAGE_NONE);
    ScrollAnim(AnimFrame);
}
// New handler for client's reload request
// Can be called directly as a command or automatically, by intercepting ReloadMeNow command (handled in 'NiceInteraction')
exec simulated function ClientReloadMeNow(){
    local float ReloadMulti;
    local NicePlayerController nicePlayer;
    local class<NiceVeterancyTypes> niceVet;
    if(reloadType != RTYPE_AUTO && bAutoReload && !IsMagazineFull())
       ClientForceInterruptReload(CANCEL_RELOAD);
    nicePlayer = NicePlayerController(Instigator.Controller);
    if(nicePlayer != none)
       niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(nicePlayer.PlayerReplicationInfo);
    bGiveObsessiveBonus = false;
    if(bIsReloading)
       AttemptActiveReload();
    else if(niceVet.static.hasSkill(nicePlayer, class'NiceSkillSupportObsessive') && GetMagazineAmmo() >= float(MagCapacity) * class'NiceSkillSupportObsessive'.default.reloadLevel)
       bGiveObsessiveBonus = true;
    if(!AllowReload())
       return;
    if(reloadType == RTYPE_AUTO)
       ResumeAutoReload(autoReloadsDescriptions[currentAutoReload].resumeFrame);
    else{
       SetupReloadVars();
       if(bHasAimingMode && bAimingRifle && !bAutoReload){
           FireMode[1].bIsFiring = false;
           ZoomOut(false);
           ServerZoomOut(false);
       }
       subReloadStage = 0;
       ReloadMulti = GetCurrentReloadMult();
       if(bMagazineOut && reloadMagStartFrame >= 0){
           ServerReload((1 - reloadMagStartFrame) * default.ReloadRate / ReloadMulti);
           PlayReloadAnimation(default.ReloadAnimRate * ReloadMulti, RSTAGE_MAINREL);
       }
       else{
           ServerReload(default.ReloadRate / ReloadMulti);
           PlayReloadAnimation(default.ReloadAnimRate * ReloadMulti, RSTAGE_NONE);
       }
    }
}
// Tells server that reload was started and how long should it take
function ServerReload(float duration, optional bool autoReload){
    bIsReloading = true;
    Instigator.SetAnimAction(WeaponReloadAnim);
    ReloadDeadLine = Level.TimeSeconds + duration;
    if(bHasAimingMode && bAimingRifle && !autoReload)
       FireMode[1].bIsFiring = false;
    if(Level.Game.NumPlayers > 1 && KFGameType(Level.Game).bWaveInProgress && KFPlayerController(Instigator.Controller) != none &&
       Level.TimeSeconds - KFPlayerController(Instigator.Controller).LastReloadMessageTime > KFPlayerController(Instigator.Controller).ReloadMessageDelay){
       KFPlayerController(Instigator.Controller).Speech('AUTO', 2, "");
       KFPlayerController(Instigator.Controller).LastReloadMessageTime = Level.TimeSeconds;
    }
}
// Shift deadline of reload on server
function ServerShiftReloadTime(float delta){
    if(bIsReloading)
       ReloadDeadLine += delta;
}
// Forces reload to stop on server
function ServerStopReload(){
    bIsReloading = false;
}
// Reloaded to implement new reload mechanism
simulated function WeaponTick(float dt){
    local int i;
    local name SeqName;
    local float ReloadMulti;
    local float AnimFrame, AnimRate;
    local ERelStage newStage;
    if(lastRecordedReloadRate != GetFittingReloadSpeed())
       UpdateReloadRate();
    // Resume charging magazine weapon next time we can
    if(bNeedToCharge && GetReloadStage() == RSTAGE_NONE){
       GetAnimParams(0, SeqName, AnimFrame, AnimRate);
       if(SeqName == IdleAnim){
           ReloadMulti = GetCurrentReloadMult();
           if(Role == ROLE_Authority)
               ServerReload((1 - reloadChargeStartFrame) * default.ReloadRate / ReloadMulti);
           else{
               SetupReloadVars();
               PlayReloadAnimation(ReloadAnimRate * ReloadMulti, RSTAGE_POSTREL);
           }
       }
    }
    // Resume auto reload from pause next time we can
    if(bAutoReloadPaused && Role < ROLE_Authority && ClientGrenadeState == GN_NONE){
       GetAnimParams(0, SeqName, AnimFrame, AnimRate);
       if(SeqName == IdleAnim)
           ResumeAutoReload(autoReloadPauseFrame);
    }
    // Resume reloading in case auto reload was interrupted as soon as possible
    if(bAutoReloadInterrupted && Role < ROLE_Authority && ClientGrenadeState == GN_none){
       GetAnimParams(0, SeqName, AnimFrame, AnimRate);
       if(SeqName == IdleAnim)
           ResumeAutoReload(autoReloadsDescriptions[currentAutoReload].resumeFrame);
    }
    // Try and detect when animation that should trigger auto reload starts
    if(autoReloadsDescriptions.Length > 0 && currentAutoReloadStage == RAUTOSTAGE_NONE && Role < ROLE_Authority){
       GetAnimParams(0, SeqName, AnimFrame, AnimRate);
       for(i = 0;i < autoReloadsDescriptions.Length;i ++)
           if(SeqName == autoReloadsDescriptions[i].animName && AnimFrame < autoReloadsDescriptions[i].trashStartFrame){
               // Since animation is already running - all we need to do is to setup appropriate variables
               SetupReloadVars(true, i);
               break;
           }
    }
    // Random TWI's code block appears!
    if(bHasAimingMode && bForceLeaveIronsights)
       if(!shouldLeaveIronsight())
           bForceLeaveIronsights = false;
    if(bHasAimingMode){
       if(bForceLeaveIronsights){
           if(bAimingRifle){
               ZoomOut(true);
               if(Role < ROLE_Authority)
                   ServerZoomOut(false);
           }
           bForceLeaveIronsights = false;
       }
       if(ForceZoomOutTime > 0){
           if(bAimingRifle){
               if(Level.TimeSeconds - ForceZoomOutTime > 0){
                   ForceZoomOutTime = 0;
                   ZoomOut(true);
                   if(Role < ROLE_Authority)
                       ServerZoomOut(false);
               }
           }
           else
               ForceZoomOutTime = 0;
       }
    }
    // We want to be up to date on this one
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);
    // Next we have 3 possibilities.
    if(Role == ROLE_Authority){
       // 1. We're on the server. Then just check if we've reached reload deadline.
       if(Level.TimeSeconds >= ReloadDeadLine)
           bIsReloading = false;
    }
    else{
       if(bAutoReload)
           // 2. It's auto reload. Handle it in it's own tick function.
           AutoReloadTick();
       else if(Role < ROLE_Authority){
           // 3. It's not. Then just handle stage swapping for magazine ('goThroughStages' function) and single reloads ('goThroughSubStages' function)
           newStage = GetReloadStage();
           if(reloadType == RTYPE_SINGLE && newStage == RSTAGE_MAINREL)
               goThroughSubStages();
           if(currentRelStage != newStage)
               goThroughStages(currentRelStage, newStage);
       }
       if(Role < ROLE_Authority){
           // Call events
           GetAnimParams(0, SeqName, AnimFrame, AnimRate);
           if(newStage == RSTAGE_NONE && !bAutoReload)
               AnimFrame = 1.0;
           if(newStage != RSTAGE_NONE || lastEventCheckFrame > 0 || bAutoReload)
               HandleReloadEvents(lastEventCheckFrame, AnimFrame);
           if(newStage == RSTAGE_NONE && !bAutoReload)
               lastEventCheckFrame = -1.0;
       }
    }
    // Some other TWI's code leftovers
    if((Level.NetMode == NM_Client) || Instigator == none || KFFriendlyAI(Instigator.Controller) == none && Instigator.PlayerReplicationInfo == none)
       return;
    // Turn it off on death / battery expenditure
    if(FlashLight != none){
       // Keep the 1P weapon client beam up to date.
       AdjustLightGraphic();
       if(FlashLight.bHasLight){
           if(Instigator.Health <= 0 || KFHumanPawn(Instigator).TorchBatteryLife <= 0 || Instigator.PendingWeapon != none ){
               KFHumanPawn(Instigator).bTorchOn = false;
               ServerSpawnLight();
           }
       }
    }
}
simulated function HandleReloadEvents(float oldFrame, float newFrame){
    local int i;
    local float currEventFrame;
    // Old reload ended and new started between checks somehow, no point in it, but try to fix that
    if(oldFrame > newFrame){
       if(oldFrame < 1.0)
           HandleReloadEvents(oldFrame, 1.0);
       if(newFrame > 0.0)
           HandleReloadEvents(0.0, newFrame);
       return;
    }
    for(i = 0;i < relEvents.Length;i ++){
       currEventFrame = relEvents[i].eventFrame;
       if(oldFrame < currEventFrame && newFrame >= currEventFrame)
           ReloadEvent(relEvents[i].eventName);
    }
    if(newFrame > lastEventCheckFrame)
       lastEventCheckFrame = newFrame;
}
simulated function ReloadEvent(string eventName){}
// This function is called each tick while auto reload is active
simulated function AutoReloadTick(){
    local bool bFinishAutoReload;
    local name SeqName;
    local float AnimFrame, AnimRate;
    bFinishAutoReload = false;
    GetAnimParams(0, SeqName, AnimFrame, AnimRate);
    // Apply reload rate to the animation's speed when it's time
    if(AnimFrame > autoReloadsDescriptions[currentAutoReload].speedFrame && !bAutoReloadRateApplied){
       ChangeReloadRate(AutoReloadBaseRate() * GetCurrentReloadMult());
       bAutoReloadRateApplied = true;
    }
    // Change state to interruptible and set reload to finish if there's no ammo
    if(AnimFrame > autoReloadsDescriptions[currentAutoReload].canInterruptFrame){
       if(autoReloadAmmo() > 0){
           currentAutoReloadStage = RAUTOSTAGE_INTERRUPTIBLE;
           ClientTryPendingWeapon();
       }
       else{
           bFinishAutoReload = true;
           PlayIdle();
       }
    }
    // Might as well end reload when we enter trash stage (or when animation is finished)
    if(SeqName != autoReloadsDescriptions[currentAutoReload].animName || AnimFrame > autoReloadsDescriptions[currentAutoReload].trashStartFrame){
       bFinishAutoReload = true;
       AddAutoReloadedAmmo();
    }
    // Finish the reload as asked
    if(bFinishAutoReload)
       ResetReloadVars();
}
simulated function float AutoReloadBaseRate(){
    if(reloadType == RTYPE_AUTO && FireModeClass[0] != none
       && (!bHasSecondaryAmmo || FireMode[1] != Class'KFMod.NoFire'))
       return FireModeClass[0].default.FireAnimRate;
    return FireModeClass[1].default.FireAnimRate;
}
// Called when current state of reload changes; only called on client side
simulated function ReloadChangedStage(ERelStage prevStage, ERelStage newStage){
    local NiceHumanPawn nicePawn;
    local class<NiceVeterancyTypes> niceVet;
    nicePawn = NiceHumanPawn(Instigator);
    if(nicePawn != none)
       niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(nicePawn.PlayerReplicationInfo);
    // Reload was canceled, so all that is meaningless
    if(!bIsReloading)
       return;
    if(reloadType == RTYPE_MAG){
       if(newStage == RSTAGE_MAINREL){
           bNeedToCharge = false;
           ServerSetCharging(bNeedToCharge);
           bMagazineOut = true;
           MagAmmoRemainingClient = 0;
           if(bHasChargePhase && bRoundInChamber)
               MagAmmoRemainingClient ++;
           ServerSetMagSize(MagAmmoRemainingClient, bRoundInChamber, Level.TimeSeconds);
       }
       else if(newStage == RSTAGE_POSTREL){
           bMagazineOut = false;
           HideMagazine(false);
           if(bHasChargePhase){
               if(bRoundInChamber){
                   bNeedToCharge = false;
                   PlayIdle();
               }
               else
                   bNeedToCharge = true;
           }
           ServerSetCharging(bNeedToCharge);
       }
       else if(newStage == RSTAGE_TRASH && (!bHasChargePhase || bRoundInChamber)){
           bMagazineOut = false;
           HideMagazine(false);
       }
       else if(newStage == RSTAGE_NONE)
           ResetReloadVars();
       if(prevStage == RSTAGE_MAINREL && newStage != RSTAGE_NONE)
           AddReloadedAmmo();
       if(prevStage == RSTAGE_POSTREL && newStage == RSTAGE_TRASH){
           bNeedToCharge = false;
           bRoundInChamber = true;
           ServerSetCharging(bNeedToCharge);
           ServerSetMagSize(MagAmmoRemainingClient, bRoundInChamber, Level.TimeSeconds);
       }
       if(newStage == RSTAGE_TRASH)
           ClientTryPendingWeapon();
    }
    else if(reloadType == RTYPE_SINGLE){
       if(newStage == RSTAGE_NONE)
           ResetReloadVars();
       if(prevStage == RSTAGE_MAINREL && bIsReloading)
           goThroughSubStages(true);
    }
}
// Return current magazine (also has limited use for single reload) stage of reload
simulated function ERelStage GetReloadStage(){
    local name SeqName;
    local float AnimFrame, AnimRate;
    GetAnimParams(0, SeqName, AnimFrame, AnimRate);
    if(SeqName != ReloadAnim)
       return RSTAGE_NONE;
    if(AnimFrame < reloadPreEndFrame)
       return RSTAGE_PREREL;
    if(AnimFrame < reloadEndFrame)
       return RSTAGE_MAINREL;
    if(AnimFrame < reloadChargeEndFrame && bHasChargePhase)
       return RSTAGE_POSTREL;
    return RSTAGE_TRASH;
}
// Returns next magazine reload stage
simulated function ERelStage GetNextReloadStage(ERelStage curr){
    local byte i;
    i = curr;
    i ++;
    curr = ERelStage(i);
    if(curr == RSTAGE_POSTREL && !bHasChargePhase)
       curr = RSTAGE_TRASH;
    return curr;
}
// Function that goes between given 'prev' and 'next' stages by passing every intermediate stage and calling 'ReloadChangedStage'
simulated function GoThroughStages(ERelStage prev, ERelStage next){
    local ERelStage theEnum, limitStage;
    
    if(prev < next || next == RSTAGE_NONE){
       theEnum = prev;
       if(next == RSTAGE_NONE)
           limitStage = RSTAGE_TRASH;
       else
           limitStage = next;
       while(theEnum < limitStage){
           theEnum = GetNextReloadStage(theEnum);
           ReloadChangedStage(currentRelStage, theEnum);
           currentRelStage = theEnum;
       }
    }
    if(prev > next){
       ReloadChangedStage(prev, next);
       currentRelStage = next;
    }
}
simulated function GoThroughSubStages(optional bool bReloadEnded){
    local float AnimFrame;
    AnimFrame = GetCurrentAnimFrame();
    // Conditions: 1. Is this valid stage?
    // 2, 3. Can we even load more ammo?
    while(subReloadStage < reloadStages.Length && MagAmmoRemainingClient < MagCapacity && AmmoAmount(0) - MagAmmoRemainingClient > 0)
       if(bReloadEnded || AnimFrame > reloadStages[subReloadStage]){
           AddReloadedAmmo();
           subReloadStage ++;
       }
       else break;
    // If reload hasn't ended, we can only load one more shell, but aren't yet at animation's end - scroll animation
    // 'subReloadStage' shouldn't be zero at this point, but just in case check
    // During reload client dictates size of the magazine
    if(subReloadStage > 0 && !bReloadEnded && subReloadStage != reloadStages.Length && (MagAmmoRemainingClient >= MagCapacity || MagAmmoRemainingClient - AmmoAmount(0) >= 0)){
       if(alwaysPlayAnimEnd){
           AnimFrame = reloadStages[reloadStages.Length - 1] + AnimFrame - reloadStages[subReloadStage - 1];
           ScrollAnim(AnimFrame);    // Current animation position - previous ammo load position
       }
       else
           PlayIdle();
       subReloadStage = reloadStages.Length - 1;
    }
}
//Auzilary unction for easy initial generation of sub reload stages for single reload
simulated function GenerateReloadStages(int stagesAmount, int framesAmount, int firstLoadFrame, int loadDelta){
    local int i;
    local int frame;
    local float convFrame;
    reloadStages.Length = 0;
    frame = firstLoadFrame;
    for(i = 0;i < stagesAmount;i ++){
       // Next load time
       convFrame = float(frame) / float(framesAmount);
       reloadStages[reloadStages.Length] = convFrame;
       // Shift to the next one
       frame += loadDelta;
    }
}
simulated function HideMagazine(bool bHide){
    if(magazineBone == '')
       return;
    if(bHide)
       SetBoneScale(0, 0.0, magazineBone);
    else
       SetBoneScale(0, 1.0, magazineBone);
}
simulated function float GetCurrentAnimFrame(){
    local name SeqName;
    local float AnimFrame, AnimRate;
    GetAnimParams(0, SeqName, AnimFrame, AnimRate);
    return AnimFrame;
}
simulated function BringUp(optional Weapon PrevWeapon){
    // Change HUD icons if necessary
    if(Role < ROLE_Authority){
       if(bChangeClipIcon && hudClipTexture != none)
           HUDKillingFloor(NicePlayerController(instigator.controller).myHUD).ClipsIcon.WidgetTexture = hudClipTexture;
       else
           HUDKillingFloor(NicePlayerController(instigator.controller).myHUD).ClipsIcon.WidgetTexture =
               class'ScrnHUD'.default.ClipsIcon.WidgetTexture;
       if(bChangeBulletsIcon && hudBulletsTexture != none)
           HUDKillingFloor(NicePlayerController(instigator.controller).myHUD).BulletsInClipIcon.WidgetTexture =
               hudBulletsTexture;
       else
           HUDKillingFloor(NicePlayerController(instigator.controller).myHUD).BulletsInClipIcon.WidgetTexture =
               class'ScrnHUD'.default.BulletsInClipIcon.WidgetTexture;
       if(bChangeSecondaryIcon && hudSecondaryTexture != none)
           HUDKillingFloor(NicePlayerController(instigator.controller).myHUD).SecondaryClipsIcon.WidgetTexture =
               hudSecondaryTexture;
       else
           HUDKillingFloor(NicePlayerController(instigator.controller).myHUD).SecondaryClipsIcon.WidgetTexture =
               class'ScrnHUD'.default.SecondaryClipsIcon.WidgetTexture;
    }
    HideMagazine(bMagazineOut);
    super.BringUp(PrevWeapon);
    ApplyLaserState();
}
function ServerSetCharging(bool bNewNeedToCharge){
    bNeedToCharge = bNewNeedToCharge;
}
// Function that's supposed to return current amount of ammo that's used for auto reload for this weapon
simulated function int AutoReloadAmmo(){
    if(FireModeClass[1] == class'KFMod.NoFire')
       return AmmoAmount(0);
    else
       return AmmoAmount(1);
}
simulated function int GetMagazineAmmo(){
    if(Role < ROLE_Authority)
       return MagAmmoRemainingClient;
    else
       return MagAmmoRemaining;
}
simulated function bool AllowReload(){
    local int actualMagSize;
    actualMagSize = GetMagazineAmmo();
    if(bHasChargePhase && bRoundInChamber)
       actualMagSize --;
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);
    if(FireMode[0].IsFiring() || FireMode[1].IsFiring() ||
       bIsReloading || IsMagazineFull() ||
       ClientState == WS_BringUp )
       return false;
    return true;
}
simulated function bool IsMagazineFull(){
    local int totalMagSize, actualMagSize;
    totalMagSize = GetMagazineAmmo();
    actualMagSize = totalMagSize;
    if(bHasChargePhase && bRoundInChamber)
       actualMagSize --;
    return (actualMagSize >= MagCapacity || totalMagSize >= AmmoAmount(0));
}
exec function ReloadMeNow(){
    local NicePlayerController nicePlayer;
    nicePlayer = NicePlayerController(Instigator.Controller);
    if(nicePlayer != none && nicePlayer.bFlagUseServerReload)
       ClientReloadMeNow();
}
simulated function float GetCurrentReloadMult(){
    local float ReloadMulti;
    local NiceHumanPawn nicePawn;
    local NicePlayerController nicePlayer;
    local class<NiceVeterancyTypes> niceVet;
    nicePawn = NiceHumanPawn(Instigator);
    nicePlayer = NicePlayerController(Instigator.Controller);
    if(nicePawn != none)
       niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(nicePawn.PlayerReplicationInfo);
    if(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none)
       ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
    else
       ReloadMulti = 1.0;
    if(bGiveObsessiveBonus)
       ReloadMulti *= class'NiceSkillSupportObsessive'.default.reloadBonus;
    // Active reload speedup
    if(activeReloadState == ACTR_SUCCESS)
       ReloadMulti *= activeSpeedup;
    else if(activeReloadState == ACTR_FAIL)
           ReloadMulti *= activeSlowdown;
    else if(bCanActiveReload && reloadType == RTYPE_SINGLE && subReloadStage == 0)
       ReloadMulti *= activeSpeedup;
    if(nicePlayer != none && niceVet.static.hasSkill(nicePlayer, class'NiceSkillCommandoZEDProfessional'))
       ReloadMulti /= (Level.TimeDilation / 1.1);
    if(bAutoReload && bAutoReloadRateApplied)
       ReloadMulti *= autoReloadSpeedModifier;
    return ReloadMulti;
}
function ServerRequestAutoReload(){
    ClientReloadMeNow();
}
simulated function AttemptActiveReload(optional bool bForce){
    local float windowStart;
    local float windowLenght;
    local name SeqName;
    local float AnimFrame, AnimRate;
    local NiceHumanPawn nicePawn;
    local class<NiceVeterancyTypes> niceVet;
    // Need this for skill check
    nicePawn = NiceHumanPawn(Instigator);
    if(nicePawn != none)
       niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(nicePawn.PlayerReplicationInfo);
    // Does nothing if we aren't even reloading, this is auto reload, we've already succeeded/failed or we'll auto succeed anyway
    if(!bIsReloading || !bCanActiveReload || bAutoReload || activeReloadState == ACTR_SUCCESS || activeReloadState == ACTR_FAIL)
       return;
    // Find starting frame and length of the active reload window (and declare fail if single reload is still in the first sub-stage)
    windowStart = -1.0;
    if(reloadType == RTYPE_MAG){
       windowStart = reloadPreEndFrame;
       windowLenght = activeWindow;
    }
    else if(reloadType == RTYPE_SINGLE){
       // Too early!
       if(subReloadStage <= 0){
           activeReloadState = ACTR_FAIL;
           UpdateReloadRate();
           return;
       }
       windowStart = reloadStages[subReloadStage - 1];
       windowLenght = activeWindow / MagCapacity;
    }
    // Something went wrong and active reload is inapplicable
    if(windowStart < 0)
       return;
    GetAnimParams(0, SeqName, AnimFrame, AnimRate);
    if(windowStart <= AnimFrame && AnimFrame <= windowStart + windowLenght || bForce)
       activeReloadState = ACTR_SUCCESS;
    else
       activeReloadState = ACTR_FAIL;
    UpdateReloadRate();
}
// Function that's called when client tries to use flashlight on a weapon
simulated function SecondDoToggle(){}
simulated function ClientReload(){}
simulated function bool InterruptReload(){
    return false;
}
function ServerStopFire(byte Mode){
    super(BaseKFWeapon).ServerStopFire(Mode);
}
simulated function ClientTryPendingWeapon(){
    if(Instigator.PendingWeapon != none && Instigator.PendingWeapon != self)
       Instigator.Controller.ClientSwitchToBestWeapon();
}
simulated function AnimEnd(int channel){
    local name anim;
    local float frame, rate;
    GetAnimParams(0, anim, frame, rate);
    if(!FireMode[0].IsInState('FireLoop')){
       GetAnimParams(0, anim, frame, rate);
       if(ClientState == WS_ReadyToFire)
           if((FireMode[0] == none || !FireMode[0].bIsFiring) && (FireMode[1] == none || !FireMode[1].bIsFiring))
               PlayIdle();
    }
    else if(ClientState == WS_ReadyToFire){
       if(anim == FireMode[0].FireAnim && HasAnim(FireMode[0].FireEndAnim))
           PlayAnim(FireMode[0].FireEndAnim, FireMode[0].FireEndAnimRate, 0.0);
       else if (anim== FireMode[1].FireAnim && HasAnim(FireMode[1].FireEndAnim))
           PlayAnim(FireMode[1].FireEndAnim, FireMode[1].FireEndAnimRate, 0.0);
       else if ((FireMode[0] == none || !FireMode[0].bIsFiring) && (FireMode[1] == none || !FireMode[1].bIsFiring) && !bAutoReloadPaused)
           PlayIdle();
    }
}
simulated function bool StartFire(int Mode){
    if(NiceHighROFFire(FireMode[Mode]) == none || FireMode[Mode].bWaitForRelease)
       return super.StartFire(Mode);
    if(!super.StartFire(Mode))
      return false;
    if(AmmoAmount(0) <= 0)
       return false;
    AnimStopLooping();
    if(!FireMode[Mode].IsInState('FireLoop') && (AmmoAmount(0) > 0)){
       FireMode[Mode].StartFiring();
       return true;
    }
    else
       return false;
    return true;
}
simulated event OnZoomOutFinished(){
    local name anim;
    local float frame, rate;
    GetAnimParams(0, anim, frame, rate);
    if(!FireMode[0].IsInState('FireLoop'))
       super.OnZoomOutFinished();
    else if(ClientState == WS_ReadyToFire){
       // Play the regular idle anim when we're finished zooming out
       if(anim == IdleAimAnim)
           PlayIdle();
       // Switch looping fire anims if we switched to/from zoomed
       else if( FireMode[0].IsInState('FireLoop') && anim == 'Fire_Iron_Loop')
           LoopAnim('Fire_Loop', FireMode[0].FireLoopAnimRate, FireMode[0].TweenTime);
    }
}
simulated event OnZoomInFinished(){
    local name anim;
    local float frame, rate;
    GetAnimParams(0, anim, frame, rate);
    if(!FireMode[0].IsInState('FireLoop'))
       super.OnZoomInFinished();
    else if(ClientState == WS_ReadyToFire){
       // Play the iron idle anim when we're finished zooming in
       if(anim == IdleAnim)
          PlayIdle();
       // Switch looping fire anims if we switched to/from zoomed
       else if( FireMode[0].IsInState('FireLoop') && anim == 'Fire_Loop' )
           LoopAnim('Fire_Iron_Loop', FireMode[0].FireLoopAnimRate, FireMode[0].TweenTime);
    }
}
// Some functions reloaded to force update of magazine size on client's side
function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned){
    super.GiveAmmo(m, WP, bJustSpawned);
    ClientSetMagSize(MagAmmoRemaining, bRoundInChamber);
}
simulated function GiveTo(Pawn other, optional Pickup Pickup){
    local int               actualMagSize;
    local NiceWeaponPickup  niceWeapPickup;
    local NicePlainData.Data  dummyData;
    niceWeapPickup = NiceWeaponPickup(Pickup);
    if(niceWeapPickup != none)
       SetNiceData(niceWeapPickup.GetNiceData(), NiceHumanPawn(other));
    else
       SetNiceData(dummyData, NiceHumanPawn(other));
    if(Role == ROLE_Authority){
       UpdateMagCapacity(other.PlayerReplicationInfo);

       if(NiceWeaponPickup(Pickup) != none)
           actualMagSize = NiceWeaponPickup(Pickup).MagAmmoRemaining;
       if(bRoundInChamber && actualMagSize > 0)
           actualMagSize --;
       if(NiceWeaponPickup(Pickup) != none && Pickup.bDropped)
           actualMagSize = Clamp(actualMagSize, 0, MagCapacity);
       else
           actualMagSize = MagCapacity;
       MagAmmoRemaining = actualMagSize;
       if(bRoundInChamber)
           MagAmmoRemaining ++;
       super(BaseKFWeapon).GiveTo(other, Pickup);
       ClientSetMagSize(MagAmmoRemaining, bRoundInChamber);
    }
}
function NicePlainData.Data GetNiceData(){
    local NicePlainData.Data transferData;
    if(LaserType > 0)
       class'NicePlainData'.static.SetInt(transferData, "LaserType", int(LaserType));
    class'NicePlainData'.static.SetBool(transferData, "ChamberedRound", bRoundInChamber);
    class'NicePlainData'.static.SetInt(transferData, "ChargeAmount", secondaryCharge);
    return transferData;
}
function SetNiceData(NicePlainData.Data transferData, optional NiceHumanPawn newOwner){
    local int newLaserType;
    newLaserType = class'NicePlainData'.static.GetInt(transferData, "LaserType", -1);
    if(newLaserType >= 0)
       ClientSetLaserType(byte(newLaserType));
    bRoundInChamber = class'NicePlainData'.static.GetBool(transferData, "ChamberedRound", false);
    secondaryCharge = class'NicePlainData'.static.GetInt(transferData, "ChargeAmount", 1);
    ClientSetSndCharge(secondaryCharge);
}
simulated function ApplyLaserState(){
    bLaserActive = LaserType > 0;
    if(Role < ROLE_Authority)
       ServerSetLaserType(LaserType);
    if(NiceAttachment(ThirdPersonActor) != none)
       NiceAttachment(ThirdPersonActor).SetLaserType(LaserType);
    
    if(!Instigator.IsLocallyControlled())
       return;
    
    if(bLaserActive){
       if(LaserDot == none)
           LaserDot = Spawn(LaserDotClass, self);
       LaserDot.SetLaserType(LaserType);
       if(altLaserAttachmentBone != ''){
           if(altLaserDot == none)
               altLaserDot = Spawn(LaserDotClass, self);
           altLaserDot.SetLaserType(LaserType);
       }
       //spawn 1-st person laser attachment for weapon owner
       if(LaserAttachment == none){
           SetBoneRotation(LaserAttachmentBone, LaserAttachmentRotation);
           LaserAttachment = Spawn(LaserAttachmentClass,,,,);
           AttachToBone(LaserAttachment, LaserAttachmentBone);
           if(LaserAttachment != none)
               LaserAttachment.SetRelativeLocation(LaserAttachmentOffset);
       }
       if(altLaserAttachment == none && altLaserAttachmentBone != ''){
           SetBoneRotation(altLaserAttachmentBone, altLaserAttachmentRotation);
           altLaserAttachment = Spawn(LaserAttachmentClass,,,,);
           AttachToBone(altLaserAttachment, altLaserAttachmentBone);
           if(altLaserAttachment != none)
               altLaserAttachment.SetRelativeLocation(altLaserAttachmentOffset);
       }
       ConstantColor'ScrnTex.Laser.LaserColor'.Color = LaserDot.GetLaserColor();
       LaserAttachment.bHidden = false;
       altLaserAttachment.bHidden = false;
    }
    else{
       if(LaserAttachment != none)
           LaserAttachment.bHidden = true;
       if(altLaserAttachment != none)
           altLaserAttachment.bHidden = true;
       if(LaserDot != none)
           LaserDot.Destroy();
       if(altLaserDot != none)
           altLaserDot.Destroy();
    }
}
simulated function ToggleLaser(){
    if(!Instigator.IsLocallyControlled()) 
       return;
    // Will redo this bit later, but so far it'll have to do
    if(LaserType == 0)
       LaserType = 1;
    else if(LaserType == 1)
       LaserType = 4;
    else if(LaserType == 4)
       LaserType = 2;
    else
       LaserType = 0;
    ApplyLaserState();
}
simulated function TurnOffLaser(){
    if(!Instigator.IsLocallyControlled())
       return;
    if(Role < ROLE_Authority)
       ServerSetLaserType(0);
    bLaserActive = false;
    if(LaserAttachment != none)
       LaserAttachment.bHidden = true;
    if(altLaserAttachment != none)
       altLaserAttachment.bHidden = true;
    if(LaserDot != none)
       LaserDot.Destroy();
    if(altLaserDot != none)
       altLaserDot.Destroy();
}
function ServerSetLaserType(byte NewLaserType){
    LaserType = NewLaserType;
    bLaserActive = NewLaserType > 0; 
    if(NiceAttachment(ThirdPersonActor) != none)
       NiceAttachment(ThirdPersonActor).SetLaserType(LaserType);   
}
simulated function ClientSetLaserType(byte NewLaserType){
    LaserType = NewLaserType;
    bLaserActive = NewLaserType > 0; 
    ApplyLaserState();
}
simulated function NiceFire GetMainFire(){
    return NiceFire(FireMode[0]);
}
function ServerSetSndCharge(int newCharge){
    secondaryCharge = newCharge;
}
simulated function ClientSetSndCharge(int newCharge){
    secondaryCharge = newCharge;
}
simulated function RenderOverlays(Canvas Canvas){
    local int i;
    local Vector StartTrace, EndTrace;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local vector X,Y,Z;
    local coords C;
    local array<Actor> HitActors;
    if(Instigator == none)
       return;
    if(Instigator.Controller != none)
       Hand = Instigator.Controller.Handedness;
    if((Hand < -1.0) || (Hand > 1.0))
       return;
    for(i = 0; i < NUM_FIRE_MODES;++ i)
       if(FireMode[i] != none)
           FireMode[i].DrawMuzzleFlash(Canvas);
    SetLocation(Instigator.Location + Instigator.CalcDrawOffset(self));
    SetRotation(Instigator.GetViewRotation() + ZoomRotInterp);
    // Handle drawing the laser dots
    if(LaserDot != none){
       if(bIsReloading || bAllowFreeDot){
           C = GetBoneCoords(LaserAttachmentBone);
           X = C.XAxis;
           Y = C.YAxis;
           Z = C.ZAxis;
       }
       else 
           GetViewAxes(X, Y, Z);

       StartTrace = Instigator.Location + Instigator.EyePosition();
       EndTrace = StartTrace + 65535 * X;

       while(true){
           Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
           if(ROBulletWhipAttachment(Other) != none){
               HitActors[HitActors.Length] = Other;
               Other.SetCollision(false);
               StartTrace = HitLocation + X;
           }
           else{
               if(other != none && Other != Instigator && Other.Base != Instigator)
                   EndBeamEffect = HitLocation;
               else
                   EndBeamEffect = EndTrace;
               break;
           }
       }
       // restore collision
       for(i = 0; i<HitActors.Length;++ i)
           HitActors[i].SetCollision(true);

       LaserDot.SetLocation(EndBeamEffect - X*LaserDot.ProjectorPullback);

       if(Pawn(Other) != none){
           LaserDot.SetRotation(Rotator(X));
           LaserDot.SetDrawScale(LaserDot.default.DrawScale * 0.5);
       }
       else if(HitNormal == vect(0,0,0)){
           LaserDot.SetRotation(Rotator(-X));
           LaserDot.SetDrawScale(LaserDot.default.DrawScale);
       }
       else{
           LaserDot.SetRotation(Rotator(-HitNormal));
           LaserDot.SetDrawScale(LaserDot.default.DrawScale);
       }
    }
    if(altLaserDot != none){
       if(bIsReloading || bAllowFreeDot){
           C = GetBoneCoords(altLaserAttachmentBone);
           X = C.XAxis;
           Y = C.YAxis;
           Z = C.ZAxis;
       }
       else 
           GetViewAxes(X, Y, Z);

       StartTrace = Instigator.Location + Instigator.EyePosition();
       EndTrace = StartTrace + 65535 * X;

       while(true){
           Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
           if(ROBulletWhipAttachment(Other) != none){
               HitActors[HitActors.Length] = Other;
               Other.SetCollision(false);
               StartTrace = HitLocation + X;
           }
           else{
               if(other != none && Other != Instigator && Other.Base != Instigator)
                   EndBeamEffect = HitLocation;
               else
                   EndBeamEffect = EndTrace;
               break;
           }
       }
       // restore collision
       for(i = 0; i<HitActors.Length;++ i)
           HitActors[i].SetCollision(true);

       altLaserDot.SetLocation(EndBeamEffect - X*altLaserDot.ProjectorPullback);

       if(Pawn(Other) != none){
           altLaserDot.SetRotation(Rotator(X));
           altLaserDot.SetDrawScale(altLaserDot.default.DrawScale * 0.5);
       }
       else if(HitNormal == vect(0,0,0)){
           altLaserDot.SetRotation(Rotator(-X));
           altLaserDot.SetDrawScale(altLaserDot.default.DrawScale);
       }
       else{
           altLaserDot.SetRotation(Rotator(-HitNormal));
           altLaserDot.SetDrawScale(altLaserDot.default.DrawScale);
       }
    }
    bDrawingFirstPerson = true;
    Canvas.DrawActor(self, false, false, DisplayFOV);
    bDrawingFirstPerson = false;
}
simulated function ZoomIn(bool bAnimateTransition){
    default.ZoomTime    = default.recordedZoomTime;
    PlayerIronSightFOV  = default.PlayerIronSightFOV;
    if(class'NiceVeterancyTypes'.static.hasSkill(NicePlayerController(Instigator.Controller), class'NiceSkillSharpshooterHardWork')){
       default.ZoomTime *= class'NiceSkillSharpshooterHardWork'.default.zoomSpeedBonus;
       if(instigator != none && instigator.bIsCrouched)
           PlayerIronSightFOV *= class'NiceSkillSharpshooterHardWork'.default.zoomBonus;
    }
    super.ZoomIn(bAnimateTransition);
}
simulated function ZoomOut(bool bAnimateTransition){
    default.ZoomTime    = default.recordedZoomTime;
    PlayerIronSightFOV  = default.PlayerIronSightFOV;
    if(class'NiceVeterancyTypes'.static.hasSkill(NicePlayerController(Instigator.Controller), class'NiceSkillSharpshooterHardWork')){
       default.ZoomTime *= class'NiceSkillSharpshooterHardWork'.default.zoomSpeedBonus;
       PlayerIronSightFOV *= class'NiceSkillSharpshooterHardWork'.default.zoomBonus;
    }
    super.ZoomOut(bAnimateTransition);
}
simulated function Destroyed(){
    if(LaserDot != none)
       LaserDot.Destroy();
    if(altLaserDot != none)
       altLaserDot.Destroy();
    if(LaserAttachment != none)
       LaserAttachment.Destroy();
    if(altLaserAttachment != none)
       altLaserAttachment.Destroy();
    super(KFWeapon).Destroyed();
}

defaultproperties
{
     recordedZoomTime=-1.000000
     SecondaryCharge=1
     LaserAttachmentClass=Class'ScrnBalanceSrv.ScrnLaserAttachmentFirstPerson'
     LaserDotClass=Class'ScrnBalanceSrv.ScrnLocalLaserDot'
     LaserAttachmentBone="LightBone"
     MagazineBone="Magazine"
     bHasChargePhase=True
     autoReloadSpeedModifier=1.000000
     bCanActiveReload=True
     activeSlowdown=0.850000
     activeSpeedup=1.150000
     activeWindow=0.060000
     bModeZeroCanDryFire=True
}
