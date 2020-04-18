//  ScrN copy
class NiceNitroGroundEffect extends NiceFreezeParticlesDirectional;
defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ExtentMultiplier=(X=0.000000,Y=0.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.470000
        FadeOutStartTime=0.940000
        FadeInEndTime=0.300000
        MaxParticles=50
        StartLocationShape=PTLS_Polar
        SpinsPerSecondRange=(X=(Max=0.035000))
        StartSpinRange=(X=(Min=-0.200000,Max=0.300000))
        SizeScale(0)=(RelativeTime=0.500000,RelativeSize=0.900000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=15.000000,Max=35.000000),Y=(Min=15.000000,Max=35.000000),Z=(Min=15.000000,Max=35.000000))
        InitialParticlesPerSecond=60.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'Effects_Tex.explosions.DSmoke_2'
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=-85.000000,Max=85.000000),Y=(Min=-85.000000,Max=85.000000))
        StartVelocityRadialRange=(Min=-40.000000,Max=40.000000)
    End Object
    Emitters(0)=SpriteEmitter'NicePack.NiceNitroGroundEffect.SpriteEmitter0'

    LifeSpan=5.000000
}
