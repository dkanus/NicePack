class NiceFlameNade extends NiceNade;
#exec OBJ LOAD FILE=KF_GrenadeSnd.uax
simulated function HurtRadius(float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation){
    local actor Victims;
    local float damageScale, dist;
    local vector dirs;
    local int NumKilled;
    local KFMonster KFMonsterVictim;
    local Pawn P;
    local KFPawn KFP;
    local array<Pawn> CheckedPawns;
    local int i;
    local bool bAlreadyChecked;
    if(bHurtEntry)
    bHurtEntry = true;
    foreach CollidingActors(class 'Actor', Victims, DamageRadius, HitLocation){











    }
    if(Role == ROLE_Authority){
    }
    bHurtEntry = false;
}
simulated function Explode(vector HitLocation, vector HitNormal){
    local PlayerController  LocalPlayer;
    bHasExploded = True;
    BlowUp(HitLocation);
    // Incendiary Effects..
    PlaySound(sound'KF_GrenadeSnd.FlameNade_Explode',, 100.5 * TransientSoundVolume);
    if(EffectIsRelevant(Location, false)){
    }
    // Shake nearby players screens
    LocalPlayer = Level.GetLocalPlayerController();
    if((LocalPlayer != none) && (VSize(Location - LocalPlayer.ViewTarget.Location) < (DamageRadius * 1.5)))
    Destroy();
}
defaultproperties
{
}