class MeanZombieHusk extends NiceZombieHusk;
#exec OBJ LOAD FILE=NicePackT.utx
var int consecutiveShots, totalShots, maxNormalShots;
function DoStun(optional Pawn instigatedBy, optional Vector hitLocation, optional Vector momentum, optional class<NiceWeaponDamageType> damageType, optional float headshotLevel, optional KFPlayerReplicationInfo KFPRI){
    super.DoStun(instigatedBy, hitLocation, momentum, damageType, headshotLevel, KFPRI);
    totalShots = maxNormalShots;
}
function SpawnTwoShots() {
    local vector X,Y,Z, FireStart;
    local rotator FireRotation;
    local KFMonsterController KFMonstControl;
    if(Controller != none && KFDoorMover(Controller.Target) != none){       Controller.Target.TakeDamage(22, Self, Location, vect(0,0,0), Class'DamTypeVomit');       return;
    }
    GetAxes(Rotation,X,Y,Z);
    FireStart = GetBoneCoords('Barrel').Origin;
    if (!SavedFireProperties.bInitialized){       SavedFireProperties.AmmoClass = Class'SkaarjAmmo';       SavedFireProperties.ProjectileClass = HuskFireProjClass;       SavedFireProperties.WarnTargetPct = 1;       SavedFireProperties.MaxRange = 65535;       SavedFireProperties.bTossed = False;       SavedFireProperties.bTrySplash = true;       SavedFireProperties.bLeadTarget = True;       SavedFireProperties.bInstantHit = False;       SavedFireProperties.bInitialized = True;
    }
    // Turn off extra collision before spawning vomit, otherwise spawn fails
    ToggleAuxCollision(false);
    if(Controller != none)       FireRotation = Controller.AdjustAim(SavedFireProperties, FireStart, 600);
    foreach DynamicActors(class'KFMonsterController', KFMonstControl){       if(KFMonstControl != controller){           if(PointDistToLine(KFMonstControl.Pawn.Location, vector(FireRotation), FireStart) < 75){               KFMonstControl.GetOutOfTheWayOfShot(vector(FireRotation),FireStart);           }       }
    }
    Spawn(HuskFireProjClass, Self,, FireStart, FireRotation);
    // Turn extra collision back on
    ToggleAuxCollision(true);
}
function RangedAttack(Actor A) {
    local int LastFireTime;
    if ( bShotAnim )       return;
    if ( Physics == PHYS_Swimming ) {       SetAnimAction('Claw');       bShotAnim = true;       LastFireTime = Level.TimeSeconds;
    }
    else if ( VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius ) {       bShotAnim = true;       LastFireTime = Level.TimeSeconds;       SetAnimAction('Claw');       //PlaySound(sound'Claw2s', SLOT_Interact); KFTODO: Replace this       Controller.bPreparingMove = true;       Acceleration = vect(0,0,0);
    }
    else if((KFDoorMover(A) != none ||       (!Region.Zone.bDistanceFog && VSize(A.Location-Location) <= 65535) ||       (Region.Zone.bDistanceFog && VSizeSquared(A.Location-Location) < (Square(Region.Zone.DistanceFogEnd) * 0.8)))  // Make him come out of the fog a bit       && !bDecapitated ) {       bShotAnim = true;
       SetAnimAction('ShootBurns');       Controller.bPreparingMove = true;       Acceleration = vect(0,0,0);
       //Increment the number of consecutive shtos taken and apply the cool down if needed       totalShots ++;       consecutiveShots ++;       if(consecutiveShots < 3 && totalShots > maxNormalShots)           NextFireProjectileTime = Level.TimeSeconds;       else{           NextFireProjectileTime = Level.TimeSeconds + ProjectileFireInterval + (FRand() * 2.0);           consecutiveShots = 0;       }
    }
}
defaultproperties
{    maxNormalShots=3    HuskFireProjClass=Class'NicePack.MeanHuskFireProjectile'    remainingStuns=1    MenuName="Mean Husk"    ControllerClass=Class'NicePack.MeanZombieHuskController'    Skins(0)=Texture'NicePackT.MonsterMeanHusk.burns_tatters'    Skins(1)=Shader'NicePackT.MonsterMeanHusk.burns_shdr'
}
