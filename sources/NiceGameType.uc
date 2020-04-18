// made to fix KFStoryGameInfo loading for KFO maps
class NiceGameType extends ScrnGameType;
var NicePack NicePackMutator;
function RegisterMutator(NicePack activePack){
    NicePackMutator = activePack;
}
function OverrideMonsterHealth(KFMonster M){}
/*event InitGame(string Options, out string Error){
    local int i, j;
    if(ScrnGameLength == none)
       ScrnGameLength = new(none, string(KFGameLength)) class'ScrnGameLength';
    for(i = 0;i < ScrnGameLength.
}*/
function int SpawnSquad(ZombieVolume ZVol, out array< class<KFMonster> > Squad, optional bool bLogSpawned ){
    local int i, j;
    local array<NicePack.ZedRecord> zedDatabase;
    if(NicePackMutator != none){
       zedDatabase = NicePackMutator.zedDatabase;
       for(i = 0;i < zedDatabase.Length;i ++){
           for(j = 0;j < Squad.Length;j ++){
               if(zedDatabase[i].bNeedsReplacement && zedDatabase[i].ZedType == Squad[j])
                   Squad[j] = zeddatabase[i].MeanZedType;
           }
       }
    }
    return super.SpawnSquad(ZVol, Squad, bLogSpawned);
}
function SetupWave(){
    Super.SetupWave();
    // Event call
    NicePackMutator.WaveStart();
}
function RestartPlayer(Controller aPlayer){
    Super.RestartPlayer(aPlayer);
    if(aPlayer.Pawn != none && NicePlayerController(aPlayer) != none)
       NicePlayerController(aPlayer).PawnSpawned();
}
State MatchInProgress{
    function BeginState(){
       Super(Invasion).BeginState();

       WaveNum = InitialWave;
       InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;

       if(NicePackMutator.bInitialTrader)
           WaveCountDown = NicePackMutator.initialTraderTime + 5;
       else
           WaveCountDown = 10;

       SetupPickups();
       if(ScrnGameLength != none && !ScrnGameLength.LoadWave(WaveNum))
           DoWaveEnd();

       // Event call
       NicePackMutator.MatchBegan();
    }
    function DoWaveEnd(){
       Super.DoWaveEnd();
       // Event call
       NicePackMutator.TraderStart();
    }
    function StartWaveBoss(){
       Super.StartWaveBoss();
       // Event call
       NicePackMutator.WaveStart();
    }
}
function DramaticEvent(float BaseZedTimePossibility, optional float DesiredZedTimeDuration){
    local bool bWasZedTime;
    bWasZedTime = bZEDTimeActive;
    Super.DramaticEvent(BaseZedTimePossibility, DesiredZedTimeDuration);
    // Call event
    if(!bWasZedTime && bZEDTimeActive)
       NicePackMutator.ZedTimeActivated();
}
event Tick(float DeltaTime){
    local float TrueTimeFactor;
    local Controller C;
    if(bZEDTimeActive){
       TrueTimeFactor = 1.1 / Level.TimeDilation;
       CurrentZEDTimeDuration -= DeltaTime * TrueTimeFactor;
       if(CurrentZEDTimeDuration < (ZEDTimeDuration*0.166) && CurrentZEDTimeDuration > 0 ){
           if(!bSpeedingBackUp){
               bSpeedingBackUp = true;

               for(C = Level.ControllerList;C != none;C = C.NextController){
                   if(KFPlayerController(C)!= none)
                       KFPlayerController(C).ClientExitZedTime();
               }
           }
           SetGameSpeed(Lerp( (CurrentZEDTimeDuration/(ZEDTimeDuration*0.166)), 1.0, 0.2 ));
       }
       if(CurrentZEDTimeDuration <= 0){
           if(bZEDTimeActive)
               NicePackMutator.ZedTimeDeactivated();
           bZEDTimeActive = false;
           bSpeedingBackUp = false;
           SetGameSpeed(1.0);
           ZedTimeExtensionsUsed = 0;
       }
    }
}
function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> dmgType){
    local GameRules rules;
    local ScrnGameRules scrnRules;
    local KFSteamStatsAndAchievements StatsAndAchievements;
    Super.Killed(Killer, Killed, KilledPawn, dmgType);
    if(PlayerController(Killer) != none){
       if(NiceMonster(KilledPawn) != none && Killed != Killer){
           StatsAndAchievements = KFSteamStatsAndAchievements(PlayerController(Killer).SteamStatsAndAchievements);
           if(StatsAndAchievements != none){
               if(KilledPawn.IsA('NiceZombieStalker') || KilledPawn.IsA('MeanZombieStalker')){
                   if(class<NiceDamTypeWinchester>(dmgType) != none)
                       StatsAndAchievements.AddStalkerKillWithLAR();
               }
               else if(KilledPawn.IsA('NiceZombieClot') || KilledPawn.IsA('MeanZombieClot')){
                   if(class<NiceDamTypeWinchester>(dmgType) != none)
                       KFSteamStatsAndAchievements(PlayerController(Killer).SteamStatsAndAchievements).AddClotKillWithLAR();
               }
               if(class<NiceWeaponDamageType>(dmgType) != none){
                   for(rules = Level.Game.GameRulesModifiers;rules != none;rules = rules.NextGameRules)
                       if(ScrnGameRules(rules) != none){
                           scrnRules = ScrnGameRules(rules);
                           break;
                       }
                   if(scrnRules != none)
                       class<NiceWeaponDamageType>(dmgType).Static.AwardNiceKill(StatsAndAchievements, KFPlayerController(Killer), KFMonster(KilledPawn), scrnRules.HardcoreLevel);
               }
           }
       }
    }
}
// Reloaded to award damage
function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType){
    local NiceMonster niceZed;
    local KFPlayerController PC;
    niceZed = NiceMonster(Injured);
    if(niceZed != none){
       if(instigatedBy != none){
           PC = KFPlayerController(instigatedBy.Controller);
           if(class<NiceWeaponDamageType>(damageType) != none && PC != none)
               class<NiceWeaponDamageType>(damageType).Static.AwardNiceDamage(KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements), Clamp(Damage, 1, Injured.Health), niceZed.scrnRules.HardcoreLevel);
       }
    }
    return Super.ReduceDamage(Damage, injured, InstigatedBy, HitLocation, Momentum, DamageType);
}
defaultproperties
{
    GameName="Nice Floor"
    Description="Nice Edition of ScrN Killing Floor game mode (ScrnGameType)."
}
