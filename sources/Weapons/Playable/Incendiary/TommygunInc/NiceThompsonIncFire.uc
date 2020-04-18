class NiceThompsonIncFire extends ScrnThompsonIncFire;
// Overwritten to not switch damage types for the firebug
function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
    local Actor Other;
    local KFWeaponAttachment WeapAttach;
    local array<int> HitPoints;
    local KFPawn HitPawn;
    MaxRange();
    Weapon.GetViewAxes(X, Y, Z);
    if ( Weapon.WeaponCentered() )
    {
       ArcEnd = (Instigator.Location + Weapon.EffectOffset.X * X + 1.5 * Weapon.EffectOffset.Z * Z);
    }
    else
    {
       ArcEnd = (Instigator.Location + Instigator.CalcDrawOffset(Weapon) + Weapon.EffectOffset.X * X + Weapon.Hand * Weapon.EffectOffset.Y * Y +
       Weapon.EffectOffset.Z * Z);
    }
    X = Vector(Dir);
    End = Start + TraceRange * X;
    Other = Instigator.HitPointTrace(HitLocation, HitNormal, End, HitPoints, Start,, 1);
    if ( Other != none && Other != Instigator && Other.Base != Instigator )
    {
       WeapAttach = KFWeaponAttachment(Weapon.ThirdPersonActor);

       if ( !Other.bWorldGeometry )
       {
           // Update hit effect except for pawns
           if ( !Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume') &&
                !Other.IsA('ExtendedZCollision') )
           {
               if( WeapAttach!=none )
               {
                   WeapAttach.UpdateHit(Other, HitLocation, HitNormal);
               }
           }

           HitPawn = KFPawn(Other);

           if ( HitPawn != none )
           {
               if ( !HitPawn.bDeleteMe )
               {
                   HitPawn.ProcessLocationalDamage(DamageMax, Instigator, HitLocation, Momentum * X, DamageType, HitPoints);
               }
           }
           else
               Other.TakeDamage(DamageMax, Instigator, HitLocation, Momentum * X, DamageType);
       }
       else
       {
           HitLocation = HitLocation + 2.0 * HitNormal;

           if ( WeapAttach != none )
           {
               WeapAttach.UpdateHit(Other,HitLocation,HitNormal);
           }
       }
    }
    else
    {
       HitLocation = End;
       HitNormal = Normal(Start - End);
    }
}
defaultproperties
{
    DamageType=Class'NicePack.NiceDamTypeThompsonInc'
    AmmoClass=Class'NicePack.NiceThompsonIncAmmo'
}
