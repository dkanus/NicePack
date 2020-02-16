// Zombie Monster for KF Invasion gametype
class NiceZombieSick extends NiceZombieSickBase;
#exec OBJ LOAD FILE=KF_EnemiesFinalSnd.uax
#exec OBJ LOAD FILE=NicePackT.utx
//----------------------------------------------------------------------------
// NOTE: All Variables are declared in the base class to eliminate hitching
//----------------------------------------------------------------------------
var name SpitAnimation;
var transient float NextVomitTime;
function bool FlipOver(){
    return true;
}
// don't interrupt the bloat while he is puking
simulated function bool HitCanInterruptAction(){
    if(bShotAnim)       return false;
    return true;
}

function DoorAttack(Actor A)
{
    if ( bShotAnim || Physics == PHYS_Swimming)       return;
    else if ( A!=none )
    {       bShotAnim = true;       if( !bDecapitated && bDistanceAttackingDoor )       {           SetAnimAction('ZombieBarf');       }       else       {           SetAnimAction('DoorBash');           GotoState('DoorBashing');       }
    }
}
function RangedAttack(Actor A)
{
    local int LastFireTime;
    local float ChargeChance;
    if ( bShotAnim )       return;
    if ( Physics == PHYS_Swimming )
    {       SetAnimAction('Claw');       bShotAnim = true;       LastFireTime = Level.TimeSeconds;
    }
    else if ( VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
    {       bShotAnim = true;       LastFireTime = Level.TimeSeconds;       SetAnimAction('Claw');       //PlaySound(sound'Claw2s', SLOT_Interact); KFTODO: Replace this       Controller.bPreparingMove = true;       Acceleration = vect(0,0,0);
    }
    else if ( (KFDoorMover(A) != none || VSize(A.Location-Location) <= 250) && !bDecapitated )
    {       bShotAnim = true;
       // Decide what chance the bloat has of charging during a puke attack       if( Level.Game.GameDifficulty < 2.0 )       {           ChargeChance = 0.6;       }       else if( Level.Game.GameDifficulty < 4.0 )       {           ChargeChance = 0.8;       }       else if( Level.Game.GameDifficulty < 5.0 )       {           ChargeChance = 1.0;       }       else // Hardest difficulty       {           ChargeChance = 1.2;       }
       // Randomly do a moving attack so the player can't kite the zed       if( FRand() < ChargeChance )       {           SetAnimAction('ZombieBarfMoving');           RunAttackTimeout = GetAnimDuration('ZombieBarf', 0.5);           bMovingPukeAttack=true;       }       else       {           SetAnimAction('ZombieBarf');           Controller.bPreparingMove = true;           Acceleration = vect(0,0,0);       }
       // Randomly send out a message about Bloat Vomit burning(3% chance)       if ( FRand() < 0.03 && KFHumanPawn(A) != none && PlayerController(KFHumanPawn(A).Controller) != none )       {           PlayerController(KFHumanPawn(A).Controller).Speech('AUTO', 7, "");       }
    }
}
// Overridden to handle playing upper body only attacks when moving
simulated event SetAnimAction(name NewAction)
{
    local int meleeAnimIndex;
    local bool bWantsToAttackAndMove;
    if( NewAction=='' )       Return;
    bWantsToAttackAndMove = NewAction == 'ZombieBarfMoving';
    if( NewAction == 'Claw' )
    {       meleeAnimIndex = Rand(3);       NewAction = meleeAnims[meleeAnimIndex];
    }
    if( bWantsToAttackAndMove )
    {      ExpectingChannel = AttackAndMoveDoAnimAction(NewAction);
    }
    else
    {      ExpectingChannel = DoAnimAction(NewAction);
    }
    if( !bWantsToAttackAndMove && AnimNeedsWait(NewAction) )
    {       bWaitForAnim = true;
    }
    else
    {       bWaitForAnim = false;
    }
    if( Level.NetMode!=NM_Client )
    {       AnimAction = NewAction;       bResetAnimAct = True;       ResetAnimActTime = Level.TimeSeconds+0.2;
    }
}
// Handle playing the anim action on the upper body only if we're attacking and moving
simulated function int AttackAndMoveDoAnimAction( name AnimName )
{
    if( AnimName=='ZombieBarfMoving' )
    {       AnimBlendParams(1, 1.0, 0.0,, FireRootBone);       PlayAnim('ZombieBarf',, 0.1, 1);
       return 1;
    }
    return super.DoAnimAction( AnimName );
}
function PlayDyingSound()
{
    if( Level.NetMode!=NM_Client )
    {       if ( bGibbed )       {           PlaySound(sound'KF_EnemiesFinalSnd.Bloat_DeathPop', SLOT_Pain,2.0,true,525);           return;       }
       if( bDecapitated )       {           PlaySound(HeadlessDeathSound, SLOT_Pain,1.30,true,525);       }       else       {           PlaySound(sound'KF_EnemiesFinalSnd.Bloat_DeathPop', SLOT_Pain,2.0,true,525);       }
    }
}

// Barf Time.
function SpawnTwoShots()
{
    local vector X,Y,Z, FireStart;
    local rotator FireRotation;
    if( Controller!=none && KFDoorMover(Controller.Target)!=none )
    {       Controller.Target.TakeDamage(22,Self,Location,vect(0,0,0),Class'DamTypeVomit');       return;
    }
    GetAxes(Rotation,X,Y,Z);
    FireStart = Location+(vect(30,0,64) >> Rotation)*DrawScale;
    if ( !SavedFireProperties.bInitialized )
    {       SavedFireProperties.AmmoClass = Class'SkaarjAmmo';       SavedFireProperties.ProjectileClass = Class'NiceSickVomit';       SavedFireProperties.WarnTargetPct = 1;       SavedFireProperties.MaxRange = 600;       SavedFireProperties.bTossed = False;       SavedFireProperties.bTrySplash = False;       SavedFireProperties.bLeadTarget = True;       SavedFireProperties.bInstantHit = True;       SavedFireProperties.bInitialized = True;
    }
    // Turn off extra collision before spawning vomit, otherwise spawn fails
    ToggleAuxCollision(false);
    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
    Spawn(Class'NiceSickVomit',,,FireStart,FireRotation);
    FireStart-=(0.5*CollisionRadius*Y);
    FireRotation.Yaw -= 1200;
    spawn(Class'NiceSickVomit',,,FireStart, FireRotation);
    FireStart+=(CollisionRadius*Y);
    FireRotation.Yaw += 2400;
    spawn(Class'NiceSickVomit',,,FireStart, FireRotation);
    // Turn extra collision back on
    ToggleAuxCollision(true);
}


function BileBomb()
{
    BloatJet = spawn(class'BileJet', self,,Location,Rotator(-PhysicsVolume.Gravity));
}

State Dying
{
  function tick(float deltaTime)
  {
   if (BloatJet != none)
   {
    BloatJet.SetLocation(location);
    BloatJet.SetRotation(GetBoneRotation(FireRootBone));
   }
    super.tick(deltaTime);
  }
}
function RemoveHead()
{
    bCanDistanceAttackDoors = False;
    Super.RemoveHead();
}
static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
    myLevel.AddPrecacheMaterial(Texture'NicePackT.MonsterSick.Sick_diffuse');
    myLevel.AddPrecacheMaterial(Combiner'NicePackT.MonsterSick.Sick_env');
    myLevel.AddPrecacheMaterial(Combiner'NicePackT.MonsterSick.Sick_cmb');
}
defaultproperties
{    DetachedArmClass=Class'NicePack.NiceSeveredArmSick'    DetachedLegClass=Class'NicePack.NiceSeveredLegSick'    DetachedHeadClass=Class'NicePack.NiceSeveredHeadSick'    ControllerClass=Class'NicePack.NiceSickZombieController'
}
