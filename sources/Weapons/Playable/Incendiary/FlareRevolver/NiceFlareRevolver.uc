class NiceFlareRevolver extends ScrnFlareRevolver;
simulated function bool PutDown()
{
    if ( Instigator.PendingWeapon.class == class'NicePack.NiceDualFlareRevolver' )
    {
    }
    return super(KFWeapon).PutDown();
}

function GiveTo( pawn Other, optional Pickup Pickup )
{
    local KFPlayerReplicationInfo KFPRI;
    local KFWeaponPickup WeapPickup;
    KFPRI = KFPlayerReplicationInfo(Other.PlayerReplicationInfo);
    WeapPickup = KFWeaponPickup(Pickup);
    //pick the lowest sell value
    if ( WeapPickup != none && KFPRI != none && KFPRI.ClientVeteranSkill != none ) {
    }
    Super.GiveTo(Other,Pickup);
}
defaultproperties
{
}