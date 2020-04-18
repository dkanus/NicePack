class NiceBallisticHarpoon extends NiceBullet;
// Have we added this harpoon to a stuck projectiles list?
var bool bAddedMyself;
simulated function Tick(float delta){
    local NiceSealSquealHarpoonBomber harpoonWeap;
    if(bInitFinished && !bAddedMyself && bStuck && nicePlayer == localPlayer){
       bAddedMyself = true;
       harpoonWeap = NiceSealSquealHarpoonBomber(sourceWeapon);
       harpoonWeap.stuckProjectiles[harpoonWeap.stuckProjectiles.Length] = stuckID;
    }
    super.Tick(delta);
}
function KillBullet(){
    local int index;
    local NiceSealSquealHarpoonBomber harpoonWeap;
    if(bStuck && sourceWeapon != none){
       harpoonWeap = NiceSealSquealHarpoonBomber(sourceWeapon);
       for(index = 0;index < harpoonWeap.stuckProjectiles.Length;index ++)
           if(harpoonWeap.stuckProjectiles[index] == stuckID){
               NiceSealSquealHarpoonBomber(sourceWeapon).stuckProjectiles[index] = -1;
               break;
           }
    }
    super.KillBullet();
}
defaultproperties
{
    charMinExplosionDist=300.000000
    bDisableComplexMovement=False
    movementFallTime=1.000000
    TrailClass=Class'KFMod.SealSquealFuseEmitter'
    trailXClass=None
    regularImpact=(noiseRef="KF_FY_SealSquealSND.WEP_Harpoon_Hit_Flesh")
    explosionImpact=(bImportanEffect=True,decalClass=Class'KFMod.KFScorchMark',EmitterClass=Class'KFMod.KFNadeLExplosion',emitterShiftWall=20.000000,emitterShiftPawn=20.000000,noiseRef="KF_FY_SealSquealSND.WEP_Harpoon_Explode",noiseVolume=2.000000)
    disintegrationImpact=(EmitterClass=Class'KFMod.SirenNadeDeflect',noiseRef="Inf_Weapons.faust_explode_distant02",noiseVolume=2.000000)
    StaticMeshRef="KF_IJC_Halloween_Weps2.Harpoon_Projectile"
    AmbientSoundRef="KF_IJC_HalloweenSnd.KF_FlarePistol_Projectile_Loop"
}
