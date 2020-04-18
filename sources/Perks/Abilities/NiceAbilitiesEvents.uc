//==============================================================================
//  NicePack / NiceAbilitiesEvents
//==============================================================================
//  Temporary stand-in for future functionality.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceAbilitiesEvents extends Object;
var array< class<NiceAbilitiesAdapter> > adapters;
//  If adapter was already added also returns 'false'.
static function bool AddAdapter(class<NiceAbilitiesAdapter> newAdapter,
                               optional LevelInfo level){
    local int i;
    if(newAdapter == none) return false;
    for(i = 0;i < default.adapters.length;i ++)
       if(default.adapters[i] == newAdapter)
           return false;
    newAdapter.default.level = level;
    default.adapters[default.adapters.length] = newAdapter;
    return true;
}
//  If adapter wasn't even present also returns 'false'.
static function bool RemoveAdapter(class<NiceAbilitiesAdapter> adapter){
    local int i;
    if(adapter == none) return false;
    for(i = 0;i < default.adapters.length;i ++){
       if(default.adapters[i] == adapter){
           default.adapters.Remove(i, 1);
           return true;
       }
    }
    return false;
}
static function CallAbilityActivated
    (
       string abilityID,
       NicePlayerController relatedPlayer
    ){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
       default.adapters[i].static.AbilityActivated(abilityID, relatedPlayer);
}
static function CallAbilityAdded
    (
       string abilityID,
       NicePlayerController relatedPlayer
    ){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
       default.adapters[i].static.AbilityAdded(abilityID, relatedPlayer);
}
static function CallAbilityRemoved
    (
       string abilityID,
       NicePlayerController relatedPlayer
    ){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
       default.adapters[i].static.AbilityRemoved(abilityID, relatedPlayer);
}
static function CallModAbilityCooldown
    (
       string abilityID,
       NicePlayerController relatedPlayer,
       out float cooldown
    ){
    local int i;
    for(i = 0;i < default.adapters.length;i ++){
       default.adapters[i].static.ModAbilityCooldown(  abilityID,
                                                       relatedPlayer,
                                                       cooldown);
    }
}
defaultproperties
{
}
