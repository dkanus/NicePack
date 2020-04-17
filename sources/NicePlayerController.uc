class NicePlayerController extends ScrnPlayerController
    config(NiceUser)
    dependson(NicePack)
    dependson(NiceFire);
var globalconfig int nicePlayerInfoVersionNumber;
// These are values stored in a settings file
var globalconfig bool   bDebug;
var globalconfig bool   bShowHLMessages;
var globalconfig bool   bAltSwitchesModes;
var globalconfig bool   bUseServerReload;               // Should we reload on 'ReloadMeNow' call?
var globalconfig bool   bAdvReloadCheck;                // Should we try guessing if a given binding is supposed to cause reload?
// Reload canceling options
var globalconfig bool   bRelCancelByFire;
var globalconfig bool   bRelCancelBySwitching;
var globalconfig bool   bRelCancelByNades;
var globalconfig bool   bRelCancelByAiming;
// Weapon management
var globalconfig bool   bNiceWeaponManagement;
var globalconfig bool   bNiceWeaponManagementWasInitialized;
// Additional information displaying
var globalconfig bool   bDisplayCounters;
var globalconfig bool   bDisplayWeaponProgress;
// ScrN panel-related hack to fix crashes
var globalconfig bool   bShowScrnMenu;
struct PlayedWith{
    var string playerName;
    var string steamID;
};
var globalconfig int                maxPlayedWithRecords;
var globalconfig array<PlayedWith>  recentlyPlayedWithDatabase;
var globalconfig array<PlayedWith>  playedWithDatabase;
struct WeaponGroup{
    var bool    bCanBeRemoved;
    var string  groupName;
    // Parameters for automatically adding weapons to the groups
    var bool        bAutoAddWeapon;
    var int         autoPerk;
    var array<int>  autoInvGroups;
};
var globalconfig array<WeaponGroup> UserWeaponGroups;
struct WeaponRecord{
    var string          friendlyName;
    var array<string>   groupsNames;
    var class<KFWeapon> weaponClass;
};
var globalconfig array<WeaponRecord> UserWeaponRecords;
struct WeaponPreset{
    var bool                        bCanBeRemoved;
    var string                      presetName;
    var bool                        perkedFirst;
    var int                         reqPerk;
    var array< class<KFWeapon> >    reqWeapons;
    var int                         dumpSelector;
    var array<int>                  selectorsList;
    var array<string>               groupsList;
    var bool                        bUsesMouseWheel;
    var bool                        bMouseWheelLoops;
};
var WeaponPreset DefaultWeaponPreset;
var globalconfig array<WeaponPreset> UserWeaponPresets;
struct WeaponSelector{
    var int                         selectorNumber;
    var array< class<KFWeapon> >    weaponList;
};
var bool                    hasZeroSelector;
var bool                    bUsesMouseWheel;
var bool                    bMouseWheelLoops;
var array<WeaponSelector>   activeSelectors;
var const string WeapGroupMeleeName;
var const string WeapGroupNonMeleeName;
var const string WeapGroupPistolsName;
var const string WeapGroupGeneralName;
var const string WeapGroupToolsName;
var const string WeapPresetDefaultName;
var const string WeapPresetGunslingerName;
var globalconfig int    tracesPerTickLimit;
var int                 tracesThisTick;
var globalconfig int    effectsLimitSoft;
var globalconfig int    effectsLimitHard;
// We break second into 10 parts and count how much projectiles has spawned in each one of them
var int                 effectsSpawned[10];
var int                 currentEffectTimeWindow;
var float               nextEffectsResetTime;
var int                 wallHitsLeft;
var NiceStorageClient   storageClient;
// These are actually used variables
var bool    bSettingsLoaded;
var bool    bFlagDebug;
var bool    bFlagShowHLMessages;
var bool    bFlagAltSwitchesModes;
var bool    bFlagUseServerReload;
var bool    bFlagDisplayCounters;
var bool    bFlagDisplayWeaponProgress;
var NiceCollisionManager        localCollisionManager;
struct StuckBulletRecord{
    var NiceBullet  bullet;
    var float       registrationTime;
};
var array<StuckBulletRecord> stuckBulletsSet;
var NicePack NicePackMutator;
var string SteamID64;
var bool hasExpConverted;
var bool bOpenedInitTrader;
var float sirenScreamMod;
// Skills stuff
struct SkillChoices{
    var byte isAltChoice[5];
};
// Player's skill choices. 'pendingSkills' are skill choices that player wants to use next, 'currentSkills' are current skills choices
var SkillChoices pendingSkills[20];
var globalConfig SkillChoices currentSkills[20];
// Skills that someone has and that clients should be aware of
var array< class<NiceSkill> >   broadcastedSkills;
// A new, updated broadcast skill set that's being received from the server
var array< class<NiceSkill> >   broadcastQueue;
var NiceReplicationInfo niceRI;
var NiceRepInfoRemoteData remoteRI;
var NiceAbilityManager abilityManager;
var bool bJunkieExtFailed;
replication{
    reliable if(Role == ROLE_Authority)
       niceRI, remoteRI, SteamID64, bJunkieExtFailed, pendingSkills, bSettingsLoaded, bFlagAltSwitchesModes, bFlagUseServerReload,
           bFlagShowHLMessages, bFlagDebug, bFlagDisplayCounters, bFlagDisplayWeaponProgress,
           abilityManager;
    reliable if(Role < ROLE_Authority)
            sirenScreamMod;
    reliable if(Role == ROLE_Authority)
       ClientSetSkill, ClientLoadSettings, ClientSaveConfig, ClientSetKey, ClientUpdatePlayedWithDatabase, ClientReceiveSkill, ClientBroadcastEnded, ClientLog, ClientUpdatePawnMaxHealth, ClientSetNiceWeapManagement,
           ClientSpawnSirenBall, ClientRemoveSirenBall, ClientNailsExplosion, ClientStickGhostProjectile, ClientSetZedStun, ClientShowScrnMenu;
    unreliable if(Role == ROLE_Authority)
       ClientSpawnGhostProjectile, ClientPrint;
    reliable if(Role < ROLE_Authority)
       ServerSetSkill, ServerSetPendingSkill, ServerSetAltSwitchesModes, ServerSetUseServerReload,
           ServerSetHLMessages, ServerMarkSettingsLoaded, ServerStartleZeds, ServerSetDisplayCounters,
           ServerSetDisplayWeaponProgress, ActivateAbility;
}
// Called on server only!
function PostLogin(){
    local NicePack.PlayerRecord record;
    local NiceGameType NiceGT;
    local NiceTSCGame TSCGT;
    local ScrnCustomPRI ScrnPRI;
    Super.PostLogin();
    // Restore data
    NiceGT = NiceGameType(Level.Game);
    TSCGT = NiceTSCGame(Level.Game);
    ScrnPRI = class'ScrnCustomPRI'.static.FindMe(PlayerReplicationInfo);
    if(ScrnPRI != none)
       SteamID64 = ScrnPRI.GetSteamID64();
    if(SteamID64 != "")
       NicePackMutator = class'NicePack'.static.Myself(Level);
    if(NicePackMutator != none){
       record = NicePackMutator.FindPlayerRecord(SteamID64);
       // Copy data from a record
       PlayerReplicationInfo.Kills = record.kills;
       PlayerReplicationInfo.Deaths = record.deaths;
       KFPlayerReplicationInfo(PlayerReplicationInfo).KillAssists = record.assists;
    }
    // Set pending skills to current skill's values
    ClientLoadSettings();
    // Try giving necessary dosh to the player
    if(NicePackMutator != none)
       NicePackMutator.GiveProgressiveDosh(self);
    // Update recently played with players records
    if(SteamID64 != "")
       UpdateRecentPlayers(PlayerReplicationInfo.PlayerName, SteamID64);
    // Spawn ability manager
    abilityManager = Spawn(class'NiceAbilityManager', self);
}
simulated function ClientPostLogin(){
    local int i, j, k;
    local bool bEntryExists;
    local array<PlayedWith> newPlayedWithData;
    j = 0;
    for(i = 0;i < maxPlayedWithRecords;i ++){
       if(j < recentlyPlayedWithDatabase.Length){
           newPlayedWithData[newPlayedWithData.Length] = recentlyPlayedWithDatabase[j ++];
       }
       else
           break;
    }
    if(i < maxPlayedWithRecords){
       j = 0;
       for(i = newPlayedWithData.Length - 1;i < maxPlayedWithRecords;i ++){
           bEntryExists = false;
           for(k = 0;k < newPlayedWithData.Length;k ++)
               if(newPlayedWithData[k].steamID == playedWithDatabase[j].steamID){
                   bEntryExists = true;
                   break;
               }
           if(j < playedWithDatabase.Length && !bEntryExists)
               newPlayedWithData[newPlayedWithData.Length] = playedWithDatabase[j ++];
           else
               break;
       }
    }
    recentlyPlayedWithDatabase.Length = 0;
    playedWithDatabase = newPlayedWithData;
    UpdateDefaultWeaponSettings();
    //  Create sync node
    storageClient = new class'NicePack.NiceStorageClient';
    storageClient.events.static.AddAdapter(class'NiceRemoteDataAdapter', level);
    // Init collisions
    if(Role < ROLE_Authority)
       localCollisionManager = Spawn(class'NiceCollisionManager');
    // Update ScrN menu setting
    ClientShowScrnMenu(bShowScrnMenu);
}
function ShowLobbyMenu(){
    Super.ShowLobbyMenu();
}
function TryActivatePendingSkills(){
    local int i, j;
    for(i = 0;i < 20;i ++)
       for(j = 0;j < 5;j ++)
           ServerSetSkill(i, j, pendingSkills[i].isAltChoice[j]);
}
simulated function ServerSetAltSwitchesModes(bool bSwitches){
    bFlagAltSwitchesModes = bSwitches;
}
simulated function ServerSetUseServerReload(bool bUseServer){
    bFlagUseServerReload = bUseServer;
}
simulated function ServerSetHLMessages(bool bDoMessages){
    bFlagShowHLMessages = bDoMessages;
}
simulated function ServerSetDebug(bool bDoDebug){
    bFlagDebug = bDoDebug;
}
simulated function ServerSetDisplayCounters(bool bDoDisplay){
    bFlagDisplayCounters = bDoDisplay;
}
simulated function ServerSetDisplayWeaponProgress(bool bDoDisplay){
    bFlagDisplayWeaponProgress = bDoDisplay;
}
simulated function ServerMarkSettingsLoaded(){
    bSettingsLoaded = true;
}
simulated function ClientSaveConfig(){
    if(bSettingsLoaded){
       bDebug                          = bFlagDebug;
       bShowHLMessages                 = bFlagShowHLMessages;
       bAltSwitchesModes               = bFlagAltSwitchesModes;
       bUseServerReload                = bFlagUseServerReload;
       bDisplayCounters                = bFlagDisplayCounters;
       bDisplayWeaponProgress          = bFlagDisplayWeaponProgress;
       SaveConfig();
    }
}
simulated function ClientLoadSettings(){
    local int i, j;
    ServerSetDebug(bDebug);
    ServerSetHLMessages(bShowHLMessages);
    ServerSetAltSwitchesModes(bAltSwitchesModes);
    ServerSetUseServerReload(bUseServerReload);
    ServerSetDisplayCounters(bDisplayCounters);
    ServerSetDisplayWeaponProgress(bDisplayWeaponProgress);
    if(Role < ROLE_Authority){
       for(i = 0;i < 20;i ++)
           for(j = 0;j < 5;j ++)
               ServerSetSkill(i, j, currentSkills[i].isAltChoice[j], true);
    }
    // If reliable replicated functions really are replicated in order, that should do the trick
    ServerMarkSettingsLoaded();
}
// Changes skill locally, without any replication
simulated function SetSkill(int perkIndex, int skillIndex, byte newValue){
    if(perkIndex < 0 || skillIndex < 0 || perkIndex >= 20 || skillIndex >= 5)
       return;
    if(newValue > 0)
       newValue = 1;
    else
       newValue = 0;
    currentSkills[perkIndex].isAltChoice[skillIndex] = newValue;
}
// Changes skill choice on client side
simulated function ClientSetSkill(int perkIndex, int skillIndex, byte newValue){
    local byte oldValue;
    oldValue = currentSkills[perkIndex].isAltChoice[skillIndex];
    SetSkill(perkIndex, skillIndex, newValue);
    if(oldValue != newValue)
       TriggerSelectEventOnSkillChange(perkIndex, skillIndex, newValue);
}
// Changes pending skill choice on client side
simulated function ServerSetPendingSkill(int perkIndex, int skillIndex, byte newValue){
    if(perkIndex < 0 || skillIndex < 0 || perkIndex >= 20 || skillIndex >= 5)
       return;
    if(newValue > 0)
       newValue = 1;
    else
       newValue = 0;
    pendingSkills[perkIndex].isAltChoice[skillIndex] = newValue;
}
// Calls skill change events
simulated function TriggerSelectEventOnSkillChange(int perkIndex, int skillIndex, byte newValue){
    local class<NiceVeterancyTypes> niceVet;
    niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(PlayerReplicationInfo);
    if(niceVet == none || niceVet.default.PerkIndex != perkIndex)
       return;
    if(newValue == 1){
       niceVet.default.SkillGroupA[skillIndex].static.SkillDeSelected(self);
       niceVet.default.SkillGroupB[skillIndex].static.SkillSelected(self);
    }
    else{
       niceVet.default.SkillGroupB[skillIndex].static.SkillDeSelected(self);
       niceVet.default.SkillGroupA[skillIndex].static.SkillSelected(self);
    }
}
// Calls skill change events
simulated function TriggerSelectEventOnPerkChange(class<NiceVeterancyTypes> oldVet, class<NiceVeterancyTypes> newVet){
    local int i;
    for(i = 0;i < 5;i ++){
       // Deselect old skill
       if( oldVet != none && currentSkills[oldVet.default.PerkIndex].isAltChoice[i] == 0
           && oldVet.default.SkillGroupA[i] != none)
           oldVet.default.SkillGroupA[i].static.SkillDeSelected(self);
       if( oldVet != none && currentSkills[oldVet.default.PerkIndex].isAltChoice[i] == 1
           && oldVet.default.SkillGroupB[i] != none)
           oldVet.default.SkillGroupB[i].static.SkillDeSelected(self);
       // Select new skill
       if( newVet != none && currentSkills[newVet.default.PerkIndex].isAltChoice[i] == 0
           && newVet.default.SkillGroupA[i] != none)
           newVet.default.SkillGroupA[i].static.SkillSelected(self);
       if( newVet != none && currentSkills[newVet.default.PerkIndex].isAltChoice[i] == 1
           && newVet.default.SkillGroupB[i] != none)
           newVet.default.SkillGroupB[i].static.SkillSelected(self);
    }
}
// Changes (if possible) skill choice on server side and calls 'ClientSetSkill' to also alter value on the client side
// Always calls 'ServerSetPendingSkill' for a change of a pending skill array
simulated function ServerSetSkill(int perkIndex, int skillIndex, byte newValue, optional bool bForce){
    local byte oldValue;
    if(bForce || niceRI.Mut.CanChangeSkill(Self)){
       oldValue = currentSkills[perkIndex].isAltChoice[skillIndex];
       SetSkill(perkIndex, skillIndex, newValue);
       ClientSetSkill(perkIndex, skillIndex, newValue);
       if(oldValue != newValue)
           TriggerSelectEventOnSkillChange(perkIndex, skillIndex, newValue);
    }
    ServerSetPendingSkill(perkIndex, skillIndex, newValue);
}
simulated function ClientReceiveSkill(class<NiceSkill> newSkill){
    broadcastQueue[broadcastQueue.Length] = newSkill;
}
simulated function ClientBroadcastEnded(){
    broadcastedSkills = broadcastQueue;
    broadcastQueue.Length = 0;
}
simulated function array< class<NiceSkill> > GetActiveBroadcastSkills(){
    local int i;
    local int currentLevel;
    local SkillChoices choices;
    local class<NiceVeterancyTypes> niceVet;
    local array< class<NiceSkill> > broadcastSkills;
    niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(PlayerReplicationInfo);
    currentLevel = class'NiceVeterancyTypes'.static.GetClientVeteranSkillLevel(KFPlayerReplicationInfo(PlayerReplicationInfo));
    if(niceVet != none){
       choices = currentSkills[niceVet.default.PerkIndex];
       for(i = 0;i < 5 && i < currentLevel;i ++){
           if(niceVet.default.SkillGroupA[i].default.bBroadcast && choices.isAltChoice[i] == 0)
               broadcastSkills[broadcastSkills.Length] = niceVet.default.SkillGroupA[i];
           if(niceVet.default.SkillGroupB[i].default.bBroadcast && choices.isAltChoice[i] > 0)
               broadcastSkills[broadcastSkills.Length] = niceVet.default.SkillGroupB[i];
       }
    }
    return broadcastSkills;
}
simulated function ClientSetKey(int key){
    Pawn.Weapon.InventoryGroup = key;
}
// Remove shaking for sharpshooter with a right skill
function bool ShouldShake(){
    local class<NiceVeterancyTypes> niceVet;
    niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(PlayerReplicationInfo);
    if(niceVet != none && niceVet.static.hasSkill(self, class'NiceSkillEnforcerUnshakable'))
       return false;
    return true;
}
event SetAmbientShake(float FalloffStartTime, float    FalloffTime, vector    OffsetMag, float OffsetFreq, rotator RotMag, float RotFreq){
    if(ShouldShake())
       Super.SetAmbientShake(FalloffStartTime, FalloffTime, OffsetMag, OffsetFreq, RotMag, RotFreq);
}
function ShakeView(vector shRotMag, vector shRotRate, float shRotTime, vector shOffsetMag, vector shOffsetRate, float shOffsetTime){
    if(ShouldShake())
       Super.ShakeView(shRotMag, shRotRate, shRotTime, shOffsetMag, shOffsetRate, shOffsetTime);
}
simulated event Destroyed(){
    local NicePack.PlayerRecord record;
    if(NicePackMutator != none && SteamID64 != ""){
       record = NicePackMutator.FindPlayerRecord(SteamID64);
       // Copy data from a record
       record.kills = PlayerReplicationInfo.Kills;
       record.deaths = PlayerReplicationInfo.Deaths;
       record.assists = KFPlayerReplicationInfo(PlayerReplicationInfo).KillAssists;
       NicePackMutator.UpdatePlayerRecord(record);
    }
    Super.Destroyed();
}
// Screw that
simulated function ClientWeaponDestroyed(class<Weapon> WClass){}
// This event is generated when new pawn spawns
function PawnSpawned(){
    local bool bFoundExp;
    local float convertedExp;
    local ClientPerkRepLink R;
    local SRCustomProgress exp;
    local MeanReplicationInfo meanRI;
    local NicePack.PlayerRecord record;
    //local NiceHumanPawn nicePawn;
    // Make sure our health is at it's top
    Pawn.Health = Pawn.HealthMax;
    // Make a record about spawning
    record = NicePackMutator.FindPlayerRecord(SteamID64);
    record.bHasSpawned = true;
    NicePackMutator.UpdatePlayerRecord(record);
    // Exp conversion
    if(!hasExpConverted){
       R = SRStatsBase(SteamStatsAndAchievements).Rep;
       if(R == none)
           return;
       hasExpConverted = true;
       // Field medic
       convertedExp = R.RDamageHealedStat * class'NicePack'.default.vetFieldMedicExpCost;
       if(R.GetCustomValueInt(Class'NiceVetFieldMedicExp') == 0 && convertedExp > 0){
           bFoundExp = false;
           for(exp = R.CustomLink;exp != none;exp = exp.NextLink)
               if(exp.Class.Name == 'NiceVetFieldMedicExp'){
                   bFoundExp = true;
                   break;
               }
           if(bFoundExp)
               exp.IncrementProgress(convertedExp);
       }
       // Support
       convertedExp = R.RShotgunDamageStat * class'NicePack'.default.vetSupportDamageExpCost;
       if(R.GetCustomValueInt(Class'NiceVetSupportExp') == 0 && convertedExp > 0){
           bFoundExp = false;
           for(exp = R.CustomLink;exp != none;exp = exp.NextLink)
               if(exp.Class.Name == 'NiceVetSupportExp'){
                   bFoundExp = true;
                   break;
               }
           if(bFoundExp)
               exp.IncrementProgress(convertedExp);
       }
       // Commando
       convertedExp = R.RBullpupDamageStat * class'NicePack'.default.vetCommandoDamageExpCost;
       if(R.GetCustomValueInt(Class'NiceVetCommandoExp') == 0 && convertedExp > 0){
           bFoundExp = false;
           for(exp = R.CustomLink;exp != none;exp = exp.NextLink)
               if(exp.Class.Name == 'NiceVetCommandoExp'){
                   bFoundExp = true;
                   break;
               }
           if(bFoundExp)
               exp.IncrementProgress(convertedExp);
       }
       // Sharpshooter
       convertedExp = R.RHeadshotKillsStat * class'NicePack'.default.vetSharpHeadshotExpCost;
       if(R.GetCustomValueInt(Class'NiceVetSharpshooterExp') == 0 && convertedExp > 0){
           bFoundExp = false;
           for(exp = R.CustomLink;exp != none;exp = exp.NextLink)
               if(exp.Class.Name == 'NiceVetSharpshooterExp'){
                   bFoundExp = true;
                   break;
               }
           if(bFoundExp)
               exp.IncrementProgress(convertedExp);
       }
       // Demolition
       convertedExp = R.RExplosivesDamageStat * class'NicePack'.default.vetDemoDamageExpCost;
       if(R.GetCustomValueInt(Class'NiceVetDemolitionsExp') == 0 && convertedExp > 0){
           bFoundExp = false;
           for(exp = R.CustomLink;exp != none;exp = exp.NextLink)
               if(exp.Class.Name == 'NiceVetDemolitionsExp'){
                   bFoundExp = true;
                   break;
               }
           if(bFoundExp)
               exp.IncrementProgress(convertedExp);
       }
       // Berserker
       convertedExp = R.RMeleeDamageStat * class'NicePack'.default.vetZerkDamageExpCost;
       if(R.GetCustomValueInt(Class'NiceVetBerserkerExp') == 0 && convertedExp > 0){
           bFoundExp = false;
           for(exp = R.CustomLink;exp != none;exp = exp.NextLink)
               if(exp.Class.Name == 'NiceVetBerserkerExp'){
                   bFoundExp = true;
                   break;
               }
           if(bFoundExp)
               exp.IncrementProgress(convertedExp);
       }
    }
    // Stop after-death bleeding
    meanRI = class'MeanReplicationInfo'.static.findSZri(PlayerReplicationInfo);
    if(meanRI != none)
       meanRI.stopBleeding();
    // Give necessary dosh to the player
    if(NicePackMutator != none)
       NicePackMutator.GiveProgressiveDosh(self);
    // Update veterancy (possibly not needed)
    /*nicePawn = NiceHumanPawn(Pawn);
    if(nicePawn != none)
       nicePawn.VeterancyChanged();*/
}
exec function ForceSetName(coerce string S){
    ChangeName(S);
    UpdateURL("Name", S, true);
}
exec function OpenTrader(){
    if(KFHumanPawn(Pawn) != none){
       ShowBuyMenu("Initial trader", KFHumanPawn(Pawn).MaxCarryWeight);
       bOpenedInitTrader = true;
    }
}
function UpdateRecentPlayers(string playerName, string steamID){
    local Controller P;
    local NicePlayerController nicePlayer;
    for(P = Level.ControllerList; P != none; P = P.nextController){
       nicePlayer = NicePlayerController(P);
       if(nicePlayer != none && nicePlayer.SteamID64 != steamID){
           nicePlayer.ClientUpdatePlayedWithDatabase(playerName, steamID);
           if(nicePlayer.SteamID64 != ""){
               Self.ClientUpdatePlayedWithDatabase(nicePlayer.PlayerReplicationInfo.PlayerName, nicePlayer.SteamID64);
           }
       }
    }
}
simulated function ClientUpdatePlayedWithDatabase(string playerName, string steamID){
    local int i;
    local bool bFound;
    local PlayedWith newRecord;
    if(SteamID64 != "" && SteamID64 != steamID){
       // Prepare new record
       newRecord.playerName = playerName;
       newRecord.steamID = steamID;
       // Update recently played with players
       bFound = false;
       for(i = 0;i < recentlyPlayedWithDatabase.Length;i ++)
           if(recentlyPlayedWithDatabase[i].steamID == steamID){
               recentlyPlayedWithDatabase[i] = newRecord;
               bFound = true;
               break;
           }
       if(!bFound)
           recentlyPlayedWithDatabase[recentlyPlayedWithDatabase.Length] = newRecord;
       // Update older record
       for(i = 0;i < playedWithDatabase.Length;i ++)
           if(playedWithDatabase[i].steamID == steamID){
               playedWithDatabase.Remove(i, 1);
               break;
           }
    }
}
simulated function bool IsZedTimeActive(){
    local KFGameType KFGT;
    if(Role < ROLE_Authority)
       return bZedTimeActive;
    else{
       KFGT = KFGameType(Level.Game);
       if(KFGT != none)
           return KFGT.bZEDTimeActive;
    }
    return false;
}
function BecomeActivePlayer(){
    if(Role < ROLE_Authority)
       return;
    if(!Level.Game.AllowBecomeActivePlayer(self))
       return;
    super.BecomeActivePlayer();
    if(NicePackMutator != none)
       NicePackMutator.GiveProgressiveDosh(self);
}
function ServerStartleZeds(float dist){
    local Vector pawnLoc;
    local Controller contr;
    local NiceMonsterController niceZed;
    if(Pawn != none)
       pawnLoc = Pawn.Location;
    else
       return;
    for(contr = Level.ControllerList; contr != none; contr = contr.nextController){
       niceZed = NiceMonsterController(contr);
       if(niceZed != none && niceZed.Pawn != none && VSize(pawnLoc - niceZed.Pawn.Location) <= dist)
           niceZed.Startle(Pawn);
    }
}
simulated function ClientEnterZedTime(){
    super.ClientEnterZedTime();
    if(IsZedTimeActive() && class'NiceVeterancyTypes'.static.HasSkill(self, class'NiceSkillEnforcerZEDJuggernaut'))
       ServerStartleZeds(class'NiceSkillEnforcerZEDJuggernaut'.default.distance);
}
/*simulated function ClientExitZedTime(){
    super.ClientExitZedTime();
}*/
simulated function ClientLog(String logStr){
    if(bFlagDebug)
       Log("NiceDebug:"$logStr);
}
function ServerUse(){
    local NiceHumanPawn myPawn;
    myPawn = NiceHumanPawn(Pawn);
    if(myPawn == none){
       super.ServerUse();
       return;
    }
    // Handle initial shop / medic drugs
    if(NicePackMutator != none && NicePackMutator.bIsPreGame && NicePackMutator.bInitialTrader){
       if(VSize(Pawn.Velocity) <= 0.0){
           ShowBuyMenu("Initial trader", myPawn.MaxCarryWeight);
           bOpenedInitTrader = true;
       }
    }
    else
       super.ServerUse();
}
simulated function ClientUpdatePawnMaxHealth(NiceHumanPawn updatePawn, int newHealthMax){
    updatePawn.HealthMax = newHealthMax;
}
simulated function int FindWeaponGroup(string groupName){
    local int i;
    for(i = 0;i < UserWeaponGroups.Length;i ++)
       if(UserWeaponGroups[i].groupName ~= groupName)
           return i;
    return -1;
}
simulated function int AddWeaponGroup(string groupName){
    local int groupIndex;
    local WeaponGroup newWeapGroup;
    groupIndex = FindWeaponGroup(groupName);
    if(groupIndex < 0){
       newWeapGroup.bCanBeRemoved = true;
       newWeapGroup.groupName = groupName;
       newWeapGroup.autoPerk = -1;
       UserWeaponGroups[UserWeaponGroups.Length] = newWeapGroup;
       return UserWeaponGroups.Length - 1;
    }
    return groupIndex;
}
simulated function RemoveWeaponGroup(string groupName){
    local int i, j;
    local int groupIndex;
    groupIndex = FindWeaponGroup(groupName);
    if(groupIndex >= 0 && UserWeaponGroups[groupIndex].bCanBeRemoved)
       UserWeaponGroups.Remove(groupIndex, 1);
    // Remove group name from weapons' records
    for(i = 0;i < UserWeaponRecords.Length;i ++)
       for(j = 0;j < UserWeaponRecords[i].groupsNames.Length;j ++)
           if(UserWeaponRecords[i].groupsNames[j] ~= groupName){
               UserWeaponRecords[i].groupsNames.Remove(j, 1);
               break;
           }
}
// Looks through 'UserWeaponRecords' and return index of given weapon if it's placed in given group
// Passing empty string "" will force function to search for weapon in all groups
simulated function int FindWeaponInGroup(class<KFWeapon> weaponClass, string groupName){
    local int i, j;
    local bool anyRecord;
    anyRecord = (groupName == "");
    for(i = 0;i < UserWeaponRecords.Length;i ++)
       if(weaponClass == UserWeaponRecords[i].weaponClass){
           if(anyRecord)
               return i;
           for(j = 0;j < UserWeaponRecords[i].groupsNames.Length;j ++)
               if(groupName ~= UserWeaponRecords[i].groupsNames[j])
                   return i;
           break;
       }
    return -1;
}
// Returns 'true' iff weapon belongs to at least one group from 'groupsArray'
simulated function bool IsWeaponInGroups(class<KFWeapon> weaponClass, array<WeaponGroup> groupsArray){
    local int i, j;
    local int weaponIndex;
    weaponIndex = FindWeaponInGroup(weaponClass, "");
    for(i = 0;i < UserWeaponRecords[weaponIndex].groupsNames.Length;i ++)
       for(j = 0;j < groupsArray.Length;j ++)
           if(UserWeaponRecords[weaponIndex].groupsNames[i] ~= groupsArray[j].groupName)
               return true;
    return false;
}
// Returns weapons from 'input' array that are included in given group; removes them from the 'input' array
simulated function array< class<KFWeapon> > FilterWeaponsByGroup(out array< class<KFWeapon> > input, string groupName){
    local int i;
    local int weaponIndex;
    local array< class<KFWeapon> > output;
    i = 0;
    while(i < input.Length){
       weaponIndex = FindWeaponInGroup(input[i], groupName);
       if(weaponIndex < 0)
           i ++;
       else{
           output[output.Length] = input[i];
           input.Remove(i, 1);
       }
    }
    return output;
}
// Adds weapon record if this weapon class wasn't already recorded
// Returns index of the weapon after operation
simulated function int AddWeaponRecord(class<KFWeapon> weaponClass){
    local int i;
    local int weaponIndex;
    local WeaponRecord newWeapRecord;
    if(WeaponClass == none)
       return -1;
    weaponIndex = FindWeaponInGroup(weaponClass, "");
    if(weaponIndex < 0){
       newWeapRecord.weaponClass = weaponClass;
       for(i = 0;i < UserWeaponRecords.Length;i ++)
           if( UserWeaponRecords[i].weaponClass.default.InventoryGroup > weaponClass.default.InventoryGroup
               || (UserWeaponRecords[i].weaponClass.default.InventoryGroup == weaponClass.default.InventoryGroup && UserWeaponRecords[i].weaponClass.default.GroupOffset > weaponClass.default.GroupOffset) ){
               UserWeaponRecords.Insert(i, 1);
               UserWeaponRecords[i] = newWeapRecord;
               return i;
           }
       weaponIndex = UserWeaponRecords.Length;
       UserWeaponRecords[weaponIndex] = newWeapRecord;
       return weaponIndex;
    }
    return weaponIndex;
}
simulated function bool AddWeaponToGroup(class<KFWeapon> weaponClass, string groupName){
    local int i;
    local int weaponIndex;
    // Exit if there's no such group
    if(FindWeaponGroup(groupName) < 0)
       return false;
    weaponIndex = AddWeaponRecord(weaponClass);
    for(i = 0;i < UserWeaponRecords[weaponIndex].groupsNames.Length;i ++)
       if(UserWeaponRecords[weaponIndex].groupsNames[i] ~= groupName)
           return true;
    UserWeaponRecords[weaponIndex].groupsNames[UserWeaponRecords[weaponIndex].groupsNames.Length] = groupName;
    return true;
}
// Automatically adds weapon class to groups that requested it
simulated function AutoAddWeaponToGroups(class<KFWeapon> weaponClass){
    local int   i, j;
    local int   weaponIndex;
    local int   weaponPerkIndex;
    local bool  groupContains, requirementsMatch;
    // Indices of groups that don't contain 'weaponClass', but have auto addition enabled
    local array<int> autoGroups;
    weaponIndex = AddWeaponRecord(weaponClass);
    // Fill 'autoGroups' array
    for(i = 0;i < UserWeaponGroups.Length;i ++){
       // If that's not an auto add group - skip it
       if(!UserWeaponGroups[i].bAutoAddWeapon)
           continue;
       // Does this group already contain this weapon class?
       groupContains = false;
       for(j = 0;j < UserWeaponRecords[weaponIndex].groupsNames.Length;j ++)
           if(UserWeaponGroups[i].groupName ~= UserWeaponRecords[weaponIndex].groupsNames[j]){
               groupContains = true;
               break;
           }
       // If it doesn't - add it
       if(!groupContains)
           autoGroups[autoGroups.Length] = i;
    }
    // Add this weapon to new auto groups with suitable requirement
    for(i = 0;i < autoGroups.Length;i ++){
       requirementsMatch = false;
       // Let's just assume that there's always a pickup class, otherwise - wth?!
       // Match perk
       weaponPerkIndex = -1;
       if(class<KFWeaponPickup>(weaponClass.default.PickupClass) != none)
           weaponPerkIndex = class<KFWeaponPickup>(weaponClass.default.PickupClass).default.CorrespondingPerkIndex;
       requirementsMatch = (UserWeaponGroups[autoGroups[i]].autoPerk < 0 || UserWeaponGroups[autoGroups[i]].autoPerk == weaponPerkIndex);
       // Match InventoryGroup
       if(requirementsMatch && UserWeaponGroups[autoGroups[i]].autoInvGroups.Length > 0){
           // We reset flag here, but will set it to true if matching inventory group is found
           requirementsMatch = false;
           for(j = 0;j < UserWeaponGroups[autoGroups[i]].autoInvGroups.Length;j ++)
               if(UserWeaponGroups[autoGroups[i]].autoInvGroups[j] == weaponClass.default.InventoryGroup){
                   requirementsMatch = true;
                   break;
               }
       }
       // Add matched groups
       if(requirementsMatch)
           UserWeaponRecords[weaponIndex].groupsNames[UserWeaponRecords[weaponIndex].groupsNames.Length] = UserWeaponGroups[autoGroups[i]].groupName;
    }
}
simulated function int FindWeaponPreset(string presetName){
    local int i;
    for(i = 0;i < UserWeaponPresets.Length;i ++)
       if(UserWeaponPresets[i].presetName ~= presetName)
           return i;
    return -1;
}
simulated function int AddWeaponPreset(string presetName){
    local int presetIndex;
    local WeaponPreset newWeapPreset;
    presetIndex = FindWeaponPreset(presetName);
    if(presetIndex < 0){
       newWeapPreset.bCanBeRemoved = true;
       newWeapPreset.presetName = presetName;
       UserWeaponPresets[UserWeaponPresets.Length] = newWeapPreset;
       return UserWeaponPresets.Length - 1;
    }
    return presetIndex;
}
simulated function RemoveWeaponPreset(string presetName){
    local int presetIndex;
    presetIndex = FindWeaponPreset(presetName);
    if(presetIndex >= 0 && UserWeaponPresets[presetIndex].bCanBeRemoved)
       UserWeaponPresets.Remove(presetIndex, 1);
}
simulated function bool IsSubsetOf(array< class<KFWeapon> > subset, array< class<KFWeapon> > overset){
    local int i, j;
    local bool elementIncluded;
    for(i = 0;i < subset.Length;i ++){
       elementIncluded = false;
       for(j = 0;j < overset.Length;j ++)
           if(subset[i] == overset[j]){
               elementIncluded = true;
               break;
           }
       if(!elementIncluded)
           return false;
    }
    return true;
}
simulated function WeaponPreset GetCurrentPreset(int perk, array< class<KFWeapon> > currentInventory){
    local int i;
    local WeaponPreset loopPreset;
    for(i = 0;i < UserWeaponPresets.Length;i ++){
       loopPreset = UserWeaponPresets[i];
       if(loopPreset.reqPerk >= 0 && loopPreset.reqPerk != perk)
           continue;
       if(!IsSubsetOf(loopPreset.reqWeapons, currentInventory))
           continue;
       return loopPreset;
    }
    return DefaultWeaponPreset;
}
simulated function array<WeaponGroup> GetPresetGroups(WeaponPreset preset){
    local int i, j;
    local int groupIndex;
    local bool bRepeatingGroup;
    local array<WeaponGroup> result;
    for(i = 0;i < preset.groupsList.Length;i ++){
       bRepeatingGroup = false;
       for(j = 0; j < result.Length;j ++)
           if(preset.groupsList[i] ~= result[j].groupName){
               bRepeatingGroup = true;
               break;
           }
       if(!bRepeatingGroup){
           groupIndex = FindWeaponGroup(preset.groupsList[i]);
           if(groupIndex >= 0)
               result[result.Length] = UserWeaponGroups[groupIndex];
       }
    }
    return result;
}
simulated function UpdateDefaultWeaponSettings(){
    local int index;
    if(!bNiceWeaponManagementWasInitialized){
       UserWeaponGroups.Length = 0;
       UserWeaponPresets.Length = 0;
       UserWeaponRecords.Length = 0;
       AddWeaponPreset(WeapPresetGunslingerName);
       index = FindWeaponPreset(WeapPresetGunslingerName);
       if(index >= 0){
           UserWeaponPresets[index].bCanBeRemoved = true;
           UserWeaponPresets[index].presetName = WeapPresetGunslingerName;
           UserWeaponPresets[index].perkedFirst = false;
           UserWeaponPresets[index].reqPerk = 8;
           UserWeaponPresets[index].dumpSelector = -1;
           UserWeaponPresets[index].selectorsList[0] = 1;
           UserWeaponPresets[index].groupsList[0] = WeapGroupMeleeName;
           UserWeaponPresets[index].selectorsList[1] = 2;
           UserWeaponPresets[index].groupsList[1] = WeapGroupNonMeleeName;
           UserWeaponPresets[index].selectorsList[2] = 3;
           UserWeaponPresets[index].groupsList[2] = WeapGroupNonMeleeName;
           UserWeaponPresets[index].selectorsList[3] = 4;
           UserWeaponPresets[index].groupsList[3] = WeapGroupNonMeleeName;
           UserWeaponPresets[index].selectorsList[4] = 5;
           UserWeaponPresets[index].groupsList[4] = WeapGroupToolsName;
           bNiceWeaponManagementWasInitialized = true;
       }
    }
    index = AddWeaponGroup(WeapGroupMeleeName);
    UserWeaponGroups[index].bCanBeRemoved = false;
    UserWeaponGroups[index].bAutoAddWeapon = true;
    UserWeaponGroups[index].autoInvGroups[0] = 1;
    index = AddWeaponGroup(WeapGroupNonMeleeName);
    UserWeaponGroups[index].bCanBeRemoved = false;
    UserWeaponGroups[index].bAutoAddWeapon = true;
    UserWeaponGroups[index].autoInvGroups[0] = 2;
    UserWeaponGroups[index].autoInvGroups[1] = 3;
    UserWeaponGroups[index].autoInvGroups[2] = 4;
    index = AddWeaponGroup(WeapGroupPistolsName);
    UserWeaponGroups[index].bCanBeRemoved = false;
    UserWeaponGroups[index].bAutoAddWeapon = true;
    UserWeaponGroups[index].autoInvGroups[0] = 2;
    index = AddWeaponGroup(WeapGroupGeneralName);
    UserWeaponGroups[index].bCanBeRemoved = false;
    UserWeaponGroups[index].bAutoAddWeapon = true;
    UserWeaponGroups[index].autoInvGroups[0] = 3;
    UserWeaponGroups[index].autoInvGroups[1] = 4;
    index = AddWeaponGroup(WeapGroupToolsName);
    UserWeaponGroups[index].bCanBeRemoved = false;
    UserWeaponGroups[index].bAutoAddWeapon = true;
    UserWeaponGroups[index].autoInvGroups[0] = 5;
    DefaultWeaponPreset.bCanBeRemoved = false;
    DefaultWeaponPreset.reqPerk = -1;
    DefaultWeaponPreset.reqWeapons.Length = 0;
    DefaultWeaponPreset.dumpSelector = -1;
    DefaultWeaponPreset.presetName = WeapPresetDefaultName;
    DefaultWeaponPreset.selectorsList[0] = 1;
    DefaultWeaponPreset.groupsList[0] = WeapGroupMeleeName;
    DefaultWeaponPreset.selectorsList[1] = 2;
    DefaultWeaponPreset.groupsList[1] = WeapGroupPistolsName;
    DefaultWeaponPreset.selectorsList[2] = 3;
    DefaultWeaponPreset.groupsList[2] = WeapGroupGeneralName;
    DefaultWeaponPreset.selectorsList[3] = 4;
    DefaultWeaponPreset.groupsList[3] = WeapGroupGeneralName;
    DefaultWeaponPreset.selectorsList[4] = 5;
    DefaultWeaponPreset.groupsList[4] = WeapGroupToolsName;
}
simulated function array< class<KFWeapon> > SortWeaponArray(array< class<KFWeapon> > input, int perkIndex){
    local int i, j;
    local int weaponPerkIndex;
    local array< class<KFWeapon> > output, perked;
    for(i = 0;i < UserWeaponRecords.Length;i ++)
       for(j = 0;j < input.Length;j ++)
           if(UserWeaponRecords[i].weaponClass == input[j]){
               if(class<KFWeaponPickup>(input[j].default.PickupClass) != none)
                   weaponPerkIndex = class<KFWeaponPickup>(input[j].default.PickupClass).default.CorrespondingPerkIndex;
               if(perkIndex == weaponPerkIndex)
                   perked[perked.Length] = input[j];
               else
                   output[output.Length] = input[j];
               input.Remove(j, 1);
               break;
           }
    for(i = 0;i < perked.Length;i ++)
       output[output.Length] = perked[i];
    return output;
}
simulated function array< class<KFWeapon> > AddDumpSelector(int dumpSelectorNum, array<WeaponGroup> activeGroups, array< class<KFWeapon> > currentWeapons, array< class<KFWeapon> > emptyWeapons){
    local int i;
    local WeaponSelector tempSelector;
    i = 0;
    tempSelector.selectorNumber = dumpSelectorNum;
    // Add empty weapons to the bottom
    for(i = 0;i < emptyWeapons.Length;i ++)
       tempSelector.weaponList[tempSelector.weaponList.Length] = emptyWeapons[i];
    // Add weapons not in current active groups
    while(i < currentWeapons.Length)
       if(!IsWeaponInGroups(currentWeapons[i], activeGroups)){
           tempSelector.weaponList[tempSelector.weaponList.Length] = currentWeapons[i];
           currentWeapons.Remove(i, 1);
       }
       else
           i ++;
    activeSelectors[activeSelectors.Length] = tempSelector;
    return currentWeapons;
}
simulated function AddRegularSelectors(WeaponPreset currentPreset, array<WeaponGroup> activeGroups, array< class<KFWeapon> > currentWeapons){
    local int i, j, k;
    local int remWeaps;
    local int groupWeaponsAmount, groupSelectorsAmount;
    local WeaponSelector tempSelector;
    local array<WeaponSelector> groupSelectors;
    local array< class<KFWeapon> > groupWeapons;
    // Build selectors for each group
    hasZeroSelector = false;
    tempSelector.weaponList.Length = 0;
    for(i = 0;i < activeGroups.Length;i ++){
       groupWeapons = FilterWeaponsByGroup(currentWeapons, activeGroups[i].groupName);
       // Add empty selectors
       groupSelectors.Length = 0;
       for(j = 0;j < currentPreset.groupsList.Length && j < currentPreset.selectorsList.Length;j ++){
           if(currentPreset.groupsList[j] ~= activeGroups[i].groupName){
               tempSelector.selectorNumber = currentPreset.selectorsList[j];
               groupSelectors[groupSelectors.Length] = tempSelector;
           }
       }
       // Distribute weapons by selectors
       groupWeaponsAmount = groupWeapons.Length;
       groupSelectorsAmount = groupSelectors.Length;
       if(groupWeaponsAmount == groupSelectorsAmount)
           for(j = 0;j < groupSelectorsAmount;j ++)
               groupSelectors[j].weaponList[0] = groupWeapons[j];
       else if(groupWeaponsAmount < groupSelectorsAmount && groupWeaponsAmount > 0)
           for(j = 0;j < groupSelectorsAmount;j ++)
               groupSelectors[j].weaponList[0] = groupWeapons[Min(j, groupWeaponsAmount - 1)];
       else{
           remWeaps = groupWeaponsAmount % groupSelectorsAmount;
           // Load the uneven part
           for(j = 0;j < remWeaps;j ++)
               groupSelectors[j].weaponList[0] = groupWeapons[j];
           // Load everything else
           k = 0;
           for(j = remWeaps;j < groupWeaponsAmount;j ++){
               groupSelectors[k].weaponList[groupSelectors[k].weaponList.Length] = groupWeapons[j];
               k ++;
               k = k % groupSelectorsAmount;
           }
       }
       // Add selectors to main group and check if there's non-empty 0-selector
       for(j = 0;j < groupSelectorsAmount;j ++){
           activeSelectors[activeSelectors.Length] = groupSelectors[j];
           if(groupSelectors[j].selectorNumber == 0 && groupSelectors[j].weaponList.Length > 0)
               hasZeroSelector = true;
       }
    }
}
simulated function UpdateSelectors(){
    local int i;
    // Variables for finding veterancy and current weapon list
    local Inventory Inv;
    local NiceHumanPawn nicePawn;
    local KFPlayerReplicationInfo KFPRI;
    local class<ScrnVeterancyTypes> scrnVet;
    // Veterancy and current weapon list
    local int currPerk;
    local array< class<KFWeapon> > emptyWeapons;
    local array< class<KFWeapon> > currentWeapons;
    // Variables directly necessary to sort weapons by selectors
    local bool bSortByPerk;
    local int dumpSelector;
    local WeaponPreset currentPreset;
    local array<WeaponGroup> activeGroups;
    // Find current veterancy index
    nicePawn = NiceHumanPawn(Pawn);
    KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);
    if(nicePawn == none || KFPRI == none || KFPRI.ClientVeteranSkill == none)
       return;
    scrnVet = class<ScrnVeterancyTypes>(KFPRI.ClientVeteranSkill);
    if(scrnVet != none)
       currPerk = scrnVet.default.PerkIndex;
    else
       currPerk = -1;
    // Build weapons list
    for(Inv = nicePawn.Inventory;Inv != none;Inv = Inv.Inventory)
       if(class<KFWeapon>(Inv.class) != none && class<Frag>(Inv.class) == none){
           //if(KFWeapon(Inv).HasAmmo())
           currentWeapons[currentWeapons.Length] = class<KFWeapon>(Inv.class);
           //else
           //    emptyWeapons[emptyWeapons.Length] = class<KFWeapon>(Inv.class);
           // Add weapon to required groups before using it
           AutoAddWeaponToGroups(class<KFWeapon>(Inv.class));
       }
    // Find active groups and read setting from the preset
    currentPreset = GetCurrentPreset(currPerk, currentWeapons);
    activeGroups = GetPresetGroups(currentPreset);
    bUsesMouseWheel = currentPreset.bUsesMouseWheel;
    bMouseWheelLoops = currentPreset.bMouseWheelLoops;
    if(currentPreset.presetName ~= WeapPresetDefaultName)
       bSortByPerk = bPrioritizePerkedWeapons;
    else
       bSortByPerk = currentPreset.perkedFirst;
    if(bSortByPerk)
       currentWeapons = SortWeaponArray(currentWeapons, currPerk);
    else
       currentWeapons = SortWeaponArray(currentWeapons, -1);
    // Verify that dump selector exists and isn't used for something else
    dumpSelector = currentPreset.dumpSelector;
    if(dumpSelector >= 0){
       for(i = 0;i < currentPreset.selectorsList.Length;i ++)
           if(dumpSelector == currentPreset.selectorsList[i]){
               dumpSelector = -1;
               break;
           }
    }
    //////// Selectors building
    activeSelectors.Length = 0;
    // Add dump selector
    if(dumpSelector >= 0)
       currentWeapons = AddDumpSelector(dumpSelector, activeGroups, currentWeapons, emptyWeapons);
    AddRegularSelectors(currentPreset, activeGroups, currentWeapons);
}
simulated function ClientShowScrnMenu(bool bDoShow){
    class'NiceInvasionLoginMenu'.default.bShowScrnMenu = bDoShow;
    bShowScrnMenu = bDoShow;
}
simulated function ClientSetNiceWeapManagement(bool bDoManage){
    if(bDoManage && !bNiceWeaponManagement)
       UpdateSelectors();
    bNiceWeaponManagement = bDoManage;
}
simulated function ScrollSelector(byte F, bool bLoop, optional bool bReverse){
    local int i;
    local bool bFoundWeapon;
    local bool endOfSelector;
    local bool bAllowToStartOver;
    local int selectorIndex;
    // Find selector's index
    selectorIndex = -1;
    for(i = 0;i < activeSelectors.Length;i ++)
       if(activeSelectors[i].selectorNumber == F){
           selectorIndex = i;
           break;
       }
    // Do nothing in case of missing/empty selector or missing pawn
    if(selectorIndex == -1 || Pawn == none || activeSelectors[selectorIndex].weaponList.Length <= 0)
       return;
    // Find current weapon's place in this selector
    if(bReverse)
       i = 0;
    else
       i = activeSelectors[selectorIndex].weaponList.Length - 1;
    bFoundWeapon = false;
    endOfSelector = false;
    while(!endOfSelector){
       if(Pawn.Weapon == none || activeSelectors[selectorIndex].weaponList[i] == Pawn.Weapon.class){
           bFoundWeapon = (activeSelectors[selectorIndex].weaponList[i] == Pawn.Weapon.class);
           break;
       }
       if(bReverse){
           i ++;
           endOfSelector = i >= activeSelectors[selectorIndex].weaponList.Length;
       }
       else{
           i --;
           endOfSelector = i < 0;
       }
    }
    // If weapon isn't from this selector, or is placed at it's end (and looping is allowed) - begin from the start
    bAllowToStartOver = (!bFoundWeapon || bLoop);
    if(bReverse){
       if(i < activeSelectors[selectorIndex].weaponList.Length - 1)
           GetWeapon(activeSelectors[selectorIndex].weaponList[i + 1]);
       else if(bAllowToStartOver)
           GetWeapon(activeSelectors[selectorIndex].weaponList[0]);
    }
    else{
       if(i > 0)
           GetWeapon(activeSelectors[selectorIndex].weaponList[i - 1]);
       else if(bAllowToStartOver)
           GetWeapon(activeSelectors[selectorIndex].weaponList[activeSelectors[selectorIndex].weaponList.Length - 1]);
    }
}
simulated function ClientSetZedStun(NiceMonster zed, bool bStun, float duration){
    if(zed == none)
       return;
    if(bStun)
       zed.StunCountDown = duration;
    else
       zed.StunCountDown = 0.0;
    zed.StunRefreshClient(bStun);
}
exec function SwitchWeapon(byte F){
    if(!bNiceWeaponManagement)
       super.SwitchWeapon(F);
    else{
       UpdateSelectors();
       ScrollSelector(F, true);
    }
}
exec function GetWeapon(class<Weapon> NewWeaponClass){
    local Inventory Inv;
    local int Count;
    if((Pawn == none) || (Pawn.Inventory == none) || (NewWeaponClass == none))
       return;
    if((Pawn.Weapon != none) && (Pawn.Weapon.Class == NewWeaponClass) && (Pawn.PendingWeapon == none)){
       Pawn.Weapon.Reselect();
       return;
    }
    if(Pawn.PendingWeapon != none && Pawn.PendingWeapon.bForceSwitch)
       return;
    for(Inv = Pawn.Inventory;Inv != none;Inv = Inv.Inventory){
       if(Inv.Class == NewWeaponClass){
           Pawn.PendingWeapon = Weapon(Inv);
           if(Pawn.Weapon != none)
               Pawn.Weapon.PutDown();
           else
               ChangedWeapon();
           return;
       }
       Count ++;
       if(Count > 1000)
           return;
    }
}
function ServerSetViewTarget(Actor NewViewTarget){
    local bool bWasSpec;
    if(!IsInState('Spectating'))
       return;
    bWasSpec = !bBehindView && ViewTarget != Pawn && ViewTarget != self;
    SetViewTarget(NewViewTarget);
    ViewTargetChanged();
    ClientSetViewTarget(NewViewTarget);
    if(ViewTarget == self || bWasSpec)
       bBehindView = false;
    else
       bBehindView = true;
    ClientSetBehindView(bBehindView);
}
function ViewTargetChanged(){
    local Controller C;
    local ScrnHumanPawn ScrnVT;
    if(Role < ROLE_Authority)
       return;
    ScrnVT = ScrnHumanPawn(OldViewTarget);
    if(ScrnVT != none && ScrnVT != ViewTarget){
       for(C = Level.ControllerList;C != none;C = C.NextController){
           if(C.Pawn != ScrnVT && PlayerController(C) != none && PlayerController(C).ViewTarget == ScrnVT)
               break;
       }
       ScrnVT.bViewTarget = (C != none);
    }
    ScrnVT = ScrnHumanPawn(ViewTarget);
    if (ScrnVT != none)
           ScrnVT.bViewTarget = true; // tell pawn that we are watching him
    OldViewTarget = ViewTarget;
}
// Reloaded to add nice single/dual classes
function LoadDualWieldables(){
    local ClientPerkRepLink CPRL;
    local class<NiceWeaponPickup> WP;
    local class<NiceSingle> W;
    local int i;
    
    CPRL = class'ClientPerkRepLink'.Static.FindStats(self);
    if(CPRL == none || CPRL.ShopInventory.Length == 0)
       return;
    for(i = 0;i < CPRL.ShopInventory.Length;i ++){
       WP = class<NiceWeaponPickup>(CPRL.ShopInventory[i].PC);
       if(WP == none)
           continue;
       W = class<NiceSingle>(WP.default.InventoryType);
       if(W != none && W.default.DualClass != none)
           AddDualWieldable(W, W.default.DualClass);
    }
    super.LoadDualWieldables();
}
// If player only has one pistol out of two possible, then return 'false'
// Because he's got the right one and new one is the left one; completely different stuff
function bool IsInInventory(class<Pickup> PickupToCheck, bool bCheckForEquivalent, bool bCheckForVariant){
    local bool bResult;
    local Inventory CurInv;
    local NiceSingle singlePistol;
    bResult = super.IsInInventory(PickupToCheck, bCheckForEquivalent, bCheckForVariant);
    if(!bResult || class<NiceSinglePickup>(PickupToCheck) == none)
       return bResult;
    for(CurInv = Pawn.Inventory; CurInv != none; CurInv = CurInv.Inventory)
       if(CurInv.default.PickupClass == PickupToCheck){
           singlePistol = NiceSingle(CurInv);
           if(singlePistol != none && !singlePistol.bIsDual)
               return false;
           else
               break;
       }
    return bResult;
}
state Spectating{
    exec function Use(){
       local vector HitLocation, HitNormal, TraceEnd, TraceStart;
       local rotator R;
       local Actor A;

       PlayerCalcView(A, TraceStart, R);
       TraceEnd = TraceStart + 1000 * Vector(R);
       A = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true);
       if(Pawn(A) != none)
           ServerSetViewTarget(A);
    }    
}
simulated function ClientSpawnGhostProjectile(Vector Start, int pitch, int yaw, int roll, NiceFire.ShotType shotParams, NiceFire.FireModeContext fireContext, bool bForceComplexTraj){
    local Rotator projectileDir;
    projectileDir.Pitch = pitch;
    projectileDir.Yaw   = yaw;
    projectileDir.Roll  = roll;
    class'NiceProjectileSpawner'.static.SpawnProjectile(Start, projectileDir, shotParams, fireContext, true, bForceComplexTraj);
}
simulated function ClientStickGhostProjectile(KFHumanPawn instigator, Actor base, name bone, Vector shift, Rotator rot,
    NiceBullet.ExplosionData expData, int stuckID){
    class'NiceProjectileSpawner'.static.SpawnStuckProjectile(instigator, base, bone, shift, rot, expData, true,
       stuckID);
}
simulated function SpawnSirenBall(NiceZombieSiren siren){
    if(NicePackMutator == none || siren == none)
       return;
    ClientSpawnSirenBall(siren, NicePackMutator.nextSirenScreamID);
    siren.currentScreamID = NicePackMutator.nextSirenScreamID;
    NicePackMutator.nextSirenScreamID ++;
}
simulated function ClientSpawnSirenBall(NiceZombieSiren siren, int ID){
    if(localCollisionManager == none || siren == none || siren.screamTimings.Length <= 0)
       return;
    localCollisionManager.AddSphereCollision(ID, siren.ScreamRadius * 0.75, siren, Level.TimeSeconds + siren.screamLength * (siren.screamTimings[siren.screamTimings.Length-1] - siren.screamTimings[0]));
}
simulated function ClientRemoveSirenBall(int ID){
    if(localCollisionManager == none)
       return;
    localCollisionManager.RemoveSphereCollision(ID);
}
simulated function ClientNailsExplosion(int amount, Vector start, NiceFire.ShotType shotParams,
    NiceFire.FireModeContext fireContext, optional bool bIsGhost){
    local int i;
    for(i = 0;i < amount;i ++)
       class'NiceProjectileSpawner'.static.SpawnProjectile(start, RotRand(true), shotParams, fireContext, bIsGhost);
}
simulated function AddEffect(){
    effectsSpawned[currentEffectTimeWindow] ++;
}
simulated function bool CanSpawnEffect(bool bIsGhost){
    local int i;
    local int totalEffects;
    local bool surpSoftLimit, surpHardLimit, surpQuota;
    for(i = 0;i < 10;i ++)
       totalEffects += effectsSpawned[i];
    surpQuota       = (0.1 * effectsSpawned[currentEffectTimeWindow]) >= effectsLimitHard;
    surpSoftLimit   = totalEffects > effectsLimitSoft;
    surpHardLimit   = totalEffects > effectsLimitHard;
    if(bIsGhost && (surpQuota || surpSoftLimit))
       return false;
    if(surpHardLimit)
       return false;
    return true;
}
simulated function RegisterStuckBullet(NiceBullet bullet){
    local StuckBulletRecord newRecord;
    if(bullet == none)
       return;
    newRecord.bullet = bullet;
    newRecord.registrationTime = Level.TimeSeconds;
    stuckBulletsSet[stuckBulletsSet.Length] = newRecord;
}
simulated function ExplodeStuckBullet(int id){
    local int i;
    local array<StuckBulletRecord> newSet;
    for(i = 0;i < stuckBulletsSet.Length;i ++)
       if(stuckBulletsSet[i].bullet.stuckID == id)
           stuckBulletsSet[i].bullet.DoExplode(stuckBulletsSet[i].bullet.location,
               stuckBulletsSet[i].bullet.movementDirection);
       else
           newSet[newSet.Length] = stuckBulletsSet[i];
    stuckBulletsSet = newSet;
}
simulated function FreeOldStuckBullets(){
    local int i;
    local array<StuckBulletRecord> newSet;
    if(stuckBulletsSet.Length <= 0)
       return;
    for(i = 0;i < stuckBulletsSet.Length;i ++)
       if( stuckBulletsSet[i].bullet != none &&
           (!stuckBulletsSet[i].bullet.bGhost || stuckBulletsSet[i].registrationTime + 60.0 <= Level.TimeSeconds))
           newSet[newSet.Length] = stuckBulletsSet[i];
       else if(stuckBulletsSet[i].bullet != none)
           stuckBulletsSet[i].bullet.KillBullet();
    stuckBulletsSet = newSet;
}
// Dualies functions
exec function SwitchDualies(){
    local NiceSingle singlePistol;
    local NiceDualies dualPistols;
    if(Pawn != none){
       singlePistol = NiceSingle(Pawn.Weapon);
       dualPistols = NiceDualies(Pawn.Weapon);
    }
    if(singlePistol != none)
       singlePistol.ServerSwitchToDual();
    else if(dualPistols != none)
       dualPistols.ServerSwitchToSingle();
}
exec function SwitchToOtherSingle(){
    local NiceSingle singlePistol;
    if(Pawn != none)
       singlePistol = NiceSingle(Pawn.Weapon);
    if(singlePistol != none)
       singlePistol.ServerSwitchToOtherSingle();
}
exec function FireLeftGun(){
    local NiceDualies dualPistols;
    if(Pawn != none)
       dualPistols = NiceDualies(Pawn.Weapon);
    if(dualPistols != none)
       dualPistols.FireGivenGun(true);
}
exec function FireRightGun(){
    local NiceDualies dualPistols;
    if(Pawn != none)
       dualPistols = NiceDualies(Pawn.Weapon);
    if(dualPistols != none)
       dualPistols.FireGivenGun(false);
}
exec function ActivateAbility(int abilityIndex){
    if(abilityIndex < 0)
       return;
    if(abilityIndex >= abilityManager.currentAbilitiesAmount)
       return;
    switch(abilityManager.currentAbilities[abilityIndex].myState){
    case ASTATE_READY:
       abilityManager.SetAbilityState(abilityIndex, ASTATE_ACTIVE);
       break;
    case ASTATE_ACTIVE:
       abilityManager.SetAbilityState(abilityIndex, ASTATE_READY);
       break;
    }
}
simulated function ClientPrint(){
    if(storageClient == none) return;
    storageClient.Print(self);
}

