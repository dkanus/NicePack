//==============================================================================
//  NicePack / NiceBullet
//==============================================================================
//  Bullet class that's supposed to take care of all
//  damage-dealing projectile needs.
//  Functionality:
//      - Simulation of both linear and piece-wise motion
//      - Ability to 'stick' to zeds and walls
//      - Ability to explode upon reaching various conditions
//      - Ability to detect collisions from 'NiceCollisionManager'
//==============================================================================
//  Class hierarchy: Object > Actor > NiceBullet
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceBullet extends Actor
    dependson(NiceFire);


//==============================================================================
//==============================================================================
//  >   State of this bullet

//==============================================================================
//  >>  Implementation-level state details
//  Link to interaction with the server
var NiceReplicationInfo     niceRI;
//  Controller of our instigator
var NicePlayerController    nicePlayer;
//  Controller of local player
var NicePlayerController    localPlayer;
//  Indicates that all necessary values were recorded and
//  we can process this bullet normally
var bool                    bInitFinished;
//  Disables all the interaction of this bullet with the world
//  and removes it / marks it for removal
var bool                    bBulletDead;
//  Ghost bullets produce visual effects, get stuck, but never deal damage;
//  they're used for emulating shooting effects of other players
var bool                    bGhost;
//  How often trajectory is allowed to change direction?
var float                   trajUpdFreq;

//==============================================================================
//  >>  Gameplay-related state details
//  Info and state, inherited from weapon that fired us
var NiceFire.NWFireType     fireType;
var NiceFire.NWCFireState   fireState;

//  Damage our bullet deals can decrease as we
//  penetrate enemies or bounce off the walls;
//  this variable reflects that by recording current damage we can deal
var float   damage;
//  For some of the skills we need to distinguish the first bullet target from
//  everything else
var bool    bAlreadyHitZed;
//  'true' means that this bullet cannot explode
var bool    bIsDud;
//  Count-down until our projectile explodes
var float   fuseCountDown;
//  Head-shot detection multiplier, introduced to allow projectiles that
//  have bounced off the walls to hit more reliably
var float   bounceHeadMod;
//  Used for a support zed-time skill 'Bore', denotes how many more times
//  our bullet can 'bounce' between it's head and body
var int     insideBouncesLeft;
//  Can bullet still perform angle damage?
var bool    bCanAngleDamage;



//==============================================================================
//  >>  Details about bullet's 'stuck' state
//  Are we stuck in something?
var bool    bStuck;
//  (For sticking in zeds only) Data about where exactly we got stuck
var bool    bStuckToHead;
var name    stuckBone;

//==============================================================================
//==============================================================================
//  >   Collision management
//  Sole role of these variables is to remember actors
//  we've already hit to avoid them in future

//  Describes an actor that we don't wish to collide with
struct  IgnoreEntry{
    var Actor   ignored;
    //  Set to true when 3rd party already disabled this
    //  actor before we had the chance;
    //  used to avoid re-enabling it later
    var bool    bExtDisabled;
};
var array<IgnoreEntry>  ignoredActors;
//  'true' if we're enforcing our collision rules on actors to ignore them
var bool                bIgnoreIsActive;



//==============================================================================
//==============================================================================
//  >   Movement
//  This class of bullets supports both linear
//  and piece-wise movement, which allows to emulate bullets
//  bouncing off the walls and falling down because of gravity;
//  but system can be extended to reflect any kinds of changes to the trajectory
//  by altering it's direction at certain points in time

//==============================================================================
//  >>  Movement 'settings'
//  If 'true' disables any modifications to the bullet's movement,
//  making it travel in a simple, linear path,
//  but reducing amount of performed computation
var bool    bDisableComplexMovement;

//==============================================================================
//  >>  Movement state
//  Linear motion
var float   speed;
var Vector  direction;
//  Acceleration that affects this bullet
//  Different naming scheme is due to 'acceleration' being already taken and
//  not suiting our needs, since we wanted to handle movement on our own
var Vector  bulletAccel;
var float   distancePassed;

//==============================================================================
//  >>  Path building
//  We will be building a piecewise linear path for projectiles,
//  where each linear segment should be passable by projectile
//  in time 'NBulletState.trajUpdFreq'.
//  By changing trajectory in only preset point allow client to emulate
//  non-linear paths, while keeping them more or less
//  independent from the frame rate.

