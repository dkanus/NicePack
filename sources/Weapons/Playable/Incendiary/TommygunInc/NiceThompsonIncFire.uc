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
    }
    else
    {
    }
    X = Vector(Dir);
    End = Start + TraceRange * X;
    Other = Instigator.HitPointTrace(HitLocation, HitNormal, End, HitPoints, Start,, 1);
    if ( Other != none && Other != Instigator && Other.Base != Instigator )
    {




    }
    else
    {
    }
}
defaultproperties
{
}