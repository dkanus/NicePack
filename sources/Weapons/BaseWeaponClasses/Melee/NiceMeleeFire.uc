//==============================================================================
//  NicePack / NiceMeleeFire
//==============================================================================
//  Adjustment of vanilla melee fire class to NicePack.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceMeleeFire extends NiceFire;
var float   weaponRange;
var float   damageDelay;
//  How far to rot view?
var vector  impactShakeRotMag;
//  How fast to rot view?
var vector  impactShakeRotRate;
//  How much time to rot the instigator's view?
var float   impactShakeRotTime;
//  Max view offset vertically?
var vector  impactShakeOffsetMag;
//  How fast to offset view vertically?
var vector  impactShakeOffsetRate;
//  How much time to offset view?
var float   impactShakeOffsetTime;
//  Sound for this melee strike hitting a pawn (fleshy hits).
var array<sound>            meleeHitSounds;
var float                   meleeHitVolume;
var array<name>             fireAnims;
//  The class to spawn for the hit effect for
//      this melee weapon hitting the world (not pawns).
var class<KFMeleeHitEffect> hitEffectClass;
var array<string>           meleeHitSoundRefs;
//  The angle to do sweeping strikes in front of the player.
//  If zero, - do no strikes.
var float wideDamageMinHitAngle;
static function PreloadAssets(LevelInfo level, optional KFFire spawned){
    local int           i;
    local NiceMeleeFire niceFire;
    super.PreloadAssets(level, spawned);
    for(i = 0; i < default.meleeHitSoundRefs.length;i ++){
       if(default.meleeHitSoundRefs[i] == "")
           continue;
       if(     default.meleeHitSounds.length >= i + 1
           &&  default.meleeHitSounds[i] != none)
           continue;
       default.meleeHitSounds[i] = Sound(
           DynamicLoadObject(  default.meleeHitSoundRefs[i],
                               class'Sound', true));
    }
    niceFire = NiceMeleeFire(spawned);
    if(niceFire != none)
       for(i = 0; i < default.meleeHitSoundRefs.length;i ++)
           niceFire.meleeHitSounds[i] = default.meleeHitSounds[i];
}
static function bool UnloadAssets(){
    local int i;
    super.UnloadAssets();
    for(i = 0; i < default.meleeHitSoundRefs.length;i ++)
       default.meleeHitSounds[i] = none;
    return true;
}
simulated function DoBurst(optional bool bSkipFirstShot){}
function DoFireEffect(){}
function float MaxRange(){
    local bool hasWindCutterSkill;
    traceRange = weaponRange;
    if(instigator == none) return traceRange;
    hasWindCutterSkill = class'NiceVeterancyTypes'.static.
       HasSkill(   NicePlayerController(instigator.controller),
                   class'NiceSkillZerkWindCutter');
    if(hasWindCutterSkill)
       traceRange *= class'NiceSkillZerkWindCutter'.default.rangeBonus;
    return traceRange;
}
simulated function bool AllowFire(){
    local KFPawn kfPwn;
    // Check pawn actions
    kfPwn = KFPawn(instigator);
    if(kfPwn == none || kfPwn.SecondaryItem != none || kfPwn.bThrowingNade)
       return false;
    return true;
}
function name GetCorrectAnim(bool bLoop, bool bAimed){
    local int AnimToPlay;
    if(fireAnims.length > 0){
       AnimToPlay = rand(fireAnims.length);
       fireAnim = fireAnims[AnimToPlay];
    }
    return FireAnim;
}
simulated function NiceMonster DealTargetMeleeDamage
    (
       NiceReplicationInfo niceRI,
       class<NiceWeaponDamageType> niceDmgType
    ){
    local float                         headSizeModifier;
    local float                         headshotLevel;
    local NiceMonster                   niceZed;
    local Vector                        hitLocation, hitNormal;
    local KFPlayerReplicationInfo       KFPRI;
    local class<NiceVeterancyTypes>     niceVet;
    if(niceRI == none || instigator == none) return none;
    KFPRI = KFPlayerReplicationInfo(instigator.PlayerReplicationInfo);
    if(KFPRI == none)
       return none;
    niceVet = class<NiceVeterancyTypes>(KFPRI.ClientVeteranSkill);
    if(niceVet == none)
       return none;
    if(niceDmgType != none)
       headSizeModifier = niceDmgType.default.headSizeModifier;
    headSizeModifier = 1.0;
    headSizeModifier *=
       niceVet.static.GetHeadshotCheckMultiplier(KFPRI, niceDmgType);
    headshotLevel = TraceZed(niceZed, hitLocation, hitNormal, headSizeModifier);
    if(niceZed != none)
       HitZed(niceZed, headshotLevel, niceRI, niceDmgType);
    else
       HitWall(niceRI, niceDmgType);
    return niceZed;
}
function HitZed(NiceMonster niceZed,
               float headshotLevel,
               NiceReplicationInfo niceRI,
               class<NiceWeaponDamageType> niceDmgType){
    local Vector                        hitLocation, hitNormal;
    local NiceMeleeWeapon               niceWeap;
    ImpactShakeView();
    niceWeap = NiceMeleeWeapon(weapon);
    if(niceWeap != none && niceWeap.BloodyMaterial != none)
       niceWeap.Skins[niceWeap.BloodSkinSwitchArray] = niceWeap.BloodyMaterial;
    niceRI.ServerDealMeleeDamage(   niceZed, damageMax, instigator,
                                   hitLocation, -hitNormal,
                                   niceDmgType, true, headshotLevel);
}
function HitWall(   NiceReplicationInfo niceRI,
                   class<NiceWeaponDamageType> niceDmgType){
    local Actor                         wall;
    local Vector                        hitLocation, hitNormal;
    local Rotator                       rotation;
    TraceWall(wall, hitLocation, hitNormal);
    if(wall != none){
       niceRI.ServerDealMeleeDamage(   wall, damageMax, instigator,
                                       hitLocation, -hitNormal, niceDmgType,
                                       false);
       rotation = Rotator
           (
               HitLocation - instigator.location - instigator.EyePosition()
           );
       instigator.spawn(hitEffectClass,,, hitLocation, rotation);
    }
}
simulated function DealArcMeleeDamage
    (
       NiceMonster niceZed,
       NiceReplicationInfo niceRI,
       class<NiceWeaponDamageType> niceDmgType
    ){
    local NiceMonster   otherZed;
    local float         actualMinAngle, tempRadians;
    local bool          hasCleave;
    if(weapon == none) return;
    hasCleave = class'NiceVeterancyTypes'.static.
       HasSkill(   NicePlayerController(instigator.controller),
                   class'NiceSkillZerkCleave');
    actualMinAngle = wideDamageMinHitAngle;
    if(hasCleave){
       tempRadians = acos(actualMinAngle);
       tempRadians += class'NiceSkillZerkCleave'.default.bonusDegrees;
       tempRadians = FMin(tempRadians, Pi);
       actualMinAngle = cos(tempRadians);
    }
    foreach weapon.VisibleCollidingActors(
       class'NiceMonster', otherZed, weaponRange * 2,
       instigator.location + instigator.EyePosition()){

       if(niceZed != none && otherZed == niceZed) continue;
       if(otherZed == instigator || otherZed.Health <= 0) continue;
       TryHitZedArc(actualMinAngle, otherZed, niceRI, niceDmgType);
    }
}
function TryHitZedArc(float minAngle, NiceMonster niceZed,
               NiceReplicationInfo niceRI,
               class<NiceWeaponDamageType> niceDmgType){
    local vector        hitLocation, hitNormal;
    local vector        dir, lookDir;
    local float         diffAngle, victimDist;
    victimDist = VSize(instigator.location - niceZed.location);
    if(victimDist + niceZed.CollisionRadius > weaponRange * 1.1)
       return;
    lookDir = Normal(Vector(instigator.GetViewRotation()));
    dir = Normal(niceZed.location - instigator.location);
    diffAngle = lookDir dot dir;
    if(diffAngle <= minAngle)
       return;
    hitLocation =
       niceZed.location + niceZed.CollisionHeight * vect(0,0,0.7);
    niceRI.ServerDealMeleeDamage(   niceZed, damageMax * 0.5, instigator,
                                   hitLocation, hitNormal, niceDmgType,
                                   false, 0.0);
    if(meleeHitSounds.Length > 0)
       niceZed.PlaySound( meleeHitSounds[Rand(meleeHitSounds.length)],
                           SLOT_None, meleeHitVolume,,,, false);
}
simulated function Timer(){
    local NiceMonster                   niceZed;
    local NiceReplicationInfo           niceRI;
    local class<NiceWeaponDamageType>   niceDmgType;
    niceRI = GetNiceRI();
    niceDmgType = class<NiceWeaponDamageType>(damageType);
    if(niceRI == none || instigator == none || niceDmgType == none)
       return;
    niceZed = DealTargetMeleeDamage(niceRI, niceDmgType);
    DealArcMeleeDamage(niceZed, niceRI, niceDmgType);
}
simulated function MDFEffectsClient(float newAmmoPerFire, float rec){
    local float fireSpeedMod;
    fireSpeedMod = GetFireSpeed();
    super.MDFEffectsClient(newAmmoPerFire, rec);
    SetTimer(damageDelay / fireSpeedMod, false);
}
function PlayFiring_animation(){
    if(weapon       == none) return;
    if(weapon.Mesh  == none) return;
    if(fireCount <= 0){
       weapon.PlayAnim(GetCorrectAnim(false, false), fireAnimRate, 0.0);
       return;
    }
    if(weapon.HasAnim(FireLoopAnim))
       weapon.PlayAnim(GetCorrectAnim(true, false), fireLoopAnimRate, 0.0);
    else
       weapon.PlayAnim(GetCorrectAnim(false, false), fireAnimRate, 0.0);
}
function PlayFiring(){
    local float randPitch;
    local bool  shouldPlayStereo;
    if(weapon == none)              return;
    if(weapon.instigator == none)   return;
    PlayFiring_animation();
    if(bRandomPitchFireSound){
       randPitch = FRand() * RandomPitchAdjustAmt;
       if(FRand() < 0.5)
           randPitch *= -1.0;
    }
    shouldPlayStereo =      weapon.instigator.IsLocallyControlled()
                       &&  weapon.instigator.IsFirstPerson()
                       &&  StereoFireSound != none;
    if(shouldPlayStereo){
       weapon.PlayOwnedSound(  StereoFireSound, SLOT_Interact,
                               TransientSoundVolume * 0.85,,
                               TransientSoundRadius, 1.0 + randPitch, false);
    }
    else{
       weapon.PlayOwnedSound(  FireSound, SLOT_Interact, TransientSoundVolume,,
                               TransientSoundRadius, 1.0 + randPitch, false);
    }
    ClientPlayForceFeedback(fireForce);
    if(!currentContext.bIsBursting)
       fireCount ++;
}
function ImpactShakeView(){
    local NicePlayerController nicePlayer;
    if(instigator == none) return;
    nicePlayer = NicePlayerController(instigator.controller);
    if(nicePlayer == none)
       return;
    nicePlayer.WeaponShakeView( impactShakeRotMag, impactShakeRotRate,
                               impactShakeRotTime, impactShakeOffsetMag,
                               impactShakeOffsetRate, impactShakeOffsetTime);
}
simulated function HandleRecoil(float Rec){}

defaultproperties
{
     weaponRange=70.000000
     damageDelay=0.300000
     ImpactShakeRotMag=(X=50.000000,Y=50.000000,Z=50.000000)
     ImpactShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ImpactShakeRotTime=2.000000
     ImpactShakeOffsetMag=(X=10.000000,Y=10.000000,Z=10.000000)
     ImpactShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ImpactShakeOffsetTime=2.000000
     MeleeHitVolume=1.000000
     HitEffectClass=Class'KFMod.KFMeleeHitEffect'
     WideDamageMinHitAngle=1.000000
     bFiringDoesntAffectMovement=True
     FireEndAnim=
     FireForce="ShockRifleFire"
     aimerror=100.000000
}