//  Start and End point of the current linear segment
var Vector  pathSegmentS, pathSegmentE;
//  Point in the segment, at which we've stopped after last movement
var Vector  shiftPoint;
//  The part of current segment that we've already covered,
//  changes from 0.0 to 1.0;
//  - values above 1.0 indicate that segment was finished and
//  we need to build another one;
//  - values below 0.0 indicate that no segment has yet been built.
var float   finishedSegmentPart;



//==============================================================================
//==============================================================================
//  >   Visual effects
//  This class allows to set 3 different type of effect for 3 distinct cases:
//      1.  When bullet exploded
//      2.  When bullet hit actor without explosion
//      3.  When bullet was disintegrated (usually by siren's scream)

//==============================================================================
//  >>  Impact effects
//  Describes effect that projectile can produce on hit
struct  ImpactEffect{
    //  Is this effect too important to cut it due to effect limit?
    var bool                bImportanEffect;
    //  Should we play classic KF's hit effect ('ROBulletHitEffect')?
    var bool                bPlayROEffect;
    //  Decal to spawn; null to skip
    var class<Projector>    decalClass;
    //  Emitter to spawn; null to skip
    var class<Emitter>      emitterClass;
    //  How much back (against direction of the shot) should we spawn emitter?
    //  Can be used to avoid clipping with walls.
    var float               emitterShiftWall;   // Shift for wall-hits
    var float               emitterShiftPawn;   // Shift for pawn-hits
    //  Impact noise parameters
    var Sound               noise;
    //  Reference to 'Sound' to allow dynamic resource allocation
    var string              noiseRef;
    var float               noiseVolume;
};

var ImpactEffect    regularImpact;          //  Effect on imact, no eplosion
var ImpactEffect    explosionImpact;        //  Effect in case of the explosion
var ImpactEffect    disintegrationImpact;   //  Disintegration, nuff said
//  Should we play 'regularImpact' (when bullet hit actor without explosion)
//  effects after hitting a 'Pawn'?
//  It normally produces badly looking results,
//  but if set this flag to 'true' if you want it to anyway
var bool            bGenRegEffectOnPawn;

//==============================================================================
//  >>  Bullet trails
//  Bullet supports 2 different types of trails: 'Emitter' and 'xEmitter'.
//  Just define class for the one (or both) you want to use.
var class<Emitter>  trailClass;
var class<xEmitter> trailXClass;
var Emitter         bulletTrail;
var xEmitter        bulletXTrail;

//==============================================================================
//  >>  Explosion view shaking
//  Should we even do any shaking at all?
var bool    bShakeViewOnExplosion;
var Vector  shakeRotMag;        // how far to rot view
var Vector  shakeRotRate;       // how fast to rot view
var float   shakeRotTime;       // how much time to rot the instigator's view
var Vector  shakeOffsetMag;     // max view offset vertically
var Vector  shakeOffsetRate;    // how fast to offset view vertically
var float   shakeOffsetTime;    // how much time to offset view
var float   shakeRadiusMult;


//==============================================================================
//==============================================================================
//  >   Functions

//  Initialises bullet before it's use
function InitBullet(){
    //  Easy references to 'NiceReplicationInfo'
    //  + local and instigator controllers
    localPlayer     = NicePlayerController(Level.GetLocalPlayerController());
    instigator      = fireState.base.instigator;
    nicePlayer      = fireState.base.instigatorCtrl;
    if(nicePlayer != none)
        niceRI      = nicePlayer.niceRI;
    //  Bullet should only replicate damage on instigator's side
    bGhost          = (localPlayer != nicePlayer);
    //  We haven't yet do anything,
    //  so our damage is maxed out and we can do angle damage,
    //  but still dealing with regular head sizes
    bCanAngleDamage = true;
    damage          = fireType.bullet.damage;
    bounceHeadMod   = 1.0;
    //  No countdown could yet take place
    fuseCountDown   = fireType.explosion.fuseTime;
    //  Setup movement
    speed           = fireType.movement.speed;
    direction       = Vector(rotation);
    //bDisableComplexMovement = NICETODO: update as necessary
    bDisableComplexMovement = true;
    ResetPathBuilding();
    //  Setup visual effects
    UpdateTrails();
    //  Allow tick to handle the bullet
    bInitFinished   = true;
}

