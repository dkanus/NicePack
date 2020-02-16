class MeanZombieScrake extends NiceZombieScrake;
#exec OBJ LOAD FILE=MeanZedSkins.utx
function RangedAttack(Actor A){
    Super.RangedAttack(A);
    if(!bShotAnim){       if(bConfusedState)           return;       if(float(Health) / HealthMax < 0.75 || lastStunTime >= 0.0){           MovementAnims[0] = 'ChargeF';           GoToState('RunningState');       }
    }
}
simulated event SetAnimAction(name NewAction){
    if(Role < Role_AUTHORITY && NewAction == 'ChargeF')       PlayAnim('ChargeF', GetOriginalGroundSpeed() * 3.5);
    else       super.SetAnimAction(NewAction);
}
simulated function Unstun(){
    bCharging = true;
    MovementAnims[0] = 'ChargeF';
    super.Unstun();
}
function TakeDamageClient(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, float lockonTime){
    Super.TakeDamageClient(Damage, instigatedBy, hitLocation, momentum, damageType, headshotLevel, lockonTime);
    if(bIsStunned && Health > 0 && (headshotLevel <= 0.0) && Level.TimeSeconds > LastStunTime + 0.1)       Unstun();
}
function TakeFireDamage(int Damage, Pawn Instigator){
    Super.TakeFireDamage(Damage, Instigator);
    if(bIsStunned && Health > 0 && Damage > 150 && Level.TimeSeconds > LastStunTime + 0.1)       Unstun();
}
function bool CheckMiniFlinch(int flinchScore, Pawn instigatedBy, Vector hitLocation, Vector momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, KFPlayerReplicationInfo KFPRI){
    if((ClassIsChildOf(damageType, class 'DamTypeMelee') || ClassIsChildOf(damageType, class 'NiceDamageTypeVetBerserker'))       && !KFPRI.ClientVeteranSkill.Static.CanMeleeStun() && (headshotLevel <= 0.0) && flinchScore < 250)       return false;
    return super.CheckMiniFlinch(flinchScore, instigatedBy, hitLocation, momentum, damageType, headshotLevel, KFPRI);
}
defaultproperties
{    MenuName="Mean Scrake"    Skins(0)=Shader'MeanZedSkins.scrake_FB'    Skins(1)=TexPanner'MeanZedSkins.scrake_saw_panner'
}
