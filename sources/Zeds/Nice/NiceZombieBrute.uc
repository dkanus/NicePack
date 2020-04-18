class NiceZombieBrute extends NiceZombieBruteBase;
var float BlockMeleeDmgMul;     //Multiplier for melee damage taken, when Brute is blocking (no matter where the hit was landed)
var float HeadShotgunDmgMul;    //Multiplier for shotgun damage taken into UNBLOCKED head
var float HeadBulletDmgMul;    //Multiplier for non-sniper bullet damage taken into UNBLOCKED head
simulated function PostNetBeginPlay()
{
    super.PostNetBeginPlay();
    EnableChannelNotify(1,1);
    EnableChannelNotify(2,1);
    AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
    StartCharging();
}
function ServerRaiseBlock()
{
    bServerBlock = true;
    SetAnimAction('BlockLoop');
}
function ServerLowerBlock()
{
    local name Sequence;
    local float Frame, Rate;
    bServerBlock = false;
    GetAnimParams(1, Sequence, Frame, Rate);
    if (Sequence == 'BlockLoop')
       AnimStopLooping(1);
}
simulated function PostNetReceive()
{
    local name Sequence;
    local float Frame, Rate;
    if(bClientCharge != bChargingPlayer)
    {
       bClientCharge = bChargingPlayer;
       if (bChargingPlayer)
       {
           MovementAnims[0] = ChargingAnim;
           MeleeAnims[0] = 'BruteRageAttack';
           MeleeAnims[1] = 'BruteRageAttack';
           MeleeAnims[2] = 'BruteRageAttack';
       }
       else
       {
           MovementAnims[0] = default.MovementAnims[0];
           MeleeAnims[0] = default.MeleeAnims[0];
           MeleeAnims[1] = default.MeleeAnims[1];
           MeleeAnims[2] = default.MeleeAnims[2];
       }
    }
    if (bClientBlock != bServerBlock)
    {
       bClientBlock = bServerBlock;
       if (bClientBlock)
           SetAnimAction('BlockLoop');
       else
       {
           GetAnimParams(1, Sequence, Frame, Rate);
           if (Sequence == 'BlockLoop')
               AnimStopLooping(1);
       }
    }
}
simulated function Tick(float DeltaTime)
{
    super.Tick(DeltaTime);
    if (Role == ROLE_Authority)
    {
       // Lock to target when attacking (except on beginner!)
       if (bShotAnim && LookTarget != none)
           Acceleration = AccelRate * Normal(LookTarget.Location - Location);
       // Block according to rules
       if (Role == ROLE_Authority && !bServerBlock && !bShotAnim)
           if (Controller != none && Controller.Target != none)
               ServerRaiseBlock();
    }
}
// Override to always move when attacking
function RangedAttack(Actor A){
    if (bShotAnim || Physics == PHYS_Swimming)
       return;
    else if (CanAttack(A))
    {
       if (bChargingPlayer)
           SetAnimAction('AoeClaw');
       else
       {
           if (Rand(BlockHitsLanded) < 1)
               SetAnimAction('BlockClaw');
           else
               SetAnimAction('Claw');
       }
       bShotAnim = true;
       return;
    }
}
function bool IsHeadShot(vector Loc, vector Ray, float AdditionalScale)
{
    local float D;
    local float AddScale;
    local bool bIsBlocking;
    bBlockedHS = false;
    if (bServerBlock && !IsTweening(1))
    {
       bIsBlocking = true;
       AddScale = AdditionalScale + BlockAddScale;
    }
    else
       AddScale = AdditionalScale + 1.0;
    if (Super.IsHeadShot(Loc, Ray, AddScale))
    {
       if (bIsBlocking)
       {
           D = vector(Rotation) dot Ray;
           if (-D > 0.20) {
               bBlockedHS = true;
               return false;
           }
           else
               return true;
       }
       else
           return true;
    }
    else
       return false;
}
function bool CheckMiniFlinch(  int flinchScore,
                               Pawn instigatedBy,
                               Vector hitLocation,
                               Vector momentum,
                               class<NiceWeaponDamageType> damageType,
                               float headshotLevel,
                               KFPlayerReplicationInfo KFPRI){
    return false;
}
function TakeDamageClient(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, float lockonTime){
    local float D;
    local bool bIsHeadshot;
    local bool bIsBlocking;
    bBlockedHS = false;
    if(bServerBlock && !IsTweening(1))
       bIsBlocking = true;
    if(headshotLevel > 0.0 && bIsBlocking){
       D = vector(Rotation) dot Normal(Momentum);
       D *= -1;
       if(D > 0.30) {
           bBlockedHS = true;
           headshotLevel = 0.0;
       }
    }
    bIsHeadShot = (headshotLevel > 0.0);
    // damage, which doen't make headshots, always does full damage to Brute -- PooSH
    if (damageType != none && damageType.default.bCheckForHeadShots) {
       if (!bIsHeadShot && bBlockedHS)
       {
           if(damageType != none || damageType.default.bIsProjectile)
               PlaySound(class'MetalHitEmitter'.default.ImpactSounds[rand(3)],, 128);
           else if(class<NiceDamageTypeVetBerserker>(damageType) != none)
               PlaySound(Sound'KF_KnifeSnd.Knife_HitMetal',, 128);
           if(damageType.default.bDealBurningDamage && !damageType.default.bIsPowerWeapon)
               Damage *= BlockFireDmgMul; // Fire damage isn't reduced as much, excluding TrenchGun
           else
               Damage *= BlockDmgMul; // Greatly reduce damage as we only hit the metal plating
       }
       else if(bServerBlock && class<NiceDamageTypeVetBerserker>(damageType) != none)
           Damage *= BlockMeleeDmgMul; // Give Brute higher melee damage resistance, but apply it only if Brute is blocking
       else if(bIsHeadShot){
           if (damageType.default.bIsPowerWeapon)
               Damage *= HeadShotgunDmgMul; // Give Brute's head resistance to stotguns
       }
    }
    // Record damage over 2-second frames
    if (LastDamagedTime < Level.TimeSeconds)
    {
       TwoSecondDamageTotal = 0;
       LastDamagedTime = Level.TimeSeconds + 2;
    }
    TwoSecondDamageTotal += Damage;
    // If criteria is met make him rage
    if (!bDecapitated && !bChargingPlayer && TwoSecondDamageTotal > RageDamageThreshold)
       StartCharging();
    Super(NiceMonster).TakeDamageClient(Damage, instigatedBy, hitLocation, momentum, damageType, headshotLevel, lockonTime);
    if (bDecapitated)
       Died(InstigatedBy.Controller, damageType, HitLocation);
}
function TakeFireDamage(int Damage, Pawn Instigator)
{
    Super.TakeFireDamage(Damage, Instigator);
    // Adjust movement speed if not charging
    if (!bChargingPlayer)
    {
       if (bBurnified)
           GroundSpeed = GetOriginalGroundSpeed() * BurnGroundSpeedMul;
       else
           GroundSpeed = GetOriginalGroundSpeed();
    }
}
function ClawDamageTarget()
{
    local KFHumanPawn HumanTarget;
    local float UsedMeleeDamage;
    local Actor OldTarget;
    local name Sequence;
    local float Frame, Rate;
    local bool bHitSomeone;
    if (MeleeDamage > 1)
       UsedMeleeDamage = (MeleeDamage - (MeleeDamage * 0.05)) + (MeleeDamage * (FRand() * 0.1));
    else
       UsedMeleeDamage = MeleeDamage;
       GetAnimParams(1, Sequence, Frame, Rate);
    if (Controller != none && Controller.Target != none)
    {
       if (Sequence == 'BruteRageAttack')
       {
           OldTarget = Controller.Target;
           foreach VisibleCollidingActors(class'KFHumanPawn', HumanTarget, MeleeRange + class'KFHumanPawn'.default.CollisionRadius)
           {
               bHitSomeone = ClawDamageSingleTarget(UsedMeleeDamage, HumanTarget);
           }
           Controller.Target = OldTarget;
           if (bHitSomeone)
               BlockHitsLanded++;
       }
       else if (Sequence != 'BruteAttack1' && Sequence != 'BruteAttack2' && Sequence != 'DoorBash') // Block attack
       {
           bHitSomeone = ClawDamageSingleTarget(UsedMeleeDamage, Controller.Target);
           if (bHitSomeone)
               BlockHitsLanded++;
       }
       else
           bHitSomeone = ClawDamageSingleTarget(UsedMeleeDamage, Controller.Target);
               if (bHitSomeone)
           PlaySound(MeleeAttackHitSound, SLOT_Interact, 1.25);
    }
}
function bool ClawDamageSingleTarget(float UsedMeleeDamage, Actor ThisTarget)
{
    local Pawn HumanTarget;
    local KFPlayerController HumanTargetController;
    local bool bHitSomeone;
    local float EnemyAngle;
    local vector PushForceVar;
    EnemyAngle = Normal(ThisTarget.Location - Location) dot vector(Rotation);
    if (EnemyAngle > 0)
    {
       Controller.Target = ThisTarget;
       if (MeleeDamageTarget(UsedMeleeDamage, vect(0, 0, 0)))
       {
           HumanTarget = KFHumanPawn(ThisTarget);
           if (HumanTarget != none)
           {
               EnemyAngle = (EnemyAngle * 0.5) + 0.5; // Players at sides get knocked back half as much
               PushForceVar = (PushForce * Normal(HumanTarget.Location - Location) * EnemyAngle) + PushAdd;
               if (!bChargingPlayer)
                   PushForceVar *= 0.85;
                       // (!) I'm sure the VeterancyName string is localized but I'm not sure of another way compatible with ServerPerks
               if (KFPlayerReplicationInfo(HumanTarget.Controller.PlayerReplicationInfo).ClientVeteranSkill != none)
                   if (KFPlayerReplicationInfo(HumanTarget.Controller.PlayerReplicationInfo).ClientVeteranSkill
                       .default.VeterancyName == "Berserker")
                           PushForceVar *= 0.75;
                               if (!(HumanTarget.Physics == PHYS_WALKING || HumanTarget.Physics == PHYS_none))
                   PushForceVar *= vect(1, 1, 0); // (!) Don't throw upwards if we are not on the ground - adjust for more flexibility

               HumanTarget.AddVelocity(PushForceVar);

               HumanTargetController = KFPlayerController(HumanTarget.Controller);
               if (HumanTargetController != none)
                   HumanTargetController.ShakeView(ShakeViewRotMag, ShakeViewRotRate, ShakeViewRotTime, 
                       ShakeViewOffsetMag, ShakeViewOffsetRate, ShakeViewOffsetTime);
                           bHitSomeone = true;
           }
       }
    }
    return bHitSomeone;
}
function StartCharging()
{
    // How many times should we hit before we cool down?
    if (Level.Game.NumPlayers <= 3)
       MaxRageCounter = 2;
    else
       MaxRageCounter = 3;
    RageCounter = MaxRageCounter;
    PlaySound(RageSound, SLOT_Talk, 255);
    GotoState('RageCharging');
}
state RageCharging
{
Ignores StartCharging;
    function bool CanGetOutOfWay()
    {
       return false;
    }
    function bool CanSpeedAdjust()
    {
       return false;
    }
    function BeginState()
    {
       bFrustrated = false;
       bChargingPlayer = true;
       RageSpeedTween = 0.0;
       if (Level.NetMode != NM_DedicatedServer)
           ClientChargingAnims();

       NetUpdateTime = Level.TimeSeconds - 1;
    }
    function EndState()
    {
       bChargingPlayer = false;

       NiceZombieBruteController(Controller).RageFrustrationTimer = 0;

       if (Health > 0)
       {
           GroundSpeed = GetOriginalGroundSpeed();
           if (bBurnified)
               GroundSpeed *= BurnGroundSpeedMul;
       }

       if( Level.NetMode!=NM_DedicatedServer )
           ClientChargingAnims();

       NetUpdateTime = Level.TimeSeconds - 1;
    }
    function Tick(float Delta)
    {
       if (!bShotAnim)
       {
           RageSpeedTween = FClamp(RageSpeedTween + (Delta * 0.75), 0, 1.0);
           GroundSpeed = OriginalGroundSpeed + ((OriginalGroundSpeed * 0.75 / MaxRageCounter * (RageCounter + 1) * RageSpeedTween));
           if (bBurnified)
               GroundSpeed *= BurnGroundSpeedMul;
       }

       Global.Tick(Delta);
    }
    function bool MeleeDamageTarget(int HitDamage, vector PushDir)
    {
       local bool DamDone, bWasEnemy;

       bWasEnemy = (Controller.Target == Controller.Enemy);

       DamDone = Super.MeleeDamageTarget(HitDamage * RageDamageMul, vect(0, 0, 0));
       if(Controller == none)
           return true;

       if (bWasEnemy && DamDone)
       {
           //ChangeTarget();
           CalmDown();
       }

       return DamDone;
    }
    function CalmDown()
    {
       RageCounter = FClamp(RageCounter - 1, 0, MaxRageCounter);
       if (RageCounter == 0)
           GotoState('');
    }
    function ChangeTarget()
    {
       local Controller C;
       local Pawn BestPawn;
       local float Dist, BestDist;
           for (C = Level.ControllerList; C != none; C = C.NextController)
           if (C.Pawn != none && KFHumanPawn(C.Pawn) != none)
           {
               Dist = VSize(C.Pawn.Location - Location);
               if (C.Pawn == Controller.Target)
                   Dist += GroundSpeed * 4;
                           if (BestPawn == none)
               {
                   BestPawn = C.Pawn;
                   BestDist = Dist;
               }
               else if (Dist < BestDist)
               {
                   BestPawn = C.Pawn;
                   BestDist = Dist;
               }
           }
           if (BestPawn != none && BestPawn != Controller.Enemy)
           MonsterController(Controller).ChangeEnemy(BestPawn, Controller.CanSee(BestPawn));
    }
}
// Override to prevent stunning
function bool FlipOver()
{
    return true;
}
// Shouldn't fight with our own
function bool SameSpeciesAs(Pawn P)
{
    return (NiceZombieBrute(P) != none);
}
// ------------------------------------------------------
// Animation --------------------------------------------
// ------------------------------------------------------
// Overridden to handle playing upper body only attacks when moving
simulated event SetAnimAction(name NewAction)
{
    if (NewAction=='')
       return;
    if (NewAction == 'Claw')
    {
       NewAction = MeleeAnims[rand(2)];
    }
    else if (NewAction == 'BlockClaw')
    {
       NewAction = 'BruteBlockSlam';
    }
    else if (NewAction == 'AoeClaw')
    {
       NewAction = 'BruteRageAttack';
    }
    ExpectingChannel = DoAnimAction(NewAction);
    if (AnimNeedsWait(NewAction))
       bWaitForAnim = true;
    else
       bWaitForAnim = false;
    if (Level.NetMode != NM_Client)
    {
       AnimAction = NewAction;
       bResetAnimAct = True;
       ResetAnimActTime = Level.TimeSeconds+0.3;
    }
}
simulated function int DoAnimAction( name AnimName )
{
    if (AnimName=='BruteAttack1' || AnimName=='BruteAttack2' || AnimName=='ZombieFireGun' || AnimName == 'DoorBash')
    {
       if (Role == ROLE_Authority)
           ServerLowerBlock();
       AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
       PlayAnim(AnimName,, 0.1, 1);
       return 1;
    }
    else if (AnimName == 'BruteRageAttack')
    {
       if (Role == ROLE_Authority)
           ServerLowerBlock();
       AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
       PlayAnim(AnimName,, 0.1, 1);
       return 1;
    }
    else if (AnimName == 'BlockLoop')
    {
       AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
       LoopAnim(AnimName,, 0.25, 1);
       return 1;
    }
    else if (AnimName == 'BruteBlockSlam')
    {
       AnimBlendParams(2, 1.0, 0.0,, FireRootBone);
       PlayAnim(AnimName,, 0.1, 2);
       return 2;
    }
    return Super.DoAnimAction(AnimName);
}
// The animation is full body and should set the bWaitForAnim flag
simulated function bool AnimNeedsWait(name TestAnim)
{
    if (TestAnim == 'DoorBash')
       return true;
    return false;
}
simulated function AnimEnd(int Channel)
{
    local name Sequence;
    local float Frame, Rate;
    GetAnimParams(Channel, Sequence, Frame, Rate);
    // Don't allow notification for a looping animation
    if (Sequence == 'BlockLoop')
       return;
    // Disable channel 2 when we're done with it
    if (Channel == 2 && Sequence == 'BruteBlockSlam')
    {
       AnimBlendParams(2, 0);
       bShotAnim = false;
       return;
    }
    Super.AnimEnd(Channel);
}
simulated function ClientChargingAnims()
{
    PostNetReceive();
}
function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, optional int HitIdx)
{
    local Actor A;
    if (bBlockedHS)
       A = Spawn(class'NiceBlockHitEmitter', InstigatedBy,, HitLocation, rotator(Normal(HitLocation - Location)));
    else
       Super.PlayHit(Damage, InstigatedBy, HitLocation, damageType, Momentum, HitIdx);
}
defaultproperties
{
    BlockMeleeDmgMul=1.000000
    HeadShotgunDmgMul=1.000000
    HeadBulletDmgMul=1.000000
    stunLoopStart=0.130000
    stunLoopEnd=0.650000
    idleInsertFrame=0.950000
    DetachedArmClass=Class'ScrnZedPack.SeveredArmBrute'
    DetachedLegClass=Class'ScrnZedPack.SeveredLegBrute'
    DetachedHeadClass=Class'ScrnZedPack.SeveredHeadBrute'
    ControllerClass=Class'NicePack.NiceZombieBruteController'
}
