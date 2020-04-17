class NiceProjectileSpawner extends Actor
    dependson(NiceBullet);
// NICETODO: use flags correctly
static function MakeProjectile(Vector start, Rotator dir, NiceFire.ShotType shotParams, NiceFire.FireModeContext fireContext, optional bool bForceComplexTraj,
    optional bool bDuplReal, optional bool bSkipGhosts){
    local int i;
    local NicePack niceMut;
    niceMut = class'NicePack'.static.Myself(fireContext.Instigator.Level);
    if(niceMut == none)
       return;
    if(fireContext.Instigator.Role < ROLE_Authority || bDuplReal)
       SpawnProjectile(Start, Dir, shotParams, fireContext, false, bForceComplexTraj);
    if(fireContext.Instigator.Role == ROLE_Authority && niceMut != none && !bSkipGhosts){
       for(i = 0;i < niceMut.playersList.Length;i ++){
           if(niceMut.playersList[i] != fireContext.Instigator.Controller)
               niceMut.playersList[i].ClientSpawnGhostProjectile(start, dir.pitch, dir.yaw, dir.roll, shotParams, fireContext, bForceComplexTraj);
       }
    }
}
static function StickProjectile(KFHumanPawn instigator, Actor base, name bone, Vector shift, Rotator direction,
    NiceBullet.ExplosionData expData, optional bool bDuplReal, optional bool bSkipGhosts){
    local int i;
    local NicePack niceMut;
    niceMut = class'NicePack'.static.Myself(expData.Instigator.Level);
    if(niceMut == none)
       return;
    niceMut.stuckCounter ++;
    if(expData.Instigator.Role < ROLE_Authority)
       SpawnStuckProjectile(instigator, base, bone, shift, direction, expData, false, niceMut.stuckCounter);
    if(expData.Instigator.Role == ROLE_Authority && niceMut != none){
       for(i = 0;i < niceMut.playersList.Length;i ++){
           if( (niceMut.playersList[i] != expData.Instigator.Controller && !bSkipGhosts)
               || (niceMut.playersList[i] == expData.Instigator.Controller && bDuplReal) )
               niceMut.playersList[i].ClientStickGhostProjectile(instigator, base, bone, shift, direction, expData,
                   niceMut.stuckCounter);
       }
    }
}
static function NiceBullet SpawnProjectile(Vector Start, Rotator Dir, NiceFire.ShotType shotParams, NiceFire.FireModeContext fireContext, optional bool bIsGhost, optional bool bForceComplexTraj){
    local Actor other;
    local NiceBullet niceProj;
    local Vector HitLocation, HitNormal;
    local NicePlayerController nicePlayer;
    local class<NiceVeterancyTypes> niceVet;
    // No class - no projectile
    if(shotParams.bulletClass == none)
       return none;
    // Try to spawn
    if(fireContext.Instigator != none)
     niceProj = fireContext.Instigator.Spawn(shotParams.bulletClass,,, Start, Dir);
    // Try harder
    if(niceProj == none && fireContext.Instigator != none){
       other = fireContext.Instigator.Trace(HitLocation, HitNormal, Start, fireContext.Instigator.Location + fireContext.Instigator.EyePosition(), false, Vect(0,0,1));
       if(other != none)
           Start = HitLocation;
       niceProj = fireContext.Instigator.Spawn(shotParams.bulletClass,,, Start, Dir);
    }
    // Give up if failed after these two attempts
    if(niceProj == none)
       return none;
    niceProj.Renew();
    // Initialize projectile
    if(fireContext.Instigator != none)
     nicePlayer = NicePlayerController(fireContext.Instigator.Controller);
    if(nicePlayer != none)
       niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(nicePlayer.PlayerReplicationInfo);
    niceProj.bGhost = bIsGhost;
    // Fill-up data about what damage should projectile deal
    niceProj.charDamage = shotParams.damage;
    if(niceVet != none && fireContext.bIsBursting && niceVet.static.hasSkill(nicePlayer, class'NiceSkillCommandoExplosivePower'))
       niceProj.charDamage *= class'NiceSkillCommandoExplosivePower'.default.dmgMod;
    if(niceVet != none && niceVet.static.hasSkill(nicePlayer, class'NiceSkillSupportZEDBulletStorm') && nicePlayer.IsZedTimeActive())
       niceProj.charDamage = shotParams.damage * class'NiceSkillSupportZEDBulletStorm'.default.damageCut;
    niceProj.charOrigDamage = niceProj.charDamage;
    niceProj.charDamageType = shotParams.shotDamageType;
    niceProj.charExplosionDamageType = shotParams.explosionDamageType;
    niceProj.charExplosionDamage = shotParams.explosionDamage;
    niceProj.charExplosionRadius = shotParams.explosionRadius;
    niceProj.charExplosionExponent = shotParams.explosionExponent;
    niceProj.charExplosionMomentum = shotParams.explosionMomentum;
    niceProj.charFuseTime = shotParams.fuseTime;
    niceProj.charExplodeOnFuse = shotParams.explodeOnFuse;
    niceProj.charExplodeOnPawnHit = shotParams.explodeOnPawnHit;
    niceProj.charExplodeOnWallHit = shotParams.explodeOnWallHit;
    niceProj.charMomentumTransfer = shotParams.momentum;
    niceProj.charWasHipFired = fireContext.bHipfire;
    niceProj.charCausePain = shotParams.bCausePain;
    niceProj.lockonTime = fireContext.lockonTime;
    niceProj.lockonZed = fireContext.lockonZed;
    niceProj.instigator = fireContext.instigator;
    niceProj.sourceWeapon = fireContext.sourceWeapon;
    niceProj.charContiniousBonus = fireContext.continiousBonus;
    // Fill-up data about at what speed should projectile travel
    niceProj.movementSpeed = shotParams.projSpeed;
    if(niceVet != none && niceVet.static.hasSkill(nicePlayer, class'NiceSkillDemoOnperk'))
       niceProj.movementSpeed *= class'NiceSkillDemoOnperk'.default.speedBonus;
    niceProj.movementDirection = Vector(niceProj.rotation);
    niceProj.charAffectedByScream = shotParams.projAffectedByScream;
    niceProj.charIsSticky = shotParams.bShouldStick;
    niceProj.nicePlayer = nicePlayer;
    if(niceVet != none && niceVet.static.hasSkill(nicePlayer, class'NiceSkillDemoVolatile')){
       niceProj.charExplosionRadius *= class'NiceSkillDemoVolatile'.default.explRangeMult;
       niceProj.charExplosionExponent *= class'NiceSkillDemoVolatile'.default.falloffMult;
       niceProj.charMinExplosionDist *= class'NiceSkillDemoVolatile'.default.safeDistanceMult;
    }
    if(niceVet != none && niceVet.static.hasSkill(nicePlayer, class'NiceSkillDemoZEDFullBlast') && nicePlayer.IsZedTimeActive()){
       niceProj.charExplosionRadius *= class'NiceSkillDemoZEDFullBlast'.default.explRadiusMult;
       niceProj.charExplosionExponent = 0.0;
    }
    if(bForceComplexTraj)
       niceProj.bDisableComplexMovement = false;
    if(niceProj.Instigator != none && NicePlayerController(niceProj.Instigator.Controller) != none)
       niceProj.niceRI = NicePlayerController(niceProj.Instigator.Controller).NiceRI;
    // And some leftovers
    //niceProj.bShouldBounce = shotParams.bShouldBounce;
    niceProj.bInitFinished = true;
    return niceProj;
}
static function SpawnStuckProjectile(KFHumanPawn instigator, Actor base, name bone, Vector shift, Rotator direction,
    NiceBullet.ExplosionData expData, bool bIsGhost, int stuckID){
    local Pawn                      justPawn;
    local NiceFire.ShotType         shotParams;
    local NiceFire.FireModeContext  fireContext;
    local NiceBullet                spawnedBullet;
    local NicePlayerController      nicePlayer;
    nicePlayer = NicePlayerController(instigator.Controller);
    if(base == none || nicePlayer == none)
       return;
    justPawn = Pawn(base);
    fireContext.instigator          = NiceHumanPawn(instigator);
    fireContext.sourceWeapon        = expData.sourceWeapon;
    shotParams.bulletClass          = expData.bulletClass;
    shotParams.explosionDamageType  = expData.explosionDamageType;
    shotParams.explosionDamage      = expData.explosionDamage;
    shotParams.explosionRadius      = expData.explosionRadius;
    shotParams.explosionExponent    = expData.explosionExponent;
    shotParams.explosionMomentum    = expData.explosionMomentum;
    shotParams.fuseTime             = expData.fuseTime;
    shotParams.explodeOnFuse        = expData.explodeOnFuse;
    shotParams.projAffectedByScream = expData.affectedByScream;
    spawnedBullet = SpawnProjectile(base.location, direction, shotParams, fireContext, bIsGhost);
    if(spawnedBullet == none)
       return;
    spawnedBullet.stuckID = stuckID;
    spawnedBullet.bStuck = true;
    nicePlayer.RegisterStuckBullet(spawnedBullet);
    if(justPawn != none){
       spawnedBullet.bStuckToHead = expData.stuckToHead;
       spawnedBullet.SetBase(base);
       justPawn.AttachToBone(spawnedBullet, bone);
       spawnedBullet.SetRelativeLocation(shift);
       spawnedBullet.SetRelativeRotation(Rotator(Vector(direction) << justPawn.GetBoneRotation(bone, 0)));
       spawnedBullet.bUseBone = true;
       spawnedBullet.stuckBone = bone;
    }
    else{
       spawnedBullet.SetBase(base);
       spawnedBullet.SetRelativeLocation(shift);
    }
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=1.000000
}
