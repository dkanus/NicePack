//==============================================================================
//  NicePack / NiceMonster
//==============================================================================
//  New base class for zeds that makes it easier to implement various changes
//  and bugfixes.
//  Functionality:
//      - Variable zed stun time and unstun at any moment;
//      - Temperature system for zeds, that allows ignition be 'accumulated'
//          through several shots, rather that instantenious +
//          supports freezing mechanic;
//      - Increased complexity of some mechanics, like supporting
//          float-valued level of headshots instead of simple
//          true/false-switch;
//      - Fixed decapitation visuals.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceMonster extends KFMonster
    hidecategories(AnimTweaks,DeRes,Force,Gib,Karma,Udamage,UnrealPawn)
    abstract;
#exec OBJ LOAD FILE=KF_EnemyGlobalSndTwo.uax
#exec OBJ LOAD FILE=KFZED_FX_T.utx

//==============================================================================
//==============================================================================
//  >   Affliction system
//  This class, like the vanilla one, supports 3 types of afflictions:
//      - Stun: fixes zed in place for a period of time or until
//          zed-specific unstun conditions are met
//      - Flinch: prevents zed from attacking for a short periodof time,
//          defined by a variable named 'StunTime' for some stupid-fuck-reason
//      - Mini-flinch: forced anim-action that can cancel other actions of zeds
// Describes possible affliction reactions of zeds to damage
enum EPainReaction{
    PREACTION_NONE,
    PREACTION_MINIFLINCH,
    PREACTION_FLINCH,
    PREACTION_STUN
};
//==============================================================================
//  >>  Stun rules can be overwritten for each zed independently,
//  but the default behaviour is to check two conditions:
//  1.  Check a stun score of the attack against a certain threshold.
//  2.  Check if zed wasn't already stunned too many times
//      (by default amount of stuns is unlimited,
//       but can be configured by changing a variable's value)
//  Defines if zed is currently stunned
var bool    bIsStunned;
//  Stun score (defined as ratio of the default health), required to stun a zed;
//  always expected to be positive.
var float   stunThreshold;
//  How many times this zed can be stunned;
//  negative values mean there's no limit
var int     remainingStuns;
//  Standart stun duration;
//  automatically aquired from the length of stun animation
var float   stunDuration;
//  Stores the time left until the end of the current stun
var float   stunCountDown;
//  When the last stun occured;
//  doesn't update on extending active stuns (restuns)
//  Set to negative value by default
var float   lastStunTime;
//  Variables that define animation frames between which we can loop animation
//  and a frame, from which we can insert idle animation
//  (in case there isn't enough time for another loop)
var float   stunLoopStart, stunLoopEnd, idleInsertFrame;
//  Internal variables that define the state of animatin used to depict stun
//  before the current tick
var bool    bWasIdleStun;       // Were we using idleanimation for stun?
var float   prevStunAnimFrame;  // At which tick we were?
//==============================================================================
//  >>  Another default stun system allows tostuns zeds by repeatedly dealing
//  head damage to them fast enough:
//      1. Dealing head damage increases accumulated damage
//      2. If head damage was received for a certain time period, -
//          accumulated damage starts to decrease
//      3. If accumulated damage is high enough, passes 'IsStunPossible' check
//          and has low enough mind level - normal duration stun activates
//  Accumulated head damage
var float   accHeadDamage;
//  Rate (per second) at which accumulated head damage diminishes
var float   headDamageRecoveryRate;
//  Time that needs to pass after last head damage for recovery to kick in
var float   headRecoveryTime;
//  Count down variable for above mentioned time
var float   headRecoveryCountDown;

//==============================================================================
//==============================================================================
//  >   Mind system
//  Largly underdeveloped and currently only exists to decide whether or not
//  zed can be stunned by accumulating head damage
//  Current mind level (1.0 - default and maximum value)
var float mind;
//  Treshold, required for stun by accumulated head damage
var float accStunMindLvl;

//==============================================================================
//==============================================================================
//  >   Temperature system
//  Manages temperature (heat level) of the zed by either changing it because
//  of elemental damage or bringing it back to zero (normal heat) with time.
//  Allows for two afflictions to occure:
//      1. Zed being set on fire, which might cause a change in behaviour
//      2. Zed being frozen, fixing it in place
//  Having this flag set to 'true' massively decreases damage
//  taken from fire sources
var bool    bFireImmune;
//  Can this zed be set on fire?
var bool    bCanBurn;
//  Is zed currently burning?
var bool    bOnFire;
//  Tracks whether or not zed's behaviour was changed to the burning one
var bool    bBurningBehavior;
//  Having positive fuel values means that zed's heat will increase while it
//  burining and will decrease otherwise;
//  Both variables are automatically setup for zed upon spawning
var float   flameFuel, initFlameFuel;
//  Defines how much fuel (relative to scaled max health) zed will have
var float   fuelRatio;
//  Current heat level of the zed:
//      - Getting it high enough results in zed burning
//      - Getting it low enough results in zed being frozen
var float   heat;
//  Rate at which heat restores itself to default (zero) value
var float   heatDissipationRate;
//  Affects how often heat value updates and how often fire/cold DoT ticks
var float   heatTicksPerSecond;
//  Tracks last time heat tick occured
var float   lastHeatTick;
//  If set to 'true' - low-value ticks of fire DoT will waste accordingly small
//  amount of fuel, otherwise they will always waste some minimal amount,
//  resulting in a loss of potential damage
var bool    bFrugalFuelUsage;

//==============================================================================
//==============================================================================
//  >   Miscellaneous variables
//==============================================================================
//  >>  Head-damage related
//  'true' means any headshot ill destroy head completely
var bool    bWeakHead;
//  Head radius scale for client-side hitdetection
var float   clientHeadshotScale;
//  Stores maximum head health zed can have
var float   headHealthMax;
//==============================================================================
//  >>  Auxiliary variables for general purposes
var ScrnGameRules   scrnRules;
var float           lastTookDamageTime;
//  'CuteDecapFX' already performed decapitation on thiszed
var bool            bCuteDecapDone;
//  Don't run decap tick (makes sure that head is visually destroyed)
//  for this zed
var bool            bSkipDecapTick;
//==============================================================================
//  >>  Auxiliary variables for perks/skills
//  Time left before (medic's) madness wears off
var float   madnessCountDown;
//  Should this zed be decapitated in a melee-like manner?
var bool bMeleeDecapitated;
//  More precise momentum replication
var float TearOffMomentumX, TearOffMomentumY, TearOffMomentumZ;
var const material FrozenMaterial;
var bool bFrozenZed, bFrozenZedClient;
var Rotator frozenRotation;
var array<name> frozenAnimations;
var array<float> frozenAnimFrames;
var Pawn frostInstigator;
var float lastFrostDamage;
var class<NiceWeaponDamageType> frostDamageClass;
var float iceCrustStrenght;
var bool isStatue;
var class<Emitter> ShatteredIce;
//==============================================================================
//  >>  Replacement variables to store current melee damage
var class<NiceWeaponDamageType> niceZombieDamType;
replication{
    reliable if(Role < ROLE_Authority)
       ServerDropFaster;
    reliable if(Role == ROLE_Authority)
       bMeleeDecapitated, TearOffMomentumX, TearOffMomentumY, TearOffMomentumZ,
       bFrozenZed, frozenRotation;
}
simulated function PostBeginPlay(){
    local GameRules rules;
    local Vector AttachPos;
    Super.PostBeginPlay();
    //  Auto-fill of some values
    stunDuration    = GetAnimDuration('KnockDown');
    HeadHealthMax   = HeadHealth;
    InitFlameFuel   = FuelRatio * HealthMax;
    FlameFuel       = InitFlameFuel;
    if(Role == ROLE_Authority){ //  auto-fill ScrnRules
       rules = Level.Game.GameRulesModifiers;
       while(rules != none){
           if(ScrnGameRules(rules) != none){
               scrnRules = ScrnGameRules(rules);
               break;
           }
           rules = rules.NextGameRules;
       }
    }
    //  Fool-protection: in case we (someone) forgets to set both variables
    clientHeadshotScale = FMax(clientHeadshotScale, OnlineHeadshotScale);
    //  Add zed-collisions on client too
    if(Role < ROLE_Authority){
       if(bUseExtendedCollision && MyExtCollision == none){
           MyExtCollision = Spawn(Class'ExtendedZCollision', Self);
           MyExtCollision.SetCollisionSize(colRadius, colHeight);
           MyExtCollision.bHardAttach = true;
           AttachPos = Location + (ColOffset >> Rotation);
           MyExtCollision.SetLocation(AttachPos);
           MyExtCollision.SetPhysics(PHYS_none);
           MyExtCollision.SetBase(Self);
           SavedExtCollision = MyExtCollision.bCollideActors;
       }
    }
}

