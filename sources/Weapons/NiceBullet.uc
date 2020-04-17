//======================================================================================================================
//  NicePack / NiceBullet
//======================================================================================================================
//  Bullet class that's supposed to take care of all damage-dealing projectile needs.
//  Functionality:
//      - Simulation of both linear and piece-wise motion
//      - Collision detection that can be handled through the adapter class
//======================================================================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//======================================================================================================================
class NiceBullet extends Actor;
//  Link to interaction with the server
var NiceReplicationInfo niceRI;
//  Controller of our instigator
var NicePlayerController nicePlayer;
//  Controller of local player
var NicePlayerController localPlayer;
//  Link to our mutator
var NicePack niceMutator;

//======================================================================================================================
//  Battle bullet characteristic
var float                       charOrigDamage;
var float                       charDamage;
var float                       decapMod;
var float                       incapMod;
var int                         charPenetrationCount;
var float                       charMomentumTransfer;
var class<NiceWeaponDamageType> charDamageType;
var class<NiceWeaponDamageType> charExplosionDamageType;
var float                       charExplosionDamage;
var float                       charExplosionRadius;
var float                       charExplosionExponent;
var float                       charExplosionMomentum;
var bool                        charIsDud;
var float                       charFuseTime;
var bool                        charExplodeOnFuse;
var bool                        charExplodeOnPawnHit;
var bool                        charExplodeOnWallHit;
var bool                        charAffectedByScream;
var float                       charMinExplosionDist;
var bool                        charWasHipFired;
var bool                        charCausePain;
var bool                        charIsSticky;
var float                       charContiniousBonus;
var bool                        bAlreadyHitZed;
var NiceWeapon                  sourceWeapon;
var NiceMonster                 lockonZed;
var float                       lockonTime;
var float                       bounceHeadMod;
var int                         insideBouncesLeft;
var bool                        bGrazing;

//======================================================================================================================
//  Sticky projectile-related variables
var bool                            bStuck, bUseBone, bStuckToHead;
var name                            stuckBone;
var int                             stuckID;
//  Data about explosive characteristics that must be transfered after projectile sticks on something
struct ExplosionData{
    var Pawn                        instigator;
    var NiceWeapon                  sourceWeapon;
    var class<NiceBullet>           bulletClass;
    var class<NiceWeaponDamageType> explosionDamageType;
    var float                       explosionDamage;
    var float                       explosionRadius;
    var float                       explosionExponent;
    var float                       explosionMomentum;
    var float                       fuseTime;
    var bool                        explodeOnFuse;
    var bool                        affectedByScream;
    var bool                        stuckToHead;
};

//======================================================================================================================
//  Temporary variables that either need to be moved into config or generalized later
//  How often trajectory is allowed to change direction?
var const float trajUpdFreq;
//  How much tracing cycles to endure before declaring an infinite cycle?
var const int   maxTraceCycles;
var bool        bCanAngleDamage;

//======================================================================================================================
//  State variables
//  Indicates that all necessary values were recorded and we can process this bullet normally
var bool    bInitFinished;
var bool    bInitFinishDetected;
//  Disables all the interaction of this bullet with the world and removes it / marks it for removal
var bool    bBulletDead;
var bool    bGhost;

//======================================================================================================================
//  Collision management
//  Describes an actor that we don't wish to collide with
struct  IgnoreEntry{
    var Actor   ignored;
    //  Set to true when 3rd party already disabled this actor before we had the chance
    //  Used to avoid re-enabling it later
    var bool    bExtDisabled;
};
var array<IgnoreEntry>  ignoredActors;
//  'true' if we're enforcing our collision rules on actors to ignore them
var bool                bIgnoreIsActive;

//======================================================================================================================
//  Movement
//  If 'true' disables any modifications to the bullet's movement, making it travel in a simple, linear path
var bool    bDisableComplexMovement;
//  Linear motion
var float   movementSpeed;
var Vector  movementDirection;
//  Added vector acceleration
var Vector  movementAcceleration;
var bool    bShouldBounce;
//  Amount of time our bullet should fall down after hitting a wall
var float   movementFallTime;

//======================================================================================================================
//  Path building
//  We will be building a piecewise linear path for projectiles, where each linear segment should be passable by
//  projectile in time 'trajUpdFreq'.
//  By changing trajectory in only preset point allow client to emulate non-linear paths,
//  while keeping them more or less independent from the frame rate.
//  Start and End point of the current linear segment
var Vector  pathSegmentS, pathSegmentE;
//  Point in the segment, at which we've stopped after last movement
var Vector  shiftPoint;
//  The part of current segment that we've already covered, changes from 0.0 to 1.0.
//  Values above 1.0 indicate that segment was finished and we need to build another one.
//  Values below 0.0 indicate that no segment has yet been built.
var float   finishedSegmentPart;

