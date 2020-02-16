// The Nice, nasty barf we'll be using for the Bloat's ranged attack.
class NiceSickVomit extends BioGlob;
simulated function PostBeginPlay()
{
    SetOwner(none);
    if (Role == ROLE_Authority)
    {       Velocity = Vector(Rotation) * Speed;       Velocity.Z += TossZ;
    }
    if (Role == ROLE_Authority)       Rand3 = Rand(3);
    if ( (Level.NetMode != NM_DedicatedServer) && ((Level.DetailMode == DM_Low) || Level.bDropDetail) )
    {       bDynamicLight = false;       LightType = LT_none;
    }
    // Difficulty Scaling
    if (Level.Game != none)
    {       BaseDamage = Max((DifficultyDamageModifer() * BaseDamage),1);       Damage = Max((DifficultyDamageModifer() * Damage),1);
    }
}
// Scales the damage this Zed deals by the difficulty level
function float DifficultyDamageModifer()
{
    local float AdjustedDamageModifier;
    if(Level.Game.GameDifficulty >= 5.0) // Hell on Earth & Suicidal       damage = default.damage * 2.5;
    else       damage = default.damage * 1.5;
    return AdjustedDamageModifier;
}
state OnGround
{
    simulated function BeginState()
    {       SetTimer(RestTime, false);       BlowUp(Location);
    }
    simulated function Timer()
    {       if (bDrip)       {           bDrip = false;           SetCollisionSize(default.CollisionHeight, default.CollisionRadius);           Velocity = PhysicsVolume.Gravity * 0.2;           SetPhysics(PHYS_Falling);           bCollideWorld = true;           bCheckedsurface = false;           bProjTarget = false;           GotoState('Flying');       }       else BlowUp(Location);
    }
    simulated function ProcessTouch(Actor Other, Vector HitLocation)
    {       if ( Other != none )           BlowUp(Location);
    }
    function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
    {       if (DamageType.default.bDetonatesGoop)       {           bDrip = false;           SetTimer(0.1, false);       }
    }
    simulated function AnimEnd(int Channel)
    {       local float DotProduct;
       if (!bCheckedSurface)       {           DotProduct = SurfaceNormal dot Vect(0,0,-1);           if (DotProduct > 0.7)           {               bDrip = true;               SetTimer(DripTime, false);               if (bOnMover)                   BlowUp(Location);           }           else if (DotProduct > -0.5)           {               if (bOnMover)                   BlowUp(Location);           }           bCheckedSurface = true;       }
    }
    simulated function MergeWithGlob(int AdditionalGoopLevel)
    {       local int NewGoopLevel, ExtraSplash;       NewGoopLevel = AdditionalGoopLevel + GoopLevel;       if (NewGoopLevel > MaxGoopLevel)       {           Rand3 = (Rand3 + 1) % 3;           ExtraSplash = Rand3;           if (Role == ROLE_Authority)               SplashGlobs(NewGoopLevel - MaxGoopLevel + ExtraSplash);           NewGoopLevel = MaxGoopLevel - ExtraSplash;       }       SetGoopLevel(NewGoopLevel);       SetCollisionSize(GoopVolume*10.0, GoopVolume*10.0);       PlaySound(ImpactSound, SLOT_Misc);       bCheckedSurface = false;       SetTimer(RestTime, false);
    }
}
singular function SplashGlobs(int NumGloblings)
{
    local int g;
    local NiceSickVomit NewGlob;
    local Vector VNorm;
    for (g=0; g<NumGloblings; g++)
    {       NewGlob = Spawn(Class, self,, Location+GoopVolume*(CollisionHeight+4.0)*SurfaceNormal);       if (NewGlob != none)       {           NewGlob.Velocity = (GloblingSpeed + FRand()*150.0) * (SurfaceNormal + VRand()*0.8);           if (Physics == PHYS_Falling)           {               VNorm = (Velocity dot SurfaceNormal) * SurfaceNormal;               NewGlob.Velocity += (-VNorm + (Velocity - VNorm)) * 0.1;           }           NewGlob.InstigatorController = InstigatorController;       }       //else log("unable to spawn globling");
    }
}
simulated function Destroyed()
{
    if ( !bNoFX && EffectIsRelevant(Location,false) )
    {       //Spawn(class'xEffects.GoopSmoke');       Spawn(class'KFmod.VomGroundSplash');
    }
    if ( Fear != none )       Fear.Destroy();
    if (Trail != none)       Trail.Destroy();
    //Super.Destroyed();
}

auto state Flying
{
    simulated function Landed( Vector HitNormal )
    {       local Rotator NewRot;       local int CoreGoopLevel;
       if ( Level.NetMode != NM_DedicatedServer )       {           PlaySound(ImpactSound, SLOT_Misc);           // explosion effects       }
       SurfaceNormal = HitNormal;
       // spawn globlings       CoreGoopLevel = Rand3 + MaxGoopLevel - 3;       if (GoopLevel > CoreGoopLevel)       {           if (Role == ROLE_Authority)               SplashGlobs(GoopLevel - CoreGoopLevel);           SetGoopLevel(CoreGoopLevel);       }       spawn(class'KFMod.VomitDecal',,,, rotator(-HitNormal));
       bCollideWorld = false;       SetCollisionSize(GoopVolume*10.0, GoopVolume*10.0);       bProjTarget = true;
       NewRot = Rotator(HitNormal);       NewRot.Roll += 32768;       SetRotation(NewRot);       SetPhysics(PHYS_none);       bCheckedsurface = false;       Fear = Spawn(class'AvoidMarker');       GotoState('OnGround');
    }
    simulated function HitWall( Vector HitNormal, Actor Wall )
    {       Landed(HitNormal);       if ( !Wall.bStatic && !Wall.bWorldGeometry )       {           bOnMover = true;           SetBase(Wall);           if (Base == none)               BlowUp(Location);       }
    }
    simulated function ProcessTouch(Actor Other, Vector HitLocation)
    {       if( ExtendedZCollision(Other)!=none )           Return;       if (Other != Instigator && (Other.IsA('Pawn') || Other.IsA('DestroyableObjective') || Other.bProjTarget))           HurtRadius(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation );       else if ( Other != Instigator && Other.bBlockActors )           HitWall( Normal(HitLocation-Location), Other );
    }
}
defaultproperties
{    BaseDamage=4    TouchDetonationDelay=0.000000    Speed=600.000000    Damage=5.000000    MomentumTransfer=3500.000000    MyDamageType=Class'KFMod.DamTypeVomit'    ImpactSound=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_AcidSplash'    DrawType=DT_StaticMesh    StaticMesh=StaticMesh'kf_gore_trip_sm.puke.puke_chunk'    bDynamicLight=False    LifeSpan=8.000000    Skins(0)=Combiner'kf_fx_trip_t.Gore.intestines_cmb'    bUseCollisionStaticMesh=False    bBlockHitPointTraces=False
}
