//==============================================================================
//  NicePack / NiceAbilitiesAdapter
//==============================================================================
//  Temporary stand-in for future functionality.
//  Use this class to catch events from players' abilities.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceAbilitiesAdapter extends Object;
var LevelInfo           level;
static function AbilityActivated(   string abilityID,
                                   NicePlayerController relatedPlayer);
static function AbilityAdded(   string abilityID,
                               NicePlayerController relatedPlayer);
static function AbilityRemoved( string abilityID,
                               NicePlayerController relatedPlayer);
static function ModAbilityCooldown( string abilityID,
                                   NicePlayerController relatedPlayer,
                                   out float cooldown);
defaultproperties
{
}
