class NiceAmmo extends KFAmmunition;
var class<NiceWeaponPickup> WeaponPickupClass;
function UpdateAmmoAmount(){
    MaxAmmo = Default.MaxAmmo;
    if(KFPawn(Owner) != none && KFPlayerReplicationInfo(KFPawn(Owner).PlayerReplicationInfo) != none &&
       KFPlayerReplicationInfo(KFPawn(Owner).PlayerReplicationInfo).ClientVeteranSkill != none)
       MaxAmmo = float(MaxAmmo) * KFPlayerReplicationInfo(KFPawn(Owner).PlayerReplicationInfo).ClientVeteranSkill.Static.AddExtraAmmoFor(KFPlayerReplicationInfo(KFPawn(Owner).PlayerReplicationInfo), Class);
    AmmoAmount = Min(AmmoAmount, MaxAmmo);
}
defaultproperties
{
}
