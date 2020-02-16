 class NicePack extends Mutator
    dependson(NiceStorageServer)
    config(NicePack);
// Should we scale health off all zeds to 6-player level?
var config bool     bScaleZedHealth;
// Should we replace all pickups with their Nice versions when available?
var config bool     bReplacePickups;
// Settings for initial trader
var config bool     bInitialTrader;         // Use initial trader system?
var config bool     bStillDuringInitTrader; // Force players to stand still during initial trader
var config int      initialTraderTime;      // How much time should be allowed for initial trade?
// Progressive dosh config
var config bool     bUseProgresiveCash;                                                                 // Use progressive dosh system?
var config int      startupCashBeg, startupCashNormal, startupCashHard, startupCashSui, startupCashHOE; // Cash given to player for joining for the first time on current map
var config int      waveCashBeg, waveCashNormal, waveCashHard, waveCashSui, waveCashHOE;                // Cash that should be given to players for each wave they've skipped
// Experience-conversion controlling variables
var config bool     bConvertExp;                // Should we even convert old exp into a new one?
var config float    vetFieldMedicExpCost;       // Amount of exp per HP healed
var config float    vetFieldMedicDmgExpCost;    // Amount of exp per 1 medic damage
var config float    vetSharpHeadshotExpCost;    // Amount of exp per head-shot
var config float    vetSupportDamageExpCost;    // Amount of exp per 1 shotgun damage
var config float    vetCommandoDamageExpCost;   // Amount of exp per 1 assault rifle damage
var config float    vetDemoDamageExpCost;       // Amount of exp per 1 explosive damage
var config float    vetZerkDamageExpCost;       // Amount of exp per 1 melee damage
var config float    vetHeavyMGDamageExpCost;    // Amount of exp per 1 heavy machine gun damage
var config float    vetGunslingerKillExpCost;   // Amount of exp per 1 assault rifle damage
// Allow changing skills at any time
var config bool     bAlwaysAllowSkillChange;
// Variables for controlling how zeds spawn
var config float    minSpawnRate, maxSpawnRate; // Minimum and maximum allowed spawn rate
var config int      minimalSpawnDistance;       // Minimal distance between ZedVolume and players that should allow for zeds to spawn
// FF voting - related settings
var config bool     bOneFFIncOnly;              // Option that only allows one FF increase per game
var config bool     bNoLateFFIncrease;          // Disables FF increase through voting after 1st wave
// Configuration variables that store whether or not to replace the specimen with it's mean counterpart
var config bool     bReplaceCrawler, bReplaceStalker, bReplaceClot, bReplaceGorefast, bReplaceBloat, bReplaceSiren, bReplaceHusk, bReplaceScrake, bReplaceFleshpound;
var config int      bigZedMinHealth;            // If zed's base Health >= this value, zed counts as Big
var config int      mediumZedMinHealth;  

var int     maxPlayersInGame;
var bool    bAppliedPlayersMult;
   
var bool bSpawnRateEnforced;    // Set to true after spawn rate was altered
// 'Adrenaline junkie' zed-time extensions
var int junkieDoneGoals;        // How many times we collected enough head-shots to trigger zed-time extension
var int junkieNextGoal;         // How many head-shots we need for next zed-time extension
var int junkieDoneHeadshots;    // How many head-shot in a row was done from the start of last zed-time
var array<String> replCaps;
var bool bFFWasIncreased;
var int nextSirenScreamID;
var int stuckCounter;
// Max dead bodies among all players
var int maxDeadBodies;
var int deadBodyCounter;
var ScrnBalance ScrnMut;
var ScrnGameType ScrnGT;
var NiceGameType NiceGT;
var NiceTSCGame NiceTSC;
var NicePack Mut;
var NiceRules GameRules;
var NiceStorageServer serverStorage;
var bool bClientLinkEstablished;
var bool interactionAdded;
var bool bIsPreGame;
var bool bIsTraderTime;
var bool bWasZedTime;
var array<KFHumanPawn>  recordedHumanPawns;
struct PlayerRecord{
    var string  steamID;
    var bool    bHasSpawned;
    var int     lastCashWave;   //Last wave in which player either participated, or for which he received cash
    var int     kills, assists, deaths;
};
var array<PlayerRecord> PlayerDatabase;
// Zed hardcore level record
struct ZedRecord{
    var string ZedName;
    var class<NiceMonster> ZedType;
    var class<NiceMonster> MeanZedType;
    var bool bAlreadySpawned;
    var bool bMeanAlreadySpawned;
    var float HL;
    var float MeanHLBonus;
    var bool bNeedsReplacement;
};
var int lastStandardZed;
var array<ZedRecord> ZedDatabase;
struct NicePickupReplacement{
    var class<Pickup> vanillaClass;
    var class<Pickup> scrnClass;
    var class<Pickup> newClass;
};
var array<NicePickupReplacement> pickupReplaceArray;
struct CounterDisplay{
    var string              cName;
    var Texture             icon;
    var int                 value;
    var bool                bShowZeroValue;
    var class<NiceSkill>    ownerSkill;
};
var array<CounterDisplay> niceCounterSet;
struct WeaponProgressDisplay{
    var class<NiceWeapon>   weapClass;
    var float               progress;
    var bool                bShowCounter;
    var int                 counter;
};
var array<WeaponProgressDisplay> niceWeapProgressSet;
// Map Description array
var const array<localized string> NiceUniversalDescriptions[4];
// Replication of config between player and server
var int SrvFlags;
var array<NicePlayerController> playersList;
var NicePathBuilder globalPathBuilder;

replication{
    reliable if(Role == ROLE_Authority)
       SrvFlags, bIsPreGame, junkieDoneHeadshots, junkieNextGoal;
}

static function NicePathBuilder GetPathBuilder(){
    if(default.globalPathBuilder == none)
        default.globalPathBuilder = new() class'NicePathBuilder';
    return default.globalPathBuilder;
}

static final function NiceStorageBase GetStorage(LevelInfo level){
    local NicePlayerController localPlayer;
    if(default.serverStorage != none) return default.serverStorage;
    localPlayer = NicePlayerController(level.GetLocalPlayerController());
    if(localPlayer != none)
        return localPlayer.storageClient;
    return none;
}

