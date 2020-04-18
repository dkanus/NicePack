class NiceBallisticNade extends NiceBullet;
defaultproperties
{
    charMinExplosionDist=250.000000
    bDisableComplexMovement=False
    movementAcceleration=(Z=-490.000000)
    movementFallTime=1.000000
    TrailClass=Class'ROEffects.PanzerfaustTrail'
    trailXClass=None
    explosionImpact=(bImportanEffect=True,decalClass=Class'KFMod.KFScorchMark',EmitterClass=Class'KFMod.KFNadeLExplosion',emitterShiftWall=20.000000,emitterShiftPawn=20.000000,noiseRef="KF_GrenadeSnd.Nade_Explode_1",noiseVolume=2.000000)
    disintegrationImpact=(EmitterClass=Class'KFMod.SirenNadeDeflect',noiseRef="Inf_Weapons.faust_explode_distant02",noiseVolume=2.000000)
    StaticMeshRef="kf_generic_sm.40mm_Warhead"
    DrawScale=3.000000
}
