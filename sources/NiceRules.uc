class NiceRules extends GameRules;
var ScrnGameRules ScrnRules;
function PostBeginPlay(){
    if(Level.Game.GameRulesModifiers == none)
       Level.Game.GameRulesModifiers = Self;
    else{
       // We need to be the ones giving achievements first
       Self.AddGameRules(Level.Game.GameRulesModifiers);
       Level.Game.GameRulesModifiers = Self;
    }
    if(NicePack(Owner) != none)
       ScrnRules = NicePack(Owner).ScrnMut.GameRules;
    else{
       Log("Wrong owner! Owner must be NicePack!");
       Destroy();
    }
}
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason){
    local bool bWin;
    local string MapName;
    if(Level.Game.IsInState('PendingMatch'))
       return false;
    if(Level.Game.bGameEnded)
       return true;
    if(NextGameRules != none && !NextGameRules.CheckEndGame(Winner,Reason))
       return false;
    if(ScrnRules.Mut.bStoryMode)
       bWin = Reason ~= "WinAction";
    else{
       bWin = KFGameReplicationInfo(Level.GRI) != none && KFGameReplicationInfo(Level.GRI).EndGameType == 2;
    }
    if(bWin){
       // Map achievements
       MapName = ScrnRules.Mut.KF.GetCurrentMapName(Level);
       ScrnRules.CheckMapAlias(MapName);
       GiveMapAchievements(MapName);
    }
    return true;
}
// We would never get ScrN Sui and Hoe achievs with our new zeds, so let's add them ourselves. For different reasons.
function GiveMapAchievements(optional String MapName){
    local bool bCustomMap, bGiveHardAch, bGiveSuiAch, bGiveHoeAch, bNewAch;
    local ScrnPlayerInfo SPI;
    local ClientPerkRepLink PerkLink;
    local TeamInfo WinnerTeam;
    WinnerTeam = TeamInfo(Level.Game.GameReplicationInfo.Winner);
    if(ScrnRules.Mut.bStoryMode){
       bGiveHardAch = Level.Game.GameDifficulty >= 4;
       bGiveSuiAch = Level.Game.GameDifficulty >= 5;
       bGiveHoeAch = Level.Game.GameDifficulty >= 7;
    }
    else{
       bGiveHardAch = ScrnRules.HardcoreLevel >= 5;
       bGiveSuiAch = ScrnRules.HardcoreLevel >= 10;
       bGiveHoeAch = ScrnRules.HardcoreLevel >= 15;
    }
    for (SPI = ScrnRules.PlayerInfo;SPI != none;SPI = SPI.NextPlayerInfo){
       if (SPI.PlayerOwner == none || SPI.PlayerOwner.PlayerReplicationInfo == none)
           continue;
               PerkLink = SPI.GetRep();
       if(PerkLink == none)
           continue;
       if(WinnerTeam != none && SPI.PlayerOwner.PlayerReplicationInfo.Team != WinnerTeam)
           continue; // no candies for loosers
           // additional achievements that are granted only when surviving the game
       if(ScrnPlayerController(SPI.PlayerOwner) != none && !ScrnPlayerController(SPI.PlayerOwner).bChangedPerkDuringGame)
           SPI.ProgressAchievement('PerkFavorite', 1);  

       //unlock "Normal" achievement and see if the map is found
       bCustomMap = ScrnRules.MapAchClass.static.UnlockMapAchievement(PerkLink, MapName, 0) == -2;  
       bNewAch = false;
       if(bCustomMap){
           //map not found - progress custom map achievements
           if(bGiveHardAch)
               ScrnRules.AchClass.static.ProgressAchievementByID(PerkLink, 'WinCustomMapsHard', 1);
           if(bGiveSuiAch)
               ScrnRules.AchClass.static.ProgressAchievementByID(PerkLink, 'WinCustomMapsSui', 1);
           if(bGiveHoeAch)
               ScrnRules.AchClass.static.ProgressAchievementByID(PerkLink, 'WinCustomMapsHoE', 1);
           ScrnRules.AchClass.static.ProgressAchievementByID(PerkLink, 'WinCustomMapsNormal', 1);
           ScrnRules.AchClass.static.ProgressAchievementByID(PerkLink, 'WinCustomMaps', 1);
       }   
       else{
           //map found - give related achievements
           if(bGiveHardAch)
               ScrnRules.MapAchClass.static.UnlockMapAchievement(PerkLink, MapName, 1);
           if(bGiveSuiAch)
               ScrnRules.MapAchClass.static.UnlockMapAchievement(PerkLink, MapName, 2);
           if(bGiveHoeAch)
               ScrnRules.MapAchClass.static.UnlockMapAchievement(PerkLink, MapName, 3);
       }
    }
}
function int NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType){
    local TeamGame TG;
    TG = TeamGame(Level.Game);
    if(KFPawn(injured) != none && TG != none && Damage > 0 && class<DamTypeEnemyBase>(DamageType) == none){
       if((KFPawn(instigatedBy) != none || FakePlayerPawn(instigatedBy) != none) && (instigatedBy.PlayerReplicationInfo == none || instigatedBy.PlayerReplicationInfo.bOnlySpectator)){
           Momentum = vect(0,0,0);
           if(NoFF(injured, TG.FriendlyFireScale))
               return 0;
           else if(OriginalDamage == Damage)
               return Damage * TG.FriendlyFireScale;
       }
       else if(instigatedBy == none && !DamageType.default.bCausedByWorld){
           Momentum = vect(0,0,0);
           if(NoFF(injured, TG.FriendlyFireScale))
               return 0;
           else if(OriginalDamage == Damage)
               return Damage * TG.FriendlyFireScale;
       }
    }
    return super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
}
function bool NoFF(Pawn injured, float FF){
    return (FF == 0.0 || (Vehicle(injured) != none && Vehicle(injured).bNoFriendlyFire));
}
function RaiseHardcoreLevel(float inc, string reason){
    local string s;
    local Controller P;
    local NicePlayerController nicePlayer;
    
    if(ScrnRules.HardcoreLevelFloat < ScrnRules.HardcoreLevel)
       ScrnRules.HardcoreLevelFloat = ScrnRules.HardcoreLevel;
    ScrnRules.HardcoreLevelFloat += inc;
    ScrnRules.HardcoreLevel = int(ScrnRules.HardcoreLevelFloat + 0.01);
    ScrnRules.Mut.HardcoreLevel = clamp(ScrnRules.HardcoreLevel, 0, 255); 
    ScrnRules.Mut.NetUpdateTime = Level.TimeSeconds - 1;
    
    s = ScrnRules.msgHardcore;
    ReplaceText(s, "%a", String(ScrnRules.HardcoreLevel));
    ReplaceText(s, "%i", String(inc));
    ReplaceText(s, "%r", reason);
    for(P = Level.ControllerList; P != none; P = P.nextController){
       nicePlayer = NicePlayerController(P);
       if(nicePlayer != none && nicePlayer.bFlagShowHLMessages)
           nicePlayer.ClientMessage(s);
    }
}
function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation){
    local NiceHumanPawn nicePawn;
    local NicePlayerController nicePlayer;
    nicePlayer = NicePlayerController(Killed.controller);
    nicePawn = NiceHumanPawn(Killed);
    if(nicePawn != none && (!nicePawn.bReactiveArmorUsed)
       && class'NiceVeterancyTypes'.static.HasSkill(nicePlayer, class'NiceSkillDemoReactiveArmor')){
       nicePawn.bReactiveArmorUsed = true;
       nicePlayer.niceRI.ServerExplode(class'NiceSkillDemoReactiveArmor'.default.baseDamage,
           class'NiceSkillDemoReactiveArmor'.default.explRadius,
           class'NiceSkillDemoReactiveArmor'.default.explExponent,
           class'NiceDamTypeDemoSafeExplosion',
           class'NiceSkillDemoReactiveArmor'.default.explMomentum,
           killed.location, killed, true
       );
       return true;
    }
    if(NextGameRules != none)
       return NextGameRules.PreventDeath(Killed, Killer, damageType, HitLocation);
    return false;
}
defaultproperties
{
}
