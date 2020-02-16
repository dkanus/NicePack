//==============================================================================
//  NicePack / NiceBulletAdapter
//==============================================================================
//  Temporary stand-in for future functionality.
//==============================================================================
//  Class hierarchy: Object > NiceBulletAdapter
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceBulletAdapter extends Object;

var const   int BigZedMinHealth;            // If zed's base Health >= this value, zed counts as Big
var const   int MediumZedMinHealth;         // If zed's base Health >= this value, zed counts as Medium-size

static function Explode(NiceBullet bullet, Vector hitLocation){
    /*local NiceReplicationInfo niceRI;
    niceRI = bullet.niceRI;
    if(!bullet.bGhost){
        niceRI.ServerExplode(bullet.fireType.explosion.damage, bullet.fireType.explosion.radius, bullet.fireType.explosion.exponent,
            bullet.fireType.explosion.damageType, bullet.fireType.explosion.momentum, hitLocation, bullet.instigator, true,
            Vector(bullet.Rotation));
        if(KFMonster(bullet.base) != none && bullet.bStuck && bullet.bStuckToHead)
            niceRI.ServerDealDamage(KFMonster(bullet.base), bullet.fireType.explosion.damage, bullet.instigator, hitLocation,
            bullet.fireType.explosion.momentum * vect(0,0,-1), bullet.fireType.explosion.damageType, 1.0);
    }*/
}

/*static function HitWall(NiceBullet bullet, Actor targetWall,
    Vector hitLocation, Vector hitNormal){
    local NicePlayerController nicePlayer;
    local NiceReplicationInfo niceRI;
    niceRI = bullet.niceRI;
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
}*/

static function HitWall//Actor
(
    NiceBullet bullet,
    Actor targetWall,
    Vector hitLocation,
    Vector hitNormal
)
{
    local NicePlayerController  nicePlayer;
    local NiceReplicationInfo   niceRI;
    if(bullet == none || bullet.instigator == none)
        return;
    niceRI = bullet.niceRI;
    nicePlayer = NicePlayerController(bullet.instigator.controller);
    if(nicePlayer == none)
        return;
    //  No need to deal damage to geometry or static actors
    if(targetWall.bStatic || targetWall.bWorldGeometry)
        return;
    //      If target is a projectile - we must send message about damage,
    //  otherwise it's probably a wall. And if we hit our limits of reporting
    //  about wall damages - avoid sending too many replication messages
    //  about damage.
    //      NICETODO: should probably find another way to solve the
    //  `ServerDealDamage` spam issue, this is bullshit.
    if(Projectile(targetWall) == none && nicePlayer.wallHitsLeft <= 0)
        return;
    niceRI.ServerDealDamage(targetWall, bullet.fireType.bullet.damage, bullet.instigator, hitLocation,
        bullet.fireType.bullet.momentum * hitNormal, bullet.fireType.bullet.shotDamageType);
    //  We've sent a reliable message about hitting a wall
    nicePlayer.wallHitsLeft --;
}

static function HandleScream(NiceBullet bullet, Vector location, Vector entryDirection){
    bullet.bIsDud = true;
}

static function HitPawn(NiceBullet bullet, KFPawn targetPawn, Vector hitLocation,
    Vector hitNormal){
   // local NiceMedicProjectile niceDart;
    local NiceReplicationInfo niceRI;
    niceRI = bullet.niceRI;
    /*niceDart = NiceMedicProjectile(bullet);
    if(niceDart == none)
        niceRI.ServerDealDamage(targetPawn, bullet.damage, bullet.instigator, HitLocation,
            hitNormal * bullet.fireType.bullet.momentum, bullet.fireType.bullet.shotDamageType);
    else*/ //MEANTODO
        //niceRI.ServerHealTarget(targetPawn, bullet.damage, bullet.instigator);
}

