class NiceSPShotgunAltFire extends NiceShotgunFire;
var InterpCurve AppliedMomentumCurve;   // How much momentum to apply to a zed based on how much mass it has
var float       WideDamageMinHitAngle;  // The angle to do sweeping strikes in front of the player. If zero do no strikes
var float       PushRange;              // The range to push zeds away when firing
simulated function bool AllowFire(){
    if(currentContext.sourceWeapon == none || KFPawn(Instigator) == none)       return false;
    if(currentContext.sourceWeapon.bIsReloading)       return false;
    if(KFPawn(Instigator).SecondaryItem!=none)       return false;
    if(KFPawn(Instigator).bThrowingNade)       return false;
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
    if (!Weapon.WeaponCentered() && !KFWeap.bAimingRifle)       StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;
    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if(Other != none)       StartProj = HitLocation;
    Aim = AdjustAim(StartProj, AimError);
    if(WideDamageMinHitAngle > 0){       foreach Weapon.VisibleCollidingActors(class'Pawn', Victims, (PushRange * 2), StartTrace){           if(Victims.Health <= 0)               continue;           if(Victims != Instigator){               // Don't push team mates               if(Victims.GetTeamNum() == Instigator.GetTeamNum())                   continue;               VictimDist = VSizeSquared(Instigator.Location - Victims.Location);               if(VictimDist > (((PushRange * 1.1) * (PushRange * 1.1)) + (Victims.CollisionRadius * Victims.CollisionRadius)))                   continue;
               lookdir = Normal(Vector(Instigator.GetViewRotation()));               dir = Normal(Victims.Location - Instigator.Location);               DiffAngle = lookdir dot dir;               dir = Normal((Victims.Location + Victims.EyePosition()) - Instigator.Location);
               if(DiffAngle > WideDamageMinHitAngle){                   AppliedMomentum = InterpCurveEval(AppliedMomentumCurve,Victims.Mass);                   HandleAchievement( Victims );
                   vMomentum = (dir * AppliedMomentum)/Victims.Mass;                   Victims.AddVelocity(vMomentum);                   if(KFMonster(Victims) != none)                       KFMonster(Victims).BreakGrapple();               }           }       }
    }
    if(Instigator != none && Instigator.Physics == PHYS_Falling && Instigator.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z)       Instigator.AddVelocity((KickMomentum * 10.0) >> Instigator.GetViewRotation());
}
function HandleAchievement(Pawn Victim){
    local KFSteamStatsAndAchievements KFSteamStats;
    if(Victim.IsA('NiceZombieScrake')){       if(PlayerController(Instigator.Controller) != none){           KFSteamStats = KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements);           if(KFSteamStats != none)               KFSteamStats.CheckAndSetAchievementComplete(KFSteamStats.KFACHIEVEMENT_PushScrakeSPJ);       }
    }
}
defaultproperties
{    AppliedMomentumCurve=(Points=((OutVal=10000.000000),(InVal=350.000000,OutVal=175000.000000),(InVal=600.000000,OutVal=250000.000000)))    WideDamageMinHitAngle=0.600000    PushRange=150.000000    ProjPerFire=0    KickMomentum=(X=-35.000000,Z=5.000000)    maxVerticalRecoilAngle=3200    FireSoundRef="KF_SP_ZEDThrowerSnd.KFO_Shotgun_Secondary_Fire_M"    StereoFireSoundRef="KF_SP_ZEDThrowerSnd.KFO_Shotgun_Secondary_Fire_S"    NoAmmoSoundRef="KF_AA12Snd.AA12_DryFire"    bWaitForRelease=False    bModeExclusive=False    FireAnimRate=1.000000    FireRate=1.200000    AmmoClass=None    AmmoPerFire=0    ShakeRotMag=(Z=250.000000)    ShakeRotTime=3.000000    ShakeOffsetMag=(Z=6.000000)    ShakeOffsetTime=1.250000    BotRefireRate=1.750000    FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSPShotgunAlt'    Spread=0.000000
}
