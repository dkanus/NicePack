class NiceDualFlareRevolver extends ScrnDualFlareRevolver;
function bool HandlePickupQuery( pickup Item )
{
    if ( Item.InventoryType==Class'NicePack.NiceFlareRevolver' )
    {

    }
    return Super.HandlePickupQuery(Item);
}
function DropFrom(vector StartLocation)
{
    local int m;
    local KFWeaponPickup Pickup;
    local int AmmoThrown, OtherAmmo;
    local KFWeapon SinglePistol;
    if( !bCanThrow )
    AmmoThrown = AmmoAmount(0);
    ClientWeaponThrown();
    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
    }
    if ( Instigator != none )
    if( Instigator.Health > 0 )
    {
    }
    Pickup = Spawn(class'NicePack.NiceFlareRevolverPickup',,, StartLocation);
    if ( Pickup != none )
    {
    }
    Destroyed();
    Destroy();
}
simulated function bool PutDown()
{
    if ( Instigator.PendingWeapon == none || Instigator.PendingWeapon.class == class'NicePack.NiceFlareRevolver' )
    {
    }
    return super.PutDown();
}
defaultproperties
{
}