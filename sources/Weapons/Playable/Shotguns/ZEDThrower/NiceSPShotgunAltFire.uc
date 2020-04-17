class NiceSPShotgunAltFire extends NiceShotgunFire;
var InterpCurve AppliedMomentumCurve;   // How much momentum to apply to a zed based on how much mass it has
var float       WideDamageMinHitAngle;  // The angle to do sweeping strikes in front of the player. If zero do no strikes
var float       PushRange;              // The range to push zeds away when firing
simulated function bool AllowFire(){
    if(currentContext.sourceWeapon == none || KFPawn(Instigator) == none)
    if(currentContext.sourceWeapon.bIsReloading)
    if(KFPawn(Instigator).SecondaryItem!=none)
    if(KFPawn(Instigator).bThrowingNade)
    // No ammo so just always fire
    return true;
}
// No need to client-side this one
function bool IsClientSide(){
    return false;
}
// And there's nothing to force
function bool shouldFireProjectile(){
    return false;
}
function DoFireEffect(){
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local Pawn Victims;
    local vector dir, lookdir;
    local float DiffAngle, VictimDist;
    local float AppliedMomentum;
    local vector vMomentum;
    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);
    StartTrace = Instigator.Location + Instigator.EyePosition();
    StartProj = StartTrace + X*ProjSpawnOffset.X;
    if (!Weapon.WeaponCentered() && !KFWeap.bAimingRifle)
    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if(Other != none)
    Aim = AdjustAim(StartProj, AimError);
    if(WideDamageMinHitAngle > 0){



    }
    if(Instigator != none && Instigator.Physics == PHYS_Falling && Instigator.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z)
}
function HandleAchievement(Pawn Victim){
    local KFSteamStatsAndAchievements KFSteamStats;
    if(Victim.IsA('NiceZombieScrake')){
    }
}
defaultproperties
{
}