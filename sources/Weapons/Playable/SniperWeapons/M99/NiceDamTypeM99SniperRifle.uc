class NiceDamTypeM99SniperRifle extends NiceDamageTypeVetSharpshooter
    abstract;
static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed ){
    if(KFStatsAndAchievements != none){
       if(Killed.IsA('NiceZombieScrake') || Killed.IsA('MeanZombieScrake'))
           KFStatsAndAchievements.AddM99Kill();
       if(Killed.IsA('NiceZombieHusk') || Killed.IsA('MeanZombieHusk'))
           KFStatsAndAchievements.AddHuskAndZedOneShotKill(true, false);
       else
           KFStatsAndAchievements.AddHuskAndZedOneShotKill(false, true);
    }
}
defaultproperties
{
    prReqMultiplier=0.600000
    prReqPrecise=0.600000
    MaxPenetrations=-1
    BigZedPenDmgReduction=0.750000
    MediumZedPenDmgReduction=1.000000
    PenDmgReduction=1.000000
    HeadShotDamageMult=2.100000
    bSniperWeapon=True
    WeaponClass=Class'NicePack.NiceM99SniperRifle'
    DeathString="%k put a bullet in %o's head."
    FemaleSuicide="%o shot herself in the head."
    MaleSuicide="%o shot himself in the head."
    bThrowRagdoll=True
    bRagdollBullet=True
    bBulletHit=True
    PawnDamageEmitter=Class'ROEffects.ROBloodPuff'
    LowGoreDamageEmitter=Class'ROEffects.ROBloodPuffNoGore'
    LowDetailEmitter=Class'ROEffects.ROBloodPuffSmall'
    FlashFog=(X=600.000000)
    DamageThreshold=1
    KDamageImpulse=10000.000000
    KDeathVel=300.000000
    KDeathUpKick=100.000000
    VehicleDamageScaling=0.650000
}
