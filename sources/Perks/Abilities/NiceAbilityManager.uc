//==============================================================================
//  NicePack / NiceAbilityManager
//==============================================================================
//  Class that manager active abilities, introduced along with a NicePack.
//  Can support at most 5 ('maxAbilitiesAmount') different abilities at once.
//  NICETODO: refactor later
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceAbilityManager extends Actor;
var const int maxAbilitiesAmount;
//  Defines a list of all possible ability's states
enum EAbilityState{
    //  Ability is ready to use
    ASTATE_READY,
    //  Ability is being used
    ASTATE_ACTIVE,
    //  Ability is on cooldown
    ASTATE_COOLDOWN
};
//  Describes all the necessary information about an ability
struct NiceAbilityDescription{
    //  Ability's ID, supposed to be unique per ability,
    //      but no checks are enforced yet
    var string  ID;
    //  Image to be used as an ability's icon
    var Texture icon;
    //  Default cooldown duration
    var float   cooldownLength;
    //  Can ability be canceled once activated?
    var bool    canBeCancelled;
};
//  Complete description of current status of an ability,
//      including it's complete description.
struct NiceAbilityStatus{
    //  Complete description of ability in question
    var NiceAbilityDescription  description;
    //  Current cooldown value
    var float                   cooldown;
    //  Current state of an ability
    var EAbilityState           myState;
};
var NiceAbilityStatus   currentAbilities[5];
var int                 currentAbilitiesAmount;
//  Refers to the player whose abilities we manage
var NicePlayerController relatedPlayer;
var const class<NiceAbilitiesEvents> events;
//  Unfortunately this hackk is required to force replication of structure array
var int hackCounter;
replication{
    reliable if(Role == ROLE_Authority)
       currentAbilities, currentAbilitiesAmount, hackCounter;
}
simulated function PostBeginPlay(){
    relatedPlayer = NicePlayerController(owner);
}
function AddAbility(NiceAbilityDescription description){
    local int               i;
    local NiceAbilityStatus newRecord;
    if(currentAbilitiesAmount >= maxAbilitiesAmount) return;
    for(i = 0;i < currentAbilitiesAmount;i ++)
       if(currentAbilities[i].description.ID ~= description.ID)
           return;
    newRecord.description   = description;
    newRecord.cooldown      = 0.0;
    newRecord.myState       = ASTATE_READY;
    currentAbilities[currentAbilitiesAmount] = newRecord;
    currentAbilitiesAmount += 1;
    events.static.CallAbilityAdded(description.ID, relatedPlayer);
    netUpdateTime = level.timeSeconds - 1;
}
function RemoveAbility(string abilityID){
    local int   i, j;
    local bool  wasRemoved;
    j = 0;
    for(i = 0;i < currentAbilitiesAmount;i ++){
       if(currentAbilities[i].description.ID ~= abilityID){
           wasRemoved = true;
           continue;
       }
       currentAbilities[j] = currentAbilities[i];
       j += 1;
    }
    currentAbilitiesAmount = j;
    if(wasRemoved)
       events.static.CallAbilityRemoved(abilityID, relatedPlayer);
    netUpdateTime = level.timeSeconds - 1;
}
function ClearAbilities(){
    currentAbilitiesAmount = 0;
    netUpdateTime = level.timeSeconds - 1;
}
//  Returns index of the ability with a given name.
//  Returns '-1' if such ability doesn't exist.
simulated function int GetAbilityIndex(string abilityID){
    local int i;
    for(i = 0;i < currentAbilitiesAmount;i ++)
       if(currentAbilities[i].description.ID ~= abilityID)
           return i;
    return -1;
}
simulated function bool IsAbilityActive(string abilityID){
    local int index;
    index = GetAbilityIndex(abilityID);
    if(index < 0)
       return false;
    return (currentAbilities[index].myState == ASTATE_ACTIVE);
}
//  Sets ability to a proper state.
//  Does nothing if ability is already in a specified state.
//  Setting active ability to a ready state is only allowed
//      if ability can be canceled.
//  Updates cooldown to full length if new state is 'ASTATE_COOLDOWN'.
function SetAbilityState(int abilityIndex, EAbilityState newState){
    local float         cooldown;
    local EAbilityState currentState;
    if(abilityIndex < 0 || abilityIndex >= currentAbilitiesAmount) return;
    currentState = currentAbilities[abilityIndex].myState;
    if(currentState == newState)
       return;
    if(     currentState == ASTATE_ACTIVE && newState == ASTATE_READY
       &&  !currentAbilities[abilityIndex].description.canBeCancelled)
       return;
    currentAbilities[abilityIndex].myState = newState;
    if(newState == ASTATE_COOLDOWN){
       cooldown = currentAbilities[abilityIndex].description.cooldownLength;
       events.static.CallModAbilityCooldown(
           currentAbilities[abilityIndex].description.ID,
           relatedPlayer,
           cooldown
       );
       currentAbilities[abilityIndex].cooldown = cooldown;
    }
    hackCounter ++;
    netUpdateTime = level.timeSeconds - 1;
    //  Fire off events
    if(newState == ASTATE_ACTIVE){
       events.static.CallAbilityActivated(
           currentAbilities[abilityIndex].description.ID,
           relatedPlayer
       );
    }
}
//  Changes ability's cooldown by a given amount.
//  If this brings cooldown to zero or below -
//      resets current ability to a 'ready' (ASTATE_READY) state.
function AddToCooldown(int abilityIndex, float delta){
    if(abilityIndex < 0 || abilityIndex >= currentAbilitiesAmount)  return;
    if(currentAbilities[abilityIndex].myState != ASTATE_COOLDOWN)   return;
    currentAbilities[abilityIndex].cooldown += delta;
    if(currentAbilities[abilityIndex].cooldown <= 0)
       SetAbilityState(abilityIndex, ASTATE_READY);
    hackCounter ++;
}
function Tick(float deltaTime){
    local int i;
    if(Role != Role_AUTHORITY) return;
    for(i = 0;i < currentAbilitiesAmount;i ++)
       AddToCooldown(i, -deltaTime);
}
defaultproperties
{
    maxAbilitiesAmount=5
    Events=Class'NicePack.NiceAbilitiesEvents'
    DrawType=DT_None
}
