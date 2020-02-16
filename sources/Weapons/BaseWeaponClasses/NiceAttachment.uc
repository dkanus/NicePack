class NiceAttachment extends ScrnLaserWeaponAttachment
    abstract;
var array<string>   SkinRefs;
var bool bSpawnLight;
var bool bSecondaryModeNoEffects;
static function PreloadAssets(optional KFWeaponAttachment Spawned){
    local int i;
    if(default.Mesh == none && default.MeshRef != "")       UpdateDefaultMesh(Mesh(DynamicLoadObject(default.MeshRef, class'Mesh', true)));
    if(default.AmbientSound == none && default.AmbientSoundRef != "")       default.AmbientSound = sound(DynamicLoadObject(default.AmbientSoundRef, class'Sound', true));
    if(Spawned != none){       Spawned.LinkMesh(default.Mesh);       Spawned.AmbientSound = default.AmbientSound;
    }
    for(i = 0; i < default.SkinRefs.Length;i ++){       if(default.SkinRefs[i] != "" && (default.Skins.Length < i + 1 || default.Skins[i] == none))           default.Skins[i] = Material(DynamicLoadObject(default.SkinRefs[i], class'Material'));       if(Spawned != none)           Spawned.Skins[i] = default.Skins[i];
    }
}
static function bool UnloadAssets(){
    local int i;
    UpdateDefaultMesh(none);
    default.AmbientSound = none;
    for(i = 0;i < default.Skins.Length;i ++)       default.Skins[i] = none;
    return super.UnloadAssets();
}
simulated event ThirdPersonEffects(){
    local NicePlayerController PC;
    if((Level.NetMode == NM_DedicatedServer) || (Instigator == none))       return;
    PC = NicePlayerController(Level.GetLocalPlayerController());
    if(FiringMode == 0){       if(OldSpawnHitCount != SpawnHitCount){           OldSpawnHitCount = SpawnHitCount;           GetHitInfo();           if(((Instigator != none) && (Instigator.Controller == PC)) || (VSize(PC.ViewTarget.Location - mHitLocation) < 4000)){               if(PC != Instigator.Controller){                   if(mHitActor != none)                       Spawn(class'ROBulletHitEffect',,, mHitLocation, Rotator(-mHitNormal));                   CheckForSplash();                   SpawnTracer();               }           }       }
    }
    if(FlashCount > 0){       if(KFPawn(Instigator) != none){           if(FiringMode == 0)               KFPawn(Instigator).StartFiringX(false, bRapidFire);           else               KFPawn(Instigator).StartFiringX(true, bRapidFire);       }       if(bDoFiringEffects && (!bSecondaryModeNoEffects || FiringMode == 0)){           if((Level.TimeSeconds - LastRenderTime > 0.2) && (Instigator.Controller != PC))               return;           if(bSpawnLight)               WeaponLight();           DoFlashEmitter();           ThirdPersonShellEject();       }
    }
    else{       GotoState('');       if(KFPawn(Instigator) != none)           KFPawn(Instigator).StopFiring();
    }
}
function UpdateHit(Actor HitActor, vector HitLocation, vector HitNormal){
    SpawnHitCount++;
    mHitLocation = HitLocation;
    mHitActor = HitActor;
    mHitNormal = HitNormal;
    NetUpdateTime = Level.TimeSeconds - 1;
}
simulated function ThirdPersonShellEject(){
    if((mShellCaseEmitter == none) && (Level.DetailMode != DM_Low) && !Level.bDropDetail){       mShellCaseEmitter = Spawn(mShellCaseEmitterClass);       if(mShellCaseEmitter != none)           AttachToBone(mShellCaseEmitter, 'ShellPort');
    }
    if(mShellCaseEmitter != none)       mShellCaseEmitter.mStartParticles++;
}
simulated function SpawnTracerAtLocation(vector HitLocation){
    local vector SpawnLoc, SpawnDir, SpawnVel;
    local float hitDist;
    if(!bDoFiringEffects)       return;
    if(mTracer == none)       mTracer = Spawn(mTracerClass);
    if(mTracer != none){       SpawnLoc = GetTracerStart();       mTracer.SetLocation(SpawnLoc);       hitDist = VSize(HitLocation - SpawnLoc) - mTracerPullback;       SpawnDir = Normal(HitLocation - SpawnLoc);       if(hitDist > mTracerMinDistance){           SpawnVel = SpawnDir * mTracerSpeed;           mTracer.Emitters[0].StartVelocityRange.X.Min = SpawnVel.X;           mTracer.Emitters[0].StartVelocityRange.X.Max = SpawnVel.X;           mTracer.Emitters[0].StartVelocityRange.Y.Min = SpawnVel.Y;           mTracer.Emitters[0].StartVelocityRange.Y.Max = SpawnVel.Y;           mTracer.Emitters[0].StartVelocityRange.Z.Min = SpawnVel.Z;           mTracer.Emitters[0].StartVelocityRange.Z.Max = SpawnVel.Z;
           mTracer.Emitters[0].LifetimeRange.Min = hitDist / mTracerSpeed;           mTracer.Emitters[0].LifetimeRange.Max = mTracer.Emitters[0].LifetimeRange.Min;
           mTracer.SpawnParticle(1);       }
    }
}
simulated function CheckForSplashAtLocation(vector HitLoc){
    local Actor HitActor;
    local vector HitNormal, HitLocation;
    if(!Level.bDropDetail && (Level.DetailMode != DM_Low) && (SplashEffect != none) && !Instigator.PhysicsVolume.bWaterVolume){       // check for splash       bTraceWater = true;       HitActor = Trace(HitLocation, HitNormal, HitLoc, Instigator.Location, true);       bTraceWater = false;       if((FluidSurfaceInfo(HitActor) != none) || ((PhysicsVolume(HitActor) != none) && PhysicsVolume(HitActor).bWaterVolume))           Spawn(SplashEffect,,,HitLocation, rot(16384,0,0));
    }
}
defaultproperties
{    bSpawnLight=True
}
