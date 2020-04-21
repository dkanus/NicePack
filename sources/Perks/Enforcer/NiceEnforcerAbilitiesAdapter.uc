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
class NiceEnforcerAbilitiesAdapter extends NiceAbilitiesAdapter;
static function AbilityActivated(   string abilityID,
                                   NicePlayerController relatedPlayer){
   local NiceHumanPawn nicePawn;
   local NiceMonster victim;
   if(relatedPlayer == none) return;
   nicePawn = NiceHumanPawn(relatedPlayer.pawn);
   if(nicePawn == none)
      return;
   if(abilityID == "fullcounter"){
      nicePawn.remainingFCArmor = 100.0;
      nicePawn.remainingFCTime = 1.0;
   }
    if(abilityID == "carnage"){
      nicePawn.brutalCranageTimer = 10.0;
   }
   if(abilityID == class'NiceSkillEnforcerStuporA'.default.abilityID){
      relatedPlayer.abilityManager.SetAbilityState(1, ASTATE_COOLDOWN);
      foreach relatedPlayer.CollidingActors(class'NiceMonster', victim, class'NicePack.NiceSkillEnforcerStuporA'.default.radius, relatedPlayer.pawn.location)
      {
         if (victim == none) continue;
         victim.DoRightPainReaction(class'NicePack.NiceSkillEnforcerStuporA'.default.painScore,
                                    relatedPlayer.pawn, victim.location, Vect(0,0,0), none, 0.0,
                                    KFPlayerReplicationInfo(relatedPlayer.PlayerReplicationInfo));
      }
   }
}/*
static function AbilityAdded(   string abilityID,
                               NicePlayerController relatedPlayer){
    local NiceHumanPawn nicePawn;
    if(relatedPlayer == none) return;
    nicePawn = NiceHumanPawn(relatedPlayer.pawn);
    if(nicePawn == none)
       return;
    if(abilityID == "Calibration"){
       nicePawn.currentCalibrationState = CALSTATE_FINISHED;
       nicePawn.calibrationScore = 3;
    }
}
static function AbilityRemoved( string abilityID,
                               NicePlayerController relatedPlayer){
    local NiceHumanPawn nicePawn;
    if(relatedPlayer == none) return;
    nicePawn = NiceHumanPawn(relatedPlayer.pawn);
    if(nicePawn == none)
       return;
    if(abilityID == "Calibration")
       nicePawn.currentCalibrationState = CALSTATE_NOABILITY;
    if(abilityID == class'NiceSkillSharpshooterGunslingerA'.default.abilityID){
       nicePawn.gunslingerTimer = 0.0;
    }
}
static function ModAbilityCooldown( string abilityID,
                                   NicePlayerController relatedPlayer,
                                   out float cooldown){
    local NiceHumanPawn nicePawn;
    if(relatedPlayer == none) return;
    nicePawn = NiceHumanPawn(relatedPlayer.pawn);
    if( abilityID != class'NiceSkillSharpshooterGunslingerA'.default.abilityID
       &&  abilityID != class'NiceSkillSharpshooterReaperA'.default.abilityID)
       return;
    switch(nicePawn.calibrationScore){
       case 2:
           cooldown *= 0.85;
           break;
       case 3:
           cooldown *= 0.7;
           break;
       case 4:
           cooldown *= 0.5;
           break;
       case 5:
           cooldown *= 0.25;
           break;
    }
    //  Reduce calibration score
    if(nicePawn.calibrationScore > 3)
       nicePawn.calibrationScore -= 1;
}*/
defaultproperties
{
}
