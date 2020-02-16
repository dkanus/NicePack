//==============================================================================
//  NicePack / NiceSharpshooterAbilitiesAdapter
//==============================================================================
//  Temporary stand-in for future functionality.
//  Use this class to catch events from sharpshooter players' abilities.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceSharpshooterAbilitiesAdapter extends NiceAbilitiesAdapter;
static function AbilityActivated(   string abilityID,                                   NicePlayerController relatedPlayer){
    local NiceHumanPawn nicePawn;
    if(relatedPlayer == none) return;
    nicePawn = NiceHumanPawn(relatedPlayer.pawn);
    if(nicePawn == none)       return;
    if(abilityID == "Calibration"){       nicePawn.currentCalibrationState = CALSTATE_ACTIVE;       nicePawn.calibrateUsedZeds.length = 0;       nicePawn.calibrationScore = 1;       nicePawn.calibrationRemainingTime = 7.0;       nicePawn.calibrationHits = 0;       nicePawn.calibrationTotalShots = 0;
    }
    if(abilityID == class'NiceSkillSharpshooterGunslingerA'.default.abilityID){       nicePawn.gunslingerTimer =           class'NiceSkillSharpshooterGunslingerA'.default.duration;
    }
}
static function AbilityAdded(   string abilityID,                               NicePlayerController relatedPlayer){
    local NiceHumanPawn nicePawn;
    if(relatedPlayer == none) return;
    nicePawn = NiceHumanPawn(relatedPlayer.pawn);
    if(nicePawn == none)       return;
    if(abilityID == "Calibration"){       nicePawn.currentCalibrationState = CALSTATE_FINISHED;       nicePawn.calibrationScore = 1;
    }
}
static function AbilityRemoved( string abilityID,                               NicePlayerController relatedPlayer){
    local NiceHumanPawn nicePawn;
    if(relatedPlayer == none) return;
    nicePawn = NiceHumanPawn(relatedPlayer.pawn);
    if(nicePawn == none)       return;
    if(abilityID == "Calibration")       nicePawn.currentCalibrationState = CALSTATE_NOABILITY;
    if(abilityID == class'NiceSkillSharpshooterGunslingerA'.default.abilityID){       nicePawn.gunslingerTimer = 0.0;
    }
}
static function ModAbilityCooldown( string abilityID,                                   NicePlayerController relatedPlayer,                                   out float cooldown){
    local NiceHumanPawn nicePawn;
    if(relatedPlayer == none) return;
    nicePawn = NiceHumanPawn(relatedPlayer.pawn);
    if( abilityID != class'NiceSkillSharpshooterGunslingerA'.default.abilityID       &&  abilityID != class'NiceSkillSharpshooterReaperA'.default.abilityID)       return;
    switch(nicePawn.calibrationScore){       case 2:           cooldown *= 0.85;           break;       case 3:           cooldown *= 0.7;           break;       case 4:           cooldown *= 0.5;           break;       case 5:           cooldown *= 0.25;           break;
    }
    //  Reduce calibration score
    if(nicePawn.calibrationScore > 1)       nicePawn.calibrationScore -= 1;
}
defaultproperties
{
}
