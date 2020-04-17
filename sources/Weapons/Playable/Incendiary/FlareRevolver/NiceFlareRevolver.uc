class NiceFlareRevolver extends ScrnFlareRevolver;
simulated function bool PutDown()
{
    if ( Instigator.PendingWeapon.class == class'NicePack.NiceDualFlareRevolver' )
    {       bIsReloading = false;
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
    if ( WeapPickup != none && KFPRI != none && KFPRI.ClientVeteranSkill != none ) {       SellValue = 0.75 * min(WeapPickup.Cost, WeapPickup.default.Cost            * KFPRI.ClientVeteranSkill.static.GetCostScaling(KFPRI, WeapPickup.class));
    }
    Super.GiveTo(Other,Pickup);
}
defaultproperties
{    AppID=0    FireModeClass(0)=Class'NicePack.NiceFlareRevolverFire'    PickupClass=Class'NicePack.NiceFlareRevolverPickup'    ItemName="Flare Revolver NW"
}