function UpdateTrails(){
    local Actor trailBase;
    if(Level.NetMode == NM_DedicatedServer) return;

    //  Spawn necessary trails first
    if(trailClass != none && bulletTrail == none)
        bulletTrail = Spawn(trailClass, self);
    if(trailXClass != none && bulletXTrail == none)
        bulletXTrail = Spawn(trailXClass, self);

    //  Handle positioning differently for stuck and non-stuck projectiles
    if(bStuck && base != none){
        if(stuckBone != ''){
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

    //  Update lifetime and base (latter is for non-bone attachments only)
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

simulated function Tick(float delta){
    local bool bBaseIsDead;
    local bool bFuseJustRunOut;
    super.Tick(delta);

    //  Fuse didn't run out before this tick, but should after
    if(fireType.explosion.bOnFuse){
        bFuseJustRunOut = (fuseCountDown > 0) && (fuseCountDown < delta);
         fuseCountDown -= delta;
    }
    //  Explode when fuse runs out
    if(bFuseJustRunOut)
        DoExplode(location, direction);

    //  Explode stuck bullet if the target it was attached to died
    if(bInitFinished && bStuck){
        bBaseIsDead = (base == none);
        if(NiceMonster(base) != none)
            bBaseIsDead = NiceMonster(base).health <= 0;
        /*if(bBaseIsDead) NICETODO: finish it
            nicePlayer.ExplodeStuckBullet(stuckID);*/
    }

    //  Progress movemnt
    if(bInitFinished && !bBulletDead && !bStuck)
        DoProcessMovement(delta);
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

//  Returns 'true' if passed actor is either world geometry,
//  'Level' itself or nothing ('none');
//  neither of these related to pawn damage dealing
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

    //  Try to find main actor as KFPawn
    pawnOther = KFPawn(other);
    if(pawnOther == none)
        pawnOther = KFPawn(other.base);
    if(pawnOther == none)
        pawnOther = KFPawn(other.owner);

    //  Try to find main actor as KFMonster
    zedOther = KFMonster(other);
    if(zedOther == none)
        zedOther = KFMonster(other.base);
    if(zedOther == none)
        zedOther = KFMonster(other.owner);

    //  Ignore everything that's associated with this actor
    //  and can have collision
    IgnoreActor(other);
    IgnoreActor(other.base);
    IgnoreActor(other.owner);
    if(pawnOther != none)
        IgnoreActor(pawnOther.AuxCollisionCylinder);
    if(zedOther != none)
        IgnoreActor(zedOther.MyExtCollision);
}

//  Adds a given actor to ignore list
//  and removes it's collision in case ignore is active (see 'bIgnoreIsActive')
function IgnoreActor(Actor other){
    local int           i;
    local IgnoreEntry   newIgnoredEntry;

    //  Check if that's a non-level actor and not already on the list
    if(IsLevelActor(other))
        return;
    for(i = 0;i < ignoredActors.Length;i ++)
        if(ignoredActors[i].ignored == other)
            return;

    //  Add actor to the ignore list & disable collision if needed
    if(other != none){
        //  Make entry
        newIgnoredEntry.ignored         = other;
        newIgnoredEntry.bExtDisabled    = !other.bCollideActors;
        //  Add and activate it
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
//  Ignore deactivation doesn't restore collision if actor
//  was set to not collide prior most recent ignore activation.
//  Activating ignore when it's already active does nothing;
//  same with deactivation.
//  Ignore deactivation is supposed to be used in the same function call
//  in which activation took place before
//  to avoid unwanted editing of the collision flags
function SetIgnoreActive(bool bActive){
    local int i;

    //  Do nothing if we're already in a correct state
    if(bActive == bIgnoreIsActive)
        return;

    //  Change ignore state & disable collision for ignored actors
    bIgnoreIsActive = bActive;
    for(i = 0;i < ignoredActors.Length;i ++)
        if(ignoredActors[i].ignored != none){
            //  Mark actors that were set to not collide before activation
            if(bActive && !ignoredActors[i].ignored.bCollideActors)
                ignoredActors[i].bExtDisabled = true;
            //  Change collision for actors that weren't externally modified
            if(!ignoredActors[i].bExtDisabled)
                ignoredActors[i].ignored.SetCollision(!bActive);
            //  After we deactivated our rules -
            //  forget about external modifications
            if(!bActive)
                ignoredActors[i].bExtDisabled = false;
        }
}

function float CheckHeadshot(   KFMonster kfZed,
                                Vector hitLocation,
                                Vector hitDirection){
    local float                     hsMod;
    local NiceMonster               niceZed;
    local KFPlayerReplicationInfo   KFPRI;
    local class<NiceVeterancyTypes> niceVet;
    //  If one of these variables is 'none' -
    //  something went terribly wrong and we might as well bail
    niceZed = NiceMonster(kfZed);
    if(niceZed == none || nicePlayer == none) return 0.0;
    KFPRI = KFPlayerReplicationInfo(nicePlayer.PlayerReplicationInfo);
    if(KFPRI == none) return 0.0;
    niceVet = class<NiceVeterancyTypes>(KFPRI.ClientVeteranSkill);
    if(niceVet == none) return 0.0;
    
    hitDirection = Normal(hitDirection);
    //  Compute proper head-shot check multiplier
    hsMod = bounceHeadMod;
    hsMod *= fireType.bullet.shotDamageType.default.headSizeModifier;
    hsMod *= niceVet.static.
        GetHeadshotCheckMultiplier(KFPRI, fireType.bullet.shotDamageType);
    return niceZed.IsHeadshotClient(hitLocation, hitDirection,
                                    niceZed.clientHeadshotScale * hsMod);
}

function bool CheckSirenBallCollision(Vector lineStart, Vector lineEnd){
    if(localPlayer == none || localPlayer.localCollisionManager == none)
        return false;
    return localPlayer.localCollisionManager.
        IsCollidingWithAnything(lineStart, lineEnd);
}

//  Makes bullet trace a directed line segment given by start and end points.
//  All traced actors and geometry are then properly
//  affected by either 'HandleHitActor' or 'HandleHitWall'.
//  Might have to do several traces in case it either hits a (several) target(s)
function DoTraceLine(Vector lineStart, Vector lineEnd){
    //  Amount of tracing iterations we had to do
    local int       iterationCount;
    //  Direction and length of traced line
    local Vector    lineDirection;
    //  Auxiliary variables for retrieving results of tracing
    local Vector    hitLocation, hitNormal;
    local Actor     tracedActor;
    if(localPlayer == none || instigator == none) return;

    lineDirection = (lineEnd - lineStart);
    lineDirection = (lineDirection) / VSize(lineDirection);
    //  Do not trace for disabled bullets and prevent infinite loops
    while(!bBulletDead && iterationCount < 128){
        iterationCount ++;
        //  Find next collision.
        //  > Trace next object.
        //  But only if:
        //  1. It isn't a ghost and can actually deal damage;
        //  2. It's a ghost projectile,
        //  but we still haven't gone over our traces per tick limit.
        if( !bGhost
            || localPlayer.tracesThisTick <= localPlayer.tracesPerTickLimit){
            tracedActor = instigator.Trace( hitLocation, hitNormal,
                                            lineEnd, lineStart, true);
            localPlayer.tracesThisTick ++;
        }
        else
            tracedActor = none;
        //  > Check and handle collision with siren's scream ball
        if( fireType.bullet.bAffectedByScream && !bIsDud
            && CheckSirenBallCollision(lineStart, lineEnd))
            HandleScream(lineStart, lineDirection);

        //  If we hit level actor (wall) - bail
        if(tracedActor != none && IsLevelActor(tracedActor)){
            HandleHitWall(tracedActor, hitLocation, hitNormal);
            break;
        }
        else{
            TotalIgnore(tracedActor);
            tracedActor = GetMainActor(tracedActor);
        }

        //  If tracing between current trace points haven't found anything and
        //  tracing step is less than segment's length -- shift tracing bounds
        if(tracedActor == none)
            return;
        HandleHitActor(tracedActor, hitLocation, lineDirection, hitNormal);
    }
}

//  Handles bullet collision with an actor,
//  it calls 'HandleHitPawn', 'HandleHitZed' or 'HandleHitWall',
//  depending on the type of the actor.
//  This function takes two direction parameters:
//  - 'hitDirection' is bullet's direction before the impact
//  - 'hitNormal' normal of the surface we've hit,
//      used to handle effects upon wall hits
function HandleHitActor(Actor hitActor,
                        Vector hitLocation,
                        Vector hitDirection,
                        Vector hitNormal){
    local float         headshotLevel;
    local KFPawn        hitPawn;
    local NiceMonster   hitZed;
    hitZed  = NiceMonster(hitActor);
    hitPawn = KFPawn(hitActor);
    if( hitPawn != none && NiceHumanPawn(instigator).ffScale <= 0
       /* && NiceMedicProjectile(self) == none */) return;//MEANTODO
    if(hitZed != none){
        if(hitZed.health > 0){
            headshotLevel = CheckHeadshot(hitZed, hitLocation, hitDirection);
            HandleHitZed(hitZed, hitLocation, hitDirection, headshotLevel);
        }
    }
    else if(hitPawn != none && hitPawn.health > 0){
        if(hitPawn.health > 0)
            HandleHitPawn(hitPawn, hitLocation, hitDirection);
    }
    else
        HandleHitWall(hitActor, hitLocation, hitNormal);
}

//  Replaces current path segment with the next one.
//  Doesn't check whether or not we've finished with the current segment.
function BuildNextPathSegment(){
    //  Only set start point to our location when
    //  we build path segment for the first time.
    //  After that we can't even assume that bullet
    //  is exactly in the 'pathSegmentE' point.
    if(finishedSegmentPart < 0.0)
        pathSegmentS = Location;
    else
        pathSegmentS = pathSegmentE;
    direction += (bulletAccel * trajUpdFreq) / speed;
    pathSegmentE = pathSegmentS + direction * speed * trajUpdFreq;
    finishedSegmentPart = 0.0;
    shiftPoint = pathSegmentS;
}

//  Updates 'shiftPoint' to the next bullet position in current segment.
//  Does nothing if current segment is finished or no segment was built at all.
//  @param  delta   Amount of time bullet has to move through the segment.
//  @return         Amount of time left for bullet to move after this segment
function float ShiftInSegment(float delta){
    //  Time that bullet still has available to move after this segment
    local float remainingTime;
    //  Part of segment we can pass in a given time
    local float segmentPartWeCanPass;
    //  Exit if there's no segment in progress
    if(finishedSegmentPart < 0.0 || finishedSegmentPart > 1.0)
        return delta;

    //  [speed * delta] / [speed * trajUpdFreq] = [delta / trajUpdFreq]
    segmentPartWeCanPass = delta / trajUpdFreq;
    // If we can move through the rest of the segment -
    //  move to end point and mark it finished
    if(segmentPartWeCanPass >= (1.0 - finishedSegmentPart)){
        remainingTime = delta - (1.0 - finishedSegmentPart) * trajUpdFreq;
        finishedSegmentPart = 1.1;
        shiftPoint = pathSegmentE;
    }
    //  Otherwise compute new 'shiftPoint' normally
    else{
        remainingTime = 0.0;
        finishedSegmentPart += (delta / trajUpdFreq);
        shiftPoint = pathSegmentS +
            direction * speed * trajUpdFreq * finishedSegmentPart;
    }
    return remainingTime;
}

//  Moves bullet according to settings,
//  decides when and how much tracing should it do.
//  @param  delta   Amount of time passed after previous bullet movement
function DoProcessMovement(float delta){
    local Vector    tempVect;

    SetIgnoreActive(true);
    //  Simple linear movement
    if(bDisableComplexMovement){
        //  Use 'traceStart' as a shift variable here
        //  Naming is bad in this case, but it avoids 
        tempVect = direction * speed * delta;
        DoTraceLine(location, location + tempVect);
        Move(tempVect);
        //  Reset path building
        //  If in future complex movement would be re-enabled,
        //  - we want to set first point of the path to
        //  the location of bullet at a time and not use outdated information.
        finishedSegmentPart = -1.0;
    }
    //  Non-linear movement support
    else{
        while(delta > 0.0){
            if(finishedSegmentPart < 0.0 || finishedSegmentPart > 1.0)
                BuildNextPathSegment();
            //  Remember current 'shiftPoint'.
            //  That's where we stopped tracing last time and
            //  where we must resume.
            tempVect = shiftPoint;
            //  Update 'shiftPoint' (bullet position) and update how much time
            //  we've got left after we wasted some to move.
            delta = ShiftInSegment(delta);
            //  Trace between end point of previous tracing
            //  and end point of the new one.
            DoTraceLine(tempVect, shiftPoint);
        }
        tempVect = shiftPoint - location;
        Move(shiftPoint - location);
    }
    SetRotation(Rotator(direction));
    if(distancePassed > 0)
        distancePassed -= VSize(tempVect);
    SetIgnoreActive(false);
}

function Stick(Actor target, Vector hitLocation){
/*    local NiceMonster   targetZed;
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
    KillBullet();*/
}

function DoExplode(Vector explLocation, Vector impactNormal){
    local ImpactEffect visualEffect;
    if(!bIsDud){
        class'NiceBulletAdapter'.static.Explode(self, explLocation);
        if(bShakeViewOnExplosion)
            ShakeView(explLocation);
        visualEffect = explosionImpact;
    }
    else
        visualEffect = disintegrationImpact;
    GenerateImpactEffects(visualEffect, explLocation, impactNormal, true, true);
    KillBullet();
}

function HandleHitWall(Actor wall, Vector hitLocation, Vector hitNormal){
    local bool bCanExplode;
    local bool bBulletTooWeak;

    bCanExplode = !bIsDud && distancePassed < fireType.explosion.minArmDistance;
    if(fireType.explosion.bOnWallHit && bCanExplode){
        DoExplode(hitLocation, hitNormal);
        return;
    }
    class'NiceBulletAdapter'.static.HitWall(self, wall,
                                            hitLocation, hitNormal);
    GenerateImpactEffects(regularImpact, hitLocation, hitNormal, true, true);
    if(fireType.bullet.bStickToWalls)
        Stick(wall, hitLocation);
    else if(bBounce && !bDisableComplexMovement){
        direction = direction - 2.0 * hitNormal * (direction dot hitNormal);
        bBulletTooWeak = !class'NiceBulletAdapter'.static.
            ZedPenetration(damage, self, none, 0.0);
        ResetPathBuilding();
        ResetIgnoreList();
        bounceHeadMod *= 2;
    }
    else if(fireType.movement.fallTime > 0.0){
        bIsDud = true;
        lifeSpan = fireType.movement.fallTime;
        fireType.movement.fallTime = 0.0;
        direction = vect(0,0,0);
        ResetPathBuilding();
        ResetIgnoreList();
    }
    else
        bBulletTooWeak = true;
    if(bBulletTooWeak)
        KillBullet();
}

//  Decide whether to explode or just hit after non-zed pawn collision
function HandleHitPawn(KFPawn hitPawn, Vector hitLocation, Vector hitDirection){
    local bool bCanExplode;
    //  Deal damage due to impact + effects
    class'NiceBulletAdapter'.static.HitPawn(self, hitPawn, hitLocation,
                                            hitDirection);
    if(bGenRegEffectOnPawn)
        GenerateImpactEffects(  regularImpact, hitLocation, hitDirection,
                                false, false);

    //  Explode if you can
    bCanExplode = !bIsDud && distancePassed < fireType.explosion.minArmDistance;
    if(fireType.explosion.bOnPawnHit && bCanExplode){
        DoExplode(hitLocation, hitDirection);
        return;
    }

    //  Kill weakened bullets
    if(!class'NiceBulletAdapter'.static.
        ZedPenetration(damage, self, none, 0.0))
        KillBullet();
}

//  Decide whether to explode or just hit after zed collision;
//  Kill the bullet on explosion or when can't penetrate anymore
function HandleHitZed(  NiceMonster targetZed,
                        Vector hitLocation,
                        Vector hitDirection,
                        float headshotLevel){
    local bool bCanExplode;
    if(nicePlayer == none || niceRI == none) return;

    //  Deal damage due to impact + effects +
    //  some skill-related stuff ('ServerJunkieExtension')
    class'NiceBulletAdapter'.static.HitZed( self, targetZed,
                                            hitLocation, hitDirection,
                                            headshotLevel);
    if(!bGhost && !bAlreadyHitZed){
        bAlreadyHitZed = true;// NICETODO: send only when actually used
        niceRI.ServerJunkieExtension(nicePlayer, headshotLevel > 0.0);
    }
    if(bGenRegEffectOnPawn)
        GenerateImpactEffects(  regularImpact, hitLocation, hitDirection,
                                false, false);
    //  Explode if you can...
    bCanExplode = !bIsDud && distancePassed < fireType.explosion.minArmDistance;
    if(fireType.explosion.bOnPawnHit && bCanExplode){
        DoExplode(hitLocation, hitDirection);
        return;
    }
    //  ...otherwise try sticking
    else if(fireType.bullet.bStickToZeds)
        Stick(targetZed, hitLocation);

    //  Kill weakened bullets
    if(!class'NiceBulletAdapter'.static.
        ZedPenetration(damage, self, targetZed, headshotLevel))
        KillBullet();
}

function HandleScream(Vector disintegrationLocation, Vector entryDirection){
    if(!bIsDud)
        GenerateImpactEffects(  disintegrationImpact, disintegrationLocation,
                                entryDirection);
    class'NiceBulletAdapter'.static.HandleScream(   self,
                                                    disintegrationLocation,
                                                    entryDirection);
}

function GenerateImpactEffects( ImpactEffect effect,
                                Vector hitLocation,
                                Vector hitNormal,
                                optional bool bWallImpact,
                                optional bool bGenerateDecal){
    local bool  generatedEffect;
    local float actualCullDistance, actualImpactShift;
    if(localPlayer == none) return;
    // No need to play visuals on a server or for dead bullets
    if(Level.NetMode == NM_DedicatedServer || bBulletDead) return;
    if(!localPlayer.CanSpawnEffect(bGhost) && !effect.bImportanEffect) return;

    //  Classic effect
    if(effect.bPlayROEffect && !bBulletDead)
        Spawn(class'ROBulletHitEffect',,, hitLocation, rotator(-hitNormal));

    //  Generate decal
    if(bGenerateDecal && effect.decalClass != none){
        //  Find appropriate cull distance for this decal
        actualCullDistance = effect.decalClass.default.cullDistance;
        //  Double cull distance if local player is an instigator
        if(instigator != none && localPlayer == instigator.Controller)
            actualCullDistance *= 2;    // NICETODO: magic number
        //  Spawn decal
        if(!localPlayer.BeyondViewDistance(hitLocation, actualCullDistance)){
            Spawn(effect.decalClass, self,, hitLocation, rotator(- hitNormal));
            generatedEffect = true;
        }
    }

    //  Generate custom effect
    if(effect.emitterClass != none && EffectIsRelevant(hitLocation, false)){
        if(bWallImpact)
            actualImpactShift = effect.emitterShiftWall;
        else
            actualImpactShift = effect.emitterShiftPawn;
        Spawn(  effect.emitterClass,,,
                hitLocation - direction * actualImpactShift,
                Rotator(direction));
        generatedEffect = true;
    }

    //  Generate custom sound
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
    local float explRadius;
    local float distance, scale;
    if(nicePlayer == none || shakeRadiusMult < 0.0) return;
    explRadius = fireType.explosion.radius;
    distance = VSize(hitLocation - nicePlayer.ViewTarget.Location);
    if(distance < explRadius * shakeRadiusMult){
        if(distance < explRadius)
            scale = 1.0;
        else
            scale = (explRadius * ShakeRadiusMult - distance) / explRadius;
        nicePlayer.ShakeView(   shakeRotMag*scale, shakeRotRate,
                                shakeRotTime, shakeOffsetMag * scale,
                                shakeOffsetRate, shakeOffsetTime);
    }
}

function KillBullet(){
    local int i;
    if(bulletTrail != none){
        for(i = 0;i < bulletTrail.Emitters.Length;i ++){
            if(bulletTrail.emitters[i] == none)
                continue;
            bulletTrail.emitters[i].ParticlesPerSecond          = 0;
            bulletTrail.emitters[i].InitialParticlesPerSecond   = 0;
            bulletTrail.emitters[i].RespawnDeadParticles        = false;
        }
        bulletTrail.SetBase(none);
        bulletTrail.autoDestroy = true;
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
    bDisableComplexMovement=True
    trailXClass=Class'KFMod.KFTracer'
    regularImpact=(bPlayROEffect=True)
    //StaticMeshRef="kf_generic_sm.Shotgun_Pellet"
    DrawType=DT_StaticMesh
    bAcceptsProjectors=False
    LifeSpan=15.000000
    Texture=Texture'Engine.S_Camera'
    bGameRelevant=True
    bCanBeDamaged=True
    SoundVolume=255
}