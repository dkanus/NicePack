// Different naming scheme 'cause kf-scrntestingrounds has a stupid restriction on what zeds can be used in it's spawns
class NiceZombieShiver extends NiceZombieShiverBase;
var float TeleportBlockTime;
var float HeadOffsetY;
var transient bool bRunning, bClientRunning;
replication
{
    reliable if ( Role == ROLE_Authority)
       bRunning;
}
simulated function PostNetReceive()
{
    super.PostNetReceive();
    if( bClientRunning != bRunning )
    {
       bClientRunning = bRunning;
       if( bRunning ) {
           MovementAnims[0] = RunAnim;
       }
       else {
           MovementAnims[0] = WalkAnim;
       }
    }
}
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    if (Level.NetMode != NM_DedicatedServer)
    {
       MatAlphaSkin = ColorModifier(Level.ObjectPool.AllocateObject(class'ColorModifier'));
       if (MatAlphaSkin != none)
       {
           MatAlphaSkin.Color = class'Canvas'.static.MakeColor(255, 255, 255, 255);
           MatAlphaSkin.RenderTwoSided = false;
           MatAlphaSkin.AlphaBlend = true;
           MatAlphaSkin.Material = Skins[0];
           Skins[0] = MatAlphaSkin;
       }
    }
}
simulated function Destroyed()
{
    if (Level.NetMode != NM_DedicatedServer && MatAlphaSkin != none)
    {
       Skins[0] = default.Skins[0];
       Level.ObjectPool.FreeObject(MatAlphaSkin);
    }
    Super.Destroyed();
}
// Overridden to add HeadOffsetY
function bool IsHeadShot(vector loc, vector ray, float AdditionalScale)
{
    local coords C;
    local vector HeadLoc, B, M, diff;
    local float t, DotMM, Distance;
    local int look;
    local bool bUseAltHeadShotLocation;
    local bool bWasAnimating;
    if (HeadBone == '')
       return False;
    // If we are a dedicated server estimate what animation is most likely playing on the client
    if (Level.NetMode == NM_DedicatedServer)
    {
       if (Physics == PHYS_Falling)
           PlayAnim(AirAnims[0], 1.0, 0.0);
       else if (Physics == PHYS_Walking)
       {
           // Only play the idle anim if we're not already doing a different anim.
           // This prevents anims getting interrupted on the server and borking things up - Ramm

           if( !IsAnimating(0) && !IsAnimating(1) )
           {
               if (bIsCrouched)
               {
                   PlayAnim(IdleCrouchAnim, 1.0, 0.0);
               }
               else
               {
                   bUseAltHeadShotLocation=true;
               }
           }
           else
           {
               bWasAnimating = true;
           }

           if ( bDoTorsoTwist )
           {
               SmoothViewYaw = Rotation.Yaw;
               SmoothViewPitch = ViewPitch;

               look = (256 * ViewPitch) & 65535;
               if (look > 32768)
                   look -= 65536;

               SetTwistLook(0, look);
           }
       }
       else if (Physics == PHYS_Swimming)
           PlayAnim(SwimAnims[0], 1.0, 0.0);

       if( !bWasAnimating )
       {
           SetAnimFrame(0.5);
       }
    }
    if( bUseAltHeadShotLocation )
    {
       HeadLoc = Location + (OnlineHeadshotOffset >> Rotation);
       AdditionalScale *= OnlineHeadshotScale;
    }
    else
    {
       C = GetBoneCoords(HeadBone);

       HeadLoc = C.Origin + (HeadHeight * HeadScale * AdditionalScale * C.XAxis)
           + HeadOffsetY * C.YAxis;
    }
    //ServerHeadLocation = HeadLoc;
    // Express snipe trace line in terms of B + tM
    B = loc;
    M = ray * (2.0 * CollisionHeight + 2.0 * CollisionRadius);
    // Find Point-Line Squared Distance
    diff = HeadLoc - B;
    t = M Dot diff;
    if (t > 0)
    {
       DotMM = M dot M;
       if (t < DotMM)
       {
           t = t / DotMM;
           diff = diff - (t * M);
       }
       else
       {
           t = 1;
           diff -= M;
       }
    }
    else
       t = 0;
    Distance = Sqrt(diff Dot diff);
    return (Distance < (HeadRadius * HeadScale * AdditionalScale));
}
function bool FlipOver() 
{
    if ( super.FlipOver() ) {
       TeleportBlockTime = Level.TimeSeconds + 3.0; // can't teleport during stun
       // do not rotate while stunned
       Controller.Focus = none; 
       Controller.FocalPoint = Location + 512*vector(Rotation);
    }
    return false;
}
simulated function StopBurnFX()
{
    if (bBurnApplied)
    {
       MatAlphaSkin.Material = Texture'PatchTex.Common.ZedBurnSkin';
       Skins[0] = MatAlphaSkin;
    }
    Super.StopBurnFX();
}
function RangedAttack(Actor A)
{
    if (bShotAnim || Physics == PHYS_Swimming)
       return;
    else if (CanAttack(A))
    {
       bShotAnim = true;
       SetAnimAction('Claw');
       return;
    }
}
state Running
{
    function Tick(float Delta)
    {
       Global.Tick(Delta);
       if (RunUntilTime < Level.TimeSeconds)
           GotoState('');
       GroundSpeed = GetOriginalGroundSpeed();
    }
    function BeginState()
    {
       bRunning = true;
       RunUntilTime = Level.TimeSeconds + PeriodRunBase + FRand() * PeriodRunRan;
       MovementAnims[0] = RunAnim;
    }
    function EndState()
    {
       bRunning = false;
       GroundSpeed = global.GetOriginalGroundSpeed();
       RunCooldownEnd = Level.TimeSeconds + PeriodRunCoolBase + FRand() * PeriodRunCoolRan;
       MovementAnims[0] = WalkAnim;
    }
    function float GetOriginalGroundSpeed() 
    {
       return global.GetOriginalGroundSpeed() * 2.5;
    }
    function bool CanSpeedAdjust()
    {
       return false;
    }
}
/*function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamType, optional int HitIndex)
{
    if (InstigatedBy == none || class<KFWeaponDamageType>(DamType) == none)
       Super(Monster).TakeDamage(Damage, instigatedBy, hitLocation, momentum, DamType); // skip none-reference error
    else 
       Super(KFMonster).TakeDamage(Damage, instigatedBy, hitLocation, momentum, DamType);
}*/
// returns true also for KnockDown (stun) animation -- PooSH
simulated function bool AnimNeedsWait(name TestAnim)
{
    if( TestAnim == 'DoorBash' || TestAnim == 'KnockDown' )
    {
       return true;
    }
    return ExpectingChannel == 0;
}
simulated function float GetOriginalGroundSpeed()
{
    local float result;
    result = OriginalGroundSpeed;
    if( bZedUnderControl )
       result *= 1.25;
       return result;
}
simulated function HandleAnimation(float Delta)
{
    // hehehe
}
simulated function Tick(float Delta)
{
    Super.Tick(Delta);
    if (Health > 0 && !bBurnApplied)
    {
       if (Level.NetMode != NM_DedicatedServer)
           HandleAnimation(Delta);
           // Handle targetting
       if (Level.NetMode != NM_Client && !bDecapitated)
       {
           if (Controller == none || Controller.Target == none || !Controller.LineOfSightTo(Controller.Target))
           {
               if (bCanSeeTarget)                    bCanSeeTarget = false;
           }
           else
           {
               if (!bCanSeeTarget)
               {
                   bCanSeeTarget = true;
                   SeeTargetTime = Level.TimeSeconds;
               }
               else if (Level.TimeSeconds > SeeTargetTime + PeriodSeeTarget)
               {
                   if (VSize(Controller.Target.Location - Location) < MaxTeleportDist)
                   {
                       if (VSize(Controller.Target.Location - Location) > MinTeleportDist || !Controller.ActorReachable(Controller.Target))
                       {
                           if (CanTeleport())
                               StartTelePort();
                       }
                       else
                       {
                           if (CanRun())
                               GotoState('Running');
                       }
                   }
               }
           }
       }
    }
    // Handle client-side teleport variables
    if (!bBurnApplied)
    {
       if (Level.NetMode != NM_DedicatedServer && OldFadeStage != FadeStage)
       {
           OldFadeStage = FadeStage;
                   if (FadeStage == 2)
               AlphaFader = 0;
           else
               AlphaFader = 255;
       }
           // Handle teleporting
       if (FadeStage == 1) // Fade out (pre-teleport)
       {
           AlphaFader = FMax(AlphaFader - Delta * 512, 0);

           if (Level.NetMode != NM_Client && AlphaFader == 0)
           {
               SetCollision(true, true);
               FlashTeleport();
               SetCollision(false, false);
               FadeStage = 2;
           }
       }
       else if (FadeStage == 2) // Fade in (post-teleport)
       {
           AlphaFader = FMin(AlphaFader + Delta * 512, 255);
                   if (Level.NetMode != NM_Client && AlphaFader == 255)
           {
               FadeStage = 0;
               SetCollision(true, true);
               GotoState('Running');
           }
       }

       if (Level.NetMode != NM_DedicatedServer && ColorModifier(Skins[0]) != none)
           ColorModifier(Skins[0]).Color.A = AlphaFader;
    }
}
//can't teleport if set on fire
function bool CanTeleport()
{
    if (HeadHealth <= 0) return false;
    return !bFlashTeleporting && !bOnFire && Physics == PHYS_Walking && Level.TimeSeconds > TeleportBlockTime 
       && LastFlashTime + 7.5 < Level.TimeSeconds && !bIsStunned;
}
function bool CanRun()
{
    local float distanceToTargetSquared;
    if(controller == none) return false;
    if(controller.focus != none){
       distanceToTargetSquared = VSize(controller.focus.location - location);
       if(distanceToTargetSquared > 900 * 2500)    //  (30 * 50)^2 / 30 meters
           return false;
    }
    return (!bFlashTeleporting && !IsInState('Running') && RunCooldownEnd < Level.TimeSeconds);
}
function StartTeleport()
{
    FadeStage = 1;
    AlphaFader = 255;
    SetCollision(false, false);
    bFlashTeleporting = true;
}
function FlashTeleport()
{
    local Actor Target;
    local vector OldLoc;
    local vector NewLoc;
    local vector HitLoc;
    local vector HitNorm;
    local rotator RotOld;
    local rotator RotNew;
    local float LandTargetDist;
    local int iEndAngle;
    local int iAttempts;
    if (Controller == none || Controller.Target == none)
       return;
    Target = Controller.Target;
    RotOld = rotator(Target.Location - Location);
    RotNew = RotOld;
    OldLoc = Location;
    for (iEndAngle = 0; iEndAngle < MaxTeleportAngles; iEndAngle++)
    {
       RotNew = RotOld;
       RotNew.Yaw += iEndAngle * (65536 / MaxTelePortAngles);
           for (iAttempts = 0; iAttempts < MaxTeleportAttempts; iAttempts++)
       {
           LandTargetDist = Target.CollisionRadius + CollisionRadius +
               MinLandDist + (MaxLandDist - MinLandDist) * (iAttempts / (MaxTeleportAttempts - 1.0));

           NewLoc = Target.Location - vector(RotNew) * LandTargetDist; // Target.Location - Location
           NewLoc.Z = Target.Location.Z;

           if (Trace(HitLoc, HitNorm, NewLoc + vect(0, 0, -500), NewLoc) != none)
               NewLoc.Z = HitLoc.Z + CollisionHeight;

           // Try a new location
           if (SetLocation(NewLoc))
           {
               SetPhysics(PHYS_Walking);
                           if (Controller.PointReachable(Target.Location))
               {
                   Velocity = vect(0, 0, 0);
                   Acceleration = vect(0, 0, 0);
                   SetRotation(rotator(Target.Location - Location));
                                   PlaySound(Sound'ScrnZedPack_S.Shiver.ShiverWarpGroup', SLOT_Interact, 4.0);
                   Controller.GotoState('');
                   MonsterController(Controller).WhatToDoNext(0);
                   goto Teleported;
               }
           }
                   // Reset location
           SetLocation(OldLoc);
       }
    }
Teleported:
    bFlashTeleporting = false;
    LastFlashTime = Level.TimeSeconds;
}
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    // (!)
    Super.Died(Killer, damageType, HitLocation);
}
function RemoveHead()
{
    local class<KFWeaponDamageType> KFDamType;
    KFDamType = class<KFWeaponDamageType>(LastDamagedByType);
    if ( KFDamType != none && !KFDamType.default.bIsPowerWeapon  
           && !KFDamType.default.bSniperWeapon && !KFDamType.default.bIsMeleeDamage
           && !KFDamType.default.bIsExplosive && !KFDamType.default.bDealBurningDamage 
           && !ClassIsChildOf(KFDamType, class'DamTypeDualies')
           && !ClassIsChildOf(KFDamType, class'DamTypeMK23Pistol')
           && !ClassIsChildOf(KFDamType, class'DamTypeMagnum44Pistol') )
    {
       LastDamageAmount *= 3.5; //significantly raise decapitation bonus for Assault Rifles

       //award shiver kill on decap for Commandos
       if ( KFPawn(LastDamagedBy)!=none && KFPlayerController(LastDamagedBy.Controller) != none 
               && KFSteamStatsAndAchievements(KFPlayerController(LastDamagedBy.Controller).SteamStatsAndAchievements) != none )
       {
           KFDamType.Static.AwardKill(
               KFSteamStatsAndAchievements(KFPlayerController(LastDamagedBy.Controller).SteamStatsAndAchievements),
               KFPlayerController(LastDamagedBy.Controller), self);
       }
    }
    if (IsInState('Running'))
       GotoState('');
    Super(NiceMonster).RemoveHead();
}
function bool CheckMiniFlinch(int flinchScore, Pawn instigatedBy, Vector hitLocation, Vector momentum, class<NiceWeaponDamageType> damageType, float headshotLevel, KFPlayerReplicationInfo KFPRI){
    if(IsInState('Running'))
       return false;
    return super.CheckMiniFlinch(flinchScore, instigatedBy, hitLocation, momentum, damageType, headshotLevel, KFPRI);
}
simulated function int DoAnimAction( name AnimName )
{
    if (AnimName=='Claw' || AnimName=='Claw2' || AnimName=='Claw3')
    {
       AnimBlendParams(1, 1.0, 0.1,, FireRootBone);
       PlayAnim(AnimName,, 0.1, 1);
       return 1;
    }
    return Super.DoAnimAction(AnimName);
}
defaultproperties
{
    HeadOffsetY=-3.000000
    idleInsertFrame=0.468000
    PlayerCountHealthScale=0.200000
    OnlineHeadshotOffset=(X=19.000000,Z=39.000000)
    ScoringValue=15
    HealthMax=300.000000
    Health=300
    HeadRadius=8.000000
    HeadHeight=3.000000
}