//==============================================================================
//==============================================================================
//  >   Dismemberment-related functions
//  Created to move some repeated code from 'HideBone' function
simulated function
AttachSeveredLimb(  out SeveredAppendageAttachment replacement,
                   class<SeveredAppendageAttachment> replacementClass,
                   float replacementScale,
                   name attachmentPoint,
                   name boneName){
    local coords boneCoords;
    local class<DismembermentJet> emitterClass;
    //  Leave if replacement limb has already spawned
    if(replacement != none) return;
    //  Decide on the right emitter class
    if(boneName == headBone){
       if(bNoBrainBitEmitter)
           emitterClass = NeckSpurtNoGibEmitterClass;
       else
           emitterClass = NeckSpurtEmitterClass;
    }
    else
       emitterClass = LimbSpurtEmitterClass;
    //  Spawn & attach replacement
    replacement = Spawn(replacementClass, self);
    replacement.SetDrawScale(replacementScale);
    boneCoords = GetBoneCoords(attachmentPoint);
    AttachEmitterEffect(    emitterClass, attachmentPoint,
                           boneCoords.Origin, rot(0,0,0));
    AttachToBone(replacement, attachmentPoint);
}
simulated function HideBone(name boneName){
    switch(boneName){
       case LeftThighBone:
           SetBoneScale(0, 0.0, boneName);
           AttachSeveredLimb(  SeveredLeftLeg, SeveredLegAttachClass,
                               SeveredLegAttachScale, 'lleg', boneName);
           break;
       case RightThighBone:
           SetBoneScale(1, 0.0, boneName);
           AttachSeveredLimb(  SeveredRightLeg, SeveredLegAttachClass,
                               SeveredLegAttachScale, 'rleg', boneName);
           break;
       case RightFArmBone:
           SetBoneScale(2, 0.0, boneName);
           AttachSeveredLimb(  SeveredRightArm, SeveredArmAttachClass,
                               SeveredArmAttachScale, 'rarm', boneName);
           break;
       case LeftFArmBone:
           SetBoneScale(3, 0.0, boneName);
           AttachSeveredLimb(  SeveredLeftArm, SeveredArmAttachClass,
                               SeveredArmAttachScale, 'larm', boneName);
           break;
       case HeadBone:
           if(SeveredHead == none)
               SetBoneScale(4, 0.0, boneName);
           AttachSeveredLimb(  SeveredHead, SeveredHeadAttachClass,
                               SeveredHeadAttachScale, 'neck', boneName);
           break;
       case 'spine':
           SetBoneScale(5, 0.0, boneName);
    }
}
simulated function CuteDecapFX(){
    local int leftRight;
    if(!bCuteDecapDone){
       LeftRight = 1;
       if(rand(10) > 5)
           LeftRight = -1;
       NeckRot.Yaw     = - Clamp(rand(24000), 14000, 24000);
       NeckRot.Roll    = leftRight * clamp(rand(8000), 2000, 8000);
       NeckRot.Pitch   = leftRight * clamp(rand(12000), 2000, 12000);
       RemoveHead();
    }
    bCuteDecapDone = true;
    SetBoneRotation('neck', NeckRot);
}
simulated function DecapFX( Vector DecapLocation,
                           Rotator DecapRotation,
                           bool bSpawnDetachedHead,
                           optional bool bNoBrainBits){
    if(SeveredHead != none)
       return;
    super.DecapFX(  DecapLocation, DecapRotation,
                   bSpawnDetachedHead, bNoBrainBits);
}
//==============================================================================
//==============================================================================
//  >   Routins that should be executed every tick
//  (and ones closely related to them), moved out from the 'Tick' function
//  to make it more comprehensible.
//==============================================================================
//  >>  Handles medic's madness count down
simulated function MadnessTick(float deltaTime){
    if(madnessCountDown > 0)
       madnessCountDown -= DeltaTime;
    if(madnessCountDown < 0.0)
       madnessCountDown = 0.0;
}
//==============================================================================
//  >>  Makes sure zed loses it's head upon decapitation
simulated function DecapTick(float deltaTime){
    local Coords boneCoords;
    if(Role == ROLE_Authority) return;
    if(bDecapitated && SeveredHead == none && !bSkipDecapTick){
       boneCoords = GetBoneCoords(HeadBone);
       if(bMeleeDecapitated)
           DecapFX(boneCoords.Origin, rot(0, 0, 0), true);
       else
           DecapFX(boneCoords.Origin, rot(0, 0, 0), false);
    }
}
//==============================================================================
//  >>  Makes zeds REALLY avoid fear spots
simulated function FearTick(float deltaTime){
    local Vector fearCenter;
    local bool fstFearAffects, sndFearAffects;
    if(Role < ROLE_Authority || controller == none || bShotAnim) return;
    //  What spots saffect this zed and if affected at all
    if( controller.fearSpots[0] != none
       && Controller.fearSpots[0].RelevantTo(self))
       fstFearAffects = true;
    if( controller.fearSpots[1] != none
       && Controller.fearSpots[1].RelevantTo(self))
       sndFearAffects = true;
    if(!fstFearAffects && !sndFearAffects) return;
    //  Calculate fear center
    if(fstFearAffects)
       fearCenter = controller.fearSpots[0].Location;
    if(sndFearAffects)
       fearCenter = controller.fearSpots[1].Location;
    if(fstFearAffects && sndFearAffects)
       fearCenter *= 0.5 * fearCenter;
    //  Accelerate zed in the right direction
    acceleration = acceleration * 0.25
       + 0.75 * accelRate * Normal(Location - fearCenter);
}
//==============================================================================
//  >>  Set of functions to handle animation changes during stun
simulated function CalcRemainigStunStructure(   name        seqName,
                                               float       oFrame,
                                               float       oRate,
                                               out int     stunLoopsLeft,
                                               out float   stunLeftover){
    local float loopDuration, temp;
    loopDuration = (stunLoopEnd - stunLoopStart) * stunDuration;
    if(seqName == IdleRestAnim){
       stunLoopsLeft = 0;
       stunLeftover = StunCountDown - (1 - idleInsertFrame) * stunDuration;
    }
    else if(prevStunAnimFrame < stunLoopEnd && loopDuration > 0.0){
       temp = StunCountDown - (1 - oFrame) * stunDuration;
       if(temp <= 0){
           stunLoopsLeft = 0;
           stunLeftover = 0.0;
       }
       else{
           stunLoopsLeft = Ceil(temp / loopDuration) - 1;
           stunLeftover = temp - stunLoopsLeft * loopDuration;
       }
    }
    else{
       stunLoopsLeft = 0;
       stunLeftover = StunCountDown - (1 - oFrame) * stunDuration;
    }
    if(stunLeftover < 0.0)
       stunLeftover = 0.0;
}
simulated function UpdateStunAnim(  name    seqName,
                                   float   oFrame,
                                   float   oRate,
                                   int     stunLoopsLeft,
                                   float   stunLeftover){
    local bool bIdleFramePassed, bLoopEndFramePassed, bNotIdle;
    if(!bIsStunned){
       bWasIdleStun = (seqName == IdleRestAnim);
       prevStunAnimFrame = oFrame;
       return;
    }
    bNotIdle            = (seqName != IdleRestAnim);
    bIdleFramePassed    = oFrame >= idleInsertFrame
       && prevStunAnimFrame < idleInsertFrame;
    bLoopEndFramePassed = oFrame >= stunLoopEnd
       && prevStunAnimFrame < stunLoopEnd;
    //  Hit on idle flag
    //  (and have no stun loops left, while there's enough leftovers left)
    if( bNotIdle && bIdleFramePassed
       && stunLoopsLeft <= 0 && stunLeftover > 0.2){
       PlayAnim(IdleRestAnim,, 0.1);
       bWasIdleStun = true;
       prevStunAnimFrame = -1.0;
    }
    //  Hit on loopEnd flag detected and there's loops left
    else if(bNotIdle && bLoopEndFramePassed && stunLoopsLeft > 0){
       SetAnimFrame(stunLoopStart);
       bWasIdleStun = false;
       prevStunAnimFrame = stunLoopStart;
    }
    else{
       bWasIdleStun = !bNotIdle;
       prevStunAnimFrame = oFrame;
    }
}
simulated function StunTick(float deltaTime){
    local name  seqName;
    local float oFrame, oRate;
    // How many full loops we can play and leftovers after them
    local int   stunLoopsLeft;
    local float stunLeftover;
    //// Handle stun count down
    if(bIsStunned)
       GetAnimParams(0, seqName, oFrame, oRate);
    StunCountDown -= DeltaTime;
    if(StunCountDown < 0.0)
       StunCountDown = 0.0;
    if(bIsStunned && StunCountDown <= 0)
       Unstun();
    // Animation update
    // Compute stun loops left and their leftovers
    CalcRemainigStunStructure(  seqName, oFrame, oRate,
                               stunLoopsLeft, stunLeftover);
    // Make decisions based on current state of stun
    UpdateStunAnim( seqName, oFrame, oRate,
                   stunLoopsLeft, stunLeftover);
}
//==============================================================================
//  >>  Set of functions to handle stun from head damage accumulation
function AccumulateHeadDamage(  float addDamage,
                               bool bIsHeadshot,
                               NicePlayerController nicePlayer){
    if(bIsHeadshot){
       AccHeadDamage += addDamage;
       HeadRecoveryCountDown = HeadRecoveryTime;
       if(AccHeadDamage > (default.HeadHealth / 1.5)
           && (Mind <= AccStunMindLvl && IsStunPossible()))
           DoStun(nicePlayer.pawn,,,, 1.0);
    }
    else if(HeadRecoveryCountDown > 0.0)
       HeadRecoveryCountDown = FMin(   HeadRecoveryCountDown,
                                       HeadRecoveryTime / 2);
}
function HeadDamageRecoveryTick(float delta){
    HeadRecoveryCountDown -= delta;
    HeadRecoveryCountDown = FMax(0.0, HeadRecoveryCountDown);
    if(HeadRecoveryCountDown <= 0.0)
       AccHeadDamage -= delta * HeadDamageRecoveryRate;
    AccHeadDamage = FMax(AccHeadDamage, 0.0);
}
//==============================================================================
//  >>  Function that calls actual 'HeatTick' when needed
simulated function FakeHeatTick(float deltaTime){
    local int i;
    local name seqName;
    local float oFrame;
    local float oRate;
    local NiceMonsterController niceZedController;
    if(lastHeatTick + (1 / HeatTicksPerSecond) < Level.TimeSeconds){
           if(bOnFire && !bBurningBehavior)
               SetBurningBehavior();
           if(!bOnFire && bBurningBehavior)
               UnSetBurningBehavior();
           HeatTick();
           lastHeatTick = Level.TimeSeconds;
    }
    if(bFrozenZedClient != bFrozenZed){
       bFrozenZedClient = bFrozenZed;
       if(bFrozenZed){
           frozenAnimations.length = 0;
           frozenAnimFrames.length = 0;
           while(IsAnimating(i)){
               GetAnimParams(i, seqName, oFrame, oRate);
               frozenAnimations[i] = seqName;
               frozenAnimFrames[i] = oFrame;
               i ++;
           }
       }
    }
    if(bFrozenZed){
       if(Role < Role_AUTHORITY){
           GetAnimParams(0, seqName, oFrame, oRate);
           for(i = 0;i < frozenAnimations.length;i ++){
               PlayAnim(frozenAnimations[i],,, i);
               if(frozenAnimFrames.length > i)
                   SetAnimFrame(frozenAnimFrames[i], i);
           }
       }
       else
           StopAnimating();
       StopMovement();
       SetRotation(frozenRotation);
       niceZedController = NiceMonsterController(controller);
       if(niceZedController != none && !controller.IsInState('Freeze')){
           controller.GotoState('Freeze');
           niceZedController.bUseFreezeHack = true;
           niceZedController.focus = none;
           niceZedController.focalPoint = location + 512 * vector(rotation);
       }
    }
}
//==============================================================================
//  >>  Ticks from TWI's code
//  Updates zed's speed if it's not relevant;
//  code, specific to standalone game and listen servers was cut out
simulated function NonRelevantSpeedupTick(float deltaTime){
    if(Level.netMode == NM_Client || !CanSpeedAdjust()) return;
    if(Level.TimeSeconds - LastReplicateTime > 0.5)
       SetGroundSpeed(default.GroundSpeed * (300.0 / default.GroundSpeed));
    else{
       LastSeenOrRelevantTime = Level.TimeSeconds;
       SetGroundSpeed(GetOriginalGroundSpeed());
    }
}
// Kill zed if it has been bleeding long enough
simulated function BleedOutTick(float deltaTick){
    if(Role < ROLE_Authority || !bDecapitated) return;
    if(BleedOutTime <= 0 || Level.TimeSeconds < BleedOutTime) return;
    if(LastDamagedBy != none)
       Died(LastDamagedBy.Controller, class'DamTypeBleedOut', Location);
    else
       Died(none, class'DamTypeBleedOut', Location);
    BleedOutTime = 0;
}
// FX-stuff TWI did in the tick, unchanged
simulated function TWIFXTick(float deltaTime){
    if(Level.netMode == NM_DedicatedServer) return;
    TickFX(DeltaTime);
    if(bBurnified && !bBurnApplied){
       if(!bGibbed)
           StartBurnFX();
    }
    else if(!bBurnified && bBurnApplied)
       StopBurnFX();
    if( bAshen && Level.netMode == NM_Client
       && !class'GameInfo'.static.UseLowGore()){
       ZombieCrispUp();
       bAshen = False;
    }
}
simulated function TWIDECAPTick(float deltaTime){
    if(!DECAP) return;
    if(Level.TimeSeconds <= (DecapTime + 2.0) || Controller == none) return;
    DECAP = false;
    MonsterController(Controller).ExecuteWhatToDoNext();
}
simulated function BileTick(float deltaTime){
    if(BileCount <= 0 || NextBileTime >= level.TimeSeconds) return;
    BileCount --;
    NextBileTime += BileFrequency;
    TakeBileDamage();
}
//  TWI's code, separeted into shorter functions and segments
simulated function TWITick(float deltaTime){
    //  If we've flagged this character to be destroyed next tick, handle that
    if(bDestroyNextTick && TimeSetDestroyNextTickTime < Level.TimeSeconds)
       Destroy();
    NonRelevantSpeedupTick(deltaTime);
    //  Reset AnimAction
    if(bResetAnimAct && ResetAnimActTime < Level.TimeSeconds){
       AnimAction = '';
       bResetAnimAct = False;
    }
    //  Update look target
    if(Controller != none)
       LookTarget = Controller.Enemy;
    // Some more ticks
    BleedOutTick(deltaTime);
    TWIFXTick(deltaTime);
    TWIDECAPTick(deltaTime);
    BileTick(deltaTime);
}
//==============================================================================
//  >>  Actual tick function, that is much shorter and manageble now
simulated function Tick(float deltaTime){
    //  NicePack-specific ticks
    MadnessTick(deltaTime);
    DecapTick(deltaTime);
    FearTick(deltaTime);
    StunTick(deltaTime);
    HeadDamageRecoveryTick(deltaTime);
    FakeHeatTick(deltaTime);
    //  TWI's tick
    TWITick(deltaTime);
}
simulated function bool IsFinisher( int damage,
                                   class<NiceWeaponDamageType> niceDmg,
                                   NicePlayerController nicePlayer,
                                   optional bool isHeadshot){
    local bool hasTrashCleaner, isReaperActive;
    if(nicePlayer == none) return false;
    hasTrashCleaner = class'NiceVeterancyTypes'.static.hasSkill(nicePlayer,
                                       class'NiceSkillCommandoTrashCleaner');
    isReaperActive = false;
    if(nicePlayer.abilityManager != none){
       isReaperActive = nicePlayer.abilityManager.IsAbilityActive(
           class'NiceSkillSharpshooterReaperA'.default.abilityID);
    }
    if(     (niceDmg == none || !niceDmg.default.bFinisher)
       &&  (!hasTrashCleaner || default.health >= 500)
       &&  (!isReaperActive || !isHeadshot)    )
       return false;
    return  (isHeadshot && damage >= headHealth)
           || (!isHeadshot && damage >= health);
}
//  Checks current zed for head-shot
//  Returns result as 'float' value from 0.0 to 1.0,
//  where 1.0 means perfect head-shot and 0.0 means a miss
simulated function float IsHeadshotClient(  Vector Loc,
                                           Vector Ray,
                                           optional float additionalScale){
    local Coords C;
    local Vector HeadLoc;
    local float distance;
    local Vector HeadToLineOrig;
    //  Let A be such a dot on the bullet trajectory line,
    //  that vector between A and a head is a normal to the line and, therefore,
    //  the shortest distance
    local Vector AToLineOrig;
    local Vector lineDir;
    if(HeadBone == '')
       return 0.0;
    C = GetBoneCoords(HeadBone);
    if(additionalScale == 0.0)
       additionalScale = 1.0;
    HeadLoc = C.Origin + headHeight * headScale * C.XAxis;
    HeadToLineOrig = Loc - HeadLoc;
    lineDir = Normal(Ray);
    //  If we project 'HeadToLineOrig' onto the line,
    //  - line origin ('Loc') will go to itself and Head center ('HeadLoc')
    //  to the point A
    //  So we'll get a vector between A and head center
    AToLineOrig = (HeadToLineOrig Dot lineDir) * lineDir;
    distance = VSize(HeadToLineOrig - AToLineOrig);
    if(distance < headRadius * headScale * additionalScale)
       return 1.0 - (distance / (headRadius * headScale * additionalScale));
    return 0.0;
}
//  In case of a future modifications:
//  check if it's a player doing damage before relying on it
function ModDamage( out int damage,
                   Pawn instigatedBy,
                   Vector hitLocation,
                   Vector momentum,
                   class<NiceWeaponDamageType> damageType,
                   float headshotLevel,
                   KFPlayerReplicationInfo KFPRI,
                   optional float lockonTime){
   local NicePlayerController  nicePlayer;
   local bool                  hasGiantSlayer;
   local int                   bonusDamageStacks;
   if(KFPRI == none || KFPRI.ClientVeteranSkill == none) return;
   //  Add perked damage
   damage = KFPRI.ClientVeteranSkill.Static.AddDamage( KFPRI, self,
                                                      KFPawn(instigatedBy),
                                                      damage, damageType);
   // Skill bonuses
   if(instigatedBy == none)
      return;
   nicePlayer = NicePlayerController(instigatedBy.controller);
   if(nicePlayer == none)
      return;
   hasGiantSlayer = class'NiceVeterancyTypes'.static.hasSkill(nicePlayer,
                                          class'NiceSkillCommandoGiantSlayer');
   if(!hasGiantSlayer)
      return;
   bonusDamageStacks =
      int(health / class'NiceSkillCommandoGiantSlayer'.default.healthStep);
   damage *= 1.0f + bonusDamageStacks *
      class'NiceSkillCommandoGiantSlayer'.default.bonusDamageMult;
}
function ModRegularDamage(  out int damage,
                           Pawn instigatedBy,
                           Vector hitLocation,
                           Vector momentum,
                           class<NiceWeaponDamageType> damageType,
                           float headshotLevel,
                           KFPlayerReplicationInfo KFPRI,
                           optional float lockonTime){
    local bool                          hasOverkillSkill;
    local NicePlayerController          nicePlayer;
    local class<NiceVeterancyTypes>     niceVet;
    if(KFPRI == none) return;
    if(instigatedBy != none)
       nicePlayer = NicePlayerController(instigatedBy.Controller);
    niceVet     = class<NiceVeterancyTypes>(KFPRI.ClientVeteranSkill);
    //  Add perked damage
    if(niceVet != none)
       damage = niceVet.static.AddRegDamage(   KFPRI, self,
                                               KFPawn(instigatedBy), damage,
                                               damageType);
    //  Add some damage against crispy zeds
    if(bCrispified)
       damage += (Max(1200 - default.Health, 0) * damage) / 1200;
    //  Skills bonuses
    if(nicePlayer == none) return;
    hasOverkillSkill = class'NiceVeterancyTypes'.static.
       hasSkill(nicePlayer, class'NiceSkillSharpshooterZEDOverkill');
    if(headshotLevel > 0.0 && nicePlayer.isZedTimeActive() && hasOverkillSkill)
       damage *= class'NiceSkillSharpshooterZEDOverkill'.default.damageBonus;
}
function ModFireDamage( out int damage,
                       Pawn instigatedBy,
                       Vector hitLocation,
                       Vector momentum,
                       class<NiceWeaponDamageType> damageType,
                       float headshotLevel,
                       KFPlayerReplicationInfo KFPRI,
                       optional float lockonTime){
    local class<NiceVeterancyTypes>     niceVet;
    if(KFPRI == none) return;
    niceVet = class<NiceVeterancyTypes>(KFPRI.ClientVeteranSkill);
    //  Add perked damage
    if(niceVet != none)
       damage = niceVet.static.AddFireDamage(  KFPRI, self,
                                               KFPawn(instigatedBy), damage,
                                               damageType);
    //  Cut fire damage against fire-immune zeds
    if(bFireImmune)
       damage /= 10;
}
function ModHeadDamage( out int damage,
                       Pawn instigatedBy,
                       Vector hitLocation,
                       Vector momentum,
                       class<NiceWeaponDamageType> dmgType,
                       float headshotLevel,
                       KFPlayerReplicationInfo KFPRI,
                       optional float lockonTime){
    local bool                          shouldCountHS;
    local NicePlayerController          nicePlayer;
    local class<NiceVeterancyTypes>     niceVet;
    if(instigatedBy != none)
       nicePlayer = NicePlayerController(instigatedBy.Controller);
    shouldCountHS = (lockonTime >= dmgType.default.lockonTime)
                   && (headshotLevel > dmgType.default.prReqMultiplier);
    //  Weapon damage bonus
    if(dmgType != none && shouldCountHS)
       damage *= dmgType.default.HeadShotDamageMult;
    //  Perk damage bonus
    niceVet = class<NiceVeterancyTypes>(KFPRI.ClientVeteranSkill);
    if(KFPRI != none && niceVet != none)
       damage *= niceVet.static.GetNiceHeadShotDamMulti(KFPRI, self, dmgType);
}
//  This function must record damage actual value in 'damage' variable and
//  return value that will decide stun/flinch
function int ModBodyDamage( out int damage,
                           Pawn instigatedBy,
                           Vector hitLocation,
                           Vector momentum,
                           class<NiceWeaponDamageType> damageType,
                           float headshotLevel,
                           KFPlayerReplicationInfo KFPRI,
                           optional float lockonTime){
    local bool                          bHasMessy;
    local bool                          bIsHeadShot;
    local int                           painDamage;
    local NicePlayerController          nicePlayer;
    painDamage = damage;
    bIsHeadShot = (headshotLevel > 0.0);
    if(instigatedBy != none)
       nicePlayer = NicePlayerController(instigatedBy.Controller);
    // On damaging critical spot (so far only head) - do body destruction
    if(bIsHeadShot && damageType != none)
       damage *= damageType.default.bodyDestructionMult;
    // Skill bonuses
    if(nicePlayer == none)
       return painDamage;
    bHasMessy = class'NiceVeterancyTypes'.static.
       someoneHasSkill(nicePlayer, class'NiceSkillSharpshooterDieAlready');
    return painDamage;
}
// Do effects, based on fire damage dealt to monster
function FireDamageEffects( int damage,
                           Pawn instigatedBy,
                           Vector hitLocation,
                           Vector momentum,
                           class<NiceWeaponDamageType> damageType,
                           float headshotLevel,
                           KFPlayerReplicationInfo KFPRI){
    damage = FMax(0.0, damage);
    iceCrustStrenght = FMax(0.0, iceCrustStrenght);
    if(bFrozenZed){
       damage *= 10;
       if(iceCrustStrenght <= damage){
           damage -= iceCrustStrenght;
           if(iceCrustStrenght >= 0){
               iceCrustStrenght = 0;
               UnFreeze();
           }
       }
       else{
           iceCrustStrenght -= damage;
           damage = 0;
       }
       damage /= 10;
    }
    if(damage <= 0) return;
    //  Turn up the heat!
    //  (we can only make it twice as hot with that damage,
    //  but set limit at least at 50, as if we've dealt at least 25 heat damage)
    heat += (damage * HeatIncScale())
       * FMin(1.0, FMax(0.0, (2 - Abs(heat) / FMax(25, Abs(damage) ))));
    CapHeat();
    // Change damage type if new one was stronger
    if(!bOnFire || damage * HeatIncScale() > lastBurnDamage){
       fireDamageClass = damageType;
       burnInstigator = instigatedBy;
    }
    // Set on fire, if necessary
    if(heat > GetIgnitionPoint() && !bOnFire && bCanBurn){
       bBurnified = true;
       bOnFire = true;
       burnInstigator = instigatedBy;
       fireDamageClass = damageType; 
       lastHeatTick = Level.TimeSeconds;
    }
}
function FrostEffects(  Pawn instigatedBy,
                       Vector hitLocation,
                       Vector momentum,
                       class<NiceWeaponDamageType> damageType,
                       float headshotLevel,
                       KFPlayerReplicationInfo KFPRI){
    local float freezePower;
    local float heatChange;
    if(damageType == none) return;
    freezePower = damageType.default.freezePower;
    heatChange = freezePower * (100.0 / default.health);
    heat -= heatChange;
    heat = FMax(-freezePower, heat);
    CapHeat();
    if(heat <= 0){
       bBurnified = false;
       UnSetBurningBehavior();
       RemoveFlamingEffects();
       StopBurnFX();
       bOnFire = false;
       //Log("Pre: strenght="$iceCrustStrenght@"/"@(freezePower * GetIceCrustScale()));
       iceCrustStrenght += freezePower * GetIceCrustScale();
       iceCrustStrenght = FMin(iceCrustStrenght, 150.0);
       //Log("Crusts status: freezePower="$freezePower$", scale="$GetIceCrustScale()$", strenght="$iceCrustStrenght);
    }
    if(!bFrozenZed || freezePower * 0.05 > lastFrostDamage){
       frostDamageClass = damageType;
       frostInstigator = instigatedBy;
    }
    if(!bFrozenZed && iceCrustStrenght >= GetFreezingPoint())
       Freeze();
}
function BileDamageEffect(   int damage,
                           Pawn instigatedBy,
                           class<damageType> damageType){
    if(class<DamTypeVomit>(damageType) != none){
       BileCount = 7;
       BileInstigator = instigatedBy;
       LastBileDamagedByType=class<DamTypeVomit>(damageType);
       if(NextBileTime < Level.TimeSeconds )
           NextBileTime = Level.TimeSeconds + BileFrequency;
    }
}
function float GetDecapDamageModifier(  class<NiceWeaponDamageType> damageType,
                                       NicePlayerController nicePlayer,
                                       KFPlayerReplicationInfo KFPRI){
    local float                     damageMod;
    local bool                      shouldDoGoodDecap;
    local bool                      hasTrashCleaner;
    local bool                      isPerkedPickup;
    local class<NiceWeaponPickup>   pickupClass;
    local class<NiceVeterancyTypes> niceVet;
    niceVet = class<NiceVeterancyTypes>(KFPRI.ClientVeteranSkill);
    isPerkedPickup = false;
    if(niceVet != none){
       pickupClass = niceVet.static.GetPickupFromDamageType(damageType);
       if(pickupClass != none)
           isPerkedPickup = niceVet.static.IsPerkedPickup(pickupClass);
    }
    shouldDoGoodDecap = false;
    shouldDoGoodDecap = (damageType.default.decapType == DB_DROP);
    shouldDoGoodDecap = shouldDoGoodDecap ||
       (damageType.default.decapType == DB_PERKED &&  isPerkedPickup);
    if(shouldDoGoodDecap)
       damageMod = damageType.default.goodDecapMod;
    else
       damageMod = damageType.default.badDecapMod;
    if(nicePlayer != none)
       hasTrashCleaner = class'NiceVeterancyTypes'.static.
           hasSkill(nicePlayer, class'NiceSkillCommandoTrashCleaner');
    if(hasTrashCleaner){
       damageMod = FMin(
                       damageMod,
                       class'NiceSkillCommandoTrashCleaner'.default.
                           decapitationMultiLimit
                       );
    }
    return damageMod;
}
function DealDecapDamage(   int damage,
                           Pawn instigatedBy,
                           Vector hitLocation,
                           Vector momentum,
                           class<NiceWeaponDamageType> damageType,
                           float headshotLevel,
                           KFPlayerReplicationInfo KFPRI,
                           optional float lockonTime){
    local int                   decapDmg;
    local NicePlayerController  nicePlayer;
    if(instigatedBy != none)
       nicePlayer = NicePlayerController(instigatedBy.Controller);
    RemoveHead();
    if(damageType == none){
       ModDamage(  decapDmg, instigatedBy, hitLocation, momentum, damageType,
                   headshotLevel, KFPRI, lockonTime);
       ModHeadDamage(  decapDmg, instigatedBy, hitLocation, momentum,
                       damageType, headshotLevel, KFPRI, lockonTime);
    }
    else
    {
       decapDmg = Ceil(HealthMax * GetDecapDamageModifier(  damageType,
                                                      nicePlayer, KFPRI));
    }
    DealBodyDamage( decapDmg, instigatedBy, hitLocation, momentum, damageType,
                   headshotLevel, KFPRI, lockonTime);
    if(class'NiceVeterancyTypes'.static.
       hasSkill(nicePlayer, class'NiceSkillSharpshooterDieAlready'))
       ServerDropFaster(NiceHumanPawn(nicePlayer.pawn));
}
function DealHeadDamage(    int damage,
                           Pawn instigatedBy,
                           Vector hitLocation,
                           Vector momentum,
                           class<NiceWeaponDamageType> damageType,
                           float headshotLevel,
                           KFPlayerReplicationInfo KFPRI,
                           optional float lockonTime){
    local NicePlayerController          nicePlayer;
    local KFSteamStatsAndAchievements   KFStatsAndAchievements;
    if(instigatedBy != none)
       nicePlayer = NicePlayerController(instigatedBy.Controller);
    //  Sound effects
    PlaySound(  Sound'KF_EnemyGlobalSndTwo.Impact_Skull', SLOT_none,
               2.0, true, 500);
    //  Actual damage effects
    // Skull injury killed a zed
    if(HeadHealth <= 0) return;
    HeadHealth -= damage;
    if(nicePlayer != none && IsFinisher(damage, damageType, nicePlayer, true))
       HeadHealth -= damage;
    //  Remove head for the weak creatures
    if(bWeakHead && damage > 0 && HeadHealth > 0)
       HeadHealth = 0;
    if(HeadHealth <= 0 || damage > Health)
       DealDecapDamage(damage, instigatedBy, hitLocation, momentum, damageType,
                       headshotLevel, KFPRI, lockonTime);
    //  Head damage accumulation
    AccumulateHeadDamage(damage, headshotLevel > 0.0, nicePlayer);
    //  Award head-shot for achievements and stats
    if(nicePlayer == none || damageType == none || !bDecapitated) return;
    KFStatsAndAchievements =
       KFSteamStatsAndAchievements(nicePlayer.SteamStatsAndAchievements);
    damageType.static.ScoredNiceHeadshot(  KFStatsAndAchievements, self.class,
                                           scrnRules.HardcoreLevel);
}
function Vector RecalculateMomentum(Vector momentum,
                                   Pawn instigatedBy,
                                   class<NiceWeaponDamageType> damageType){
    local bool bApplyMomentum;
    if(Physics == PHYS_none)
       SetMovementPhysics();
    if(Physics == PHYS_Walking && damageType.default.bExtraMomentumZ)
       momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
    if(instigatedBy == self)
       momentum *= 0.6;
    momentum = momentum / mass;
    bApplyMomentum = ShouldApplyMomentum(damageType);
    if(Health > 0 && !bApplyMomentum)
       momentum = vect(0 ,0, 0);
    return momentum;
}
function ManageDeath(   Vector hitLocation,
                       Vector momentum,
                       Pawn instigatedBy,
                       class<NiceWeaponDamageType> damageType,
                       float headshotLevel){
    local bool          bWorldOrSafeCaused;
    local Controller    killer;
    if(damageType == none) return;
    bWorldOrSafeCaused = damageType.default.bCausedByWorld
       && (instigatedBy == none || instigatedBy == self);
    if(bWorldOrSafeCaused && LastHitBy != none)
       killer = LastHitBy;
    else if(instigatedBy != none)
       killer = instigatedBy.GetKillerController();
    if(killer == none && damageType.Default.bDelayedDamage)
       killer = DelayedDamageInstigatorController;
    if(bPhysicsAnimUpdate)
       SetTearOffMomemtum(momentum);
    if(bFrozenZed){
       bHidden = true;
       Spawn(ShatteredIce,,, location);
    }
    Died(killer, damageType, hitLocation);
    if(headshotLevel > 0.0 && KFGameType(Level.Game) != none)
       KFGameType(Level.Game).DramaticEvent(0.03);
}
function DealBodyDamage(int damage,
                       Pawn instigatedBy,
                       Vector hitLocation,
                       Vector momentum,
                       class<NiceWeaponDamageType> damageType,
                       float headshotLevel,
                       KFPlayerReplicationInfo KFPRI,
                       optional float lockonTime){
    local int                   actualDamage;
    local bool                  delayedDamage;
    local NicePlayerController  nicePlayer;
    if(Health <= 0 || damageType == none || Role < ROLE_Authority) return;
    // Find correct instigator and it's controller
    delayedDamage = damageType.default.bDelayedDamage
       && DelayedDamageInstigatorController != none;
    if((instigatedBy == none || instigatedBy.Controller == none)
       && delayedDamage)
       instigatedBy = DelayedDamageInstigatorController.Pawn;
    if(instigatedBy != none)
       nicePlayer = NicePlayerController(instigatedBy.Controller);
    // Apply game rules to damage
    actualDamage = Level.Game.ReduceDamage( damage, self, instigatedBy,
                                           hitLocation, Momentum, damageType);
    // Reduce health
    Health -= actualDamage;
    if(IsFinisher(damage, damageType, nicePlayer))
    {
       Health -= actualDamage;
    }
    // Update location
    if(hitLocation == vect(0,0,0))
       hitLocation = Location;
    // Update physics/momentum
    momentum = RecalculateMomentum(momentum, instigatedBy, damageType);
    // Generate effects
    PlayHit(actualDamage, instigatedBy, hitLocation, damageType, Momentum);
    // Add momentum to survivors / manage death
    if(Health > 0){
       AddVelocity(momentum);
       if(controller != none)
           controller.NotifyTakeHit(   instigatedBy, hitLocation, actualDamage,
                                       damageType, Momentum);
       if(instigatedBy != none && instigatedBy != self)
           LastHitBy = instigatedBy.controller;
    }
    else
       ManageDeath(hitLocation, momentum, instigatedBy,
                   damageType, headshotLevel);
    MakeNoise(1.0);
}
function Died(  Controller killer,
               class<DamageType> damageType,
               vector HitLocation){
    local bool          bHasManiac;
    local NiceHumanPawn nicePawn;
    bHasManiac = class'NiceVeterancyTypes'.static.
       HasSkill(NicePlayerController(killer), class'NiceSkillDemoManiac');
    nicePawn = NiceHumanPawn(killer.pawn);
    if(bHasManiac && nicePawn != none)
       nicePawn.maniacTimeout =
           class'NiceSkillDemoManiac'.default.reloadBoostTime;
    super.Died(killer, damageType, HitLocation);
}
simulated function SetTearOffMomemtum(vector NewMomentum){
    TearOffMomentum     = NewMomentum;
    TearOffMomentumX    = NewMomentum.X;
    TearOffMomentumY    = NewMomentum.Y;
    TearOffMomentumZ    = NewMomentum.Z;
}
simulated function vector GetTearOffMomemtum(){
    TearOffMomentum.X   = TearOffMomentumX;
    TearOffMomentum.Y   = TearOffMomentumY;
    TearOffMomentum.Z   = TearOffMomentumZ;
    return TearOffMomentum;
}
function bool ShouldApplyMomentum(class<NiceWeaponDamageType> damageType){
    if(damageType!=class'DamTypeFrag' && damageType!=class'DamTypePipeBomb'
       /*&& damageType!=class'DamTypeM79Grenade'
       && damageType!=class'DamTypeM32Grenade'
       && damageType!=class'DamTypeM203Grenade'
       && damageType!=class'DamTypeDwarfAxe'
       && damageType!=class'DamTypeSPGrenade'
       && damageType!=class'DamTypeSealSquealExplosion'
       && damageType!=class'DamTypeSeekerSixRocket'
       && damageType!=class'NiceDamTypeM41AGrenade'
       && damageType!=class'NiceDamTypeRocket' NICETODO: sort this shit out*/
       && !ClassIsChildOf(damageType, class'NiceDamageTypeVetDemolitions'))
       return false;
    return true;
}
function EPainReaction GetRightPainReaction(int painDamage,
                                           Pawn instigatedBy,
                                           Vector hitLocation,
                                           Vector momentum,
                                           class<NiceWeaponDamageType> dmgType,
                                           float headshotLevel,
                                           KFPlayerReplicationInfo KFPRI){
    local int                           stunScore, flinchScore;
    local bool                          bStunPass, bFlinchPass, bMiniFlinshPass;
    local class<NiceVeterancyTypes>     niceVet;
    if(KFPRI != none)
       niceVet = class<NiceVeterancyTypes>(KFPRI.ClientVeteranSkill);
    stunScore   = painDamage;
    flinchScore = painDamage;
    if(dmgType != none){
       stunScore *= dmgType.default.stunMultiplier;
       flinchScore *= dmgType.default.flinchMultiplier;
    }
    if(niceVet != none){
       flinchScore = niceVet.static.
           AddFlinchScore( KFPRI, self, KFPawn(instigatedBy),
                           flinchScore, dmgType);
       stunScore = niceVet.static.
           AddStunScore(   KFPRI, self, KFPawn(instigatedBy),
                           stunScore, dmgType);
    }
    bStunPass = CheckStun(  stunScore, instigatedBy, hitLocation, momentum,
                           dmgType, headshotLevel, KFPRI);
    bFlinchPass = CheckFlinch(  flinchScore, instigatedBy, hitLocation,
                               momentum, dmgType, headshotLevel, KFPRI);
    bMiniFlinshPass = CheckMiniFlinch(  flinchScore, instigatedBy,
                                       hitLocation, momentum, dmgType,
                                       headshotLevel, KFPRI);
    if(bStunPass) return PREACTION_STUN;
    else if(bFlinchPass) return PREACTION_FLINCH;
    else if(bMiniFlinshPass) return PREACTION_MINIFLINCH;
    return PREACTION_NONE;
}
function DoRightPainReaction( int painDamage,
                                           Pawn instigatedBy,
                                           Vector hitLocation,
                                           Vector momentum,
                                           class<NiceWeaponDamageType> dmgType,
                                           float headshotLevel,
                                           KFPlayerReplicationInfo KFPRI){
    local EPainReaction painReaction;
    painReaction = GetRightPainReaction(painDamage, instigatedBy,
                                       hitLocation, momentum, dmgType,
                                       headshotLevel, KFPRI);
    switch(painReaction){
       case PREACTION_STUN:
           DoStun(         instigatedBy, hitLocation, momentum, dmgType,
                           headshotLevel, KFPRI);
           break;
       case PREACTION_FLINCH:
           DoFlinch(       instigatedBy, hitLocation, momentum, dmgType,
                           headshotLevel, KFPRI);
           break;
       case PREACTION_MINIFLINCH:
           DoMiniFlinch(   instigatedBy, hitLocation, momentum, dmgType,
                           headshotLevel, KFPRI);
           break;
    }
    if(Level.TimeSeconds - LastPainTime > 0.1)
       LastPainTime = Level.TimeSeconds;
}
// Only called when stun is confirmed, so no need to re-check
function float GetstunDurationMult( Pawn instigatedBy,
                                   Vector hitLocation,
                                   Vector momentum,
                                   class<NiceWeaponDamageType> damageType,
                                   float headshotLevel,
                                   KFPlayerReplicationInfo KFPRI){
    local class<NiceVeterancyTypes>     niceVet;
    //  Default out
    if(KFPRI == none) return 1.0;
    niceVet = class<NiceVeterancyTypes>(KFPRI.ClientVeteranSkill);
    if(niceVet == none) return 1.0;
    //  Perk's bonuses out
    return niceVet.static.stunDurationMult( KFPRI, self, KFPawn(instigatedBy),
                                           damageType);
}
function bool IsStunPossible(){
    return (remainingStuns != 0 || bIsStunned);
}
function bool CheckStun(int stunScore,
                       Pawn instigatedBy,
                       Vector hitLocation,
                       Vector momentum,
                       class<NiceWeaponDamageType> damageType,
                       float headshotLevel,
                       KFPlayerReplicationInfo KFPRI){
    if(bFrozenZed) return false;
    if(stunScore > float(default.Health) * stunThreshold && IsStunPossible())
       return true;
    return false;
}
function bool CheckMiniFlinch(  int flinchScore,
                               Pawn instigatedBy,
                               Vector hitLocation,
                               Vector momentum,
                               class<NiceWeaponDamageType> damageType,
                               float headshotLevel,
                               KFPlayerReplicationInfo KFPRI){
    local bool bOnCooldown;
    if(bFrozenZed) return false;
    if(instigatedBy == none || damageType == none) return false;
    if(flinchScore < 5 || Health <= 0 || StunsRemaining == 0) return false;
    bOnCooldown = Level.TimeSeconds - LastPainAnim < MinTimeBetweenPainAnims;
    if(!bOnCooldown && HitCanInterruptAction())
       return true;
    return false;
}
function bool CheckFlinch(  int flinchScore,
                           Pawn instigatedBy,
                           Vector hitLocation,
                           Vector momentum,
                           class<NiceWeaponDamageType> damageType,
                           float headshotLevel,
                           KFPlayerReplicationInfo KFPRI){
    local bool  shouldFlinch;
    local bool  bCanMiniFlinch;
    local Vector X, Y, Z, Dir;
    //  We must be able to perform at least a mini-flinch for a flinch to work
    bCanMiniFlinch = CheckMiniFlinch(   flinchScore, instigatedBy,
                                       hitLocation, momentum, damageType,
                                       headshotLevel, KFPRI);
    if(!bCanMiniFlinch) return false;
    GetAxes(Rotation, X, Y, Z);
    hitLocation.Z = Location.Z;
    //  Actual flinch check
    shouldFlinch = false;
    //  1. Check direction
    if(VSize(Location - hitLocation) < 1.0)
       shouldFlinch = true;
    else{
       Dir = -Normal(Location - hitLocation);
       shouldFlinch = Dir dot X > 0.7;
    }
    //  2. Can we still flinch? ('StunsRemaining' is amount of flinches
    //  remaining, cause stupid naming); note that negative value of
    //  'StunsRemaining' means infinite flinches
    shouldFlinch = shouldFlinch && (StunsRemaining != 0);
    //  3. Do we have high enough 'flinchScore'?
    if(ClassIsChildOf(damageType, class'NiceDamageTypeVetBerserker'))
       shouldFlinch = shouldFlinch && flinchScore >= (0.1 * default.Health);
    else
       shouldFlinch = shouldFlinch && flinchScore >= (0.5 * default.Health);
    return shouldFlinch;
}
function StopMovement(){
    if(physics == PHYS_Falling)
       SetPhysics(PHYS_Walking);
    if(health > 0){
       acceleration.X  = 0;
       acceleration.Y  = 0;
       velocity.X      = 0;
       velocity.Y      = 0;
    }
}
// Do the stun; no check, no conditions, just stun
function DoStun(optional Pawn instigatedBy,
               optional Vector hitLocation,
               optional Vector momentum,
               optional class<NiceWeaponDamageType> damageType,
               optional float headshotLevel,
               optional KFPlayerReplicationInfo KFPRI){
    local int                   i;
    local float                 stunDurationMult;
    local NicePack              niceMut;
    local NiceMonsterController niceController;
    niceMut         = class'NicePack'.static.Myself(Level);
    niceController  = NiceMonsterController(controller);
    if(niceMut == none || niceController == none) return;
    //  Freeze zed and stop it from rotating
    StopMovement();
    niceController.GoToState('Freeze');
    niceController.bUseFreezeHack = true;
    niceController.focus = none; 
    niceController.focalPoint = location + 512 * vector(rotation);
    //  Reduce this value only if player was the one to make a flinch/stun and
    //  zed isn't currently stunned
    if(remainingStuns > 0 && !bIsStunned && KFHumanPawn(InstigatedBy) != none)
       remainingStuns --;
    if(bIsStunned)
       LastStunTime = Level.TimeSeconds;
    else
       SetAnimAction('KnockDown');
    //  Stunned flags
    bSTUNNED = true;
    bShotAnim = true;
    bIsStunned = true;
    stunDurationMult = GetStunDurationMult( instigatedBy, hitLocation, momentum,
                                           damageType, headshotLevel, KFPRI);
    stunCountDown = FMax(stunCountDown, stunDuration * stunDurationMult);
    // Tell clients about a stun
    for(i = 0;i < niceMut.playersList.Length;i ++)
       if(niceMut.playersList[i] != none)
           niceMut.playersList[i].ClientSetZedStun(self, true, stunCountDown);
}
simulated function Unstun(){
    local int i;
    local NicePack niceMut;
    if(Health <= 0.0) return;
    bSTUNNED            = false;
    bIsStunned          = false;
    bShotAnim           = false;
    bWaitForAnim        = false;
    bWasIdleStun        = false;
    prevStunAnimFrame   = 0.0;
    SetAnimFrame(1.0);
    if(Role < Role_AUTHORITY) return;
    if(Controller != none)
       Controller.GoToState('ZombieHunt');
    // Tell clients about a unstun
    niceMut = class'NicePack'.static.Myself(Level);
    if(niceMut == none)
       return;
    for(i = 0;i < niceMut.playersList.Length;i ++)
       if(niceMut.playersList[i] != none)
           niceMut.playersList[i].ClientSetZedStun(self, false, 0.0);
}
simulated function StunRefreshClient(bool bEnableStun){
    local name  seqName;
    local bool  leftLoop;
    local float oFrame, oRate;
    if(bEnableStun){
       leftLoop = prevStunAnimFrame >= FMax(stunLoopEnd, idleInsertFrame);
       //  If we've already left the loop
       //  or were in the idle => restart animation
       if(leftLoop || bWasIdleStun)
           PlayAnim('KnockDown',, 0.1);
       // Other than that - just register stun
       bIsStunned = true;
    }
    else{
       GetAnimParams(0, seqName, oFrame, oRate);
       if(seqName == 'KnockDown' || seqName == IdleRestAnim)
           SetAnimFrame(1.0);
       bIsStunned = false;
    }
}
// Do the flinch; no check, no conditions, just stun
function DoFlinch(  optional Pawn instigatedBy,
                   optional Vector hitLocation,
                   optional Vector momentum,
                   optional class<NiceWeaponDamageType> damageType,
                   optional float headshotLevel,
                   optional KFPlayerReplicationInfo KFPRI){
    SetAnimAction(HitAnims[Rand(3)]);
    LastPainAnim = Level.TimeSeconds;
    bSTUNNED = true;
    SetTimer(StunTime, false);
    // Reduce this value only if play was the one to make a flinch/stun
    if(StunsRemaining > 0 && KFHumanPawn(InstigatedBy) != none)
       StunsRemaining --;
    PainSoundEffect(instigatedBy, hitLocation, momentum, damageType,
                   headshotLevel, KFPRI);
}
// Do the mini-flinch; no check, no conditions, just stun
function DoMiniFlinch(  optional Pawn instigatedBy,
                       optional Vector hitLocation,
                       optional Vector momentum,
                       optional class<NiceWeaponDamageType> damageType,
                       optional float headshotLevel,
                       optional KFPlayerReplicationInfo KFPRI){
    local Vector X,Y,Z, Dir;
    GetAxes(Rotation, X, Y, Z);
    hitLocation.Z = Location.Z;
    Dir = -Normal(Location - hitLocation);
    if(Dir dot X > 0.7 || VSize(Location - hitLocation) < 1.0)
       SetAnimAction(KFHitFront);
    else if(Dir Dot X < -0.7)
       SetAnimAction(KFHitBack);
    else if(Dir Dot Y > 0)
       SetAnimAction(KFHitRight);
    else
       SetAnimAction(KFHitLeft);
    LastPainAnim = Level.TimeSeconds;
    PainSoundEffect(instigatedBy, hitLocation, momentum, damageType,
                   headshotLevel, KFPRI);
}
// Plays sound effect for flinch and updates last sound time
function PainSoundEffect(   Pawn instigatedBy,
                           Vector hitLocation,
                           Vector momentum,
                           class<NiceWeaponDamageType> damageType,
                           float headshotLevel,
                           KFPlayerReplicationInfo KFPRI){
    local PlayerController Hearer;
    if(damageType.default.bDirectDamage)
       Hearer = PlayerController(instigatedBy.Controller);
    if(Hearer != none)
       Hearer.bAcuteHearing = true;
    if(Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds){
       LastPainSound = Level.TimeSeconds;
       if(class<NiceDamTypeFire>(damageType) == none)
           PlaySound(HitSound[0], SLOT_Pain, 1.25,, 400);
    }
    if(Hearer != none)
       Hearer.bAcuteHearing = false;
}
function UpdateLastDamageVars(  Pawn instigatedBy,
                               int damage,
                               class<NiceWeaponDamageType> damageType,
                               Vector hitLocation,
                               Vector momentum){
    lastTookDamageTime  = Level.TimeSeconds;
    lastDamageAmount    = damage;
    lastDamagedBy       = instigatedBy;
    lastDamagedByType   = damageType;
    hitMomentum         = VSize(momentum);
    lasthitLocation     = hitLocation;
    lastMomentum        = momentum;
}
//  Breaks damage into different elemental components and
//  applies damage mods to them
function ExtractElementalDamage(out int regDamage,
                               out int heatDamage,
                               int damage,
                               Pawn instigatedBy,
                               Vector hitLocation,
                               Vector momentum,
                               class<NiceWeaponDamageType> damageType,
                               KFPlayerReplicationInfo KFPRI,
                               float headshotLevel,
                               float lockonTime){
    ModDamage(  damage, instigatedBy, hitLocation, momentum, damageType,
               headshotLevel, KFPRI, lockonTime);
    // Divide damage into different components (so far only regular and fire)
    if(damageType != none){
       RegDamage = damage * (1 - damageType.default.heatPart);
       HeatDamage = damage * damageType.default.heatPart;
    }
    else{
       RegDamage = damage;
       HeatDamage = 0.0;
    }
    // Mod different component's damages
    ModRegularDamage(   RegDamage, instigatedBy, hitLocation, momentum,
                       damageType, headshotLevel, KFPRI, lockonTime);
    ModFireDamage(  HeatDamage, instigatedBy, hitLocation, momentum,
                   damageType, headshotLevel, KFPRI, lockonTime);
}
//  Extracts damage to different body components and applies damage mods to them
function ExtractPartsDamage(out int bodyDamage,
                           out int headDamage,
                           out int painDamage,
                           int damage,
                           Pawn instigatedBy,
                           Vector hitLocation,
                           Vector momentum,
                           class<NiceWeaponDamageType> damageType,
                           KFPlayerReplicationInfo KFPRI,
                           float headshotLevel,
                           float lockonTime){
    bodyDamage = damage;
    headDamage = 0.0;
    //  Mod head health on head-shots only
    if(headshotLevel > 0.0 && HeadHealth > 0){
       headDamage = bodyDamage;
       ModHeadDamage(  headDamage, instigatedBy, hitLocation, momentum,
                       damageType, headshotLevel, KFPRI, lockonTime);
    }
    //  Make sure whole body damage is always at least the
    //  highest single component damage
    bodyDamage = Max(bodyDamage, headDamage);
    //  Always mod body health
    painDamage = ModBodyDamage( bodyDamage, instigatedBy, hitLocation, momentum,
                               damageType, headshotLevel, KFPRI, lockonTime);
    //  Limit pain damage by a head damage
    painDamage = Max(painDamage, headDamage);
}
function AddKillAssistant(Pawn assistant, float damage){
    local KFMonsterController myController;
    myController = KFMonsterController(Controller);
    if(assistant == none || myController == none) return;
    if(!assistant.IsPlayerPawn()) return;
    KFMonsterController(Controller).
       AddKillAssistant(assistant.controller, FMin(health, damage));
}
function DealPartsDamage(   int bodyDamage,
                           int headDamage,
                           Pawn instigatedBy,
                           Vector hitLocation,
                           Vector momentum,
                           class<NiceWeaponDamageType> damageType,
                           KFPlayerReplicationInfo KFPRI,
                           float headshotLevel,
                           float lockonTime){
    if(headDamage > 0 && headshotLevel > 0.0 && !bDecapitated)
       DealHeadDamage(headDamage, instigatedBy, hitLocation, momentum,
           damageType, headshotLevel, KFPRI, lockonTime);
    if(bodyDamage > 0)
       DealBodyDamage(bodyDamage, instigatedBy, hitLocation, momentum,
           damageType, headshotLevel, KFPRI, lockonTime);
}
simulated event SetAnimAction(name NewAction){
    if(bFrozenZed)
       return;
    super.SetAnimAction(NewAction);
}
function Freeze(){
    SetOverlayMaterial(FrozenMaterial, 999, true);
    AnimAction = '';
    bShotAnim = true;
    bWaitForAnim = true;
    StopMovement();
    Disable('AnimEnd');
    StopAnimating();
  
    if(Controller != none){
       Controller.FocalPoint = Location + 512*vector(Rotation);
       Controller.Enemy = none;
       Controller.Focus = none;
       if(!Controller.IsInState('Freeze'))
           Controller.GoToState('Freeze');        
       KFMonsterController(Controller).bUseFreezeHack = true;
    }
    bFrozenZed = true;
    frozenRotation = rotation;
}
function UnFreeze(){
    if(controller == none || Health <= 0) return;
    SetOverlayMaterial(none, 0.1, true);
    bShotAnim = false;
    bWaitForAnim = false;
    Enable('AnimEnd');
    AnimEnd(0);
    AnimEnd(1);
    controller.GotoState('ZombieHunt');
    GroundSpeed = GetOriginalGroundSpeed();
    bFrozenZed = false;
}
function TakeDamageClient(  int damage,
                           Pawn instigatedBy,
                           Vector hitLocation,
                           Vector momentum,
                           class<NiceWeaponDamageType> damageType,
                           float headshotLevel,
                           float lockonTime){
    local KFPlayerReplicationInfo KFPRI;
    //  Elemental damage components
    local int   regDamage;
    local int   heatDamage;
    //  Body part damage components
    local int   headDamage;
    local int   bodyDamage;
    local int   painDamage;
    if(instigatedBy != none)
       KFPRI = KFPlayerReplicationInfo(instigatedBy.PlayerReplicationInfo);
    if(headHealth <= 0)
       headshotLevel = 0.0;
    //  Handle elemental damage components
    ExtractElementalDamage( regDamage, heatDamage, damage,
                           instigatedBy, hitLocation, momentum,
                           damageType, KFPRI, headshotLevel, lockonTime);
    FireDamageEffects(      HeatDamage, instigatedBy, hitLocation, momentum,
                           damageType, headshotLevel, KFPRI);
    FrostEffects(           instigatedBy, hitLocation, momentum,
                           damageType, headshotLevel, KFPRI);
    //  Handle body parts damage components
    ExtractPartsDamage(     bodyDamage, headDamage, painDamage,
                           RegDamage + HeatDamage, instigatedBy,
                           hitLocation, momentum, damageType, KFPRI,
                           headshotLevel, lockonTime);
    DoRightPainReaction(    painDamage, instigatedBy, hitLocation, momentum,
                           damageType, headshotLevel, KFPRI);
    DealPartsDamage(        bodyDamage, headDamage, instigatedBy,
                           hitLocation,    momentum, damageType, KFPRI,
                           headshotLevel, lockonTime);
    AddKillAssistant(instigatedBy, bodyDamage);
    //  Rewrite values of last deal damage, instigator, etc.
    UpdateLastDamageVars(   instigatedBy, bodyDamage, damageType,
                           hitLocation, momentum);
    //  Reset flags: NICETODO: remove this fucking bullshit
    //  like why the fuck is it being done HERE? Makes no fucking sense
    bBackstabbed = false;
}
function TakeDamage(int damage,
                   Pawn instigatedBy,
                   Vector hitLocation,
                   Vector momentum,
                   class<damageType> damageType,
                   optional int HitIndex){
    local bool                          isHeadDamage;
    local bool                          isInstigatorMad;
    local class<KFWeaponDamageType>     kfDmgType;
    local class<NiceWeaponDamageType>   niceDmgType;
    //  Figure out what damage type to use
    kfDmgType = class<KFWeaponDamageType>(damageType);
    niceDmgType = class<NiceWeaponDamageType>(damageType);
    if(niceDmgType == none){
       if(kfDmgType != none && kfDmgType.default.bDealBurningDamage)
           niceDmgType = class'NiceEnviromentalDamageFire';
       else
           niceDmgType = class'NiceEnviromentalDamage';
    }
    // Increase damage from mad zeds, 'cause they aren't kidding
    if(NiceMonster(instigatedBy) != none)
       isInstigatorMad = NiceMonster(instigatedBy).madnessCountDown > 0.0;
    if(isInstigatorMad)
       damage *= damageToMonsterScale;
    if(class<DamTypeVomit>(damageType) != none)
       BileDamageEffect(damage, instigatedBy, damageType);
    if(kfDmgType != none){
       if(!bDecapitated && kfDmgType.default.bCheckForHeadShots)
           isHeadDamage = IsHeadShot(hitLocation, normal(momentum), 1.0);
    }
    if(isHeadDamage)
       TakeDamageClient(   damage, instigatedBy, hitLocation, momentum,
                           niceDmgType, 1.0, 0.0);
    else
       TakeDamageClient(   damage, instigatedBy, hitLocation, momentum,
                           niceDmgType, 0.0, 0.0);
    if(isInstigatorMad){
       madnessCountDown =
           FMax(   madnessCountDown,
                   class'NiceSkillMedicZEDFrenzy'.default.madnessTime * 0.25);
       if(KFMonsterController(Controller) != none)
           KFMonsterController(Controller).FindNewEnemy();
    }
}
function TakeFireDamage(int damage, Pawn instigator){
    local bool      bLowFuel, bHighHeat;
    local Vector    DummyHitLoc, DummyMomentum;
    super(Skaarj).TakeDamage(   damage, instigator, dummyHitLoc,
                               dummyMomentum, fireDamageClass);
    lastBurnDamage = damage;
    //  Melt em' :)
    bHighHeat   = heat > default.health / 20;
    bLowFuel    = FlameFuel < 0.75 * InitFlameFuel;
    if(FlameFuel <= 0 || bHighHeat && bLowFuel)
       ZombieCrispUp();
}
function TakeFrostDamage(int damage, Pawn instigator){
    local Vector    dummyHitLoc, dummyMomentum;
    if(damage > health)
       damage = health - 1;
    if(damage > 0)
       super(Skaarj).TakeDamage(   damage, instigator, dummyHitLoc,
                                   dummyMomentum, frostDamageClass);
    lastFrostDamage = damage;
}
simulated function ZombieCrispUp(){
    bAshen = true;
    bCrispified = true;
    if(Level.netMode == NM_DedicatedServer) return;
    if(class'GameInfo'.static.UseLowGore()) return;
    Skins[0]=Combiner'PatchTex.Common.BurnSkinEmbers_cmb';
    Skins[1]=Combiner'PatchTex.Common.BurnSkinEmbers_cmb';
    Skins[2]=Combiner'PatchTex.Common.BurnSkinEmbers_cmb';
    Skins[3]=Combiner'PatchTex.Common.BurnSkinEmbers_cmb';
}
simulated function HeatTick(){
    local float iceDamage;
    //  Update heat value
    if(!bOnFire || flameFuel <= 0)
           heat *= heatDissipationRate;
    else{
       if(flameFuel < heat)
           heat = flameFuel * 1.1 + (heat - flameFuel) * heatDissipationRate;
       else
           heat = heat * 1.1;
       if(bFrugalFuelUsage)
           flameFuel -= heat;
       else
           flameFuel -= FMax(heat, InitFlameFuel / 15);
    }
    CapHeat();
    if(Abs(heat) < 1)
       heat = 0.0;
    //  Update on-fire status
    if(bOnFire){
       if(heat > 0)
           TakeFireDamage(heat + rand(5), burnInstigator);
       else{
           bBurnified = false;
           UnSetBurningBehavior();
           RemoveFlamingEffects();
           StopBurnFX();
           bOnFire = false;
       }
    }
    //  Update frozen status (always deal frost damage)
    iceCrustStrenght = FMax(iceCrustStrenght, heat);
    if(heat >= -10 && health > 1)
       iceCrustStrenght -= 5 * (heat + 10);
    iceCrustStrenght = FMax(0.0, iceCrustStrenght);
    if(bFrozenZed){
       iceDamage = -heat * 0.25;
       if(iceDamage > 10)
           TakeFrostDamage(iceDamage + rand(5), frostInstigator);
       if(iceCrustStrenght <= 0){
           UnFreeze();
           heat = 0;
       }
    }
}
simulated function SetBurningBehavior(){
    bBurningBehavior = true;
    if(default.Health >= 1000) return;
    if(Role == Role_Authority)
       Intelligence = BRAINS_Retarded;
    MovementAnims[0] = BurningWalkFAnims[Rand(3)];
    WalkAnims[0]     = BurningWalkFAnims[Rand(3)];
    MovementAnims[1] = BurningWalkAnims[0];
    WalkAnims[1]     = BurningWalkAnims[0];
    MovementAnims[2] = BurningWalkAnims[1];
    WalkAnims[2]     = BurningWalkAnims[1];
    MovementAnims[3] = BurningWalkAnims[2];
    WalkAnims[3]     = BurningWalkAnims[2];
}
simulated function UnSetBurningBehavior(){
    local int i;
    bBurningBehavior = false;
    if(Role == Role_Authority){
       Intelligence = default.Intelligence;
       if(!bZapped){
           SetGroundSpeed(GetOriginalGroundSpeed());
           AirSpeed = default.AirSpeed;
           WaterSpeed = default.WaterSpeed;
       }
    }
    if(bCrispified)
       bAshen = True;
    for(i = 0; i < 4; i++){
       MovementAnims[i]  = default.MovementAnims[i];
       WalkAnims[i]      = default.WalkAnims[i];
    }
}
simulated function ServerDropFaster(NiceHumanPawn nicePawn){
    if(nicePawn == none) return;
    if(Health > 0)
       BleedOutTime = Level.TimeSeconds
         + class'NiceSkillSharpshooterDieAlready'.default.bleedOutTime[nicePawn.calibrationScore - 1];
}
simulated function RemoveHead(){
    local int i;
    local class<KFWeaponDamageType> kfDmgType;
    Intelligence    = BRAINS_Retarded;
    bDecapitated    = true;
    DECAP           = true;
    DecapTime       = Level.TimeSeconds;
    kfDmgType = class<KFWeaponDamageType>(lastDamagedByType);
    if(kfDmgType != none && kfDmgType.default.bIsMeleeDamage)
       bMeleeDecapitated = true;
    SetAnimAction('HitF');
    SetGroundSpeed(GroundSpeed *= 0.80);
    //  No more raspy breathin'...cuz he has no throat or mouth :S
    AmbientSound = MiscSound;
    if(Health > 0)
       BleedOutTime = Level.TimeSeconds + BleedOutDuration;
    if(MeleeAnims[1] == 'Claw3')
       MeleeAnims[1] = 'Claw1';
    if(MeleeAnims[2] == 'Claw3')
       MeleeAnims[2] = 'Claw2';
    //  Plug in headless anims if we have them
    for(i = 0;i < 4;i ++)
       if(HeadlessWalkAnims[i] != '' && HasAnim(HeadlessWalkAnims[i])){
           MovementAnims[i] = HeadlessWalkAnims[i];
           WalkAnims[i]     = HeadlessWalkAnims[i];
       }
    PlaySound(DecapitationSound, SLOT_Misc, 1.30, true, 525);
    if(NiceMonsterController(Controller) != none)
       NiceMonsterController(Controller).FindNewEnemy();
}
function bool FlipOverWithIntsigator(Pawn InstigatedBy){
    return FlipOver();
}
//  Calculates bone which bone we've hit
//  as well as updates hit location and hit normal;
//  extracted from TWI code without much changes
function CalculateHitBone(  out Vector hitLocation,
                           out Vector hitNormal,
                           out name hitBone,
                           Pawn instigatedBy,
                           class<damageType> damageType){
    local Vector    hitRay;
    local Vector    instigatorEyes;
    local float     hitBoneDist;
    //  We have 'hitLocation' that designates where we approximately hit zed
    //  (it's collision cylinder).
    //  We want to know which bone instigator hit,
    //  so here we compute direction in wich bullet flew.
    hitRay = vect(0,0,0);
    if(instigatedBy != none){
       instigatorEyes = instigatedBy.location
           + vect(0,0,1) * instigatedBy.EyeHeight;
       hitRay = hitLocation - instigatorEyes;
       hitRay = Normal(hitLocation);
    }
    //  Now we have a vector that gives us bullet's
    //  trajectory direction ('hitRay')
    //  and a point it passes through ('hitRay'),
    //  so we can use magic funtion to find out which bone that bullet hit
    if(damageType.default.bLocationalHit)
       CalcHitLoc(hitLocation, hitRay, hitBone, hitBoneDist);
    else{
       //  ...or just ignore all that and chose whatever
       hitLocation = location;
       hitBone = fireRootBone;
    }
    //  Now get let's come up with some 'hitNormal'
    if(instigatedBy != none){
       hitNormal =     Normal(instigatedBy.location - hitLocation);
       hitNormal +=    vect(0, 0, 2.8);
       hitNormal +=    VRand() * 0.2;
       hitNormal =     Normal(hitNormal);
    }
    else
       hitNormal = Normal(Vect(0, 0, 1) + VRand() * 0.2 + vect(0, 0, 2.8));
}
function SplatterBlood( Pawn instigatedBy,
                       Vector hitLocation,
                       class<damageType> damageType,
                       Vector momentum){
    local bool      bNotRecentHit;
    local bool      bBloodDisabled;
    local rotator   splatRot;
    //  Is this hit recent?
    //  Even if recent - randomly count ome hits as non-recent
    bNotRecentHit = Level.TimeSeconds - LastPainTime >= 0.2;
    bNotRecentHit = bNotRecentHit || FRand() > 0.8;
    //  Is blood allowed?
    bBloodDisabled = class'GameInfo'.static.NoBlood();
    bBloodDisabled = bBloodDisabled || class'GameInfo'.static.UseLowGore();
    //  Generate some blood
    if(damageType.default.bCausesBlood && !bBloodDisabled && bNotRecentHit){
       //  Get correct-looking rotatin for our blood splat,
       //  if possible for momentum
       if(momentum != vect(0,0,0))
           splatRot = rotator(Normal(momentum));
       else{
           if(instigatedBy != none)
               splatRot = rotator(Normal(Location - instigatedBy.Location));
           else
               splatRot = rotator(Normal(Location - hitLocation));
       }
       Spawn(ProjectileBloodSplatClass, instigatedBy,, hitLocation, splatRot);
    }
}
//  Overloaded to suck less ass,
//  for example containing only visual side of effects.
//  Removed zapped effect, since zeds can't be zapped in NicePack.
simulated function PlayHit( float damage,
                       Pawn instigatedBy,
                       Vector hitLocation,
                       class<damageType> damageType,
                       Vector momentum,
                       optional int HitIdx){
    local Vector    hitNormal;
    local name      hitBone;
    // Call the modified version of the original Pawn playhit
    OldPlayHit(damage, instigatedBy, hitLocation, damageType, momentum);
    if(damage <= 0) return;
    CalculateHitBone(hitLocation, hitNormal, hitBone, instigatedBy, damageType);
    SplatterBlood(instigatedBy, hitLocation, damageType, momentum);
    DoDamageFX(hitBone, damage, damageType, Rotator(hitNormal));
    if(damageType.default.DamageOverlayMaterial != none && damage > 0)
       SetOverlayMaterial( damageType.default.damageOverlayMaterial,
                           damageType.default.damageOverlayTime, false);
}
//  I've gotta come clean - I'm not sure what this one does exactly
function SpawnPVolumeExitActor(){
    local bool  bPVCanExitActor;
    if(PhysicsVolume != none){
       bPVCanExitActor = PhysicsVolume.bDestructive;
       bPVCanExitActor = bPVCanExitActor && PhysicsVolume.bDestructive;
       bPVCanExitActor = bPVCanExitActor && PhysicsVolume.ExitActor != none;
    }
    if(health <= 0 && bPVCanExitActor)
       Spawn(PhysicsVolume.ExitActor);
}
function OldSpawnEffect(Vector hitLocation,
                       Vector hitNormal,
                       Vector momentum,
                       class<Effects> effectClass){
    local Vector bloodOffset;
    if(effectClass == none) return;
    bloodOffset     = 0.2 * collisionRadius * hitNormal;
    bloodOffset.Z   = 0.5 * bloodOffset.Z;
    if(momentum.Z > 0)
       momentum.Z *= 0.5;
    Spawn(effectClass, self,, hitLocation + bloodOffset, rotator(momentum));
}
function OldSpawnEmitter(   Vector hitLocation,
                           Vector hitNormal,
                           Pawn instigatedBy,
                           class<Emitter> emitterClass){
    local Vector emitterOffset;
    local Vector instigatorEyes;
    if(emitterClass == none) return;
    emitterOffset   = hitNormal - hitNormal * CollisionRadius;
    instigatorEyes  = instigatedBy.location
       + vect(0,0,1) * instigatedBy.EyeHeight;
    if(instigatedBy != none)
       hitNormal = Normal(instigatorEyes - hitLocation);
    Spawn(emitterClass,,, hitLocation + emitterOffset, Rotator(hitNormal));
}
// Now only visual part of effects
function OldPlayHit(float damage,
                   Pawn instigatedBy,
                   Vector hitLocation,
                   class<damageType> damageType,
                   Vector momentum,
                   optional int HitIndex){
    local bool              bLowDetails;
    local bool              bShouldPlayEffect;
    local Vector            hitNormal;
    local class<Effects>    desiredEffect;
    local class<Emitter>    desiredEmitter;
    if(damageType == none || damage <= 0) return;
    SpawnPVolumeExitActor();
    //  Comment in 'DamageType' says that 'DamageThreshold' is
    //  how much damage much occur before playing effects.
    bShouldPlayEffect = damage > damageType.default.damageThreshold;
    bShouldPlayEffect = bShouldPlayEffect && EffectIsRelevant(location, true);
    if(!bShouldPlayEffect) return;
    hitNormal = Normal(hitLocation - Location);
    bLowDetails = Level.bDropDetail || Level.detailMode == DM_Low;
    desiredEffect = damageType.static.GetPawnDamageEffect(  hitLocation, damage,
                                                           momentum,
                                                           self, bLowDetails);
    desiredEmitter = damageType.Static.GetPawnDamageEmitter(    hitLocation,
                                                               damage,
                                                               momentum, self,
                                                               bLowDetails);
    OldSpawnEffect(hitLocation, hitNormal, momentum, desiredEffect);
    OldSpawnEmitter(hitLocation, hitNormal, instigatedBy, desiredEmitter);
}
simulated function PlayTakeHit( Vector hitLocation,
                               int damage,
                               class<damageType> damageType){}
