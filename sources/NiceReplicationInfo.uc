//==============================================================================
//  NicePack / NiceReplicationInfo
//==============================================================================
//  Manages sending messages from clients to server.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceReplicationInfo extends ReplicationInfo
    dependson(NiceBullet);
var NicePack Mut;
replication{
    reliable if(Role < ROLE_Authority)
       ServerDamagePawn, ServerDealDamage, ServerDealMeleeDamage,
       ServerUpdateHit, ServerExplode, ServerJunkieExtension,
       ServerStickProjectile, ServerHealTarget;
}
//  Makes server to spawn a sticked projectile.
simulated function ServerStickProjectile
(
    KFHumanPawn instigator,
    Actor base,
    name bone,
    Vector shift,
    Rotator direction,
    NiceBullet.ExplosionData expData
){
    class'NiceProjectileSpawner'.static.
       StickProjectile(instigator, base, bone, shift, direction, expData);
}
//  Returns scale value that determines how to scale explosion damage to
//      given victim.
//  Method assumes that a valid victim was passed.
simulated function float GetDamageScale(Actor victim, Vector explosionLocation,
                                       Vector victimPoint,
                                       float explRadius, float explExp){
    local Vector    dirToVictim;
    local float     scale;
    local float     distToVictim;
    local KFPawn    victimKFPawn;
    local KFMonster victimMonster;
    dirToVictim     = victimPoint - explosionLocation;
    distToVictim    = FMax(1.0, VSize(dirToVictim));
    scale = 1 - FMax(0.0, (distToVictim - victim.collisionRadius) / explRadius);
    if(scale <= 0)
       scale = 0;
    else
       scale = scale ** explExp;
    //  Try scaling for exposure level (only available to monsters and KFPawns)
    victimKFPawn    = KFPawn(victim);
    victimMonster   = KFMonster(victim);
    if(victimKFPawn != none && victimKFPawn.health <= 0)
       scale *= victimKFPawn.GetExposureTo(explosionLocation);
    else if(victimMonster != none && victimMonster.health <= 0)
       scale *= victimMonster.GetExposureTo(explosionLocation);
    return scale;
}
//  Returns scale values that determine how to scale explosion damage to
//      given victim.
//  There's two scale values due to how kf1 calculated explosion damage:
//      by scaling it according to distance to two different points
//      (location of the victim and a point 75% of collision height higher).
//  First scale will be the one with the highest number.
//  Method assumes that a valid victim was passed.
simulated function CalculateDamageScales(   out float scale1, out float scale2,
                                           Actor victim,
                                           Vector explosionLocation,
                                           float explRadius, float explExp){
    local Vector    victimPoint1, victimPoint2;
    local float     swap;
    victimPoint1    = victim.location;
    victimPoint2    = victim.location;
    victimPoint2.z  += victim.CollisionHeight * 0.75;
    scale1 = GetDamageScale(victim, explosionLocation, victimPoint1,
                           explRadius, explExp);
    scale2 = GetDamageScale(victim, explosionLocation, victimPoint2,
                           explRadius, explExp);
    if(scale1 < scale2){
       swap    = scale1;
       scale1  = scale2;
       scale2  = swap;
    }
}
//  Simulates an explosion on a server.
simulated function ServerExplode
(
    float explDamage,
    float explRadius,
    float explExp,
    class<NiceWeaponDamageType> explDmgType,
    float momentum,
    Vector explLocation,
    Pawn instigator,
    optional bool allowDoubleExplosion,
    optional Actor explosionTarget,
    optional vector explosiveDirection
){
    local Actor         victim;
    local int           numKilled;
    local Vector        dirToVictim;
    local Vector        hitLocation;
    local float         scale1, scale2;
    if(Role < ROLE_Authority) return;
    foreach CollidingActors(class'Actor', victim, explRadius, explLocation){
       if(victim == none || victim == self)    continue;
       if(victim.role < ROLE_Authority)        continue;
       if(ExtendedZCollision(victim) != none)  continue;
       if(Trigger(victim) != none)             continue;
       dirToVictim = Normal(victim.location - explLocation);
       hitLocation = victim.location - 0.5 *
           (victim.collisionHeight + victim.collisionRadius) * dirToVictim;
       CalculateDamageScales(  scale1, scale2,
                               victim, explLocation, explRadius, explExp);
       // Deal main damage
       if(scale1 > 0){
           ServerDealDamage(   victim, explDamage * scale1, instigator,
                               hitLocation, scale1 * momentum * dirToVictim,
                               explDmgType);
       }
       // Deal secondary damage
       if(allowDoubleExplosion && victim != none && scale2 > 0){
           ServerDealDamage(   victim, explDamage * scale2, instigator,
                               hitLocation, scale2 * momentum * dirToVictim,
                               explDmgType);
       }
       if(NiceMonster(victim) != none && NiceMonster(victim).health <= 0)
           numKilled ++;
    }
    if(numKilled >= 4)
       KFGameType(level.game).DramaticEvent(0.05);
    else if(numKilled >= 2)
       KFGameType(level.game).DramaticEvent(0.03);
}
simulated function ServerDamagePawn
(
    KFPawn injured,
    int damage,
    Pawn instigatedBy,
    Vector hitLocation,
    Vector momentum,
    Class<DamageType> damageType,
    int hitPoint
){
    local array<int> hitPoints;
    if(injured == none) return;
    hitPoints[0] = hitPoint;
    injured.ProcessLocationalDamage(damage, instigatedBy, hitLocation, momentum,
                                   damageType, hitPoints);
}
simulated function HandleNiceHealingMechanicsAndSkills
(
    NiceHumanPawn healer,
    NiceHumanPawn healed,
    float healPotency
){
    local bool                  hasZEDHeavenCanceller;
    local NicePlayerController  nicePlayer;
    if(healer == none || healed == none) return;
    nicePlayer = NicePlayerController(healer.controller);
    if(nicePlayer == none)
       return;
    if(class'NiceVeterancyTypes'.static.
       hasSkill(nicePlayer, class'NiceSkillCommandoAdrenalineShot')){
       healed.medicAdrenaliteTime =
           class'NiceSkillCommandoAdrenalineShot'.default.boostTime;
    }
    if(class'NiceVeterancyTypes'.static.
       hasSkill(nicePlayer, class'NiceSkillMedicSymbioticHealth')){
       healer.TakeHealing(
           healer,
           healer.healthMax *
               class'NiceSkillMedicSymbioticHealth'.default.selfBoost,
           healPotency,
           KFWeapon(healer.weapon));
    }
    hasZEDHeavenCanceller = class'NiceVeterancyTypes'.static.
       hasSkill(nicePlayer, class'NiceSkillCommandoZEDHeavenCanceller');
    if(nicePlayer.IsZedTimeActive() && hasZEDHeavenCanceller){
       healed.health = healed.healthMax;
       healed.bZedTimeInvincible = true;
    }
}
simulated function RemovePoisonAndBleed(NiceHumanPawn healed){
    local Inventory             I;
    local MeanReplicationInfo   MRI;
    // No bleeding
    MRI = class'MeanReplicationInfo'.static.
           findSZri(healed.PlayerReplicationInfo);
    if(MRI != none)
       MRI.stopBleeding();
    // No poison
    if(healed.inventory == none) return;
    for(I = healed.inventory; I != none; I = I.inventory){
       if(MeanPoisonInventory(I) != none)
           I.Destroy();
    }
}
//  Tells server to heal given human pawn.
simulated function ServerHealTarget(NiceHumanPawn healed, float charPotency,
                                   Pawn instigator){
    local NiceHumanPawn healer;
    local KFPlayerReplicationInfo KFPRI;
    local float healTotal;
    local float healPotency;
    if(instigator == none || healed == none)                    return;
    if(healed.health <= 0 || healed.health >= healed.healthMax) return;
    KFPRI = KFPlayerReplicationInfo(instigator.PlayerReplicationInfo);
    if(KFPRI == none || KFPRI.ClientVeteranSkill == none)
       return;
    healer = NiceHumanPawn(instigator);
    if(healer == none)
       return;
    healPotency = KFPRI.ClientVeteranSkill.static.GetHealPotency(KFPRI);
    healTotal = charPotency * healPotency;
    
    healer.AlphaAmount = 255;
    if(NiceMedicGun(healer.weapon) != none)
       NiceMedicGun(healer.weapon).ClientSuccessfulHeal(healer, healed);
    if(healed.health >= healed.healthMax){
       healed.GiveHealth(healTotal, healed.healthMax);
       return;
    }
    HandleNiceHealingMechanicsAndSkills(healer, healed, healPotency);
    if(healed.health < healed.healthMax){
       healed.TakeHealing( healed, healTotal, healPotency,
                           KFWeapon(instigator.weapon));
    }
    RemovePoisonAndBleed(healed);
}
simulated function HandleNiceDamageMechanicsAndSkills
(
    NiceMonster niceZed,
    out int damage,
    NiceHumanPawn nicePawn,
    out Vector hitLocation,
    out Vector momentum,
    class<NiceWeaponDamageType> damageType,
    out float headshotLevel,
    out float lockonTime
){
    local bool                  hasZEDFrenzy;
    local bool                  hasTranquilizer;
    local bool                  hasVorpalBlade;
    local NiceMonsterController zedController;
    local NicePlayerController  nicePlayer;
    if(niceZed == none)     return;
    if(nicePawn == none)    return;
    nicePlayer = NicePlayerController(nicePawn.controller);
    if(nicePlayer == none)
       return;
    //  Medic's skills
    if(class<NiceDamTypeMedicDart>(damageType) != none){
       hasTranquilizer = class'NiceVeterancyTypes'.static.
           hasSkill(nicePlayer, class'NiceSkillCommandoTranquilizer');
       hasZEDFrenzy = class'NiceVeterancyTypes'.static.
           hasSkill(nicePlayer, class'NiceSkillMedicZEDFrenzy');
       // Medic's suppression
       if(hasTranquilizer)
           niceZed.mind = FMin(niceZed.mind, 0.5);
       // Medic's frenzy
       if(hasZEDFrenzy && nicePlayer.IsZedTimeActive()){
           niceZed.madnessCountDown =
               class'NiceSkillMedicZEDFrenzy'.default.madnessTime;
           zedController = NiceMonsterController(niceZed.controller);
           if(zedController != none)
               zedController.FindNewEnemy();
       }
    }
    //  Zerker's skills
    if(class<niceDamageTypeVetBerserker>(DamageType) != none){
       hasVorpalBlade = class'NiceVeterancyTypes'.static.
           HasSkill(nicePlayer, class'NiceSkillZerkVorpalBlade');
       if(     hasVorpalBlade && headshotLevel > 0.0
           &&  !nicePawn.IsZedExtentionsRecorded(niceZed))
           damage *= class'NiceSkillZerkVorpalBlade'.default.damageBonus;
    }
}
simulated function UpdateMeleeInvincibility
(
    NiceMonster niceZed,
    int damage,
    NiceHumanPawn nicePawn,
    Vector hitLocation,
    Vector momentum,
    class<NiceWeaponDamageType> damageType,
    float headshotLevel,
    bool mainTarget
){
    local bool hasGunzerker;
    local bool allowedInvincibility;
    if(nicePawn == none)    return;
    if(niceZed == none)     return;
    allowedInvincibility = class'NiceVeterancyTypes'.static.
       GetVeterancy(nicePawn.PlayerReplicationInfo) == class'NiceVetBerserker';
    allowedInvincibility = allowedInvincibility || niceZed.headHealth <= 0;
    if(!allowedInvincibility)
       return;
    //  Handle non-melee cases (gunzerker-invincibility)
    hasGunzerker = class'NiceVeterancyTypes'.static.
       hasSkill(   NicePlayerController(nicePawn.controller),
                   class'NiceSkillZerkGunzerker');
    if(hasGunzerker && class<niceDamageTypeVetBerserker>(damageType) == none)
       nicePawn.TryExtendingInv(niceZed, false, headshotLevel > 0.0);
    //  Handle melee-cases
    if(mainTarget && class<niceDamageTypeVetBerserker>(damageType) != none)
       nicePawn.TryExtendingInv(niceZed, true, headshotLevel > 0.0); 
    nicePawn.ApplyWeaponStats(nicePawn.weapon);
}
simulated function UpdateArdour(bool isKill, NicePlayerController nicePlayer){
    local bool          hasArdour;
    local NiceHumanPawn nicePawn;
    local float         cooldownChange;
    if(nicePlayer == none)                  return;
    if(nicePlayer.abilityManager == none)   return;
    nicePawn = NiceHumanPawn(nicePlayer.pawn);
    if(nicePawn == none)
        return;
    hasArdour = class'NiceVeterancyTypes'.static.
       hasSkill(   nicePlayer,
                   class'NiceSkillSharpshooterArdour');
    if(!hasArdour)
       return;
    cooldownChange =
        class'NiceSkillSharpshooterArdour'.default.
            headshotKillReduction[nicePawn.calibrationScore - 1];
    if(!isKill){
       cooldownChange *=
           class'NiceSkillSharpshooterArdour'.default.justHeadshotReduction;
    }
    nicePlayer.abilityManager.AddToCooldown(1, -cooldownChange);
}
//  Returns 'true' if before calling it zed was alive and had a head.
simulated function bool ServerDealDamageBase
(
    Actor other,
    int damage,
    Pawn instigatedBy,
    Vector hitLocation,
    Vector momentum,
    class<NiceWeaponDamageType> damageType,
    optional float headshotLevel,
    optional float lockonTime
){
    local NiceMonster           niceZed;
    local NiceHumanPawn         nicePawn;
    local NicePlayerController  nicePlayer;
    local bool                  zedWasAliveWithHead;
    if(other == none) return false;
    niceZed = NiceMonster(other);
    nicePawn = NiceHumanPawn(InstigatedBy);
    if(nicePawn != none)
       nicePlayer = NicePlayerController(nicePawn.Controller);
    if(niceZed == none || nicePlayer == none){
       other.TakeDamage(   damage, instigatedBy,
                           hitLocation, momentum, damageType);
       return false;
    }
    zedWasAliveWithHead = (niceZed.health > 0.0) && (niceZed.headHealth > 0.0);
    HandleNiceDamageMechanicsAndSkills( niceZed, damage, nicePawn,
                                       hitLocation, momentum, damageType,
                                       headshotLevel, lockonTime);
    niceZed.TakeDamageClient(   damage, instigatedBy, hitLocation, momentum,
                               damageType, headshotLevel, lockonTime);
    return zedWasAliveWithHead;
}
//  Tells server to damage given pawn.
simulated function ServerDealDamage
(
    Actor other,
    int damage,
    Pawn instigatedBy,
    Vector hitLocation,
    Vector momentum,
    class<NiceWeaponDamageType> damageType,
    optional float headshotLevel,
    optional float lockonTime
){
    local NiceMonster   niceZed;
    local bool          zedWasAliveWithHead;
    if(headshotLevel > 0)
       UpdateArdour(false, NicePlayerController(instigatedBy.controller));
    zedWasAliveWithHead = ServerDealDamageBase( other, damage, instigatedBy,
                                               hitLocation, momentum,
                                               damageType, headshotLevel,
                                               lockonTime);
    if(!zedWasAliveWithHead)
       return;
    niceZed = NiceMonster(other);
    if(     niceZed != none
       &&  (niceZed.health < 0 || niceZed.headHealth < 0))
       UpdateArdour(true, NicePlayerController(instigatedBy.controller));
    UpdateMeleeInvincibility(   niceZed, damage,
                               NiceHumanPawn(instigatedBy),
                               hitLocation, momentum, damageType,
                               headshotLevel, true);
}
//  Tells server to damage given pawn with melee.
//  Difference with 'ServerDealDamage' is that this function passes data about
//      whether our target was 'main' target of melee swing
//      or was hit by AOE effect.
simulated function ServerDealMeleeDamage
(
    Actor other,
    int damage,
    Pawn instigatedBy,
    Vector hitLocation,
    Vector momentum,
    class<NiceWeaponDamageType> damageType,
    bool mainTarget,
    optional float headshotLevel
){
    local bool zedWasAliveWithHead;
    zedWasAliveWithHead = ServerDealDamageBase( other, damage, instigatedBy,
                                               hitLocation, momentum,
                                               damageType, headshotLevel, 0.0);
    if(!zedWasAliveWithHead)
       return;
    UpdateMeleeInvincibility(   NiceMonster(other), damage,
                               NiceHumanPawn(instigatedBy),
                               hitLocation, momentum, damageType,
                               headshotLevel, mainTarget);
}
simulated function ServerUpdateHit
(
    Actor tpActor,
    Actor hitActor,
    Vector clientHitLoc,
    Vector hitNormal,
    optional Vector hitLocDiff
){
    local KFWeaponAttachment weapAttach;
    weapAttach = KFWeaponAttachment(tpActor);
    if(weapAttach != none)
       weapAttach.UpdateHit(hitActor, clientHitLoc + hitLocDiff, hitNormal);
}
simulated function ServerJunkieExtension(   NicePlayerController player,
                                           bool isHeadshot){
    local NiceGameType              niceGame;
    local class<NiceVeterancyTypes> niceVet;
    if(player == none || player.bJunkieExtFailed) return;
    niceGame = NiceGameType(player.Level.Game);
    if(niceGame == none || !niceGame.bZEDTimeActive)
       return;
    niceVet = class'NiceVeterancyTypes'.static.
       GetVeterancy(player.PlayerReplicationInfo);   
    if(niceVet == none)
       return;
    if(niceVet.static.hasSkill(player, class'NiceSkillSharpshooterZEDAdrenaline')){
       if(!isHeadshot)
           player.bJunkieExtFailed = true;
       else if(Mut != none)
           Mut.JunkieZedTimeExtend();
    }
}

defaultproperties
{
}
