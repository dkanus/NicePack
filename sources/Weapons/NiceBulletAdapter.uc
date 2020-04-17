//======================================================================================================================
//  NicePack / NiceBulletAdapter
//======================================================================================================================
//  Temporary stand-in for future functionality.
//======================================================================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//======================================================================================================================
class NiceBulletAdapter extends Object;
var const   int BigZedMinHealth;            // If zed's base Health >= this value, zed counts as Big
var const   int MediumZedMinHealth;         // If zed's base Health >= this value, zed counts as Medium-size
static function Explode(NiceBullet bullet, NiceReplicationInfo niceRI, Vector hitLocation, optional Actor explosionTarget){
    if(!bullet.bGhost){
       niceRI.ServerExplode(bullet.charExplosionDamage, bullet.charExplosionRadius, bullet.charExplosionExponent,
           bullet.charExplosionDamageType, bullet.charExplosionMomentum, hitLocation, bullet.instigator, true,
           explosionTarget, Vector(bullet.Rotation));
       if(KFMonster(bullet.base) != none && bullet.bStuck && bullet.bStuckToHead)
           niceRI.ServerDealDamage(KFMonster(bullet.base), bullet.charExplosionDamage, bullet.instigator, hitLocation,
           bullet.charExplosionMomentum * vect(0,0,-1), bullet.charExplosionDamageType, 1.0);
    }
}
static function HandleCalibration
    (
       bool isHeadshot,
       NiceHumanPawn nicePawn,
       NiceMonster targetZed
    ){
    if(nicePawn == none)                                    return;
    if(nicePawn.currentCalibrationState != CALSTATE_ACTIVE) return;
    nicePawn.ServerUpdateCalibration(isHeadshot, targetZed);
}
static function HitWall(NiceBullet bullet, NiceReplicationInfo niceRI, Actor targetWall,
    Vector hitLocation, Vector hitNormal){
    local NicePlayerController nicePlayer;
    nicePlayer = NicePlayerController(bullet.Instigator.Controller);
    if(nicePlayer == none)
       return;
    if(!bullet.bAlreadyHitZed)
       HandleCalibration(false, NiceHumanPawn(bullet.Instigator), none);
    if(!targetWall.bStatic && !targetWall.bWorldGeometry && nicePlayer != none && (nicePlayer.wallHitsLeft > 0 || Projectile(targetWall) != none)){
       niceRI.ServerDealDamage(targetWall, bullet.charOrigDamage, bullet.Instigator, hitLocation,
           bullet.charMomentumTransfer * hitNormal, bullet.charDamageType);
       nicePlayer.wallHitsLeft --;
    }
}
static function HandleScream(NiceBullet bullet, NiceReplicationInfo niceRI, Vector location, Vector entryDirection){
    bullet.charIsDud = true;
}
static function HitPawn(NiceBullet bullet, NiceReplicationInfo niceRI, KFPawn targetPawn, Vector hitLocation,
    Vector hitNormal, array<int> hitPoints){
    local NiceMedicProjectile niceDart;
    niceDart = NiceMedicProjectile(bullet);
    if(niceDart == none)
       niceRI.ServerDealDamage(targetPawn, bullet.charDamage, bullet.instigator, HitLocation,
           hitNormal * bullet.charMomentumTransfer, bullet.charDamageType);
    else
       niceRI.ServerHealTarget(NiceHumanPawn(targetPawn), bullet.charDamage, bullet.instigator);
}
static function HitZed(NiceBullet bullet, NiceReplicationInfo niceRI, KFMonster kfZed, Vector hitLocation,
    Vector hitNormal, float headshotLevel){
    local bool bIsHeadshot, bIsPreciseHeadshot;
    local float actualDamage;
    local int lockonTicks;
    local float lockOnTickRate;
    local float angle;
    local NiceHumanPawn nicePawn;
    local NicePlayerController nicePlayer;
    local class<NiceVeterancyTypes> niceVet;
    bIsHeadshot = (headshotLevel > 0.0);
    bIsPreciseHeadshot = (headshotLevel > bullet.charDamageType.default.prReqPrecise);
    if(!bullet.bAlreadyHitZed || bIsHeadshot)
       HandleCalibration(bIsHeadshot, NiceHumanPawn(bullet.Instigator), NiceMonster(kfZed));
    if(bIsHeadshot && bullet.sourceWeapon != none)
       bullet.sourceWeapon.lastHeadshotTime = bullet.Level.TimeSeconds;
    // Try to get necessary variables and bail in case they're unaccessible
    nicePlayer = NicePlayerController(bullet.Instigator.Controller);
    if(nicePlayer == none)
       return;
    nicePawn = NiceHumanPawn(bullet.instigator);
    if(     !bIsHeadshot
       &&  nicePawn != none
       &&  nicePlayer.abilityManager != none
       &&  nicePlayer.abilityManager.IsAbilityActive(class'NiceSkillSharpshooterReaperA'.default.abilityID))
       nicePawn.ServerCooldownAbility(class'NiceSkillSharpshooterReaperA'.default.abilityID);
    niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(KFPlayerReplicationInfo(nicePlayer.PlayerReplicationInfo));
    if(bullet.charCausePain)
       actualDamage = bullet.charOrigDamage;
    else
       actualDamage = bullet.charDamage;
    if(headshotLevel > 0)
        actualDamage *= bullet.charContiniousBonus;
    if(bullet.bGrazing)
       actualDamage *= class'NiceSkillSupportGraze'.default.grazeDamageMult;
    bullet.bGrazing = false;
    if(kfZed == bullet.lockonZed && bullet.lockonTime > bullet.sourceWeapon.stdFireRate
       && niceVet != none && niceVet.static.hasSkill(nicePlayer, class'NiceSkillSharpshooterKillConfirmed')){
       lockOnTickRate =class'NiceSkillSharpshooterKillConfirmed'.default.stackDelay;
       lockonTicks = Ceil(bullet.lockonTime / lockOnTickRate) - 1;
       lockonTicks = Min(class'NiceSkillSharpshooterKillConfirmed'.default.maxStacks, lockonTicks);
       //actualDamage *= 1.0 +
       //    0.5 * lockonTicks * (lockonTicks + 1) * class'NiceSkillSharpshooterKillConfirmed'.default.damageBonus;
       //damageMod *= 1.0 + lockonTicks * class'NiceSkillSharpshooterKillConfirmed'.default.damageBonus;
       actualDamage *= 1.0 + lockonTicks * class'NiceSkillSharpshooterKillConfirmed'.default.damageBonus;
    }
    if(!bullet.bGhost)
       niceRI.ServerDealDamage(kfZed, actualDamage, bullet.instigator, hitLocation,
           bullet.charMomentumTransfer * hitNormal, bullet.charDamageType, headshotLevel, bullet.lockonTime);
    //// Handle angled shots
    angle = asin(hitNormal.Z);
    // Apply angled shots
    if((angle > 0.8 || angle < -0.45) && bullet.bCanAngleDamage && kfZed != none){
       bullet.bCanAngleDamage = false;
       bullet.bAlreadyHitZed = true;
       if(ZedPenetration(bullet.charDamage, bullet, kfZed, bIsHeadshot, bIsPreciseHeadshot))
           HitZed(bullet, niceRI, kfZed, hitLocation, hitNormal, headshotLevel);
    }
    //// 'Bore' support skill
    if( niceVet != none && nicePlayer.IsZedTimeActive() && bullet.insideBouncesLeft > 0
       && niceVet.static.hasSkill(nicePlayer, class'NiceSkillSupportZEDBore')){
       // Count one bounce
       bullet.insideBouncesLeft --;
       // Swap head-shot level
       if(headshotLevel <= 0.0)
           headshotLevel = class'NiceSkillSupportZEDBore'.default.minHeadshotPrecision;
       else
           headshotLevel = -headshotLevel;
       // Deal next batch of damage
       ZedPenetration(bullet.charDamage, bullet, kfZed, false, false);
       HitZed(bullet, niceRI, kfZed, hitLocation, hitNormal, headshotLevel);
    }
    bullet.insideBouncesLeft = 2;
}
static function bool ZedPenetration(out float Damage, NiceBullet bullet, KFMonster targetZed, bool bIsHeadshot, bool bIsPreciseHeadshot){
    local float reductionMod;
    local NiceMonster niceZed;
    local NicePlayerController nicePlayer;
    local int actualMaxPenetrations;
    local class<NiceVeterancyTypes> niceVet;
    local class<NiceWeaponDamageType> niceDmgType;
    // True if we can penetrate even body, but now penetrating a head and shouldn't reduce damage too much
    local bool bEasyHeadPenetration;
    // Init variables
    niceZed = NiceMonster(targetZed);
    nicePlayer = NicePlayerController(bullet.Instigator.Controller);
    niceVet = none;
    if(nicePlayer != none)
       niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(KFPlayerReplicationInfo(nicePlayer.PlayerReplicationInfo));
    niceDmgType = bullet.charDamageType;
    bEasyHeadPenetration = bIsHeadshot && !niceDmgType.default.bPenetrationHSOnly;
    reductionMod = 1.0f;
    // Apply zed reduction and perk reduction of reduction`
    if(niceZed != none){
       // Railgun skill exception
       if(niceVet != none && niceVet.static.hasSkill(nicePlayer, class'NiceSkillSharpshooterZEDRailgun') && nicePlayer.IsZedTimeActive())
           return true;
       if(niceZed.default.Health >= default.BigZedMinHealth && !bEasyHeadPenetration)
           reductionMod *= niceDmgType.default.BigZedPenDmgReduction;
       else if(niceZed.default.Health >= default.MediumZedMinHealth && !bEasyHeadPenetration)
           reductionMod *= niceDmgType.default.MediumZedPenDmgReduction;
    }
    else
       reductionMod *= niceDmgType.default.BigZedPenDmgReduction;
    if(niceVet != none)
       reductionMod = niceVet.static.GetPenetrationDamageMulti(KFPlayerReplicationInfo(nicePlayer.PlayerReplicationInfo), reductionMod, niceDmgType);
   actualMaxPenetrations = niceDmgType.default.maxPenetrations;  
    if(niceVet != none && !bullet.charWasHipFired && niceVet.static.hasSkill(nicePlayer, class'NiceSkillSharpshooterSurgical') && bIsHeadshot){
      actualMaxPenetrations += 1;
       reductionMod = FMax(reductionMod, class'NiceSkillSharpshooterSurgical'.default.penDmgReduction);
   }
    // Assign new damage value and tell us if we should stop with penetration
    Damage *= reductionMod * niceDmgType.default.PenDmgReduction;
    bullet.decapMod *= reductionMod * niceDmgType.default.PenDecapReduction;
    bullet.incapMod *= reductionMod * niceDmgType.default.PenIncapReduction;
    if(niceVet != none && actualMaxPenetrations >= 0)
       actualMaxPenetrations +=
           niceVet.static.GetAdditionalPenetrationAmount(KFPlayerReplicationInfo(nicePlayer.PlayerReplicationInfo));
    if(!bIsHeadshot && niceDmgType.default.bPenetrationHSOnly)
       return false;
    if(actualMaxPenetrations < 0)
       return true;
    if(Damage / bullet.charOrigDamage < (niceDmgType.default.PenDmgReduction ** (actualMaxPenetrations + 1)) + 0.0001 || Damage < 1)
       return false;
    return true;
}

defaultproperties
{
     BigZedMinHealth=1000
     MediumZedMinHealth=500
}
