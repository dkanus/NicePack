class NiceWeaponDamageType extends KFProjectileWeaponDamageType
    abstract;
enum DecapitationBehaviour{
    DB_PERKED,  //  Decap result depends on whether weapon is perked or not
    DB_DROP,    //  Weapon always drops decapped zeds
    DB_NODROP   //  Weapon never drops decapped zeds
};
var         DecapitationBehaviour   decapType;
var         float   badDecapMod;
var         float   goodDecapMod;
var         bool    bFinisher;                  // If set to true, target will recieve double damage if that's would kill it
var         float   prReqMultiplier;            // How precise must head-shot be for damage multiplier to kick-in?
var         float   prReqPrecise;               // How precise must head-shot be to be considered precise?
var         float   lockonTime;
var         float   flinchMultiplier;           // How effective is weapon for flinching zeds
var         float   stunMultiplier;             // How effective is weapon for stunning zeds
var         float   heatPart;                   // How much of this damage should be a heat component?
var         float   freezePower;                // How good is weapon at freezing?
var         float   bodyDestructionMult;        // How much more damage do to body on a head-shot?
var         float   headSizeModifier;           // How much bigger (smaller) head should be to be detected by a shot with this damage type
var         bool    bPenetrationHSOnly;         // Only allow penetrations on head-shots
var         int     MaxPenetrations;            // Maximum of penetrations; 0 = no penetration, -1 = infinite penetration
var         float   BigZedPenDmgReduction;      // Additional penetration effect reduction after hitting big zeds. 0.5 = 50% red.
var const   int     BigZedMinHealth;            // If zed's base Health >= this value, zed counts as Big
var         float   MediumZedPenDmgReduction;   // Additional penetration effect reduction after hitting medium-size zeds. 0.5 = 50% red.
var const   int     MediumZedMinHealth;         // If zed's base Health >= this value, zed counts as Medium-size
var         float   PenDmgReduction;            // Penetration damage reduction after hitting small zed
var         float   penDecapReduction;          // Penetration decapitaion effectiveness reduction after hitting small zed
var         float   penIncapReduction;          // Penetration incapacitation (flinch or stun) effectiveness reduction after hitting small zed
var bool bIsProjectile; // If original damage type's version was derived from 'KFProjectileWeaponDamageType', then set this to true
// Scales exp gain according to given HardcoreLevel
static function float getScale(int HL){
    HL = Max(0, HL);
    return 0.5 + Float(HL) * 0.1;
}
static function ScoredNiceHeadshot(KFSteamStatsAndAchievements KFStatsAndAchievements, class<KFMonster> monsterClass, int HL){
    ScoredHeadshot(KFStatsAndAchievements, monsterClass, false);
}
// New function for awarding damage to nice perks
static function AwardNiceDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount, int HL){}
// New function for awarding kills to nice perks
static function AwardNiceKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed, int HL){}
// Function that governs damage reduction on penetration
// Return false if weapon shouldn't be allowed to penetrate anymore
static function bool ReduceDamageAfterPenetration(out float Damage, float origDamage, Actor target, class<NiceWeaponDamageType> niceDmgType, bool bIsHeadshot, KFPlayerReplicationInfo KFPRI){
    local float penReduction;
    local NiceMonster niceZed;
    local NicePlayerController nicePlayer;
    local class<NiceVeterancyTypes> niceVet;
    // True if we can penetrate even body, but now penetrating a head and shouldn't reduce damage too much
    local bool bEasyHeadPenetration;
    // Init variables
    niceZed = NiceMonster(target);
    nicePlayer = NicePlayerController(KFPRI.Owner);
    niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(KFPRI);
    bEasyHeadPenetration = bIsHeadshot && !niceDmgType.default.bPenetrationHSOnly;
    penReduction = niceDmgType.default.PenDmgReduction;
    // Apply zed reduction and perk reduction of reduction`
    if(niceZed != none){
       if(niceZed.default.Health >= default.BigZedMinHealth && (!bEasyHeadPenetration || niceDmgType.default.BigZedPenDmgReduction <= 0.0))
           penReduction *= niceDmgType.default.BigZedPenDmgReduction;
       else if(niceZed.default.Health >= default.MediumZedMinHealth && (!bEasyHeadPenetration || niceDmgType.default.MediumZedPenDmgReduction <= 0.0))
           penReduction *= niceDmgType.default.MediumZedPenDmgReduction;
    }
    else
       penReduction *= niceDmgType.default.BigZedPenDmgReduction;
    if(niceVet != none)
       penReduction = niceVet.static.GetPenetrationDamageMulti(KFPRI, penReduction, niceDmgType);
    // Assign new damage value and tell us if we should stop with penetration
    Damage *= penReduction;
    if(!bIsHeadshot && niceDmgType.default.bPenetrationHSOnly)
       return false;
    if(niceDmgType.default.MaxPenetrations < 0)
       return true;
    if(niceDmgType.default.MaxPenetrations == 0 || Damage / origDamage < (niceDmgType.default.PenDmgReduction ** (niceDmgType.default.MaxPenetrations + 1)) + 0.0001)
       return false;
    return true;
}
defaultproperties
{
    badDecapMod=0.500000
    goodDecapMod=1.000000
    prReqPrecise=0.750000
    flinchMultiplier=1.000000
    stunMultiplier=1.000000
    bodyDestructionMult=1.000000
    headSizeModifier=1.000000
    BigZedPenDmgReduction=0.500000
    BigZedMinHealth=1000
    MediumZedPenDmgReduction=0.750000
    MediumZedMinHealth=500
    PenDmgReduction=0.700000
    PawnDamageEmitter=None
    LowGoreDamageEmitter=None
    LowDetailEmitter=None
}