//======================================================================================================================
//  Visual effects
var class<Emitter>  trailClass;
var class<xEmitter> trailXClass;
var Emitter         bulletTrail;
var xEmitter        bulletXTrail;
//  Describes effect that projectile should produce on hit
struct  ImpactEffect{
    //  Is this effect too important to cut it due to effect limit?
    var bool                bImportanEffect;
    //  Should we play classic KF's hit effect ('ROBulletHitEffect')?
    var bool                bPlayROEffect;
    //  Decal to spawn; null to skip
    var class<Projector>    decalClass;
    //  Emitter to spawn; null to skip
    var class<Emitter>      emitterClass;
    //  How much back (against direction of the shot) should we spawn emitter? Can be used to avoid clipping with walls
    var float               emitterShiftWall;   // Shift for wall-hits
    var float               emitterShiftPawn;   // Shift for pawn-hits
    //  Impact noise parameters
    var Sound               noise;
    var string              noiseRef;           // Reference to 'Sound' to allow dynamic resource allocation
    var float               noiseVolume;
};
var ImpactEffect    regularImpact;
var ImpactEffect    explosionImpact;
var ImpactEffect    disintegrationImpact;
var bool            bGenRegEffectOnPawn;
var bool    bShakeViewOnExplosion;
var Vector  shakeRotMag;        // how far to rot view
var Vector  shakeRotRate;       // how fast to rot view
var float   shakeRotTime;       // how much time to rot the instigator's view
var Vector  shakeOffsetMag;     // max view offset vertically
var Vector  shakeOffsetRate;    // how fast to offset view vertically
var float   shakeOffsetTime;    // how much time to offset view
var float   shakeRadiusMult;

//======================================================================================================================
//  References
//  References to allow pre-loading of some resource objects, declared in parent classes
var string meshRef;
var string staticMeshRef;
var string ambientSoundRef;

