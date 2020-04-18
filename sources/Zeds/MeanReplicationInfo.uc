// Copy pasted from super zombies mutator with small alterations
class MeanReplicationInfo extends ReplicationInfo;
struct BleedingState {
    var float nextBleedTime;
    var Pawn instigator;
    var int count;
};
var PlayerReplicationInfo ownerPRI;
var bool isBleeding;
var int maxBleedCount;
var BleedingState bleedState;
var float bleedPeriod;
var float bleedLevel;
replication {
    reliable if (bNetDirty && Role == ROLE_Authority)
       isBleeding, ownerPRI;
}
// Returns bleed damage, corresponding to given bleed level and damage scale.
// Rand(7) should be used as a scale.
// Separate function created to allow for lowest/highest damage value computing.
function int calcBleedDamage(float level, int scale){
    return level * (3 + scale);
}
function Tick(float DeltaTime) {
    local PlayerController ownerCtrllr;
    local bool amAlive;
    local float bleedDamage;
    ownerCtrllr = PlayerController(Owner);
    amAlive = ownerCtrllr != none && ownerCtrllr.Pawn != none && ownerCtrllr.Pawn.Health > 0;
    if(amAlive && bleedState.count > 0) {
       if(bleedState.nextBleedTime < Level.TimeSeconds) {
           bleedState.count--;
           bleedState.nextBleedTime+= bleedPeriod;
           // Fix bleeding when stalker dies
           bleedDamage = calcBleedDamage(bleedLevel, rand(7));
           if(bleedDamage < 1.0)
               stopBleeding();
           if(bleedState.instigator != none)
               ownerCtrllr.Pawn.TakeDamage(bleedDamage, bleedState.instigator, ownerCtrllr.Pawn.Location, 
                   vect(0, 0, 0), class'NiceDamTypeStalkerBleed');
           else
               ownerCtrllr.Pawn.TakeDamage(bleedDamage, ownerCtrllr.Pawn, ownerCtrllr.Pawn.Location, 
                   vect(0, 0, 0), class'NiceDamTypeStalkerBleed');
           if (ownerCtrllr.Pawn.isA('KFPawn')) {
               KFPawn(ownerCtrllr.Pawn).HealthToGive -= 2 * bleedLevel;
           }
       }
    } else {
       isBleeding= false;
    }
}
function stopBleeding(){
    isBleeding = false;
    bleedState.count = 0;
}
function setBleeding(Pawn instigator, float effectStrenght) {
    // Can max possible damage do anything? If no, then don't even bother.
    if(calcBleedDamage(effectStrenght, 7) < 1.0)
       return;
    bleedState.instigator = instigator;
    bleedState.count = maxBleedCount;
    bleedLevel = effectStrenght;
    if(!isBleeding){
       bleedState.nextBleedTime = Level.TimeSeconds;
       isBleeding = true;
    }
}
static function MeanReplicationInfo findSZri(PlayerReplicationInfo pri) {
    local MeanReplicationInfo repInfo;
    if(pri == none)
       return none;
    foreach pri.DynamicActors(Class'MeanReplicationInfo', repInfo)
       if(repInfo.ownerPRI == pri)
           return repInfo;
 
    return none;
}
defaultproperties
{
    maxBleedCount=7
    bleedPeriod=1.500000
}
