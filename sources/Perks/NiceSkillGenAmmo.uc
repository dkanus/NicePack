class NiceSkillGenAmmo extends NiceSkill
    abstract;
function static UpdateWeapons(NicePlayerController nicePlayer){
    local Inventory I;
    local NiceHumanPawn nicePawn;
    nicePawn = NiceHumanPawn(nicePlayer.Pawn);
    if(nicePawn != none){
       for(I = nicePawn.Inventory; I != none; I = I.Inventory)
           if(NiceWeapon(I) != none){
               NiceWeapon(I).UpdateWeaponAmmunition();
               NiceWeapon(I).ClientUpdateWeaponMag();
           }
           else if(FragAmmo(I) != none){
               FragAmmo(I).MaxAmmo = FragAmmo(I).default.MaxAmmo;
               if(KFPlayerReplicationInfo(nicePawn.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(nicePawn.PlayerReplicationInfo).ClientVeteranSkill != none)
                   FragAmmo(I).MaxAmmo = float(FragAmmo(I).MaxAmmo)
                       * KFPlayerReplicationInfo(nicePawn.PlayerReplicationInfo).ClientVeteranSkill.static.AddExtraAmmoFor(KFPlayerReplicationInfo(nicePawn.PlayerReplicationInfo), class'FragAmmo');
               FragAmmo(I).AmmoAmount = Min(FragAmmo(I).AmmoAmount, FragAmmo(I).MaxAmmo);
           }
    }
}
function static SkillSelected(NicePlayerController nicePlayer){
    super.SkillSelected(nicePlayer);
    UpdateWeapons(nicePlayer);
}
function static SkillDeSelected(NicePlayerController nicePlayer){
    super.SkillDeSelected(nicePlayer);
    UpdateWeapons(nicePlayer);
}
defaultproperties
{
}
