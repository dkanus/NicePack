class NiceM79IncGrenadeProjectile extends ScrnM79IncGrenadeProjectile;
#exec OBJ LOAD FILE=KF_GrenadeSnd.uax
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
    foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation)
    {
       // null pawn variables here just to be sure they didn't left from previous iteration
       // and waste another day of my life to looking for this fucking bug -- PooSH /totallyPissedOff!!!
       P = none;
       KFMonsterVictim = none;
       KFP = none;
           // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
       if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo')
        && ExtendedZCollision(Victims)==none )
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
                   P = none; // and if you forget to re-null it somewhere?!! and then look for a bug during 2 days?!! Damned Tripwire, I hate you so much
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
                   damageScale *= KFMonsterVictim.GetExposureTo(HitLocation/*Location + 15 * -Normal(PhysicsVolume.Gravity)*/);
               }
               else if( KFP != none )
               {
                   damageScale *= KFP.GetExposureTo(HitLocation/*Location + 15 * -Normal(PhysicsVolume.Gravity)*/);
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

           if( Role == ROLE_Authority && KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
           {
               NumKilled++;
           }
       }
    }
    /*
    if ( (LastTouched != none) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
    {
       Victims = LastTouched;
       LastTouched = none;
       dirs = Victims.Location - HitLocation;
       dist = FMax(1,VSize(dirs));
       dirs = dirs/dist;
       damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
       if ( Instigator == none || Instigator.Controller == none )
           Victims.SetDelayedDamageInstigatorController(InstigatorController);
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

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
    // Don't let it hit this player, or blow up on another player
    if ( Other == none || Other == Instigator || Other.Base == Instigator )
       return;
    // Don't collide with bullet whip attachments
    if( KFBulletWhipAttachment(Other) != none )
    {
       return;
    }
    // Don't allow hits on people on the same team - except hardcore mode
    if( !class'ScrnBalance'.default.Mut.bHardcore && KFHumanPawn(Other) != none && Instigator != none
       && KFHumanPawn(Other).PlayerReplicationInfo.Team.TeamIndex == Instigator.PlayerReplicationInfo.Team.TeamIndex )
    {
       return;
    }
    // Use the instigator's location if it exists. This fixes issues with
    // the original location of the projectile being really far away from
    // the real Origloc due to it taking a couple of milliseconds to
    // replicate the location to the client and the first replicated location has
    // already moved quite a bit.
    if( Instigator != none )
    {
       OrigLoc = Instigator.Location;
    }
    if( !bDud && ((VSizeSquared(Location - OrigLoc) < ArmDistSquared) || OrigLoc == vect(0,0,0)) )
    {
       if( Role == ROLE_Authority )
       {
           AmbientSound=none;
           PlaySound(Sound'ProjectileSounds.PTRD_deflect04',,2.0);
           Other.TakeDamage( ImpactDamage, Instigator, HitLocation, Normal(Velocity), ImpactDamageType );
       }
       bDud = true;
       Velocity = vect(0,0,0);
       LifeSpan=1.0;
       SetPhysics(PHYS_Falling);
    }
    if( !bDud )
    {
      Explode(HitLocation,Normal(HitLocation-Other.Location));
    }
}
defaultproperties
{
    MyDamageType=Class'NicePack.NiceDamTypeFlameNade'
}
