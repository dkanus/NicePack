class NiceDelayedNade extends NiceNailNade;
var float EarlyExplodeTimer;
simulated function Tick(float DeltaTime){
    if(EarlyExplodeTimer >= 0 && Physics == PHYS_None)
       EarlyExplodeTimer -= DeltaTime;
    Super.Tick(DeltaTime);
    if(!bHasExploded && !bDisintegrated && EarlyExplodeTimer < 0)
       Explode(Location, vect(0,0,1));
    if(LifeSpan < 0.1){
       ReleaseNails(true);
       Disintegrate(Location, vect(0,0,1));
    }
}
simulated function bool TooClose(){
    local Vector Diff;
    local float distance;
    if(Instigator == none)
       return false;
    Diff = Location - Instigator.Location;
    distance = Sqrt(Diff Dot Diff);
    return (distance < DamageRadius);
}
// Overloaded to implement nade skills
simulated function Explode(vector HitLocation, vector HitNormal){
    local PlayerController LocalPlayer;
    // Variables for skill-detection
    local NiceHumanPawn nicePawn;
    local class<NiceVeterancyTypes> niceVet;
    // Do we need to blow up?
    if(!TooClose()){
       bHasExploded = true;
       nicePawn = NiceHumanPawn(Instigator);
       if(nicePawn != none)
           niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(nicePawn.PlayerReplicationInfo);
       BlowUp(HitLocation);

       // null reference fix
       if(ExplodeSounds.length > 0)
           PlaySound(ExplodeSounds[rand(ExplodeSounds.length)],,2.0);

       // Real shrapnel
       ReleaseNails();
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
}

defaultproperties
{
     EarlyExplodeTimer=2.000000
     ExplodeTimer=5.000000
     LifeSpan=5.100000
}
