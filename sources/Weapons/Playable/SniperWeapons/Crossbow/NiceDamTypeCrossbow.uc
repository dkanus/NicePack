class NiceDamTypeCrossbow extends NiceDamageTypeVetSharpshooter;
static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
    local NiceMonster niceKilled;
    niceKilled = NiceMonster(Killed);
    if(KFStatsAndAchievements!=none && (Killed.BurnDown > 0 || (niceKilled != none && niceKilled.bOnFire == true) ))
       KFStatsAndAchievements.AddBurningCrossbowKill();
}
defaultproperties
{
    MaxPenetrations=-1
    BigZedPenDmgReduction=0.000000
    MediumZedPenDmgReduction=1.000000
    PenDmgReduction=1.000000
    HeadShotDamageMult=4.000000
    bSniperWeapon=True
    WeaponClass=Class'NicePack.NiceCrossbow'
    bThrowRagdoll=True
    bRagdollBullet=True
    PawnDamageEmitter=Class'ROEffects.ROBloodPuff'
    LowGoreDamageEmitter=Class'ROEffects.ROBloodPuffNoGore'
    LowDetailEmitter=Class'ROEffects.ROBloodPuffSmall'
    DamageThreshold=1
    KDamageImpulse=2000.000000
    KDeathVel=110.000000
    KDeathUpKick=10.000000
}
