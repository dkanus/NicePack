class MeanZombieGorefast extends NiceZombieGorefast;
#exec OBJ LOAD FILE=MeanZedSkins.utx
var float minRageDist;
function bool IsStunPossible(){
    return false;
}
function RangedAttack(Actor A) {
    Super(NiceMonster).RangedAttack(A);
    if(!bShotAnim && !bDecapitated && VSize(A.Location-Location) <= minRageDist)
       GoToState('RunningState');
}
state RunningState {
    function RangedAttack(Actor A){
       if(bShotAnim || Physics == PHYS_Swimming)
           return;
       else if(CanAttack(A)){
           bShotAnim = true;

           //Always do the charging melee attack
           SetAnimAction('ClawAndMove');
           RunAttackTimeout = GetAnimDuration('GoreAttack1', 1.0);
           return;
       }
    }
Begin:
    GoTo('CheckCharge');
CheckCharge:
    if(Controller != none && Controller.Target != none && VSize(Controller.Target.Location - Location) < minRageDist){
       Sleep(0.5 + FRand() * 0.5);
       GoTo('CheckCharge');
    }
    else 
       GoToState('');
}
defaultproperties
{
    minRageDist=1400.000000
    MenuName="Mean Gorefast"
    Skins(0)=Combiner'MeanZedSkins.gorefast_cmb'
}
