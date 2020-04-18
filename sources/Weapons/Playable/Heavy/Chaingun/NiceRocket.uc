class NiceRocket extends NiceBullet;
defaultproperties
{
    charMinExplosionDist=250.000000
    bDisableComplexMovement=False
    movementAcceleration=(Z=-490.000000)
    movementFallTime=1.000000
    TrailClass=Class'ROEffects.PanzerfaustTrail'
    trailXClass=None
    explosionImpact=(bImportanEffect=True,decalClass=Class'ROEffects.RocketMarkDirt',EmitterClass=Class'KFMod.LawExplosion',emitterShiftWall=20.000000,emitterShiftPawn=20.000000,noiseRef="KF_LAWSnd.Rocket_Explode",noiseVolume=2.000000)
    disintegrationImpact=(EmitterClass=Class'KFMod.SirenNadeDeflect',noiseRef="Inf_Weapons.faust_explode_distant02",noiseVolume=2.000000)
    StaticMeshRef="KillingFloorStatics.LAWRocket"
    DrawScale=0.700000
}
