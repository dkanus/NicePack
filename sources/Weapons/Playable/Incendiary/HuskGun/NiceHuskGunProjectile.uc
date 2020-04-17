class NiceHuskGunProjectile extends ScrnHuskGunProjectile;
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
    local vector X;
    local Vector TempHitLocation, HitNormal;
    local array<int>    HitPoints;
    local KFPawn HitPawn;
    // Don't let it hit this player, or blow up on another player
    if ( Other == none || Other == Instigator || Other.Base == Instigator )
    // Don't collide with bullet whip attachments
    if( KFBulletWhipAttachment(Other) != none )
    {
    }
    // Don't allow hits on poeple on the same team
    if( KFHumanPawn(Other) != none && Instigator != none
    {
    }
    if( !bDud )
    {
    }
    // Use the instigator's location if it exists. This fixes issues with
    // the original location of the projectile being really far away from
    // the real Origloc due to it taking a couple of milliseconds to
    // replicate the location to the client and the first replicated location has
    // already moved quite a bit.
    if( Instigator != none )
    {
    }
    X = Vector(Rotation);
    if( Role == ROLE_Authority )
    {





    }
}
// Overrided to not use alternate burning mechanism
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    local actor Victims;
    local float damageScale, dist;
    local vector dirs;
    local int NumKilled;
    local Pawn P;
    local KFMonster KFMonsterVictim;
    local KFPawn KFP;
    local array<Pawn> CheckedPawns;
    local int i;
    local bool bAlreadyChecked;
    //local int OldHealth;
    if ( bHurtEntry )
    bHurtEntry = true;
    foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation) {










    }
    if( Role == ROLE_Authority )
    {
    }
    bHurtEntry = false;
}
defaultproperties
{
}