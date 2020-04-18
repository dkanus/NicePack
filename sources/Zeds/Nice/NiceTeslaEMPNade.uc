// used for Tesla Husk self-destruct explosion on decapitation
class NiceTeslaEMPNade extends NiceNade;
var() class<Emitter> ExplosionEffect;
function Timer(){
    if(bHidden)
       Destroy();
    else if(Instigator != none && Instigator.Health > 0)
       Explode(Location, vect(0,0,1));
    else 
       Disintegrate(Location, vect(0,0,1));
}
function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex){}
simulated function Explode(vector HitLocation, vector HitNormal)
{
    local PlayerController  LocalPlayer;
    bHasExploded = True;
    BlowUp(HitLocation);
    if(ExplodeSounds.length > 0)
       PlaySound(ExplodeSounds[rand(ExplodeSounds.length)],, 2.0);
    if(EffectIsRelevant(Location, false)){
       Spawn(ExplosionEffect,,, HitLocation, rotator(vect(0,0,1)));
       Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }
    // Shake nearby players screens
    LocalPlayer = Level.GetLocalPlayerController();
    if((LocalPlayer != none) && (VSize(Location - LocalPlayer.ViewTarget.Location) < (DamageRadius * 1.5)))
       LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
    if(Instigator != none){
       // blow up the instigator
       Instigator.TakeDamage(1000000, Instigator, Instigator.Location, vect(0,0,1), MyDamageType);
    }
    Destroy();
}
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    local actor Victims;
    local float damageScale, dist;
    local vector dir;
    local KFMonster KFMonsterVictim;
    local Pawn P;
    local KFPawn KFP;
    local array<Pawn> CheckedPawns;
    local int i;
    local bool bAlreadyChecked;

    if ( bHurtEntry )
       return;
    bHurtEntry = true;
    foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation)
    {
       // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
       if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo')
        && ExtendedZCollision(Victims)==none )
       {
           if( (Instigator==none || Instigator.Health<=0) && KFPawn(Victims)!=none )
               Continue;
           dir = Victims.Location - HitLocation;
           dist = FMax(1,VSize(dir));
           dir = dir/dist;
           damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

           if ( Instigator == none || Instigator.Controller == none )
           {
               Victims.SetDelayedDamageInstigatorController( InstigatorController );
           }

           P = Pawn(Victims);

           if( P != none )
           {
               for (i = 0; i < CheckedPawns.Length; i++)
               {
                   if (CheckedPawns[i] == P)
                   {
                       bAlreadyChecked = true;
                       break;
                   }
               }

               if( bAlreadyChecked )
               {
                   bAlreadyChecked = false;
                   P = none;
                   continue;
               }

               KFMonsterVictim = KFMonster(Victims);

               if( KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
               {
                   KFMonsterVictim = none;
               }

               KFP = KFPawn(Victims);

               if( KFMonsterVictim != none )
               {
                   // 10x more damage zeds
                   damageScale *= 10.0 * KFMonsterVictim.GetExposureTo(Location + 15 * -Normal(PhysicsVolume.Gravity));
                   if ( ZombieFleshpound(KFMonsterVictim) != none )
                       damageScale *= 2.0; // compensate 50% dmg.res.
               }
               else if( KFP != none )
               {
                   damageScale *= KFP.GetExposureTo(Location + 15 * -Normal(PhysicsVolume.Gravity));
               }

               CheckedPawns[CheckedPawns.Length] = P;

               if ( damageScale <= 0)
               {
                   P = none;
                   continue;
               }
               else
               {
                   //Victims = P;
                   P = none;
               }
           }

           Victims.TakeDamage(damageScale * DamageAmount,Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius)
            * dir,(damageScale * Momentum * dir),DamageType);

           if (Vehicle(Victims) != none && Vehicle(Victims).Health > 0)
           {
               Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
           }
       }
    }
    bHurtEntry = false;
}
defaultproperties
{
    ExplosionEffect=Class'KFMod.ZEDMKIISecondaryProjectileExplosion'
    ShrapnelClass=None
    ExplodeSounds(0)=Sound'KF_FY_ZEDV2SND.Fire.WEP_ZEDV2_Secondary_Fire_S'
    ExplodeSounds(1)=Sound'KF_FY_ZEDV2SND.Fire.WEP_ZEDV2_Secondary_Fire_S'
    ExplodeSounds(2)=Sound'KF_FY_ZEDV2SND.Fire.WEP_ZEDV2_Secondary_Fire_S'
    Speed=0.000000
    Damage=50.000000
    DamageRadius=400.000000
    MyDamageType=Class'ScrnZedPack.DamTypeEMP'
    DrawType=DT_None
    bCollideActors=False
    bBlockZeroExtentTraces=False
    bBlockNonZeroExtentTraces=False
}