//======================================================================================================================
//  Functions
static function PreloadAssets(){
    if(default.ambientSound == none && default.ambientSoundRef != "")
       default.ambientSound = sound(DynamicLoadObject(default.ambientSoundRef, class'Sound', true));
    if(default.staticMesh == none && default.staticMeshRef != "")
       UpdateDefaultStaticMesh(StaticMesh(DynamicLoadObject(default.staticMeshRef, class'StaticMesh', true)));
    if(default.mesh == none && default.meshRef != "")
       UpdateDefaultMesh(Mesh(DynamicLoadObject(default.meshRef, class'Mesh', true)));
    if(default.regularImpact.noise == none && default.regularImpact.noiseRef != "")
       default.regularImpact.noise =
           sound(DynamicLoadObject(default.regularImpact.noiseRef, class'Sound', true));
    if(default.explosionImpact.noise == none && default.explosionImpact.noiseRef != "")
       default.explosionImpact.noise =
           sound(DynamicLoadObject(default.explosionImpact.noiseRef, class'Sound', true));
    if(default.disintegrationImpact.noise == none && default.disintegrationImpact.noiseRef != "")
       default.disintegrationImpact.noise =
           sound(DynamicLoadObject(default.disintegrationImpact.noiseRef, class'Sound', true));
}
static function bool UnloadAssets(){
    default.AmbientSound = none;
    UpdateDefaultStaticMesh(none);
    UpdateDefaultMesh(none);
    default.regularImpact.noise = none;
    default.explosionImpact.noise = none;
    default.disintegrationImpact.noise = none;
    return true;
}
function PostBeginPlay(){
    super.PostBeginPlay();
    bounceHeadMod   = 1.0;
}
function UpdateTrails(){
    local Actor trailBase;
    // Do nothing on dedicated server
    if(Level.NetMode == NM_DedicatedServer)
       return;
    // Spawn necessary trails first
    if(trailClass != none && bulletTrail == none)
       bulletTrail = Spawn(trailClass, self);
    if(trailXClass != none && bulletXTrail == none)
       bulletXTrail = Spawn(trailXClass, self);
    // Handle positioning differently for stuck and regular projectiles
    if(bStuck && base != none){
       if(bUseBone){
           if(bulletTrail != none){
               bulletTrail.SetBase(base);
               base.AttachToBone(bulletTrail, stuckBone);
               bulletTrail.SetRelativeLocation(relativeLocation);
               bulletTrail.SetRelativeRotation(relativeRotation);
           }
           if(bulletXTrail != none){
               bulletXTrail.SetBase(base);
               base.AttachToBone(bulletTrail, stuckBone);
               bulletXTrail.SetRelativeLocation(relativeLocation);
               bulletXTrail.SetRelativeRotation(relativeRotation);
           }
       }
    }
    else
       trailBase = self;
    // Update lifetime and base (latter is for non-bone attachments only)
    if(bulletTrail != none){
       if(trailBase != none)
           bulletTrail.SetBase(trailBase);
       bulletTrail.lifespan = lifeSpan;
    }
    if(bulletXTrail != none){
       if(trailBase != none)
           bulletXTrail.SetBase(trailBase);
       bulletXTrail.lifespan = lifeSpan;
    }
}
function ResetPathBuilding(){
    finishedSegmentPart = -1.0;
    shiftPoint = location;
}
//  Resets default values for this bullet.
//  Must be called before each new use of a bullet.
function Renew(){
    bInitFinished       = false;
    bBulletDead         = false;
    bCanAngleDamage     = true;
    SoundVolume         = default.SoundVolume;
    decapMod = 1.0f;
    incapMod = 1.0f;
    ResetIgnoreList();
    ResetPathBuilding();
}
simulated function Tick(float delta){
    super.Tick(delta);
    if(localPlayer == none)
       localPlayer = NicePlayerController(Level.GetLocalPlayerController());
    if(charFuseTime > 0){
       charFuseTime -= delta;
       if(charFuseTime < 0){
           if(charExplodeOnFuse && !charIsDud){
               GenerateImpactEffects(explosionImpact, location, movementDirection);
               if(bStuck)
                   class'NiceBulletAdapter'.static.Explode(self, niceRI, location, base);
               else
                   class'NiceBulletAdapter'.static.Explode(self, niceRI, location);
           }
           if(!charExplodeOnFuse)
               GenerateImpactEffects(disintegrationImpact, location, movementDirection);
           KillBullet();
       }
    }
    if(bInitFinished && !bInitFinishDetected){
       bInitFinishDetected = true;
       UpdateTrails();
    }
    if(bInitFinished && !bBulletDead && !bStuck)
       DoProcessMovement(delta);
    if(bInitFinished && bStuck){
       if(base == none || (KFMonster(base) != none && KFMonster(base).health <= 0))
           nicePlayer.ExplodeStuckBullet(stuckID);
    }
}
//  Extracts pawn actor from it's auxiliary collision
//  @param  other   Actor we collided with
//  @return         Pawn we're interested in
function Actor GetMainActor(Actor other){
    if(other == none)
       return none;
    // Try owner
    if( KFPawn(other) == none && KFMonster(other) == none
    &&  (KFPawn(other.owner) != none || KFMonster(other.owner) != none) )
       other = other.owner;
    // Try base
    if( KFPawn(other) == none && KFMonster(other) == none
    &&  (KFPawn(other.base) != none || KFMonster(other.base) != none) )
       other = other.base;
    return other;
}
//  Returns 'true' if passed actor is either world geometry, 'Level' itself or nothing ('none')
//  Neither of these related to pawn damage dealing
function bool IsLevelActor(Actor other){
    if(other == none)
       return true;
    return (other.bWorldGeometry || other == Level);
}
//  Adds given actor and every colliding object connected to it to ignore list
//  Removes their collision in case ignore is active (see 'bIgnoreIsActive')
function TotalIgnore(Actor other){
    // These mark what objects, associated with 'other' we also need to ignore
    local KFPawn    pawnOther;
    local KFMonster zedOther;
    if(other == none)
       return;
    // Try to find main actor as KFPawn
    pawnOther = KFPawn(other);
    if(pawnOther == none)
       pawnOther = KFPawn(other.base);
    if(pawnOther == none)
       pawnOther = KFPawn(other.owner);
    // Try to find main actor as KFMonster
    zedOther = KFMonster(other);
    if(zedOther == none)
       zedOther = KFMonster(other.base);
    if(zedOther == none)
       zedOther = KFMonster(other.owner);
    // Ignore everything that's associated with this actor and can have collision
    IgnoreActor(other);
    IgnoreActor(other.base);
    IgnoreActor(other.owner);
    if(pawnOther != none)
       IgnoreActor(pawnOther.AuxCollisionCylinder);
    if(zedOther != none)
       IgnoreActor(zedOther.MyExtCollision);
}
//  Adds a given actor to ignore list and removes it's collision in case ignore is active (see 'bIgnoreIsActive')
function IgnoreActor(Actor other){
    local int           i;
    local IgnoreEntry   newIgnoredEntry;
    // Check if that's a non-level actor and not already on the list
    if(IsLevelActor(other))
       return;
    for(i = 0;i < ignoredActors.Length;i ++)
       if(ignoredActors[i].ignored == other)
           return;
    // Add actor to the ignore list & disable collision if needed
    if(other != none){
       // Make entry
       newIgnoredEntry.ignored         = other;
       newIgnoredEntry.bExtDisabled    = !other.bCollideActors;
       // Add and activate it
       ignoredActors[ignoredActors.Length] = newIgnoredEntry;
       if(bIgnoreIsActive)
           other.SetCollision(false);
    }
}
//  Restores ignored state of the actors and zeroes our ignored arrays
function ResetIgnoreList(){
    SetIgnoreActive(false);
    ignoredActors.Length = 0;
}
//  Activates/deactivates ignore for actors on the ignore list.
//  Ignore deactivation doesn't restore collision if actor was set to not collide prior most recent ignore activation.
//  Activating ignore when it's already active does nothing; same with deactivation.
//  Ignore deactivation is supposed to be used in the same function call in which activation took place before.
function SetIgnoreActive(bool bActive){
    local int i;
    // Do nothing if we're already in a correct state
    if(bActive == bIgnoreIsActive)
       return;
    // Change ignore state & disable collision for ignored actors
    bIgnoreIsActive = bActive;
    for(i = 0;i < ignoredActors.Length;i ++)
       if(ignoredActors[i].ignored != none){
           // Mark actors that were set to not collide before activation
           if(bActive && !ignoredActors[i].ignored.bCollideActors)
               ignoredActors[i].bExtDisabled = true;
           // Change collision for actors that weren't externally modified
           if(!ignoredActors[i].bExtDisabled)
               ignoredActors[i].ignored.SetCollision(!bActive);
           // After we deactivated our rules - forget about external modifications
           if(!bActive)
               ignoredActors[i].bExtDisabled = false;
       }
}
function SetHumanPawnCollision(bool bEnable){
    local int i;
    if(niceMutator == none)
       niceMutator = class'NicePack'.static.Myself(Level);
    for(i = 0;i < niceMutator.recordedHumanPawns.Length;i ++)
       if(niceMutator.recordedHumanPawns[i] != none)
           niceMutator.recordedHumanPawns[i].bBlockHitPointTraces = bEnable;
}
function float CheckHeadshot(KFMonster kfZed, Vector hitLocation, Vector hitDirection){
    local float                     hsMod;
    local float                     precision;
    local bool                      bIsShotgunBullet;
    local NiceMonster               niceZed;
    local KFPlayerReplicationInfo   KFPRI;
    local class<NiceVeterancyTypes> niceVet;
    niceZed = NiceMonster(kfZed);
    hitDirection = Normal(hitDirection);
    bIsShotgunBullet = ClassIsChildOf(charDamageType, class'NiceDamageTypeVetEnforcer');
    if(niceZed != none){
       hsMod = bounceHeadMod;    // NICETODO: Add bounce and perk and damage type head-shot zones bonuses
       hsMod *= charDamageType.default.headSizeModifier;
       hsMod *= bounceHeadMod;
       if(nicePlayer != none)
           KFPRI = KFPlayerReplicationInfo(nicePlayer.PlayerReplicationInfo);
       if(KFPRI != none)
           niceVet = class<NiceVeterancyTypes>(KFPRI.ClientVeteranSkill);
       if(niceVet != none)
           hsMod *= niceVet.static.GetHeadshotCheckMultiplier(KFPRI, charDamageType);
       precision = niceZed.IsHeadshotClient(hitLocation, hitDirection, niceZed.clientHeadshotScale * hsMod);
       if(precision <= 0.0 && bIsShotgunBullet && nicePlayer != none && class'NiceVeterancyTypes'.static.hasSkill(nicePlayer, class'NiceSkillSupportGraze')){
           bGrazing = true;
           hsMod *= class'NiceSkillSupportGraze'.default.hsBonusZoneMult;
           precision = niceZed.IsHeadshotClient(hitLocation, hitDirection, niceZed.clientHeadshotScale * hsMod);
       }
       return precision;
    }
    else{
       if(kfZed.IsHeadShot(hitLocation, hitDirection, 1.0))
           return 1.0;
       else
           return 0.0;
    }
}
//  Makes bullet trace a directed line segment given by start and end points.
//  All traced actors and geometry are then properly affected by corresponding 'HandleHitPawn', 'HandleHitZed' and
//  'HandleHitWall' functions.
//  Might have to do several traces in case it either hits a (several) target(s)
function DoTraceLine(Vector lineStart, Vector lineEnd){
    local float         headshotLevel;
    // Amount of tracing iterations we had to do
    local int           iterationCount;
    // Direction and length of traced line
    local Vector        lineDirection;
    // Auxiliary variables for retrieving results of tracing
    local Vector        hitLocation, hitNormal;
    local Actor         tracedActor;
    local array<int>    hitPoints;
    local KFMonster     tracedZed;
    local KFPawn        tracedPawn;
    lineDirection = (lineEnd - lineStart);
    lineDirection = (lineDirection) / VSize(lineDirection);
    // Do not trace for disabled bullets and prevent infinite loops
    while(!bBulletDead && iterationCount < maxTraceCycles){
       iterationCount ++;
       // Trace next object
       if(!bGhost || localPlayer == none || localPlayer.tracesThisTick <= localPlayer.tracesPerTickLimit){
           if(Instigator != none)
               tracedActor = Instigator.Trace(hitLocation, hitNormal, lineEnd, lineStart, true);
           else
               tracedActor = none;
           localPlayer.tracesThisTick ++;
       }
       else
           tracedActor = none;
       if(charAffectedByScream && !charIsDud && localPlayer != none && localPlayer.localCollisionManager != none && localPlayer.localCollisionManager.IsCollidingWithAnything(lineStart, lineEnd))
           HandleScream(lineStart, lineDirection);
       if(tracedActor != none && IsLevelActor(tracedActor)){
           HandleHitWall(tracedActor, hitLocation, hitNormal);
           break;
       }
       else{
           TotalIgnore(tracedActor);
           tracedActor = GetMainActor(tracedActor);
       }

       // If tracing between current trace points haven't found anything and tracing step is less than segment's length
       // -- shift tracing bounds
       if(tracedActor == none)
           return;

       // First, try to handle pawn like a zed; if fails, - try to handle it like 'KFPawn'
       tracedZed = KFMonster(tracedActor);
       tracedPawn = KFPawn(tracedActor);
       if(tracedPawn != none && NiceHumanPawn(instigator) != none &&
           (NiceHumanPawn(instigator).ffScale <= 0 && NiceMedicProjectile(self) == none) )
           continue;
       if(tracedZed != none){
           if(tracedZed.Health > 0){
               headshotLevel = CheckHeadshot(tracedZed, hitLocation, lineDirection);
               HandleHitZed(tracedZed, hitLocation, lineDirection, headshotLevel);
           }
       }
       else if(tracedPawn != none && tracedPawn.Health > 0){
           if(tracedPawn.Health > 0)
               HandleHitPawn(tracedPawn, hitLocation, lineDirection, hitPoints);
       }
       else
           HandleHitWall(tracedActor, hitLocation, hitNormal);
    }
}
//  Replaces current path segment with the next one.
//  Doesn't check whether or not we've finished with the current segment.
function BuildNextPathSegment(){
    // Only set start point to our location when we build path segment for the first time
    // After that we can't even assume that bullet is exactly in the 'pathSegmentE' point
    if(finishedSegmentPart < 0.0)
       pathSegmentS = Location;
    else
       pathSegmentS = pathSegmentE;
    movementDirection += (movementAcceleration * trajUpdFreq) / movementSpeed;
    pathSegmentE = pathSegmentS + movementDirection * movementSpeed * trajUpdFreq;
    finishedSegmentPart = 0.0;
    shiftPoint = pathSegmentS;
}
//  Updates 'shiftPoint' to the next bullet position in current segment.
//  Does nothing if current segment is finished or no segment was built at all.
//  @param  delta   Amount of time bullet has to move through the segment.
//  @return         Amount of time left for bullet to move after this segment
function float ShiftInSegment(float delta){
    // Time that bullet still has available to move after this segment
    local float remainingTime;
    // Part of segment we can pass in a given time
    local float segmentPartWeCanPass;
    // Exit if there's no segment in progress
    if(finishedSegmentPart < 0.0 || finishedSegmentPart > 1.0)
       return delta;
    // [movementSpeed * delta] / [movementSpeed * trajUpdFreq] = [delta / trajUpdFreq]
    segmentPartWeCanPass = delta / trajUpdFreq;
    // If we can move through the rest of the segment - move to end point and mark it finished
    if(segmentPartWeCanPass >= (1.0 - finishedSegmentPart)){
       remainingTime = delta - (1.0 - finishedSegmentPart) * trajUpdFreq;
       finishedSegmentPart = 1.1;
       shiftPoint = pathSegmentE;
    }
    // Otherwise compute new 'shiftPoint' normally
    else{
       remainingTime = 0.0;
       finishedSegmentPart += (delta / trajUpdFreq);
       shiftPoint = pathSegmentS + movementDirection * movementSpeed * trajUpdFreq * finishedSegmentPart;
    }
    return remainingTime;
}
//  Moves bullet according to settings and decides when and how much tracing should it do.
//  @param  delta   Amount of time passed after previous bullet movement
function DoProcessMovement(float delta){
    local Vector    tempVect;
    SetIgnoreActive(true);
    //SetHumanPawnCollision(true);
    //  Simple linear movement
    if(bDisableComplexMovement){
       // Use 'traceStart' as a shift variable here
       // Naming is bad in this case, but it avoids 
       tempVect = movementDirection * movementSpeed * delta;
       DoTraceLine(location, location + tempVect);
       Move(tempVect);
       // Reset path building
       // If in future complex movement would be re-enabled, - we want to set first point of the path to
       // the location of bullet at a time and not use outdated information.
       finishedSegmentPart = -1.0;
    }
    //  Non-linear movement support
    else{
       while(delta > 0.0){
           if(finishedSegmentPart < 0.0 || finishedSegmentPart > 1.0)
               BuildNextPathSegment();
           // Remember current 'shiftPoint'. That's where we stopped tracing last time and where we must resume.
           tempVect = shiftPoint;
           // Update 'shiftPoint' (bullet position)
           // and update how much time we've got left after we wasted some to move.
           delta = ShiftInSegment(delta);
           // Trace between end point of previous tracing and end point of the new one.
           DoTraceLine(tempVect, shiftPoint);
       }
       tempVect = shiftPoint - location;
       Move(shiftPoint - location);
    }
    SetRotation(Rotator(movementDirection));
    if(charMinExplosionDist > 0)
       charMinExplosionDist -= VSize(tempVect);
    SetIgnoreActive(false);
    //SetHumanPawnCollision(false);
}
function Stick(Actor target, Vector hitLocation){
    local NiceMonster   targetZed;
    local name          boneStick;
    local float         distToBone;
    local float         t;
    local Vector        boneStrickOrig;
    local ExplosionData expData;
    if(bGhost)
       return;
    expData.explosionDamageType = charExplosionDamageType;
    expData.explosionDamage = charExplosionDamage;
    expData.explosionRadius = charExplosionRadius;
    expData.explosionExponent = charExplosionExponent;
    expData.explosionMomentum = charExplosionMomentum;
    expData.fuseTime = charFuseTime;
    expData.explodeOnFuse = charExplodeOnFuse;
    expData.affectedByScream = charAffectedByScream;
    expData.sourceWeapon = sourceWeapon;
    targetZed = NiceMonster(target);
    if(targetZed == none){
       expData.bulletClass = class;
       expData.instigator = instigator;
       niceRI.ServerStickProjectile(KFHumanPawn(instigator), target, 'None', hitLocation - target.location,
           Rotator(movementDirection), expData);
       class'NiceProjectileSpawner'.static.StickProjectile(KFHumanPawn(instigator), target, 'None',
           hitLocation - target.location, Rotator(movementDirection), expData);
    }
    else{
       expData.bulletClass = class;
       expData.instigator = instigator;
       boneStick = targetZed.GetClosestBone(hitLocation, movementDirection, distToBone);
       if(CheckHeadshot(targetZed, hitLocation, movementDirection) > 0.0)
           boneStick = targetZed.HeadBone;
       if(boneStick == targetZed.HeadBone)
           expData.stuckToHead = true;
       boneStrickOrig = targetZed.GetBoneCoords(boneStick).origin;
       t = movementDirection.x * (boneStrickOrig.x - hitLocation.x) +
           movementDirection.y * (boneStrickOrig.y - hitLocation.y) +
           movementDirection.z * (boneStrickOrig.z - hitLocation.z);
       t /= VSizeSquared(movementDirection);
       t *= 0.5;
       hitLocation = hitLocation + t * movementDirection;
       niceRI.ServerStickProjectile(KFHumanPawn(instigator), targetZed, boneStick,
           hitLocation - boneStrickOrig, Rotator(movementDirection), expData);
       class'NiceProjectileSpawner'.static.StickProjectile(KFHumanPawn(instigator), targetZed, boneStick,
           hitLocation - boneStrickOrig, Rotator(movementDirection), expData);
    }
    KillBullet();
}
function DoExplode(Vector explLocation, Vector impactNormal){
    if(charIsDud)
       return;
    if(bStuck)
       class'NiceBulletAdapter'.static.Explode(self, niceRI, explLocation, base);
    else
       class'NiceBulletAdapter'.static.Explode(self, niceRI, explLocation);
    GenerateImpactEffects(explosionImpact, explLocation, impactNormal, true, true);
    if(bShakeViewOnExplosion)
       ShakeView(explLocation);
    KillBullet();
}
function HandleHitWall(Actor wall, Vector hitLocation, Vector hitNormal){
    local bool          bBulletTooWeak;
    if(charExplodeOnWallHit && !charIsDud && charMinExplosionDist <= 0.0){
       DoExplode(hitLocation, hitNormal);
       return;
    }
    else{
       class'NiceBulletAdapter'.static.HitWall(self, niceRI, wall, hitLocation, hitNormal);
       GenerateImpactEffects(regularImpact, hitLocation, hitNormal, true, true);
       if(charIsSticky)
           Stick(wall, hitLocation);
    }
    if(bShouldBounce && !bDisableComplexMovement){
       movementDirection = (movementDirection - 2.0 * hitNormal * (movementDirection dot hitNormal));
       bBulletTooWeak = !class'NiceBulletAdapter'.static.ZedPenetration(charDamage, self, none, false, false);
       charPenetrationCount += 1;
       ResetPathBuilding();
       ResetIgnoreList();
       bounceHeadMod *= 2;
    }
    else if(movementFallTime > 0.0){
       charIsDud = true;
       lifeSpan = movementFallTime;
       movementFallTime = 0.0;
       movementDirection = vect(0,0,0);
       ResetPathBuilding();
       ResetIgnoreList();
    }
    else
       bBulletTooWeak = true;
    if(bBulletTooWeak)
       KillBullet();
}
function HandleHitPawn(KFPawn hitPawn, Vector hitLocation, Vector hitDirection, array<int> hitPoints){
    if(charExplodeOnPawnHit && !charIsDud && charMinExplosionDist <= 0.0){
       DoExplode(hitLocation, hitDirection);
       GenerateImpactEffects(explosionImpact, hitLocation, hitDirection);
       return;
    }
    else{
       class'NiceBulletAdapter'.static.HitPawn(self, niceRI, hitPawn, hitLocation, hitDirection, hitPoints);
       if(bGenRegEffectOnPawn)
           GenerateImpactEffects(regularImpact, hitLocation, hitDirection, false, false);
    }
    if(!class'NiceBulletAdapter'.static.ZedPenetration(charDamage, self, none, false, false)){
        charPenetrationCount += 1;
        KillBullet();
    }
}
function HandleHitZed(KFMonster targetZed, Vector hitLocation, Vector hitDirection, float headshotLevel){
    local bool bHitZedCalled;
    if(class'NiceVeterancyTypes'.static.hasSkill(nicePlayer, class'NiceSkillDemoDirectApproach')){
       class'NiceBulletAdapter'.static.HitZed(self, niceRI, targetZed, hitLocation, hitDirection, headshotLevel);
       if(bGenRegEffectOnPawn)
           GenerateImpactEffects(regularImpact, hitLocation, hitDirection, false, false);
       bHitZedCalled = true;
    }
    if(charExplodeOnPawnHit && !charIsDud && charMinExplosionDist <= 0.0){
       class'NiceBulletAdapter'.static.Explode(self, niceRI, hitLocation, targetZed);
       GenerateImpactEffects(explosionImpact, hitLocation, hitDirection);
       if(bShakeViewOnExplosion)
           ShakeView(hitLocation);
       KillBullet();
       return;
    }
    else{
       if(!bHitZedCalled){
           class'NiceBulletAdapter'.static.HitZed(self, niceRI, targetZed, hitLocation, hitDirection, headshotLevel);
           if(bGenRegEffectOnPawn)
               GenerateImpactEffects(regularImpact, hitLocation, hitDirection, false, false);
       }
       bHitZedCalled = true;
       if(!bGhost && !bAlreadyHitZed){
           bAlreadyHitZed = true;
           if(nicePlayer != none && niceRI != none)
               niceRI.ServerJunkieExtension(nicePlayer, headshotLevel > 0.0);
       }
       if(charIsSticky)
           Stick(targetZed, hitLocation);
    }
    if(!class'NiceBulletAdapter'.static.ZedPenetration(charDamage, self, targetZed, (headshotLevel > 0.0), (headshotLevel > charDamageType.default.prReqPrecise))){
        charPenetrationCount += 1;
        KillBullet();
    }
}
function HandleScream(Vector disintegrationLocation, Vector entryDirection){
    if(!charIsDud)
       GenerateImpactEffects(disintegrationImpact, disintegrationLocation, entryDirection);
    class'NiceBulletAdapter'.static.HandleScream(self, niceRI, disintegrationLocation, entryDirection);
}
function GenerateImpactEffects(ImpactEffect effect, Vector hitLocation, Vector hitNormal,
    optional bool bWallImpact, optional bool bGenerateDecal){
    local float                 actualCullDistance;
    local float                 actualImpactShift;
    local bool                  generatedEffect;
    // No need to play visuals on a server, for a dead bullets or in case there's no local player at all
    if(Level.NetMode == NM_DedicatedServer || bBulletDead || localPlayer == none)
       return;
    if(!localPlayer.CanSpawnEffect(bGhost) && !effect.bImportanEffect)
       return;
    // -- Classic effect
    if(effect.bPlayROEffect && !bBulletDead)
       Spawn(class'ROBulletHitEffect',,, hitLocation, rotator(-hitNormal));
    // -- Generate decal
    if(bGenerateDecal && effect.decalClass != none){
       // Find appropriate cull distance for this decal
       actualCullDistance = effect.decalClass.default.cullDistance;
       // Double cull distance if local player is an instigator
       if(instigator != none && localPlayer == instigator.Controller)
           actualCullDistance *= 2;    // NICETODO: magic number
       // Spawn decal
       if(!localPlayer.BeyondViewDistance(hitLocation, actualCullDistance)){
           Spawn(effect.decalClass, self,, hitLocation, rotator(- hitNormal));
           generatedEffect = true;
       }
    }
    // -- Generate custom effect
    if(effect.emitterClass != none && EffectIsRelevant(hitLocation, false)){
       if(bWallImpact)
           actualImpactShift = effect.emitterShiftWall;
       else
           actualImpactShift = effect.emitterShiftPawn;
       Spawn(effect.emitterClass,,, hitLocation - movementDirection * actualImpactShift, rotator(movementDirection));
       generatedEffect = true;
    }
    // -- Generate custom sound
    if(effect.noise != none){
       class'NiceSoundCls'.default.effectSound    = effect.noise;
       class'NiceSoundCls'.default.effectVolume   = effect.noiseVolume;
       Spawn(class'NiceSoundCls',,, hitLocation);
       generatedEffect = true;
    }
    if(generatedEffect)
       localPlayer.AddEffect();
}
function ShakeView(Vector hitLocation){
    local float distance, scale;
    if(nicePlayer == none || shakeRadiusMult < 0.0)
       return;
    distance = VSize(hitLocation - nicePlayer.ViewTarget.Location);
    if(distance < charExplosionRadius * shakeRadiusMult){
       if(distance < charExplosionRadius)
           scale = 1.0;
       else
           scale = (charExplosionRadius * ShakeRadiusMult - distance) / (charExplosionRadius);
       nicePlayer.ShakeView(shakeRotMag*scale, shakeRotRate, shakeRotTime, shakeOffsetMag * scale, shakeOffsetRate, shakeOffsetTime);
    }
}
function KillBullet(){
    local int i;
    if(bulletTrail != none){
       for(i = 0;i < bulletTrail.Emitters.Length;i ++){
           if(bulletTrail.Emitters[i] == none)
               continue;
           bulletTrail.Emitters[i].ParticlesPerSecond          = 0;
           bulletTrail.Emitters[i].InitialParticlesPerSecond   = 0;
           bulletTrail.Emitters[i].RespawnDeadParticles        = false;
       }
       bulletTrail.SetBase(none);
       bulletTrail.AutoDestroy = true;
    }
    if(bulletXTrail != none){
       bulletXTrail.mRegen = false;
       bulletXTrail.LifeSpan = LifeSpan;
    }
    bBulletDead = true;
    bHidden     = true;
    SoundVolume = 0;
    LifeSpan    = FMin(LifeSpan, 0.1);
}
event Destroyed(){
    KillBullet();
}

defaultproperties
{
     insideBouncesLeft=2
     trajUpdFreq=0.100000
     maxTraceCycles=128
     bDisableComplexMovement=True
     trailXClass=Class'KFMod.KFTracer'
     regularImpact=(bPlayROEffect=True)
     StaticMeshRef="kf_generic_sm.Shotgun_Pellet"
     DrawType=DT_StaticMesh
     bAcceptsProjectors=False
     LifeSpan=15.000000
     Texture=Texture'Engine.S_Camera'
     bGameRelevant=True
     bCanBeDamaged=True
     SoundVolume=255
}
