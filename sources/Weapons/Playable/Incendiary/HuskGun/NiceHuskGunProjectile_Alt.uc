class NiceHuskGunProjectile_Alt extends NiceHuskGunProjectile_Strong;
/*
//can't be destroyed by Siren's scream
//Explode only by heavy explosive damage
function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
    if ( !bDud && !bHasExploded && Damage >= 100 && class<KFWeaponDamageType>(damageType) != none 
    }
}
*/
/*
simulated function float MosterDamageMult( KFMonster Victim )
{
    float mult;
    mult = super.MosterDamageMult();
    // prevent big monsters from 1-shot be killed by hitting all projectiles
    if ( KFMonsterVictim.bBurnified && KFMonsterVictim.default.Health >= 1000 )
    return mult;
}
*/
/*
// copy-pasted with deletion of impact damage
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
    // Don't let it hit this player, or blow up on another player
    if ( Other == none || Other == Instigator || Other.Base == Instigator )
    // Don't collide with bullet whip attachments
    if( ROBulletWhipAttachment(Other) != none )
    {
    }
    // Don't allow hits on people on the same team
    //if( KFHumanPawn(Other) != none && Instigator != none
    //    && KFHumanPawn(Other).PlayerReplicationInfo.Team.TeamIndex == Instigator.PlayerReplicationInfo.Team.TeamIndex )
    //{
    //    return;
    //}
    if( !bDud && !bHasExploded )
    {
    }
}*/
defaultproperties
{
}