exec simulated function DoConnect(string S){
    local bool varb;
    if(storageClient == none) return;
    varb = storageClient.ConnectData(S);
}

exec simulated function DoCreate(string S){
    if(storageClient == none) return;
    storageClient.CreateData(S, NSP_HIGH);
}

exec simulated function DoesExist(string S){
    if(storageClient == none) return;
    storageClient.DoesDataExistOnServer(S);
}

exec simulated function DoGetAccess(string S){
    if(storageClient == none) return;
    storageClient.RequestWriteAccess(S);
}

exec simulated function DoFree(string S){
    if(storageClient == none) return;
    storageClient.GiveupWriteAccess(S);
}

exec simulated function DoSet(string dataName, string varName, int varValue){
    if(storageClient == none) return;
    storageClient.GetData(dataName).SetInt(varName, varValue);
}

exec simulated function Siren(float value)
{
    sirenScreamMod = value;
}

defaultproperties
{
     nicePlayerInfoVersionNumber=1
     bAltSwitchesModes=True
     bAdvReloadCheck=True
     bRelCancelByFire=True
     bRelCancelBySwitching=True
     bRelCancelByNades=True
     bRelCancelByAiming=True
     bNiceWeaponManagement=True
     bDisplayCounters=True
     bDisplayWeaponProgress=True
     bShowScrnMenu=True
     maxPlayedWithRecords=100
     WeapGroupMeleeName="Melee"
     WeapGroupNonMeleeName="NonMelee"
     WeapGroupPistolsName="Pistols"
     WeapGroupGeneralName="General"
     WeapGroupToolsName="Tools"
     WeapPresetDefaultName="Default"
     WeapPresetGunslingerName="Gunslinger"
     tracesPerTickLimit=1000
     effectsLimitSoft=100
     effectsLimitHard=200
     sirenScreamMod=1.000000
     TSCLobbyMenuClassString="NicePack.NiceTSCLobbyMenu"
     LobbyMenuClassString="NicePack.NiceLobbyMenu"
     PawnClass=Class'NicePack.NiceHumanPawn'
}