static function HitZed(NiceBullet bullet, NiceMonster niceZed, Vector hitLocation,
    Vector hitNormal, float headshotLevel){
    local bool bIsHeadshot;
    local float actualDamage;
    local int lockonTicks;
    local float angle;
    local NicePlayerController nicePlayer;
    local class<NiceVeterancyTypes> niceVet;
    local NiceReplicationInfo niceRI;
    niceRI = bullet.niceRI;
    bIsHeadshot = (headshotLevel > 0.0);
   /*  if(bIsHeadshot && bullet.fireState.base.sourceWeapon != none){
        if(bullet.level.TimeSeconds - bullet.fireState.base.sourceWeapon.lastHeadshotTime <=
            class'NiceSkillGunslingerPlayful'.default.quickWindow)
            bullet.fireState.base.sourceWeapon.quickHeadshots ++;
        bullet.fireState.base.sourceWeapon.lastHeadshotTime = bullet.Level.TimeSeconds;
    }*/
    // Try to get necessary variables and bail in case they're unaccessible
    nicePlayer = NicePlayerController(bullet.Instigator.Controller);
    if(nicePlayer == none)
        return;
    niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(KFPlayerReplicationInfo(nicePlayer.PlayerReplicationInfo));
    if(bullet.fireType.bullet.bCausePain)
        actualDamage = bullet.fireType.bullet.damage;
    else
        actualDamage = bullet.damage;
    if(niceZed == bullet.fireState.lockon.target && bullet.fireState.lockon.time > 0.5
        && niceVet != none && niceVet.static.hasSkill(nicePlayer, class'NiceSkillSharpshooterKillConfirmed')){
        lockonTicks = Ceil(2 * bullet.fireState.lockon.time) - 1;
        //actualDamage *= 1.0 +
        //    0.5 * lockonTicks * (lockonTicks + 1) * class'NiceSkillSharpshooterKillConfirmed'.default.damageBonus;
        //damageMod *= 1.0 + lockonTicks * class'NiceSkillSharpshooterKillConfirmed'.default.damageBonus;
        actualDamage *= 1.0 + lockonTicks * class'NiceSkillSharpshooterKillConfirmed'.default.damageBonus;
    }/*
    if(niceVet == class'NiceVetGunslinger' && !bullet.bAlreadyHitZed)
        niceRI.ServerGunslingerConfirm(niceZed, actualDamage, bullet.instigator, hitLocation,
            bullet.fireType.bullet.momentum * hitNormal, bullet.fireType.bullet.shotDamageType, headshotLevel, bullet.fireState.lockon.time);*/
    if(!bullet.bGhost)
        niceRI.ServerDealDamage(niceZed, actualDamage, bullet.instigator, hitLocation,
            bullet.fireType.bullet.momentum * hitNormal, bullet.fireType.bullet.shotDamageType, headshotLevel, bullet.fireState.lockon.time);

    //// Handle angled shots
    angle = asin(hitNormal.Z);
    // Gunslinger skill check
    /*bGunslingerAngleShot = class'NiceVeterancyTypes'.static.hasSkill(nicePlayer, class'NiceSkillGunslingerCloseAndPersonal');
    if(bGunslingerAngleShot)
        bGunslingerAngleShot =
            VSizeSquared(bullet.instigator.location - niceZed.location) <=
                class'NiceSkillGunslingerCloseAndPersonal'.default.closeDistance ** 2;*/
    // Apply angled shots
    if((angle > 0.8 || angle < -0.45) && bullet.bCanAngleDamage && niceZed != none){
        bullet.bCanAngleDamage = false;
        bullet.bAlreadyHitZed = true;
        if(ZedPenetration(bullet.damage, bullet, niceZed, headshotLevel))
            HitZed(bullet, niceZed, hitLocation, hitNormal, headshotLevel);
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
        ZedPenetration(bullet.damage, bullet, niceZed, 0.0);
        HitZed(bullet, niceZed, hitLocation, hitNormal, headshotLevel);
    }
    bullet.insideBouncesLeft = 2;
}

static function bool ZedPenetration(out float Damage, NiceBullet bullet, NiceMonster niceZed, float headshotLevel){
    local float penReduction;
    local bool bIsHeadshot, bIsPreciseHeadshot;
    local NicePlayerController nicePlayer;
    local int actualMaxPenetrations;
    local class<NiceVeterancyTypes> niceVet;
    local class<NiceWeaponDamageType> niceDmgType;
    // True if we can penetrate even body, but now penetrating a head and shouldn't reduce damage too much
    local bool bEasyHeadPenetration;
    // Init variables
    nicePlayer = NicePlayerController(bullet.Instigator.Controller);
    niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(KFPlayerReplicationInfo(nicePlayer.PlayerReplicationInfo));
    niceDmgType = bullet.fireType.bullet.shotDamageType;
    bIsHeadshot = (headshotLevel > 0.0);
    bIsPreciseHeadshot = (headshotLevel > bullet.fireType.bullet.shotDamageType.default.prReqPrecise);
    bEasyHeadPenetration = bIsHeadshot && !niceDmgType.default.bPenetrationHSOnly;

    penReduction = niceDmgType.default.PenDmgReduction;
    // Apply zed reduction and perk reduction of reduction`
    if(niceZed != none){
        // Railgun skill exception
        if(niceVet != none && niceVet.static.hasSkill(nicePlayer, class'NiceSkillSharpshooterZEDRailgun') && nicePlayer.IsZedTimeActive())
            return true;
        if(niceZed.default.Health >= default.BigZedMinHealth && !bEasyHeadPenetration)
            penReduction *= niceDmgType.default.BigZedPenDmgReduction;
        else if(niceZed.default.Health >= default.MediumZedMinHealth && !bEasyHeadPenetration)
            penReduction *= niceDmgType.default.MediumZedPenDmgReduction;
    }
    else
        penReduction *= niceDmgType.default.BigZedPenDmgReduction;
    if(niceVet != none)
        penReduction = niceVet.static.GetPenetrationDamageMulti(KFPlayerReplicationInfo(nicePlayer.PlayerReplicationInfo), penReduction, niceDmgType);
    if(niceVet != none && nicePlayer.pawn.bIsCrouched && niceVet.static.hasSkill(nicePlayer, class'NiceSkillSharpshooterSurgical') && bIsHeadshot)
        penReduction = FMax(penReduction, class'NiceSkillSharpshooterSurgical'.default.penDmgReduction);
    // Assign new damage value and tell us if we should stop with penetration
    Damage *= penReduction;
    actualMaxPenetrations = niceDmgType.default.maxPenetrations;
    if(actualMaxPenetrations >= 0)
        actualMaxPenetrations +=
            niceVet.static.GetAdditionalPenetrationAmount(KFPlayerReplicationInfo(nicePlayer.PlayerReplicationInfo));
    if(!bIsHeadshot && niceDmgType.default.bPenetrationHSOnly)
        return false;
    if(actualMaxPenetrations < 0)
        return true;
    if(Damage / bullet.fireType.bullet.damage < (niceDmgType.default.PenDmgReduction ** (actualMaxPenetrations + 1)) + 0.0001 || Damage < 1)
        return false;
    return true;
}

defaultproperties
{
    BigZedMinHealth=1000
    MediumZedMinHealth=500
}