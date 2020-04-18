class NiceFlareRevolverProjectile extends ScrnFlareRevolverProjectile;
//overrided to use alternate burning mechanism
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
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
    if ( bHurtEntry )
       return;
    bHurtEntry = true;
    foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation) {
       // null pawn variables here just to be sure they didn't left from previous iteration
       // and waste another day of my life to looking for this fucking bug -- PooSH /totallyPissedOff!!!
       P = none;
       KFMonsterVictim = none;
       KFP = none;
           // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
       if( (Victims != self) && (Victims != Instigator) &&(Hurtwall != Victims)
           && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo')
           && ExtendedZCollision(Victims)==none && KFBulletWhipAttachment(Victims)==none )
       {
           dirs = Victims.Location - HitLocation;
           dist = FMax(1,VSize(dirs));
           dirs = dirs/dist;
           damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
           if ( Instigator == none || Instigator.Controller == none )
               Victims.SetDelayedDamageInstigatorController( InstigatorController );
           if ( Victims == LastTouched )
               LastTouched = none;

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
                   damageScale *= KFMonsterVictim.GetExposureTo(HitLocation);
               }
               else if( KFP != none )
               {
                   damageScale *= KFP.GetExposureTo(HitLocation);
               }

               CheckedPawns[CheckedPawns.Length] = P;

               if ( damageScale <= 0)
               {
                   P = none;
                   continue;
               }
               else
               {
                   P = none;
               }
           }

           Victims.TakeDamage
           (
               damageScale * DamageAmount,
               Instigator,
               Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dirs,
               (damageScale * Momentum * dirs),
               DamageType//Class'NicePack.NiceDamTypeFlareProjectileFire'
           );
           if (Vehicle(Victims) != none && Vehicle(Victims).Health > 0)
               Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController,
                   DamageType,//Class'NicePack.NiceDamTypeFlareProjectileFire',
                   Momentum, HitLocation);

           if( Role == ROLE_Authority && KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
           {
               NumKilled++;
           }
       }
    }
    /*
    if ( (LastTouched != none) && (LastTouched != self) && (LastTouched != Instigator) &&
       (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
    {
       Victims = LastTouched;
       LastTouched = none;
       dirs = Victims.Location - HitLocation;
       dist = FMax(1,VSize(dirs));
       dirs = dirs/dist;
       damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
       if ( Instigator == none || Instigator.Controller == none )
           Victims.SetDelayedDamageInstigatorController(InstigatorController);

       log("Part 2 Doing "$(damageScale * DamageAmount)$" damage to "$Victims);
       Victims.TakeDamage
       (
           damageScale * DamageAmount,
           Instigator,
           Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dirs,
           (damageScale * Momentum * dirs),
           DamageType
       );
       if (Vehicle(Victims) != none && Vehicle(Victims).Health > 0)
           Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
    }
    */
    if( Role == ROLE_Authority )
    {
       if( NumKilled >= 4 )
       {
           KFGameType(Level.Game).DramaticEvent(0.05);
       }
       else if( NumKilled >= 2 )
       {
           KFGameType(Level.Game).DramaticEvent(0.03);
       }
    }
    bHurtEntry = false;
}
defaultproperties
{
    ImpactDamageType=Class'NicePack.NiceDamTypeFlareProjectileImpact'
    MyDamageType=Class'NicePack.NiceDamTypeFlareProjectileFire'
}
