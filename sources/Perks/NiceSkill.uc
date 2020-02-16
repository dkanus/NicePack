class NiceSkill extends ReplicationInfo
    abstract;
var bool    bBroadcast; // Should we broadcast to clients that someone has this skill?
var string  SkillName, SkillEffects;
// Functions that are called when skills becomes active / deactivated
function static SkillSelected(NicePlayerController nicePlayer){
    local NiceHumanPawn nicePawn;
    nicePawn = NiceHumanPawn(nicePlayer.Pawn);
    if(nicePawn != none){       nicePawn.RecalcAmmo();       if(nicePawn.Role < Role_AUTHORITY)           nicePawn.ApplyWeaponStats(nicePawn.weapon);
    }
}
function static SkillDeSelected(NicePlayerController nicePlayer){
    local NiceHumanPawn nicePawn;
    nicePawn = NiceHumanPawn(nicePlayer.Pawn);
    if(nicePawn != none){       nicePawn.RecalcAmmo();       if(nicePawn.Role < Role_AUTHORITY)           nicePawn.ApplyWeaponStats(nicePawn.weapon);
    }
}
function static int UpdateCounterValue(string counterName, NicePlayerController nicePlayer){
    return 0;
}
defaultproperties
{    SkillName="All Fiction"    SkillEffects="Does nothing!"
}