function float GetIgnitionPoint(){
    return 10;
}
function float GetFreezingPoint(){
    return 100.0;
}
function float GetIceCrustScale(){
    return 25000 / (default.health * default.health);
}
function float HeatIncScale(){
    return 100.0 / default.health;
}
function CapHeat(){
    heat = FMin(heat, 135 + rand(10) - 5);
    heat = FMax(heat, -150 + rand(10) - 5);
}
function bool TryMeleeReachTarget(out Vector hitLocation){
    local Actor     hitActor;
    local Vector    hitNormal;
    //  See if a trace would hit a pawn
    //  (have to turn off hit point collision so trace doesn't hit the
    //  HumanPawn's bullet whiz cylinder)
    bBlockHitPointTraces = false;
    hitActor = Trace(   hitLocation, hitNormal, controller.target.location,
                       location + EyePosition(), true);
    bBlockHitPointTraces = true;
    if(Pawn(hitActor) != none) return true;
    //  If the trace wouldn't hit a pawn, do the old thing of just checking if
    //  there is something blocking the trace
    bBlockHitPointTraces = false;
    hitActor = Trace(   hitLocation, hitNormal, controller.target.location,
                       location, false);
    bBlockHitPointTraces = true;
    return (hitActor == none);  //  Nothing in the way means no problems
}
function MeleeGoreDeadPlayer(   KFHumanPawn kfHumanPawn,
                               Vector hitLocation,
                               Vector pushDir){
    local float dummy;
    local name  tearBone;
    if(kfHumanPawn == none || class'GameInfo'.static.UseLowGore()) return;
    Spawn(  class'KFMod.FeedingSpray', self,,
           kfHumanPawn.location, rotator(pushDir));
    kfHumanPawn.SpawnGibs(rotator(pushDir), 1);
    tearBone = kfHumanPawn.GetClosestBone(hitLocation, velocity, dummy);
    kfHumanPawn.HideBone(tearBone);
}
function bool MeleeDamageTarget(int hitDamage, Vector pushDir){
    local bool          bTargetIsDoor;
    local bool          bInMeleeRange, bCanMeleeReach;
    local float         meleeDistance, distanceFromTarget;
    local Vector        hitLocation;
    local KFHumanPawn   kfHumanPawn;
    if(Level.netMode == NM_Client) return false;
    if(controller == none || controller.target == none) return false;
    //  Melee for doors
    kfHumanPawn = KFHumanPawn(controller.target);
    bTargetIsDoor = controller.target.IsA('KFDoorMover');
    if(bTargetIsDoor){
       controller.target.TakeDamage(   hitDamage, self, hitLocation,
                                       pushDir, niceZombieDamType);
       return true;
    }
    //  Check if still in melee range
    meleeDistance = meleeRange * 1.4;
    meleeDistance += controller.target.collisionRadius + collisionRadius;
    distanceFromTarget = VSize(controller.target.location - location);
    bInMeleeRange = distanceFromTarget <= meleeDistance;
    bCanMeleeReach = TryMeleeReachTarget(hitLocation);
    if(!bInMeleeRange || !bCanMeleeReach || bSTUNNED) return false;
    //  Melee for non-human actors
    if(kfHumanPawn == none){
       controller.target.TakeDamage(   hitDamage, self, hitLocation,
                                       pushDir, niceZombieDamType);
       return true;
    }
    //  Melee for human pawns
    kfHumanPawn.TakeDamage( hitDamage, instigator,
                           hitLocation, pushDir, niceZombieDamType);
    if(kfHumanPawn != none && kfHumanPawn.Health <= 0){
       MeleeGoreDeadPlayer(kfHumanPawn, hitLocation, pushDir);
       // Give us some health back
       if(health <= (1.0 - feedThreshold) * healthMax)
           health += feedThreshold * healthMax * health / healthMax;
    }
    return true;
}
state ZombieDying {
    ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange,
       PhysicsVolumeChange, Falling, BreathTimer, Died, RangedAttack;
    simulated function Landed(vector HitNormal){
       SetCollision(false, false, false);
       if(!bDestroyNextTick)
           Disable('Tick');
    }
    simulated function TakeDamageClient(int damage,
                                       Pawn InstigatedBy,
                                       Vector hitLocation,
                                       Vector momentum,
                                       class<NiceWeaponDamageType> damageType,
                                       optional float headshotLevel,
                                       optional float lockonTime){
       local Vector shotDir;
       local Vector pushLinVel, pushAngVel;
       if(bFrozenBody || bRubbery || damage <= 0) return;

       if(headshotLevel > 0.0)
           RemoveHead();
       PlayHit(damage, InstigatedBy, hitLocation, damageType, momentum);

       //  Can't shoot corpses during de-res
       if(Physics != PHYS_KarmaRagdoll || bDeRes) return;

       //  Throw the body if its a rocket explosion or shock combo
       if(momentum == vect(0,0,0))
           momentum = hitLocation - instigatedBy.Location;
       shotDir = Normal(momentum);
       if(damageType.default.bThrowRagdoll){
           pushLinVel = (RagDeathVel * shotDir) +  vect(0, 0, 250);
           pushAngVel = Normal(shotDir Cross vect(0, 0, 1)) * -18000;
           KSetSkelVel(pushLinVel, pushAngVel);
       }
       else if(damageType.default.bRagdollBullet){
           if(FRand() < 0.65){
               if(velocity.Z <= 0)
                   pushLinVel = vect(0,0,40);
               pushAngVel = Normal(shotDir Cross vect(0, 0, 1)) * (-8000);
               pushAngVel.X *= 0.5;
               pushAngVel.Y *= 0.5;
               pushAngVel.Z *= 4;
               KSetSkelVel(pushLinVel, pushAngVel);
           }
           pushLinVel = RagShootStrength * shotDir;
           KAddImpulse(pushLinVel, hitLocation);
           if((LifeSpan > 0) && (LifeSpan < DeResTime + 2))
               LifeSpan += 0.2;
       }
       else{
           pushLinVel = RagShootStrength * shotDir;
           KAddImpulse(pushLinVel, hitLocation);
       }
    }
}
defaultproperties
{
    StunThreshold=0.666000
    remainingStuns=-1
    lastStunTime=-1.000000
    headDamageRecoveryRate=100.000000
    headRecoveryTime=1.000000
    mind=1.000000
    accStunMindLvl=0.500000
    bCanBurn=True
    fuelRatio=0.750000
    heatDissipationRate=0.666000
    heatTicksPerSecond=3.000000
    bFrugalFuelUsage=True
    clientHeadshotScale=1.000000
    FrozenMaterial=Texture'HTec_A.Overlay.IceOverlay'
    ShatteredIce=Class'NicePack.NiceIceChunkEmitter'
    niceZombieDamType=Class'NicePack.NiceZedMeleeDamageType'
    ZappedSpeedMod=0.300000
    DamageToMonsterScale=5.000000
    RagdollLifeSpan=120.000000
    ControllerClass=Class'NicePack.NiceMonsterController'
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkelN
        KConvulseSpacing=(Max=2.200000)
        KLinearDamping=0.150000
        KAngularDamping=0.050000
        KBuoyancy=1.000000
        KStartEnabled=True
        KVelDropBelowThreshold=50.000000
        bHighDetailOnly=False
        KFriction=1.300000
        KRestitution=0.200000
        KImpactThreshold=85.000000
    End Object
    KParams=KarmaParamsSkel'NicePack.NiceMonster.KarmaParamsSkelN'
}