static final function NicePack Myself(LevelInfo Level){
    local Mutator M;
    local NicePack NicePackMutator;
    if(default.Mut != none)
       return default.Mut; 
    // server-side
    if(Level != none && Level.Game != none){
       for(M = Level.Game.BaseMutator;M != none;M = M.NextMutator){
           NicePackMutator = NicePack(M);
           if(NicePackMutator != none){
               default.Mut = NicePackMutator;
               return NicePackMutator;
           }
       }
    }
    // client-side
    foreach Level.DynamicActors(class'NicePack', NicePackMutator){
       default.Mut = NicePackMutator;
       return NicePackMutator;
    }
    return none;
}
function PreBeginPlay()
{
    local ZombieVolume ZV;
    super.PreBeginPlay();
    foreach AllActors(Class'ZombieVolume', ZV)
       ZV.MinDistanceToPlayer = minimalSpawnDistance;
    AddToPackageMap("NicePackA.ukx");
    AddToPackageMap("NicePackSM.usx");
    AddToPackageMap("NicePackSnd.uax");
    AddToPackageMap("NicePackT.utx");
}
simulated function PostBeginPlay(){
    local int i;
    local ZedRecord record;
    local ScrnVotingHandlerMut VH;
    local MeanVoting VO;
    local NiceFFVoting FFVO;
    super.PostBeginPlay();
    class'NicePack'.default.Mut = self;
    // Gun skins
    /*class'NicePack.NiceMaulerPickup'.default.VariantClasses[class'NicePack.NiceMaulerPickup'.default.VariantClasses.length] = class'ScrnBalanceSrv.ScrnSPSniperPickup';
    class'NicePack.NiceDeaglePickup'.default.VariantClasses[class'NicePack.NiceDeaglePickup'.default.VariantClasses.length] = class'NicePack.SkinExecutionerPickup';
    class'NicePack.NiceDualDeaglePickup'.default.VariantClasses[class'NicePack.NiceDualDeaglePickup'.default.VariantClasses.length] = class'NicePack.SkinDualExecutionerPickup';
    class'NicePack.NiceMagnumPickup'.default.VariantClasses[class'NicePack.NiceMagnumPickup'.default.VariantClasses.length] = class'NicePack.SkinCowboyMagnumPickup';
    class'NicePack.NiceDualMagnumPickup'.default.VariantClasses[class'NicePack.NiceDualMagnumPickup'.default.VariantClasses.length] = class'NicePack.SkinDualCowboyMagnumPickup';
    class'NicePack.NiceWinchesterPickup'.default.VariantClasses[class'NicePack.NiceWinchesterPickup'.default.VariantClasses.length] = class'NicePack.SkinRetroLARPickup';
    class'NicePack.NiceM14EBRPickup'.default.VariantClasses[class'NicePack.NiceM14EBRPickup'.default.VariantClasses.length] = class'NicePack.SkinM14EBR2ProPickup';
    class'ScrnBalanceSrv.ScrnKrissMPickup'.default.VariantClasses[class'ScrnBalanceSrv.ScrnKrissMPickup'.default.VariantClasses.length] = class'NicePack.SkinGoldenKrissPickup';
    class'NicePack.NiceSCARMK17Pickup'.default.VariantClasses[class'NicePack.NiceSCARMK17Pickup'.default.VariantClasses.length] = class'NicePack.SkinCamoSCARMK17Pickup';*/
    // Abilities
    class'NiceAbilityManager'.default.events.static.AddAdapter(class'NiceSharpshooterAbilitiesAdapter', level);
    SetTimer(0.25, true);
    if(Role < ROLE_Authority)
       return;
    //  Create sync node
    serverStorage = new class'NicePack.NiceStorageServer';
    default.serverStorage = serverStorage;
    serverStorage.events.static.AddAdapter(class'NiceRemoteDataAdapter', Level);
    // Find game type and ScrN mutator
    ScrnGT = ScrnGameType(Level.Game); 
    NiceGT = NiceGameType(Level.Game);
    NiceTSC = NiceTSCGame(Level.Game);
    if(ScrnGT == none){
       Log("ERROR: Wrong GameType (requires at least ScrnGameType)", Class.Outer.Name);
       Destroy();
       return;
    }
    // Skills menu
    ScrnGT.LoginMenuClass = string(Class'NicePack.NiceInvasionLoginMenu');
    if(NiceGT != none)
       NiceGT.RegisterMutator(Self);
    if(NiceTSC != none)
       NiceTSC.RegisterMutator(Self);
    ScrnMut = ScrnGT.ScrnBalanceMut;
    if(bReplacePickups)
       ScrnMut.bReplacePickups = false;
    // Replication of some variables
    SetReplicationData();
    // New player controller class
    if(!ClassIsChildOf(ScrnGT.PlayerControllerClass, class'NicePack.NicePlayerController')){
       ScrnGT.PlayerControllerClass = class'NicePack.NicePlayerController';
       ScrnGT.PlayerControllerClassName = string(Class'NicePack.NicePlayerController');
    }
    // Game rules
    GameRules = Spawn(Class'NicePack.NiceRules', self);
    // -- Lower starting HL
    ScrnMut.GameRules.HardcoreLevel -= 7;
    ScrnMut.GameRules.HardcoreLevelFloat -= 7;
    // -- Fill-in zed info
    i = 0;
    // - Clot
    record.ZedName = "Clot";
    record.ZedType = class'NicePack.NiceZombieClot';
    record.MeanZedType = class'NicePack.MeanZombieClot';
    record.HL = 0.0;
    record.MeanHLBonus = 0.5;
    record.bNeedsReplacement = bReplaceClot;
    ZedDatabase[i++] = record;
    // - Crawler
    record.ZedName = "Crawler";
    record.ZedType = class'NicePack.NiceZombieCrawler';
    record.MeanZedType = class'NicePack.MeanZombieCrawler';
    record.HL = 0.5;
    record.MeanHLBonus = 1.5;
    record.bNeedsReplacement = bReplaceCrawler;
    ZedDatabase[i++] = record;
    // - Stalker
    record.ZedName = "Stalker";
    record.ZedType = class'NicePack.NiceZombieStalker';
    record.MeanZedType = class'NicePack.MeanZombieStalker';
    record.HL = 0.5;
    record.MeanHLBonus = 0.5;
    record.bNeedsReplacement = bReplaceStalker;
    ZedDatabase[i++] = record;
    // - Gorefast
    record.ZedName = "Gorefast";
    record.ZedType = class'NicePack.NiceZombieGorefast';
    record.MeanZedType = class'NicePack.MeanZombieGorefast';
    record.HL = 0.0;
    record.MeanHLBonus = 0.5;
    record.bNeedsReplacement = bReplaceGorefast;
    ZedDatabase[i++] = record;
    // - Bloat
    record.ZedName = "Bloat";
    record.ZedType = class'NicePack.NiceZombieBloat';
    record.MeanZedType = class'NicePack.MeanZombieBloat';
    record.HL = 0.0;
    record.MeanHLBonus = 0.5;
    record.bNeedsReplacement = bReplaceBloat;
    ZedDatabase[i++] = record;
    // - Siren
    record.ZedName = "Siren";
    record.ZedType = class'NicePack.NiceZombieSiren';
    record.MeanZedType = class'NicePack.MeanZombieSiren';
    record.HL = 1.0;
    record.MeanHLBonus = 1.0;
    record.bNeedsReplacement = bReplaceSiren;
    ZedDatabase[i++] = record;
    // - Husk
    record.ZedName = "Husk";
    record.ZedType = class'NicePack.NiceZombieHusk';
    record.MeanZedType = class'NicePack.MeanZombieHusk';
    record.HL = 1.0;
    record.MeanHLBonus = 1.5;
    record.bNeedsReplacement = bReplaceHusk;
    ZedDatabase[i++] = record;
    // - Scrake
    record.ZedName = "Scrake";
    record.ZedType = class'NicePack.NiceZombieScrake';
    record.MeanZedType = class'NicePack.MeanZombieScrake';
    record.HL = 1.5;
    record.MeanHLBonus = 1.5;
    record.bNeedsReplacement = bReplaceScrake;
    ZedDatabase[i++] = record;
    // - Fleshpound
    lastStandardZed = i;
    record.ZedName = "Fleshpound";
    record.ZedType = class'NicePack.NiceZombieFleshPound';
    record.MeanZedType = class'NicePack.MeanZombieFleshPound';
    record.HL = 2.5;
    record.MeanHLBonus = 1.5;
    record.bNeedsReplacement = bReplaceFleshpound;
    ZedDatabase[i++] = record;
    // - Shiver
    record.ZedName = "Shiver";
    record.ZedType = class'NicePack.NiceZombieShiver';
    record.MeanZedType = none;
    record.HL = 1;
    record.bNeedsReplacement = false;
    ZedDatabase[i++] = record;
    // - Jason
    record.ZedName = "Jason";
    record.ZedType = class'NicePack.NiceZombieJason';
    record.MeanZedType = none;
    record.HL = 1.5;
    record.bNeedsReplacement = false;
    ZedDatabase[i++] = record;
    // - Tesla Husk
    record.ZedName = "Tesla husk";
    record.ZedType = class'NicePack.NiceZombieTeslaHusk';
    record.MeanZedType = none;
    record.HL = 1.5;
    record.bNeedsReplacement = false;
    ZedDatabase[i++] = record;
    // - Brute
    record.ZedName = "Brute";
    record.ZedType = class'NicePack.NiceZombieBrute';
    record.MeanZedType = none;
    record.HL = 2;
    record.bNeedsReplacement = false;
    ZedDatabase[i++] = record;
    // - Ghost
    record.ZedName = "Ghost";
    record.ZedType = class'NicePack.NiceZombieGhost';
    record.MeanZedType = none;
    record.HL = 0.5;
    record.bNeedsReplacement = false;
    ZedDatabase[i++] = record;
    // - Sick
    record.ZedName = "Sick";
    record.ZedType = class'NicePack.NiceZombieSick';
    record.MeanZedType = none;
    record.HL = 1.0;
    record.bNeedsReplacement = false;
    ZedDatabase[i++] = record;
    // Nothing has yet spawned
    for(i = 0;i < ZedDatabase.length;i ++){
       ZedDatabase[i].bAlreadySpawned = false;
       ZedDatabase[i].bMeanAlreadySpawned = false;
    }
    // Add voting for mean zeds
    VH = class'ScrnVotingHandlerMut'.static.GetVotingHandler(Level.Game);
    if(VH == none){
       Level.Game.AddMutator(string(class'ScrnVotingHandlerMut'), false);
       VH = class'ScrnVotingHandlerMut'.static.GetVotingHandler(Level.Game);
    }
    if(VH != none){
       VO = MeanVoting(VH.AddVotingOptions(class'MeanVoting'));
       if(VO != none)
           VO.Mut = self;
       FFVO = NiceFFVoting(VH.AddVotingOptions(class'NiceFFVoting'));
       if(FFVO != none)
           FFVO.Mut = self;
    }
    else 
       log("Unable to spawn voting handler mutator", class.outer.name);
}
simulated function PostNetBeginPlay()
{
    super.PostNetBeginPlay();
    if(Role < ROLE_Authority)
       LoadReplicationData();
}
function SetReplicationData(){
    SrvFlags = 0;
    if(bInitialTrader)
       SrvFlags = SrvFlags | 0x00000001;
    if(bStillDuringInitTrader)
       SrvFlags = SrvFlags | 0x00000002;
}
simulated function LoadReplicationData(){
    if(Role == ROLE_Authority)
       return; 
    bInitialTrader          = (SrvFlags & 0x00000001) > 0;
    bStillDuringInitTrader  = (SrvFlags & 0x00000002) > 0;
}
simulated function Timer(){
    local KFHumanPawn nextPawn;
    local int currentPlayersMax;
    local Controller P;
    local NicePlayerController nicePlayer;
    // Cull excessive pawns
    if(Role < Role_AUTHORITY){
       recordedHumanPawns.Length = 0;
       foreach DynamicActors(class'KFHumanPawn', nextPawn)
           if(nextPawn != none && nextPawn.health > 0)
               recordedHumanPawns[recordedHumanPawns.Length] = nextPawn;
       return;
    }
    // Broadcast skills & record latest player controller list
    BroadcastSkills();
    playersList.length = 0;
    for(P = Level.ControllerList; P != none; P = P.nextController){
       nicePlayer = NicePlayerController(P);
       if(nicePlayer != none){
           nicePlayer.wallHitsLeft = 10;
           //nicePlayer.FreeOldStuckBullets();
           playersList[playersList.Length] = nicePlayer;
           if(nicePlayer.Pawn != none && nicePlayer.Pawn.health > 0 && !nicePlayer.PlayerReplicationInfo.bIsSpectator
               && !nicePlayer.PlayerReplicationInfo.bOnlySpectator)
               currentPlayersMax ++;
       }
    }
    maxPlayersInGame = Max(maxPlayersInGame, currentPlayersMax);
}
simulated function Tick(float Delta){
    local int i;
    local NiceInteraction niceInt;
    local NicePlayerController localPlayer;
    super.Tick(Delta);
    if(ScrnGT != none && ScrnGT.WaveCountDown <= 5)
       bIsPreGame = false;
    if(ScrnMut != none && !bSpawnRateEnforced && ScrnMut.bTickExecuted){
       bSpawnRateEnforced = true;
       ScrnMut.OriginalWaveSpawnPeriod = FMax(minSpawnRate, FMin(maxSpawnRate, ScrnMut.OriginalWaveSpawnPeriod));
    }
    localPlayer = NicePlayerController(Level.GetLocalPlayerController());
    // Check if the local PlayerController is available yet
    if(localPlayer == none)
       return;
    if( Role < Role_AUTHORITY && !bClientLinkEstablished
        && localPlayer.storageClient != none && localPlayer.remoteRI != none){
        bClientLinkEstablished = true;
        localPlayer.storageClient.remoteRI = localPlayer.remoteRI;
        localPlayer.storageClient.events.static.CallLinkEstablished();
    }
    if(localPlayer.bFlagDisplayCounters){
       for(i = 0;i < niceCounterSet.Length;i ++){
           if(niceCounterSet[i].ownerSkill == none)
               niceCounterSet[i].value = UpdateCounterValue(niceCounterSet[i].cName);
           else if(class'NiceVeterancyTypes'.static.hasSkill(localPlayer, niceCounterSet[i].ownerSkill))
               niceCounterSet[i].value = niceCounterSet[i].ownerSkill.static.
                   UpdateCounterValue(niceCounterSet[i].cName, localPlayer);
           else
               niceCounterSet[i].value = 0;
       }
    }
    // Reset tick counter for traces
    localPlayer.tracesThisTick = 0;
    // Manage resetting of effects' limits
    if(Level.TimeSeconds >= localPlayer.nextEffectsResetTime){
       localPlayer.nextEffectsResetTime = Level.TimeSeconds + 0.1;
       localPlayer.currentEffectTimeWindow ++;
       if(localPlayer.currentEffectTimeWindow >= 10)
           localPlayer.currentEffectTimeWindow = 0;
       localPlayer.effectsSpawned[localPlayer.currentEffectTimeWindow] = 0;
    }
    // Add interaction
    if(interactionAdded)
       return;
    // Actually add the interaction
    niceInt = NiceInteraction(localPlayer.Player.InteractionMaster.AddInteraction("NicePack.NiceInteraction", localPlayer.Player));
    niceInt.RegisterMutator(Self);
    interactionAdded = true;
}
simulated function bool CheckReplacement(Actor Other, out byte bSuperRelevant){
    local int i;
    local NiceMonster niceMonster;
    local NiceZombieBoss boss;
    local Controller cIt;
    local int currNumPlayers;
    local float HLBonus;
    local NicePlayerController playerContr;
    local NiceRepInfoRemoteData remoteRI;
    local NiceReplicationInfo niceRI;
    local MeanReplicationInfo meanRI;
    local PlayerReplicationInfo pri;
    // Replace loot on levels
    if(Other.class == class'KFRandomItemSpawn' || Other.class == class'ScrnBalanceSrv.ScrnRandomItemSpawn'){
       ReplaceWith(Other, "NicePack.NiceRandomItemSpawn");
       return false;
    }
    else if(Other.class == class'KFAmmoPickup' || Other.class == class'ScrnBalanceSrv.ScrnAmmoPickup') {
       ReplaceWith(Other, "NicePack.NiceAmmoPickup");
       return false;
    }
    else if(bReplacePickups && Pickup(Other) != none){
       i = FindPickupReplacementIndex(Pickup(Other));
       if (i != -1){
           ReplaceWith(Other, String(pickupReplaceArray[i].NewClass));
           return false;
       }
       return true;
    }
    // Add our replication info
    if(PlayerReplicationInfo(Other) != none && NicePlayerController(PlayerReplicationInfo(Other).Owner) != none){
       pri = PlayerReplicationInfo(Other);
       niceRI = spawn(class'NiceReplicationInfo', pri.Owner);
       niceRI.Mut = self;
       remoteRI = spawn(class'NiceRepInfoRemoteData', pri.Owner);
       meanRI = spawn(class'MeanReplicationInfo', pri.Owner);
       meanRI.ownerPRI = pri;
       playerContr = NicePlayerController(PlayerReplicationInfo(Other).Owner);
       playerContr.niceRI = niceRI;
       playerContr.remoteRI = remoteRI;
    }
    niceMonster = NiceMonster(Other);
    if(niceMonster != none){
       // Add hardcore level
       for(i = 0;i < ZedDatabase.Length;i ++){
           HLBonus = 0.0;
           if((ZedDatabase[i].MeanZedType == Other.class || ZedDatabase[i].ZedType == Other.class)
               && !ZedDatabase[i].bAlreadySpawned){
               HLBonus = ZedDatabase[i].HL;
               ZedDatabase[i].bAlreadySpawned = true;
           }
           if(ZedDatabase[i].MeanZedType == Other.class && !ZedDatabase[i].bMeanAlreadySpawned){
               HLBonus += ZedDatabase[i].MeanHLBonus;
               ZedDatabase[i].bMeanAlreadySpawned = true;
           }
           HLBonus *= (Level.Game.GameDifficulty / 7.0);
           if(HLBonus > 0.0)
               GameRules.RaiseHardcoreLevel(HLBonus, niceMonster.MenuName);
       }
    }
    // Replace zeds with a healthier ones.
    // Code taken from a scary ghost's SpecimenHPConfig
    if(!bScaleZedHealth)
       return true;
    boss = NiceZombieBoss(Other);
    if(niceMonster != none){
       for(cIt= Level.ControllerList; cIt != none; cIt= cIt.NextController)
           if(cIt.bIsPlayer && cIt.Pawn != none && cIt.Pawn.Health > 0)
               currNumPlayers++;
       if(boss == none) {
           niceMonster.Health *= hpScale(niceMonster.PlayerCountHealthScale) / niceMonster.NumPlayersHealthModifer();
           niceMonster.HealthMax = niceMonster.Health; 
           niceMonster.HeadHealth *= hpScale(niceMonster.PlayerNumHeadHealthScale) / niceMonster.NumPlayersHeadHealthModifer();
           niceMonster.HeadHealthMax = niceMonster.HeadHealth;
           if(Level.Game.NumPlayers == 1){
               niceMonster.MeleeDamage /= 0.75;
               niceMonster.ScreamDamage /= 0.75;
               niceMonster.SpinDamConst /= 0.75;
               niceMonster.SpinDamRand /= 0.75;
           }
       }
    }
    return true;
}
// returns -1, if not found
function int FindPickupReplacementIndex(Pickup item)
{
    local int i;
    for(i=0; i < pickupReplaceArray.length;i ++){
       if(pickupReplaceArray[i].vanillaClass == item.class || pickupReplaceArray[i].scrnClass == item.class) 
           return i;
    }
    return -1;
}
// Try to extend zed-time, junkie-style
function JunkieZedTimeExtend(){
    if((ScrnGT != none && !ScrnGT.bZEDTimeActive) || ScrnGT.CurrentZEDTimeDuration <= 0)
       return;
    junkieDoneHeadshots ++;
    if(junkieNextGoal <= junkieDoneHeadshots){
       junkieDoneHeadshots = 0;
       junkieDoneGoals ++;
       junkieNextGoal ++;
       ScrnGT.DramaticEvent(1.0);
    }
}
simulated function AddCounter(string cName, Texture icon, optional bool bShowZeroValue,
    optional class<NiceSkill> owner){
    local CounterDisplay newCounter;
    RemoveCounter(cName);
    newCounter.cName = cName;
    newCounter.icon = icon;
    newCounter.bShowZeroValue = bShowZeroValue;
    newCounter.ownerSkill = owner;
    niceCounterSet[niceCounterSet.Length] = newCounter;
}
simulated function RemoveCounter(string cName){
    local int i;
    local array<CounterDisplay> newCounterSet;
    for(i = 0;i < niceCounterSet.Length;i ++)
       if(niceCounterSet[i].cName != cName)
           newCounterSet[newCounterSet.Length] = niceCounterSet[i];
    niceCounterSet = newCounterSet;
}
simulated function int GetVisibleCountersAmount(){
    local int i;
    local int amount;
    for(i = 0;i < niceCounterSet.Length;i ++)
       if(niceCounterSet[i].value != 0 || niceCounterSet[i].bShowZeroValue)
           amount ++;
    return amount;
}
simulated function int UpdateCounterValue(string cName){
    return 0;
}
simulated function AddWeapProgress(class<NiceWeapon> weapClass, float progress,
    optional bool bShowCounter, optional int counter){
    local WeaponProgressDisplay newProgress;
    newProgress.weapClass = weapClass;
    newProgress.progress = progress;
    newProgress.bShowCounter = bShowCounter;
    newProgress.counter = counter;
    niceWeapProgressSet[niceWeapProgressSet.Length] = newProgress;
}
simulated function ClearWeapProgress(){
    niceWeapProgressSet.Length = 0;
}
// Gives out appropriate (for the wave he entered) amount of dosh to the player
function GiveProgressiveDosh(NicePlayerController nicePlayer){
    local int wavesPassed;
    local PlayerRecord record;
    local class<NiceVeterancyTypes> niceVet;
    // Too early to give dosh
    if(!ScrnGT.IsInState('MatchInProgress'))
       return;
    // Real spectators shouldn't be affected
    if(!nicePlayer.PlayerReplicationInfo.bOnlySpectator){
       record = FindPlayerRecord(nicePlayer.steamID64);
       if(record.lastCashWave == -1){
           nicePlayer.PlayerReplicationInfo.Score += GetStartupCash();
           record.lastCashWave = 0;
           niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(nicePlayer.PlayerReplicationInfo);
           if(niceVet != none && niceVet.default.bNewTypePerk)
               nicePlayer.PlayerReplicationInfo.Score += 100;
       }
       wavesPassed = ScrnGT.WaveNum;   // At a trader (and that's the only time this function should be called) 'WaveNum' is already a number of the next wave, so no need for '+1' here
       if(wavesPassed > record.lastCashWave)
           nicePlayer.PlayerReplicationInfo.Score += (wavesPassed - record.lastCashWave) * GetWaveCash();
       record.lastCashWave = wavesPassed;
       UpdatePlayerRecord(record);
    }
}
simulated function Mutate(string MutateString, PlayerController kfPlayer){
    local int i;
    local NicePlayerController nicePlayer;
    local NiceServerData remoteData;
    // Tokens from 'MutateString'
    local array<String> wordsArray;
    local String command, mod;
    local String white;
    // Array with command modifiers.
    // Always contains at least 10 elements, that may be empty strings if there wasn't enough modifiers.
    // Done for safe access without the need to check for bounds.
    local array<String> modArray;
    // Helpful sequence
    white = chr(27)$chr(200)$chr(200)$chr(200);
    // Transform our command into array for convenience
    wordsArray = SplitString(MutateString, " ");
    // Exit if command is empty
    if(wordsArray.Length == 0)
       return;
    // Fancier access
    command = wordsArray[0];
    if(wordsArray.Length > 1)
       mod = wordsArray[1];
    else
       mod = "";
    i = 0;
    while(i + 1 < wordsArray.Length || i < 10){
       if(i + 1 < wordsArray.Length)
           modArray[i] = wordsArray[i+1];
       else
           modArray[i] = "";
       i ++;
    }
    nicePlayer = NicePlayerController(kfPlayer);
    if(command ~= "ECHO")
       kfPlayer.ClientMessage(Mid(MutateString, 5));
    else if(command ~= "ZED" && bAlwaysAllowSkillChange)
       ScrnGT.DramaticEvent(1.0);
    else if(command ~= "SAVECFG" && nicePlayer != none)
       nicePlayer.ClientSaveConfig();
    else if(command ~= "CONFIG" && nicePlayer != none){
       if(nicePlayer.bFlagAltSwitchesModes)
           nicePlayer.ClientMessage(white$"Alt fire button will switch between single and burst modes for assault rifles");
       else
           nicePlayer.ClientMessage(white$"Alt fire button will shoot either single or burst mode for assault rifles");
       if(nicePlayer.bFlagShowHLMessages)
           nicePlayer.ClientMessage(white$"Messages about HL change will be displayed for you");
       else
           nicePlayer.ClientMessage(white$"Messages about HL change will be hidden from you");
    }
    else if(command ~= "HLMESSAGES" && nicePlayer != none){
       if(mod ~= "ON")
           nicePlayer.ServerSetHLMessages(true);
       else if(mod ~= "OFF")
           nicePlayer.ServerSetHLMessages(false);
    }
    else if(command ~= "ALTSWITCH"){
       if(mod ~= "ON")
           nicePlayer.ServerSetAltSwitchesModes(true);
       else if(mod ~= "OFF")
           nicePlayer.ServerSetAltSwitchesModes(false);
    }
    else if(command ~= "SETKEY" && nicePlayer != none){
       if(Int(mod) > 0)
           nicePlayer.ClientSetKey(Int(mod));
    }
    else if(command ~= "NICEWEAPMANAGE" && nicePlayer != none){
       if(mod ~= "ON")
           nicePlayer.ClientSetNiceWeapManagement(true);
       else if(mod ~= "OFF")
           nicePlayer.ClientSetNiceWeapManagement(false);
    }
    else if(command ~= "DEBUG" && nicePlayer != none){
       if(mod ~= "ON")
           nicePlayer.ServerSetDebug(true);
       else if(mod ~= "OFF")
           nicePlayer.ServerSetDebug(false);
    }
    else if(command ~= "LOGLINE" && nicePlayer != none)
       nicePlayer.ClientLog("UserLine:"$mod);
    else if(command ~= "CREATE"){
        nicePlayer.ClientMessage("ATTEMPT"@string(serverStorage));
        serverStorage.CreateData(modArray[0], NSP_HIGH);
        remoteData = NiceServerData(serverStorage.GetData(modArray[0]));
        remoteData.isAdminOnly = true;
        nicePlayer.ClientMessage("ATTEMPT2"@string(remoteData));
    }
    else if(command ~= "CREATELOW"){
        serverStorage.CreateData(modArray[0], NSP_LOW);
    }
    else if(command ~= "SET"){
        remoteData = NiceServerData(serverStorage.GetData(modArray[0]));
        nicePlayer.ClientMessage("SETATTEMPT"@string(remoteData));
        remoteData.SetInt(modArray[1], Int(modArray[2]));
        nicePlayer.ClientMessage("SETATTEMPT 2"@modArray[1]@modArray[2]);
    }
    else if(command ~= "PRINT"){
        nicePlayer.ClientPrint();
    }
    Super.Mutate(MutateString, kfPlayer);
}
// Event functions
// Called at the start of the match
function MatchBegan(){
}
// Called when new wave begins
function WaveStart(){
    local Controller P;
    local PlayerRecord record;
    local NiceHumanPawn nicePawn;
    local NicePlayerController nicePlayer;
    bIsPreGame = false;
    bIsTraderTime = false;
    for(P = Level.ControllerList; P != none; P = P.nextController){
       nicePlayer = NicePlayerController(P);
       if(nicePlayer != none){
           // Update records
           if(!nicePlayer.PlayerReplicationInfo.bIsSpectator && !nicePlayer.PlayerReplicationInfo.bOnlySpectator){
               record = FindPlayerRecord(nicePlayer.steamID64);
               record.lastCashWave = ScrnGT.WaveNum + 1;
               UpdatePlayerRecord(record);
           }
           // Give out armor
           nicePawn = NiceHumanPawn(nicePlayer.Pawn);
           if(nicePawn != none && nicePawn.Health > 0){
               nicePawn.bGotFreeJacket = false;
               nicePawn.getFreeJacket();
               nicePawn.bReactiveArmorUsed = false;
           }
           // Update HMG's 'Full counter' level
           if(nicePawn != none)
               nicePawn.hmgShieldLevel = class'NiceSkillEnforcerFullCounter'.default.layersAmount;
       }
    }
    if(KFGameType(Level.Game).WaveNum == KFGameType(Level.Game).FinalWave && !bAppliedPlayersMult){
       bAppliedPlayersMult = true;
       if(maxPlayersInGame == 1)
           GameRules.RaiseHardcoreLevel(ScrnMut.GameRules.HardcoreLevelFloat, "solo game");
       else if(maxPlayersInGame == 2)
           GameRules.RaiseHardcoreLevel(0.5 * ScrnMut.GameRules.HardcoreLevelFloat, "low player count");
    }
}
// Called when trader time begins (not the initial one)
simulated function TraderStart(){
    local Controller P;
    local NiceHumanPawn nicePawn;
    local NicePlayerController nicePlayer;
    bIsTraderTime = true;
    for(P = Level.ControllerList; P != none; P = P.nextController){
       nicePlayer = NicePlayerController(P);
       if(nicePlayer != none){
           nicePlayer.TryActivatePendingSkills();
           nicePlayer.ClientSaveConfig();
           nicePawn = NiceHumanPawn(nicePlayer.Pawn);
       }
    }
}
// Called when zed-time begins
simulated function ZedTimeActivated(){
}
// Called when zed-time deactivated
simulated function ZedTimeDeactivated(){
    local Controller P;
    local NicePlayerController Player;
    junkieNextGoal=1;
    junkieDoneGoals=0;
    junkieDoneHeadshots=0;
    for(P = Level.ControllerList; P != none; P = P.nextController){
       Player = NicePlayerController(P);
       if(Player != none)
           Player.bJunkieExtFailed = false;
    }
}
// Utility functions
// Returns startup cash based on current difficulty
function int GetStartupCash(){
    if(Level.Game.GameDifficulty < 2.0)
       return startupCashBeg;
    else if(Level.Game.GameDifficulty < 4.0)
       return startupCashNormal;
    else if(Level.Game.GameDifficulty < 5.0)
       return startupCashHard;
    else if(Level.Game.GameDifficulty < 7.0)
       return startupCashSui;
    else
       return startupCashHOE;
}
// Returns cash per wave based on current difficulty
function int GetWaveCash(){
    if(Level.Game.GameDifficulty < 2.0)
       return waveCashBeg;
    else if(Level.Game.GameDifficulty < 4.0)
       return waveCashNormal;
    else if(Level.Game.GameDifficulty < 5.0)
       return waveCashHard;
    else if(Level.Game.GameDifficulty < 7.0)
       return waveCashSui;
    else
       return waveCashHOE;
}
// Returns player record, corresponding to the given steam id
function PlayerRecord FindPlayerRecord(string steamID){
    local int i;
    local PlayerRecord newRecord;
    for(i = 0;i < PlayerDatabase.Length;i ++)
       if(PlayerDatabase[i].steamID == steamID)
           return PlayerDatabase[i];
    newRecord.steamID = steamID;
    newRecord.bHasSpawned = false;
    newRecord.lastCashWave = -1;
    newRecord.kills = 0;
    newRecord.assists = 0;
    newRecord.deaths = 0;
    PlayerDatabase[PlayerDatabase.Length] = newRecord;
    return newRecord;
}
// Updates existing PlayerRecord (with a same steam id) and adds a new one, if necessary (record with a same steam is not found)
function UpdatePlayerRecord(PlayerRecord record){
    local int i;
    for(i = 0;i < PlayerDatabase.Length;i ++)
       if(PlayerDatabase[i].steamID == record.steamID){
           PlayerDatabase[i] = record;
           return;
       }
    PlayerDatabase[PlayerDatabase.Length] = record;
}
// Checks if it should be possible to change skills right now
function bool CanChangeSkill(NicePlayerController player){
    local PlayerRecord record;
    record = FindPlayerRecord(player.SteamID64);
    return (bIsTraderTime || (bIsPreGame && bInitialTrader) || bAlwaysAllowSkillChange || !record.bHasSpawned);
}
// Outputs info about given skill in console
function DisplaySkill(class<NiceSkill> skill, int level, bool selected, PlayerController player){
    local String skillColor;
    local String white;
    if(selected)
       skillColor = chr(27)$chr(1)$chr(200)$chr(1);
    else
       skillColor = chr(27)$chr(200)$chr(1)$chr(1);
    white = chr(27)$chr(200)$chr(200)$chr(200);
    player.ClientMessage(white$"Level"@String(level)$skillColor@"skill"$white$":"@skill.default.SkillName);
    // Just in case description is too long
    player.ClientMessage("    ");
}
function UpdateHealthLevels(){
    local Controller P, S;
    local NiceHumanPawn updatePawn;
    for(P = Level.ControllerList;P != none;P = P.nextController){
       updatePawn = NiceHumanPawn(P.Pawn);
       if(updatePawn == none)
           continue;
       updatePawn.HealthMax = (updatePawn.default.HealthMax + updatePawn.HealthBonus) * updatePawn.ScrnPerk.static.HealthMaxMult(KFPlayerReplicationInfo(P.PlayerReplicationInfo), updatePawn);
       for(S = Level.ControllerList;S != none;S = S.nextController)
           if(NicePlayerController(S) != none)
               NicePlayerController(S).ClientUpdatePawnMaxHealth(updatePawn, updatePawn.HealthMax);
    }
}
function BroadcastSkills(){
    local int i, j;
    local bool bSameSkillFound;
    local Controller P;
    local NicePlayerController nicePlayer;
    local array< class<NiceSkill> > playerSkills;
    // Skills to broadcast
    local array<int>                teamNumbers;
    local array< class<NiceSkill> > skillsToSend;
    for(P = Level.ControllerList;P != none;P = P.nextController){
       nicePlayer = NicePlayerController(P);
       if(nicePlayer != none){
           playerSkills = nicePlayer.GetActiveBroadcastSkills();
           // Process player's skills
           for(i = 0;i < playerSkills.Length;i ++){
               bSameSkillFound = false;
               // Try to find if someone already shares the same skill in the same team
               for(j = 0;j < skillsToSend.Length && !bSameSkillFound;j ++)
                   if(playerSkills[i] == skillsToSend[j] && teamNumbers[j] == nicePlayer.PlayerReplicationInfo.Team.TeamIndex)
                       bSameSkillFound = true;
               // If not - add it
               if(!bSameSkillFound){
                   teamNumbers[teamNumbers.Length] = nicePlayer.PlayerReplicationInfo.Team.TeamIndex;
                   skillsToSend[skillsToSend.Length] = playerSkills[i];
               }
           }
       }
    }
    for(P = Level.ControllerList;P != none;P = P.nextController){
       nicePlayer = NicePlayerController(P);
       if(nicePlayer != none){
           for(i = 0;i < skillsToSend.Length;i ++)
               if(teamNumbers[i] == nicePlayer.PlayerReplicationInfo.Team.TeamIndex)
                   nicePlayer.ClientReceiveSkill(skillsToSend[i]);
           nicePlayer.ClientBroadcastEnded();
       }
    }
}
// Function for string splitting, because why would we have it as a standard function? It would be silly, right?
function array<string> SplitString(string inputString, string div){
    local array<string> parts;
    local bool bEOL;
    local string tempChar;
    local int preCount, curCount, partCount, strLength;
    strLength = Len(inputString);
    if(strLength == 0)
       return parts;
    bEOL = false;
    preCount = 0;
    curCount = 0;
    partCount = 0;
    while(!bEOL)
    {
       tempChar = Mid(inputString, curCount, 1);
       if(tempChar != div)
           curCount ++;
       else
       {
           if(curCount == preCount)
           {
               curCount ++;
               preCount ++;
           }
           else
           {
               parts[partCount] = Mid(inputString, preCount, curCount - preCount);
               partCount ++;
               preCount = curCount + 1;
               curCount = preCount;
           }
       }
       if(curCount == strLength)
       {
           if(preCount != strLength)
               parts[partCount] = Mid(inputString, preCount, curCount);
           bEOL = true;
       }
    }
    return parts;
}
// Function for broadcasting messages to players
function BroadcastToAll(string message){
    local Controller P;
    local PlayerController Player;
    for(P = Level.ControllerList; P != none; P = P.nextController){
       Player = PlayerController(P);
       if(Player != none)
           Player.ClientMessage(message);
    }
}
// Function for finding number, corresponding to zed's name
function int ZedNumber(String ZedName){
    local int i;
    for(i = 0;i < ZedDatabase.Length;i ++)
       if(ZedName ~= ZedDatabase[i].ZedName)
           return i;
    return -1;
}
// Function for correct hp scaling
function float hpScale(float hpScale) {
    return 1.0 + 5.0 * hpScale;
}
static function FillPlayInfo(PlayInfo PlayInfo){
    Super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting("NicePack", "bScaleZedHealth", "Scale zeds' health?", 0, 0, "check");
    PlayInfo.AddSetting("NicePack", "bReplacePickups", "Replace pickups?", 0, 0, "check");
    PlayInfo.AddSetting("NicePack", "bInitialTrader", "Use init trader?", 0, 0, "check");
    PlayInfo.AddSetting("NicePack", "bStillDuringInitTrader", "Be still during init trader?", 0, 0, "check");
    PlayInfo.AddSetting("NicePack", "initialTraderTime", "Time for init trader?", 0, 0, "text", "3;1:999");
    PlayInfo.AddSetting("NicePack", "bUseProgresiveCash", "Use progressive dosh?", 0, 0, "check");
    PlayInfo.AddSetting("NicePack", "bConvertExp", "Convert old exp?", 0, 0, "check");
    PlayInfo.AddSetting("NicePack", "bAlwaysAllowSkillChange", "Skill change at anytime?", 0, 0, "check");
    PlayInfo.AddSetting("NicePack", "minimalSpawnDistance", "Min spawn distance", 0, 0, "text", "5;0:99999");
    PlayInfo.AddSetting("NicePack", "minSpawnRate", "Min spawn rate", 0, 0, "text", "6;0.0:10.0");
    PlayInfo.AddSetting("NicePack", "maxSpawnRate", "Max spawn rate", 0, 0, "text", "6;0.0:10.0");
    PlayInfo.AddSetting("NicePack", "bOneFFIncOnly", "Only 1 FF increase?", 0, 0, "check");
    PlayInfo.AddSetting("NicePack", "bNoLateFFIncrease", "FF increase wave 1 only?", 0, 0, "check");
}
static function string GetDescriptionText(string SettingName){
    switch (SettingName){
       case "bScaleZedHealth":
           return "Should we scale health off all zeds to 6-player level?";
       case "bReplacePickups":
           return "Should we replace all pickups with their Nice versions when available?";
       case "bInitialTrader":
           return "Use initial trader system?";
       case "bStillDuringInitTrader":
           return "Force players to stand still during initial trader?";
       case "initialTraderTime":
           return "How much time should be allowed for initial trade?";
       case "bUseProgresiveCash":
           return "Use progressive dosh system?";
       case "bConvertExp":
           return "Should we convert old exp into a new one?";
       case "bAlwaysAllowSkillChange":
           return "Allows changing skills at any time.";
       case "minimalSpawnDistance":
           return "Minimal distance between ZedVolume and players that should allow for zeds to spawn.";
       case "minSpawnRate":
           return "Minimal allowed spawn rate.";
       case "maxSpawnRate":
           return "Maximal allowed spawn rate.";
       case "bOneFFIncOnly":
           return "Option that only allows one FF increase per game.";
       case "bNoLateFFIncrease":
           return "Disables FF increase through voting after 1st wave.";
    }
    return Super.GetDescriptionText(SettingName);
}
defaultproperties
{
    bScaleZedHealth=True
    bReplacePickups=True
    bInitialTrader=True
    initialTraderTime=10
    bUseProgresiveCash=True
    startupCashBeg=500
    startupCashNormal=500
    startupCashHard=500
    startupCashSui=400
    startupCashHOE=400
    waveCashBeg=350
    waveCashNormal=300
    waveCashHard=200
    waveCashSui=150
    waveCashHOE=150
    bConvertExp=True
    vetFieldMedicExpCost=2.000000
    vetFieldMedicDmgExpCost=0.025000
    vetSharpHeadshotExpCost=10.000000
    vetSupportDamageExpCost=0.050000
    vetCommandoDamageExpCost=0.050000
    vetDemoDamageExpCost=0.050000
    vetZerkDamageExpCost=0.050000
    vetHeavyMGDamageExpCost=0.050000
    vetGunslingerKillExpCost=20.000000
    bigZedMinHealth=1000
    mediumZedMinHealth=500
    minSpawnRate=0.700000
    maxSpawnRate=1.500000
    minimalSpawnDistance=600
    bNoLateFFIncrease=True
    junkieNextGoal=1
    bIsPreGame=True
    /*pickupReplaceArray(0)=(vanillaClass=Class'KFMod.MAC10Pickup',scrnClass=Class'ScrnBalanceSrv.ScrnMAC10Pickup',NewClass=Class'NicePack.NiceMAC10Pickup')
    pickupReplaceArray(1)=(vanillaClass=Class'KFMod.WinchesterPickup',scrnClass=Class'ScrnBalanceSrv.ScrnWinchesterPickup',NewClass=Class'NicePack.NiceWinchesterPickup')
    pickupReplaceArray(2)=(vanillaClass=Class'KFMod.CrossbowPickup',scrnClass=Class'ScrnBalanceSrv.ScrnCrossbowPickup',NewClass=Class'NicePack.NiceCrossbowPickup')
    pickupReplaceArray(3)=(vanillaClass=Class'KFMod.SPSniperPickup',scrnClass=Class'ScrnBalanceSrv.ScrnSPSniperPickup',NewClass=Class'NicePack.NiceMaulerPickup')
    pickupReplaceArray(4)=(vanillaClass=Class'KFMod.M14EBRPickup',scrnClass=Class'ScrnBalanceSrv.ScrnM14EBRPickup',NewClass=Class'NicePack.NiceM14EBRPickup')
    pickupReplaceArray(5)=(vanillaClass=Class'KFMod.M99Pickup',scrnClass=Class'ScrnBalanceSrv.ScrnM99Pickup',NewClass=Class'NicePack.NiceM99Pickup')
    pickupReplaceArray(6)=(vanillaClass=Class'KFMod.ShotgunPickup',scrnClass=Class'ScrnBalanceSrv.ScrnShotgunPickup',NewClass=Class'NicePack.NiceShotgunPickup')
    pickupReplaceArray(7)=(vanillaClass=Class'KFMod.BoomStickPickup',scrnClass=Class'ScrnBalanceSrv.ScrnBoomStickPickup',NewClass=Class'NicePack.NiceBoomStickPickup')
    pickupReplaceArray(8)=(vanillaClass=Class'KFMod.NailGunPickup',scrnClass=Class'ScrnBalanceSrv.ScrnNailGunPickup',NewClass=Class'NicePack.NiceNailGunPickup')
    pickupReplaceArray(9)=(vanillaClass=Class'KFMod.KSGPickup',scrnClass=Class'ScrnBalanceSrv.ScrnKSGPickup',NewClass=Class'NicePack.NiceKSGPickup')
    pickupReplaceArray(10)=(vanillaClass=Class'KFMod.BenelliPickup',scrnClass=Class'ScrnBalanceSrv.ScrnBenelliPickup',NewClass=Class'NicePack.NiceBenelliPickup')
    pickupReplaceArray(11)=(vanillaClass=Class'KFMod.AA12Pickup',scrnClass=Class'ScrnBalanceSrv.ScrnAA12Pickup',NewClass=Class'NicePack.NiceAA12Pickup')*/
    NiceUniversalDescriptions(0)="Survive on %m in ScrN Balance mode"
    NiceUniversalDescriptions(1)="Survive on %m in ScrN Balance mode with Hardcore Level 5+"
    NiceUniversalDescriptions(2)="Survive on %m in ScrN Balance mode with Hardcore Level 10+"
    NiceUniversalDescriptions(3)="Survive on %m in ScrN Balance mode with Hardcore Level 15+"
    bAddToServerPackages=True
    GroupName="KFNicePack"
    FriendlyName="Package for nice/mean servers"
    Description="Does stuff."
    bAlwaysRelevant=True
    RemoteRole=ROLE_SimulatedProxy
}
