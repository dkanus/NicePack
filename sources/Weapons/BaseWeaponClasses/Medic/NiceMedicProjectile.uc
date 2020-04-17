class NiceMedicProjectile extends NiceBullet;
function GenerateImpactEffects(ImpactEffect effect, Vector hitLocation, Vector hitNormal,
    optional bool bWallImpact, optional bool bGenerateDecal){
    if(bWallImpact){
       effect.EmitterClass = none;
       effect.bPlayROEffect = true;
       effect.bImportanEffect = false;
       effect.noise = none;
    }
    super.GenerateImpactEffects(effect, hitLocation, hitNormal, bWallImpact, bGenerateDecal);
}

defaultproperties
{
     trailXClass=None
     regularImpact=(bImportanEffect=True,bPlayROEffect=False,decalClass=Class'KFMod.ShotgunDecal',EmitterClass=Class'KFMod.healingFX',emitterShiftWall=20.000000,emitterShiftPawn=20.000000,noiseRef="KF_MP7Snd.MP7_DartImpact",noiseVolume=2.000000)
     bGenRegEffectOnPawn=True
     StaticMeshRef="KF_pickups2_Trip.MP7_Dart"
     AmbientSoundRef="KF_MP7Snd.MP7_DartFlyLoop"
}
