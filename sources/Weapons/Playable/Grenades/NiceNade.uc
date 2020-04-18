class NiceNade extends ScrnNade;
var class<NiceAvoidMarker>      AvoidMarkerClass;
var class<NiceWeaponDamageType> niceExplosiveDamage;
// Overloaded to implement nade skills
simulated function Explode(vector HitLocation, vector HitNormal){
    local PlayerController LocalPlayer;
    local Projectile P;
    local byte i;
    bHasExploded = true;
    BlowUp(HitLocation);
    // null reference fix
    if(ExplodeSounds.length > 0)
       PlaySound(ExplodeSounds[rand(ExplodeSounds.length)],,2.0);
    for(i = Rand(6);i < 10;i ++){
       P = Spawn(ShrapnelClass,,,,RotRand(True));
       if(P != none)
           P.RemoteRole = ROLE_None;
    }
    for(i = Rand(6);i < 10;i ++){
       P = Spawn(ShrapnelClass,,,,RotRand(True));
       if(P != none)
           P.RemoteRole = ROLE_none;
    }
    if(EffectIsRelevant(Location,false)){
       Spawn(Class'KFmod.KFNadeExplosion',,, HitLocation, rotator(vect(0,0,1)));
       Spawn(ExplosionDecal, self,, HitLocation, rotator(-HitNormal));
    }
    // Shake nearby players screens
    LocalPlayer = Level.GetLocalPlayerController();
    if((LocalPlayer != none) && (VSize(Location - LocalPlayer.ViewTarget.Location) < (DamageRadius * 1.5)))
       LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
    Destroy();
}
function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex){
    if(Monster(instigatedBy) != none || instigatedBy == Instigator){
       if(DamageType == class'SirenScreamDamage')
           Disintegrate(HitLocation, vect(0,0,1));
       else
           Explode(HitLocation, vect(0,0,1));
    }
}
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    local actor Victims;
    local float damageScale, dist;
    local vector dir;
    local int NumKilled;
    local KFMonster KFMonsterVictim;
    local bool bMonster;
    local Pawn P;
    local KFPawn KFP;
    local array<Pawn> CheckedPawns;
    local int i;
    local bool bAlreadyChecked;
    local SRStatsBase Stats;

    if ( bHurtEntry )
       return;
    bHurtEntry = true;
    
    if( Role == ROLE_Authority && Instigator != none && Instigator.PlayerReplicationInfo != none )
       Stats = SRStatsBase(Instigator.PlayerReplicationInfo.SteamStatsAndAchievements);
       
    foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation)
    {
       P = none;
       KFMonsterVictim = none;
       bMonster = false;
       KFP = none;
       bAlreadyChecked = false;

       // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
       if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo')
           && ExtendedZCollision(Victims)==None )
       {
           if( (Instigator==None || Instigator.Health<=0) && KFPawn(Victims)!=None )
               Continue;
           dir = Victims.Location - HitLocation;
           dist = FMax(1,VSize(dir));
           dir = dir/dist;
           damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

           if ( Instigator == None || Instigator.Controller == None )
           {
               Victims.SetDelayedDamageInstigatorController( InstigatorController );
           }

           P = Pawn(Victims);
           if( P != none ) {
               for (i = 0; i < CheckedPawns.Length; i++) {
                   if (CheckedPawns[i] == P) {
                       bAlreadyChecked = true;
                       break;
                   }
               }
               if( bAlreadyChecked )
                   continue;
               CheckedPawns[CheckedPawns.Length] = P;

               KFMonsterVictim = KFMonster(Victims);
               if( KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
                   KFMonsterVictim = none;

               KFP = KFPawn(Victims);

               if( KFMonsterVictim != none ) {
                   damageScale *= KFMonsterVictim.GetExposureTo(Location + 15 * -Normal(PhysicsVolume.Gravity));
                   bMonster = true; // in case TakeDamage() and further Die() deletes the monster
               }
               else if( KFP != none ) {
                   damageScale *= KFP.GetExposureTo(Location + 15 * -Normal(PhysicsVolume.Gravity));
               }

               if ( damageScale <= 0)
                   continue;

               // Scrake Nader ach    
               if ( Role == ROLE_Authority && KFMonsterVictim != none && ZombieScrake(KFMonsterVictim) != none ) {
                   // need to check Scrake's stun before dealing damage, because he can unstun by himself from damage received
                   ScrakeNader(damageScale * DamageAmount, ZombieScrake(KFMonsterVictim), Stats);
               }
           }
           if(NiceMonster(Victims) != none)
               Victims.TakeDamage(damageScale * DamageAmount,Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir
               ,(damageScale * Momentum * dir), niceExplosiveDamage);
           else
               Victims.TakeDamage(damageScale * DamageAmount,Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir
               ,(damageScale * Momentum * dir), DamageType);

           if( bMonster && (KFMonsterVictim == none || KFMonsterVictim.Health < 1) ) {
               NumKilled++;
           }

           if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
           {
               Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
           }
       }
    }
    
    if( Role == ROLE_Authority )
    {
       if ( bBlewInHands && NumKilled >= 5 && Stats != none ) 
           class'ScrnBalanceSrv.ScrnAchievements'.static.ProgressAchievementByID(Stats.Rep, 'SuicideBomber', 1);  

       if ( NumKilled >= 4 )
       {
           KFGameType(Level.Game).DramaticEvent(0.05);
       }
       else if ( NumKilled >= 2 )
       {
           KFGameType(Level.Game).DramaticEvent(0.03);
       }
    }
    bHurtEntry = false;
}
// Overridden to spawn different AvoidMarker
simulated function HitWall( vector HitNormal, actor Wall ){
    local Vector VNorm;
    local PlayerController PC;
    if((Pawn(Wall) != none) || (GameObjective(Wall) != none)){
       Explode(Location, HitNormal);
       return;
    }
    if(!bTimerSet){
       SetTimer(ExplodeTimer, false);
       bTimerSet = true;
    }
    // Reflect off Wall w/damping
    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;
    RandSpin(100000);
    DesiredRotation.Roll = 0;
    RotationRate.Roll = 0;
    Speed = VSize(Velocity);
    if(Speed < 20){
       bBounce = false;
       PrePivot.Z = -1.5;
       SetPhysics(PHYS_none);
       DesiredRotation = Rotation;
       DesiredRotation.Roll = 0;
       DesiredRotation.Pitch = 0;
       SetRotation(DesiredRotation);

       if(Fear == none){
           Fear = Spawn(AvoidMarkerClass);
           Fear.SetCollisionSize(DamageRadius, DamageRadius);
           Fear.StartleBots();
       }

       if(Trail != none)
           Trail.mRegen = false; // stop the emitter from regenerating
    }
    else{
       if((Level.NetMode != NM_DedicatedServer) && (Speed > 50))
           PlaySound(ImpactSound, SLOT_Misc );
       else{
           bFixedRotationDir = false;
           bRotateToDesired = true;
           DesiredRotation.Pitch = 0;
           RotationRate.Pitch = 50000;
       }
       if(!Level.bDropDetail && (Level.DetailMode != DM_Low) && (Level.TimeSeconds - LastSparkTime > 0.5) && EffectIsRelevant(Location,false)){
           PC = Level.GetLocalPlayerController();
           if ( (PC.ViewTarget != none) && VSize(PC.ViewTarget.Location - Location) < 6000 )
               Spawn(HitEffectClass,,, Location, Rotator(HitNormal));
           LastSparkTime = Level.TimeSeconds;
       }
    }
}
defaultproperties
{
    AvoidMarkerClass=Class'NicePack.NiceAvoidMarkerExplosive'
    niceExplosiveDamage=Class'NicePack.NiceDamTypeDemoExplosion'
}
