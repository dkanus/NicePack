//  ScrN copy
class NiceNitroDecal extends ProjectedDecal;
#exec OBJ LOAD FILE=HTec_A.ukx
simulated function BeginPlay(){
    if(!level.bDropDetail && FRand() < 0.4)       projTexture = Texture'HTec_A.Nitro.NitroSplat';
    super.BeginPlay();
}
defaultproperties
{    bClipStaticMesh=True    CullDistance=7000.000000    LifeSpan=5.000000    DrawScale=0.500000
}
