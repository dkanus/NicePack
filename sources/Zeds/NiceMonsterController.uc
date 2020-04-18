//==============================================================================
//  NicePack / NiceMonsterController
//==============================================================================
//  New base class for zeds that makes it easier to implement various changes
//  and bug fixes.
//  Functionality:
//      - Removed threat assessment functionality in favor of vanilla's
//          distance-based behavior
//      - Doesn't support 'bNoAutoHuntEnemies' flag from 'KFMonster'
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceMonsterController extends KFMonsterController;
//  Just reset threat assesment flag, since it's not used in NicePack
function PostBeginPlay(){
	super.PostBeginPlay();
	bUseThreatAssessment = true;
}
event bool NotifyBump(Actor other){
    local Pawn otherPawn;
    Disable('NotifyBump');
    otherPawn = Pawn(other);
    if(otherPawn == none || otherPawn.controller == none) return false;
    if(enemy == otherPawn) return false;
    if(SetEnemy(otherPawn)){
       WhatToDoNext(4);
       return false;
    }
    if(enemy == otherPawn) return false;
    if(!AdjustAround(otherPawn))
       CancelCampFor(otherPawn.controller);
    return false;
}
state Startled{
    ignores EnemyNotVisible,SeePlayer,HearNoise;
    function Startle(Actor Feared){
       goalString = "STARTLED!";
       startleActor = feared;
       BeginState();
    }
    function BeginState(){
       if(startleActor == none){
           GotoState('');
           return;
       }
       pawn.acceleration   = pawn.location - startleActor.location;
       pawn.acceleration.Z = 0;
       pawn.bIsWalking     = false;
       pawn.bWantsToCrouch = false;
       if(pawn.acceleration == vect(0,0,0))
           pawn.acceleration = VRand();
       pawn.acceleration = pawn.accelRate * Normal(pawn.acceleration);
    }
Begin:
    if( NiceHumanPawn(StartleActor) == none
       || KFGameType(Level.Game) == none
       || KFGameType(Level.Game).bZEDTimeActive ){
       Sleep(0.5);
       WhatToDoNext(11);
    }
    else{
       Sleep(0.25);
       Goto('Begin');
    }
}
function bool IsMonsterDecapitated(){
    local NiceMonster niceZed;
    niceZed = NiceMonster(self.pawn);
    if(niceZed == none) return false;
    return niceZed.bDecapitated || niceZed.HeadHealth <= 0;
}
function bool IsMonsterMad(){
    local NiceMonster niceZed;
    niceZed = NiceMonster(self.pawn);
    if(niceZed == none) return false;
    return niceZed.madnessCountDown > 0.0;
}
function bool FindNewEnemy(){
    local bool          bSeeBest;
    local bool          bDecapitated, bAttacksAnything;
    local float         bestScore, newScore;
    local Pawn          bestEnemy;
    local Controller    ctrlIter;
    if(pawn == none) return false;
    bDecapitated        = IsMonsterDecapitated();
    bAttacksAnything    = bDecapitated || IsMonsterMad();
    for(ctrlIter = Level.controllerList;
       ctrlIter != none;
       ctrlIter = ctrlIter.nextController){
       if(ctrlIter == none || ctrlIter.pawn == none)               continue;
       if(ctrlIter.pawn.health <= 0 || ctrlIter.pawn == self.pawn) continue;
       if(ctrlIter.bPendingDelete || ctrlIter.pawn.bPendingDelete) continue;
       //  Shouldn't normally attack healthy zeds
       if(     !bAttacksAnything && NiceMonster(ctrlIter.pawn) != none
           &&  ctrlIter.pawn.health > 15) continue;
       //  Can only stand up to fleshpound if we're decapitated
       if(NiceZombieFleshpound(ctrlIter.pawn) != none && !bDecapitated)
           continue;

       //  NicePack doesn't use threat assesment, so just find closest target
       newScore = VSizeSquared(ctrlIter.pawn.Location - pawn.Location);
       if(bestEnemy == none || newScore < bestScore){
           bestEnemy   = ctrlIter.pawn;
           bestScore   = newScore;
           bSeeBest    = CanSee(bestEnemy);
       }
    }
    if(bestEnemy == enemy) return false;
    if(bestEnemy != none){
       ChangeEnemy(bestEnemy, bSeeBest);
       return true;
    }
    return false;
}
function UpdatePathFindState(){
    if(pathFindState == 0){
       initialPathGoal = FindRandomDest();
       pathFindState   = 1;
    }
    if(pathFindState == 1){
       if(initialPathGoal == none)
           pathFindState = 2;
       else if(ActorReachable(initialPathGoal)){
           MoveTarget = initialPathGoal;
           pathFindState = 2;
           return;
       }
       else if(FindBestPathToward(initialPathGoal, true, true))
           return;
       else
           pathFindState = 2;
    }
}
function PickRandomDestination(){
    local bool          bCloseToEnemy;
    local bool          bCanTrackEnemy;
    local NiceMonster   niceZed;
    niceZed = NiceMonster(pawn);
    if(niceZed == none) return;
    if(enemy != none)
       bCloseToEnemy = VSizeSquared(niceZed.Location - enemy.Location) < 40000;
    //  Can we track our enemy?
    if(enemy != none && niceZed.headHealth > 0 && FRand() < 0.5){
       bCanTrackEnemy = MoveTarget == enemy;
       if(!ActorReachable(enemy))
           bCanTrackEnemy = false;
       if(niceZed.default.health < 500 && !bCloseToEnemy)
           bCanTrackEnemy = false;
    }
    //  Choose random location
    if(bCanTrackEnemy)
       destination = enemy.location + VRand() * 50;
    else
       destination = niceZed.location + VRand() * 200;
}
state ZombieHunt{
    function BeginState(){
       local float zDif;

       if(pawn.collisionRadius > 27 || pawn.collisionHeight > 46){
           zDif = Pawn.collisionHeight - 44;
           Pawn.SetCollisionSize(24, 44);
           Pawn.MoveSmooth(vect(0,0,-1) * zDif);
       }
    }
    function EndState(){
       local float zDif;
       local bool  bCollisionSizeChanged;

       bCollisionSizeChanged =
           pawn.collisionRadius != pawn.default.collisionRadius;
       bCollisionSizeChanged = bCollisionSizeChanged ||
           pawn.collisionHeight != pawn.default.collisionHeight;

       if(pawn != none && bCollisionSizeChanged){
           zDif = pawn.Default.collisionRadius - 44;
           pawn.MoveSmooth(vect(0,0,1) * zDif);
           pawn.SetCollisionSize(  pawn.Default.collisionRadius,
                                   pawn.Default.collisionHeight);
       }
    }
    function Timer(){
       if(pawn.Velocity == vect(0,0,0))
           GotoState('ZombieRestFormation', 'Moving');
       SetCombatTimer();
       StopFiring();
    }
    function PickDestinationEnemyDied(){
    }
    function PickDestination(){
       //  Change behaviour in case we're 'BRAINS_Retarded'
       if(KFM.intelligence == BRAINS_Retarded){
           //  Some of the TWI's code
           if(FindFreshBody()) return;
           if(enemy != none && !KFM.bCannibal && enemy.health <= 0){
               enemy = none;
               WhatToDoNext(23);
               return;
           }
           UpdatePathFindState();
           if(pawn.JumpZ > 0)
               pawn.bCanJump = true;
           //  And just pick random location
           PickRandomDestination();
           return;
       }
       else
           super.PickDestination();
    }
}
function NotifyTakeHit( Pawn InstigatedBy,
                       Vector HitLocation,
                       int damage,
                       class<DamageType> damageType,
                       Vector momentum){
    local KFMonster zed;
    local bool      bZedCanVomit;
    if(class<DamTypeBlowerThrower>(damageType) == none || damage <= 0) return;
    foreach VisibleCollidingActors(class'KFMonster', zed, 1000, pawn.location){
       bZedCanVomit = zed.IsA('NiceZombieBloatBase');
       bZedCanVomit = bZedCanVomit || zed.IsA('NiceZombieSickBase');
       if(bZedCanVomit && zed != pawn && KFHumanPawn(instigatedBy) != none){
           if(KFMonster(pawn) != none)
               SetEnemy(zed, true, KFMonster(pawn).HumanBileAggroChance);
           return;
       }
    }
    super.NotifyTakeHit(InstigatedBy,HitLocation, damage, damageType, momentum);
}
state ZombieCharge{
    function SeePlayer(Pawn seen){
       if(KFM.intelligence == BRAINS_Human)
           SetEnemy(Seen);
    }
    function DamageAttitudeTo(Pawn other, float damage){
       if(KFM.intelligence >= BRAINS_Mammal && other!=none && SetEnemy(other))
           SetEnemy(other);
    }
    function HearNoise(float loudness, Actor noiseMaker){
       if(KFM.intelligence != BRAINS_Human) return;
       if(noiseMaker == none && noiseMaker.Instigator == none) return;

       if(FastTrace(noiseMaker.location, pawn.location))
           SetEnemy(noiseMaker.Instigator);
    }
    function bool StrafeFromDamage( float damage,
                                   class<DamageType> damageType,
                                   bool bFindDest){
       return false;
    }
    function bool TryStrafe(vector sideDir){
       return false;
    }
Begin:
    if(pawn.physics == PHYS_Falling){
       focus       = enemy;
       destination = enemy.location;
       WaitForLanding();
    }
    if(enemy == none)
       WhatToDoNext(16);
WaitForAnim:
    while(KFM.bShotAnim)
       Sleep(0.35);
    if(!FindBestPathToward(enemy, false, true))
       GotoState('TacticalMove');
Moving:
    if(KFM.intelligence == BRAINS_Retarded){
       if( KFMonster(pawn).HeadHealth > 0 && moveTarget == enemy
           && FRand() < 0.5
           &&  (   KFMonster(pawn).default.Health >= 500
                   || VSize(pawn.location - moveTarget.location) < 200)
               )
           MoveTo(moveTarget.location + VRand() * 50, none);
       else
           MoveTo(pawn.location + VRand() * 200, none);
    }
    else
       MoveToward(moveTarget, FaceActor(1),, ShouldStrafeTo(moveTarget));
    WhatToDoNext(17);
    if (bSoaking)
       SoakStop("STUCK IN CHARGING!");
}
state DoorBashing{
ignores EnemyNotVisible,SeeMonster;
    function Timer(){
       Disable('NotifyBump');
    }
    function AttackDoor(){
       target = targetDoor;
       KFM.Acceleration = vect(0,0,0);
       KFM.DoorAttack(target);
    }
    function SeePlayer( Pawn Seen ){
       if( KFM.intelligence == BRAINS_Human
           && ActorReachable(Seen) && SetEnemy(Seen))
           WhatToDoNext(23);
    }
    function DamageAttitudeTo(Pawn Other, float Damage){
       if( KFM.intelligence >= BRAINS_Mammal && Other != none
           && ActorReachable(Other) && SetEnemy(Other))
           WhatToDoNext(32);
    }
    function HearNoise(float Loudness, Actor NoiseMaker){
       if( KFM.intelligence == BRAINS_Human && NoiseMaker != none
           && NoiseMaker.Instigator != none
           && ActorReachable(NoiseMaker.Instigator)
           && SetEnemy(NoiseMaker.Instigator))
           WhatToDoNext(32);
    }
    function Tick(float delta){
       Global.Tick(delta);

       // Don't move while we are bashing a door!
       moveTarget = none;
       moveTimer = -1;
       pawn.acceleration = vect(0,0,0);
       pawn.groundSpeed = 1;
       pawn.accelRate = 0;
    }
    function EndState(){
       if(NiceMonster(pawn) != none){
           pawn.accelRate = pawn.default.accelRate;
           pawn.groundSpeed = NiceMonster(pawn).GetOriginalGroundSpeed();
       }
    }
Begin:
    WaitForLanding();
KeepMoving:
    while(KFM.bShotAnim)
       Sleep(0.25);
    while(  TargetDoor != none && !TargetDoor.bHidden && TargetDoor.bSealed
           && !TargetDoor.bZombiesIgnore){
       AttackDoor();
       while(KFM.bShotAnim)
           Sleep(0.25);
       Sleep(0.1);
       if( KFM.intelligence >= BRAINS_Mammal && Enemy!=none
           && ActorReachable(Enemy) )
           WhatToDoNext(14);
    }
    WhatToDoNext(152);
Moving:
    MoveToward(TargetDoor);
    WhatToDoNext(17);
    if(bSoaking)
       SoakStop("STUCK IN CHARGING!");
}
state Freeze{
    Ignores SeePlayer,HearNoise,Timer,EnemyNotVisible,NotifyBump,Startle;
    // Don't do this in this state
    function GetOutOfTheWayOfShot(vector ShotDirection, vector ShotOrigin){}
    function BeginState(){
       bUseFreezeHack = false;
    }
    function Tick(float delta){
       Global.Tick(delta);
       if(bUseFreezeHack){
           moveTarget = none;
           moveTimer = -1;
           pawn.acceleration = vect(0,0,0);
           pawn.groundSpeed = 1;
           pawn.accelRate = 0;
       }
    }
    function EndState(){
       if(pawn != none){
           pawn.accelRate = pawn.default.AccelRate;
           pawn.groundSpeed = NiceMonster(pawn).GetOriginalGroundSpeed();
       }
       bUseFreezeHack = false;
       if(enemy == none)
           FindNewEnemy();
       if(choosingAttackLevel == 0)
           WhatToDoNext(99);
    }
}
state WaitForAnim{
Ignores SeePlayer,HearNoise,Timer,EnemyNotVisible,NotifyBump,Startle;
    // Don't do this in this state
    function GetOutOfTheWayOfShot(vector ShotDirection, vector ShotOrigin){}
    event AnimEnd(int Channel){
       pawn.AnimEnd(Channel);
       if ( !Monster(pawn).bShotAnim )
           WhatToDoNext(99);
    }
    function BeginState(){
       bUseFreezeHack = False;
    }
    function Tick( float Delta ){
       Global.Tick(Delta);
       if( bUseFreezeHack )
       {
           MoveTarget = none;
           MoveTimer = -1;
           pawn.acceleration = vect(0,0,0);
           pawn.groundSpeed = 1;
           pawn.accelRate = 0;
       }
    }
    function EndState(){
       if(NiceMonster(pawn) != none){
           pawn.accelRate = pawn.Default.AccelRate;
           pawn.groundSpeed = NiceMonster(pawn).GetOriginalGroundSpeed();
       }
       bUseFreezeHack = False;
    }
Begin:
    while(KFM.bShotAnim){
       Sleep(0.15);
    }
    WhatToDoNext(99);
}
function bool SetEnemy( pawn newEnemy,
                       optional bool bHateMonster,
                       optional float MonsterHateChanceOverride){
    local NiceMonster   niceZed;
    local bool          bCanForceFight;
    //  Can we fight anything?
    niceZed = NiceMonster(pawn);
    if(niceZed != none)
       bCanForceFight =
               KFMonster(pawn).HeadHealth <= 0
           ||  KFMonster(pawn).bDecapitated
           ||  newEnemy.Health <= 15;
    if(newEnemy != none)
       bCanForceFight = bCanForceFight
           && newEnemy.Health > 0 && newEnemy != enemy;
    else
       bCanForceFight = false;
    //  Do fight if we can
    if(bCanForceFight){
       ChangeEnemy(newEnemy, true);
       FightEnemy(false);
       return true;
    }
    //  Otherwise - do the usual stupid stuff
    return super.SetEnemy(newEnemy, bHateMonster, monsterHateChanceOverride);
}
simulated function AddKillAssistant(Controller PC, float damage){
    local bool bIsalreadyAssistant;
    local int i;
    if(PC == none) return;
    for(i = 0;i < KillAssistants.length;i ++)
       if(PC == KillAssistants[i].PC){
           bIsalreadyAssistant = true;
           KillAssistants[i].damage += damage;
           break;
       }
    if(!bIsalreadyAssistant){
       KillAssistants.Insert(0, 1);
       KillAssistants[0].PC = PC;
       KillAssistants[0].damage = damage;
    }
}
defaultproperties
{
}
