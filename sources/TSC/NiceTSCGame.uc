class NiceTSCGame extends TSCGame;
// Copy-pasted from NiceGameType
var NicePack NicePackMutator;
function RegisterMutator(NicePack activePack){
    NicePackMutator = activePack;
}
function SetupWave(){
    Super.SetupWave();
    // Event call
    NicePackMutator.WaveStart();
}
function RestartPlayer(Controller aPlayer){
    Super.RestartPlayer(aPlayer);
    if(aPlayer.Pawn != none && NicePlayerController(aPlayer) != none)       NicePlayerController(aPlayer).PawnSpawned();
}
State MatchInProgress{
    function BeginState(){       Super(Invasion).BeginState();
       WaveNum = InitialWave;       InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
       if(NicePackMutator.bInitialTrader)           WaveCountDown = NicePackMutator.initialTraderTime + 10;       else           WaveCountDown = 10;
       SetupPickups();       // Event call       NicePackMutator.MatchBegan();
    }
    function DoWaveEnd(){       Super.DoWaveEnd();       // Event call       NicePackMutator.TraderStart();
    }
}
function DramaticEvent(float BaseZedTimePossibility, optional float DesiredZedTimeDuration){
    local bool bWasZedTime;
    bWasZedTime = bZEDTimeActive;
    Super.DramaticEvent(BaseZedTimePossibility, DesiredZedTimeDuration);
    // Call events
    if(!bWasZedTime && bZEDTimeActive)       NicePackMutator.ZedTimeActivated();
}
event Tick(float DeltaTime){
    local float TrueTimeFactor;
    local Controller C;
    if(bZEDTimeActive){       TrueTimeFactor = 1.1 / Level.TimeDilation;       CurrentZEDTimeDuration -= DeltaTime * TrueTimeFactor;       if(CurrentZEDTimeDuration < (ZEDTimeDuration*0.166) && CurrentZEDTimeDuration > 0 ){           if(!bSpeedingBackUp){               bSpeedingBackUp = true;
               for(C = Level.ControllerList;C != none;C = C.NextController){                   if(KFPlayerController(C)!= none)                       KFPlayerController(C).ClientExitZedTime();               }           }           SetGameSpeed(Lerp( (CurrentZEDTimeDuration/(ZEDTimeDuration*0.166)), 1.0, 0.2 ));       }       if(CurrentZEDTimeDuration <= 0){           if(bZEDTimeActive)               NicePackMutator.ZedTimeDeactivated();           bZEDTimeActive = false;           bSpeedingBackUp = false;           SetGameSpeed(1.0);           ZedTimeExtensionsUsed = 0;       }
    }
}
function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> dmgType){
    local KFSteamStatsAndAchievements StatsAndAchievements;
    Super.Killed(Killer, Killed, KilledPawn, dmgType);
    if(PlayerController(Killer) != none){       if (NiceMonster(KilledPawn) != none && Killed != Killer){           StatsAndAchievements = KFSteamStatsAndAchievements(PlayerController(Killer).SteamStatsAndAchievements);           if(StatsAndAchievements != none){               if(KilledPawn.IsA('NiceZombieStalker') || KilledPawn.IsA('MeanZombieStalker')){                   if(class<NiceDamTypeWinchester>(dmgType) != none)                       StatsAndAchievements.AddStalkerKillWithLAR();               }               else if(KilledPawn.IsA('NiceZombieClot') || KilledPawn.IsA('MeanZombieClot')){                   if(class<NiceDamTypeWinchester>(dmgType) != none)                       KFSteamStatsAndAchievements(PlayerController(Killer).SteamStatsAndAchievements).AddClotKillWithLAR();               }           }       }
    }
}
// Reloaded to award damage
function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType){
    local NiceMonster niceZed;
    local KFPlayerController PC;
    niceZed = NiceMonster(Injured);
    if(niceZed != none){       if(instigatedBy != none){           PC = KFPlayerController(instigatedBy.Controller);           if(class<NiceWeaponDamageType>(damageType) != none && PC != none)               class<NiceWeaponDamageType>(damageType).Static.AwardNiceDamage(KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements), Clamp(Damage, 1, Injured.Health), niceZed.scrnRules.HardcoreLevel);       }
    }
    return Super.ReduceDamage(Damage, injured, InstigatedBy, HitLocation, Momentum, DamageType);
}
defaultproperties
{    GameName="Nice Team Survival Competition"    Description="Nice Edition of Team Survival Competition (TSCGame)."
}
