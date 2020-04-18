class NiceAmmoPickup extends ScrnAmmoPickup;
state Pickup
{
    // When touched by an actor.
    function Touch(Actor Other){
       local Inventory CurInv;
       local bool bPickedUp;
       local int AmmoPickupAmount;
       if(Pawn(Other) != none && Pawn(Other).bCanPickupInventory && Pawn(Other).Controller != none && FastTrace(Other.Location, Location)){
           for(CurInv = Other.Inventory;CurInv != none;CurInv = CurInv.Inventory){

               if(KFAmmunition(CurInv) != none && KFAmmunition(CurInv).bAcceptsAmmoPickups){
                   if(KFAmmunition(CurInv).AmmoPickupAmount > 0){
                       if(KFAmmunition(CurInv).AmmoAmount < KFAmmunition(CurInv).MaxAmmo){
                           if(KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo).ClientVeteranSkill != none)
                               AmmoPickupAmount = float(KFAmmunition(CurInv).AmmoPickupAmount) * KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo).ClientVeteranSkill.static.GetAmmoPickupMod(KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo), KFAmmunition(CurInv));
                           else
                               AmmoPickupAmount = KFAmmunition(CurInv).AmmoPickupAmount;

                           KFAmmunition(CurInv).AmmoAmount = Min(KFAmmunition(CurInv).MaxAmmo, KFAmmunition(CurInv).AmmoAmount + AmmoPickupAmount);
                           bPickedUp = true;
                       }
                   }
                   else if(KFAmmunition(CurInv).AmmoAmount < KFAmmunition(CurInv).MaxAmmo){
                       bPickedUp = true;
                       if(FRand() <= (1.0 / Level.Game.GameDifficulty))
                           KFAmmunition(CurInv).AmmoAmount++;
                   }
               }
           }

           if(bPickedUp){

               AnnouncePickup(Pawn(Other));
               GotoState('Sleeping', 'Begin');

               if(KFGameType(Level.Game) != none)
                   KFGameType(Level.Game).AmmoPickedUp(self);
           }
       }
    }
}
defaultproperties
{
}
