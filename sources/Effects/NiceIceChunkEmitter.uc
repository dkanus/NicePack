class NiceIceChunkEmitter extends Emitter;
var() array<Sound> ImpactSounds;
simulated function PostBeginPlay(){
	if(ImpactSounds.Length > 0)
		PlaySound(ImpactSounds[Rand(ImpactSounds.Length)]);
}
//  NICETODO: change linksfrom HTeac_A to NicePackSM (and change that file)
defaultproperties
{
    ImpactSounds(0)=Sound'KFWeaponSound.bullethitglass'
    ImpactSounds(1)=Sound'KFWeaponSound.bullethitglass2'
    Begin Object Class=MeshEmitter Name=MeshEmitter0
        StaticMesh=StaticMesh'HTec_A.IceChunk1'
        UseCollision=True
        RespawnDeadParticles=False
        SpinParticles=True
        DampRotation=True
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-1000.000000)
        DampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        MaxParticles=5
        SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
        RotationDampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
        StartSizeRange=(X=(Min=5.000000,Max=8.000000),Y=(Min=5.000000,Max=8.000000),Z=(Min=5.000000,Max=8.000000))
        InitialParticlesPerSecond=10000.000000
        StartVelocityRange=(X=(Min=-75.000000,Max=75.000000),Y=(Min=-75.000000,Max=75.000000),Z=(Min=-100.000000,Max=300.000000))
    End Object
    Emitters(0)=MeshEmitter'NicePack.NiceIceChunkEmitter.MeshEmitter0'

    Begin Object Class=MeshEmitter Name=MeshEmitter2
        StaticMesh=StaticMesh'HTec_A.IceChunk2'
        UseCollision=True
        RespawnDeadParticles=False
        SpinParticles=True
        DampRotation=True
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-1000.000000)
        DampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        MaxParticles=8
        DetailMode=DM_High
        SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
        RotationDampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
        StartSizeRange=(X=(Min=3.000000,Max=6.000000),Y=(Min=3.000000,Max=6.000000),Z=(Min=3.000000,Max=6.000000))
        InitialParticlesPerSecond=10000.000000
        StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=-100.000000,Max=500.000000))
    End Object
    Emitters(1)=MeshEmitter'NicePack.NiceIceChunkEmitter.MeshEmitter2'

    Begin Object Class=MeshEmitter Name=MeshEmitter3
        StaticMesh=StaticMesh'HTec_A.IceChunk3'
        UseCollision=True
        RespawnDeadParticles=False
        SpinParticles=True
        DampRotation=True
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-1000.000000)
        DampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        MaxParticles=12
        DetailMode=DM_High
        SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
        RotationDampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
        StartSizeRange=(X=(Min=2.000000,Max=5.000000),Y=(Min=2.000000,Max=5.000000),Z=(Min=2.000000,Max=5.000000))
        InitialParticlesPerSecond=10000.000000
        StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-100.000000,Max=500.000000))
    End Object
    Emitters(2)=MeshEmitter'NicePack.NiceIceChunkEmitter.MeshEmitter3'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter8
        UseCollision=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        Acceleration=(Z=-1000.000000)
        ExtentMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
        DampingFactorRange=(X=(Min=0.250000,Max=0.250000),Y=(Min=0.250000,Max=0.250000),Z=(Min=0.250000,Max=0.250000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        FadeOutStartTime=0.500000
        MaxParticles=55
        DetailMode=DM_SuperHigh
        UseRotationFrom=PTRS_Actor
        StartSizeRange=(X=(Min=0.700000,Max=1.700000))
        InitialParticlesPerSecond=10000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'Effects_Tex.BulletHits.snowchunksfinal'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        LifetimeRange=(Min=1.400000,Max=1.400000)
        StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-300.000000,Max=350.000000))
    End Object
    Emitters(3)=SpriteEmitter'NicePack.NiceIceChunkEmitter.SpriteEmitter8'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter9
        ProjectionNormal=(Y=1.000000,Z=0.000000)
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-1000.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.500000
        FadeOutStartTime=0.442500
        FadeInEndTime=0.007500
        MaxParticles=25
        DetailMode=DM_High
        UseRotationFrom=PTRS_Actor
        SpinCCWorCW=(X=0.000000)
        SpinsPerSecondRange=(X=(Max=0.300000))
        StartSpinRange=(X=(Min=-0.300000,Max=0.300000))
        SizeScale(0)=(RelativeSize=0.400000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=0.700000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.300000)
        StartSizeRange=(X=(Min=20.000000,Max=40.000000),Y=(Min=20.000000,Max=40.000000),Z=(Min=20.000000,Max=40.000000))
        InitialParticlesPerSecond=10000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'Effects_Tex.BulletHits.watersplatter2'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        LifetimeRange=(Min=0.750000,Max=0.750000)
        StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=-25.000000,Max=300.000000))
    End Object
    Emitters(4)=SpriteEmitter'NicePack.NiceIceChunkEmitter.SpriteEmitter9'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter10
        ProjectionNormal=(Y=1.000000,Z=0.000000)
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        Acceleration=(Z=-15.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.250000
        FadeOutStartTime=0.175000
        MaxParticles=5
        StartLocationRange=(X=(Min=10.000000,Max=10.000000))
        AddLocationFromOtherEmitter=0
        UseRotationFrom=PTRS_Actor
        SpinCCWorCW=(X=0.000000)
        SpinsPerSecondRange=(X=(Max=0.200000))
        StartSpinRange=(X=(Min=-0.300000,Max=0.300000))
        SizeScale(0)=(RelativeSize=0.400000)
        SizeScale(1)=(RelativeTime=0.560000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=6.000000,Max=60.000000),Y=(Min=6.000000,Max=60.000000),Z=(Min=6.000000,Max=60.000000))
        InitialParticlesPerSecond=1.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'kf_fx_trip_t.Misc.smoke_animated'
        TextureUSubdivisions=8
        TextureVSubdivisions=8
        LifetimeRange=(Min=0.350000,Max=0.350000)
    End Object
    Emitters(5)=SpriteEmitter'NicePack.NiceIceChunkEmitter.SpriteEmitter10'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter11
        ProjectionNormal=(Y=1.000000,Z=0.000000)
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        Acceleration=(Z=-15.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.250000
        FadeOutStartTime=0.175000
        MaxParticles=8
        StartLocationRange=(X=(Min=10.000000,Max=10.000000))
        AddLocationFromOtherEmitter=1
        UseRotationFrom=PTRS_Actor
        SpinCCWorCW=(X=0.000000)
        SpinsPerSecondRange=(X=(Max=0.200000))
        StartSpinRange=(X=(Min=-0.300000,Max=0.300000))
        SizeScale(0)=(RelativeSize=0.400000)
        SizeScale(1)=(RelativeTime=0.560000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=6.000000,Max=60.000000),Y=(Min=6.000000,Max=60.000000),Z=(Min=6.000000,Max=60.000000))
        InitialParticlesPerSecond=1.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'kf_fx_trip_t.Misc.smoke_animated'
        TextureUSubdivisions=8
        TextureVSubdivisions=8
        LifetimeRange=(Min=0.350000,Max=0.350000)
    End Object
    Emitters(6)=SpriteEmitter'NicePack.NiceIceChunkEmitter.SpriteEmitter11'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter12
        ProjectionNormal=(Y=1.000000,Z=0.000000)
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        Acceleration=(Z=-15.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.250000
        FadeOutStartTime=0.175000
        MaxParticles=12
        DetailMode=DM_High
        StartLocationRange=(X=(Min=10.000000,Max=10.000000))
        AddLocationFromOtherEmitter=2
        UseRotationFrom=PTRS_Actor
        SpinCCWorCW=(X=0.000000)
        SpinsPerSecondRange=(X=(Max=0.200000))
        StartSpinRange=(X=(Min=-0.300000,Max=0.300000))
        SizeScale(0)=(RelativeSize=0.400000)
        SizeScale(1)=(RelativeTime=0.560000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=6.000000,Max=60.000000),Y=(Min=6.000000,Max=60.000000),Z=(Min=6.000000,Max=60.000000))
        InitialParticlesPerSecond=1.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'kf_fx_trip_t.Misc.smoke_animated'
        TextureUSubdivisions=8
        TextureVSubdivisions=8
        LifetimeRange=(Min=0.350000,Max=0.350000)
    End Object
    Emitters(7)=SpriteEmitter'NicePack.NiceIceChunkEmitter.SpriteEmitter12'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter13
        ProjectionNormal=(Y=1.000000,Z=0.000000)
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-1000.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.250000
        FadeOutStartTime=0.442500
        FadeInEndTime=0.007500
        MaxParticles=12
        StartLocationRange=(X=(Min=20.000000,Max=20.000000))
        UseRotationFrom=PTRS_Actor
        SpinCCWorCW=(X=0.000000)
        SpinsPerSecondRange=(X=(Max=0.300000))
        StartSpinRange=(X=(Min=-0.300000,Max=0.300000))
        SizeScale(0)=(RelativeSize=0.400000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=0.900000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.300000)
        StartSizeRange=(X=(Min=25.000000,Max=45.000000),Y=(Min=25.000000,Max=45.000000),Z=(Min=25.000000,Max=45.000000))
        InitialParticlesPerSecond=10000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'Effects_Tex.BulletHits.watersplashcloud'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        LifetimeRange=(Min=0.750000,Max=0.750000)
        StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=-5.000000,Max=150.000000))
    End Object
    Emitters(8)=SpriteEmitter'NicePack.NiceIceChunkEmitter.SpriteEmitter13'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter14
        ProjectionNormal=(Y=1.000000,Z=0.000000)
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-22.000000)
        DampingFactorRange=(X=(Min=0.250000,Max=0.250000),Y=(Min=0.250000,Max=0.250000),Z=(Min=0.250000,Max=0.250000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.500000
        FadeOutStartTime=2.720000
        MaxParticles=25
        DetailMode=DM_High
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
        UseRotationFrom=PTRS_Actor
        SpinCCWorCW=(X=0.000000)
        SpinsPerSecondRange=(X=(Max=0.150000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=2.200000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=3.200000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=4.000000)
        StartSizeRange=(X=(Min=1.000000,Max=20.000000),Y=(Min=1.000000,Max=20.000000),Z=(Min=1.000000,Max=20.000000))
        InitialParticlesPerSecond=10000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'Effects_Tex.explosions.DSmoke_2'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        StartVelocityRange=(X=(Min=-350.000000,Max=350.000000),Y=(Min=-350.000000,Max=350.000000),Z=(Min=-5.000000,Max=50.000000))
        VelocityLossRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000))
    End Object
    Emitters(9)=SpriteEmitter'NicePack.NiceIceChunkEmitter.SpriteEmitter14'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter15
        UseCollision=True
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        Acceleration=(Z=-1000.000000)
        ExtentMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
        DampingFactorRange=(X=(Min=0.250000,Max=0.250000),Y=(Min=0.250000,Max=0.250000),Z=(Min=0.250000,Max=0.250000))
        ColorScale(0)=(Color=(B=174,G=174,R=205,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=174,G=174,R=205,A=255))
        FadeOutStartTime=0.500000
        MaxParticles=15
        UseRotationFrom=PTRS_Actor
        StartSizeRange=(X=(Min=0.700000,Max=1.700000))
        InitialParticlesPerSecond=10000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'Effects_Tex.BulletHits.snowchunksfinal'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        LifetimeRange=(Min=1.400000,Max=1.400000)
        StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-300.000000,Max=350.000000))
    End Object
    Emitters(10)=SpriteEmitter'NicePack.NiceIceChunkEmitter.SpriteEmitter15'

    AutoDestroy=True
    bNoDelete=False
    bNetTemporary=True
    RemoteRole=ROLE_SimulatedProxy
    LifeSpan=5.000000
    TransientSoundVolume=150.000000
    TransientSoundRadius=80.000000
}
