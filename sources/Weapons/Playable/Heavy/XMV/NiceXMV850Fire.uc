class NiceXMV850Fire extends NiceHeavyFire;

simulated function HandleRecoil(float Rec)
{
    local float truncatedContLenght;
    local float recoilMod;
    truncatedContLenght = FMin(currentContLenght, 20.0);
    recoilMod = 1.0 - (truncatedContLenght / 20.0);
    super.HandleRecoil(Rec * recoilMod);
}

defaultproperties
{    ProjectileSpeed=42650.000000    maxBonusContLenght=5
    contBonusReset=false    FireAimedAnim="FireLoop"    RecoilRate=0.040000    maxVerticalRecoilAngle=450    maxHorizontalRecoilAngle=225    ShellEjectClass=Class'ROEffects.KFShellEjectSCAR'    ShellEjectBoneName="ejector"    FireSoundRef="HMG_S.XMV.XMV-Fire-1"    StereoFireSoundRef="HMG_S.XMV.XMV-Fire-1"    NoAmmoSoundRef="HMG_S.M41A.DryFire"    DamageType=Class'NicePack.NiceDamTypeXMV850M'    DamageMin=30    DamageMax=30    Momentum=8500.000000    bPawnRapidFireAnim=True    TransientSoundVolume=1.800000    FireAnim="FireLoop"    TweenTime=0.025000    FireForce="AssaultRifleFire"    FireRate=0.065000    AmmoClass=Class'NicePack.NiceXMV850Ammo'    ShakeRotMag=(X=50.000000,Y=50.000000,Z=300.000000)    ShakeRotRate=(X=7500.000000,Y=7500.000000,Z=7500.000000)    ShakeRotTime=0.650000    ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=7.500000)    ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)    ShakeOffsetTime=1.150000    BotRefireRate=0.990000    FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSTG'    aimerror=42.000000
}