//==============================================================================
//  NicePack / NicePathBuilder
//==============================================================================
//  - Class that allows to build string representation of paths like:
//      "/home/dk", "/Weapons/M14Ebr/StateMachine", "Store/Weapons[7].ID"
//      that are used in various places in this mutator.
//  - Reserved symbol that can't be used in names provided by user: '/'.
//  - Works by appending new elements to the end of already existed path
//      like a stack, making it possible to either remove elements from the end
//      or flush and clear the whole accumulated path.
//  - Designed to support flow-syntax allowing user to build paths like follows:
//      path.AddElement("").AddElement("home").AddElement("dk").ToString()
//              => "/home/dk/"
//      path.AddElement("Store").AddElement("Weapons").AddElement("")
//          .ToString()
//              => "Store/Weapons/"
//  - Element names can be empty:
//      /folder//another/
//      above contains following names (in order): "folder", "", "another", "".
//  - Can parse preexistent path from string,
//      which may lead to a failed state in case of incorrect formatting.
//==============================================================================
//  Class hierarchy: Object > NicePathBuilder
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NicePathBuilder extends Object;

//  'true' if path is in an invalid state, meaning no operations except
//      'Flush' and 'Parse' (that completely clear current path)
//      can be performed.
var protected bool          _isInvalid;
//  Elements of currently built path.
var protected array<string> currentPath;

//  Constants that store reserved symbols.
var const string resElementSeparator;

//  Checks if path is currently empty.
//  Invalid path isn't considered empty.
function bool IsEmpty(){
    if(IsInvalid())
        return false;
    return (currentPath.length <= 0);
}

function bool IsInvalid(){
    return _isInvalid;
}

//  Forcefully enters this path into an invalid state.
function NicePathBuilder Fail(){
    _isInvalid = true;
    return self;
}

//  Checks if passed name valid, i.e. doesn't contain any reserved characters.
function bool IsNameValid(string nameToCheck){
    if(InStr(nameToCheck, resElementSeparator) >= 0)
        return false;
    return true;
}

//  'AddElement(<elementName>)' effectively adds '/<elementName>' to the path.
//  ~ If given name contains reserved characters - path will become invalid.
function NicePathBuilder AddElement(string elementName){
    if(IsInvalid()) return self;
    if(!IsNameValid(elementName)) return Fail();
    currentPath[currentPath.length] = elementName;
    return self;
}

//  Returns string representation of this path.
//  Returns empty string if path is invalid or empty.
function string ToString(){
    local int       i;
    local string    accumulator;
    if(IsInvalid()) return "";
    if(IsEmpty()) return "";
    accumulator = currentPath[0];
    for(i = 1;i < currentPath.length;i ++)
        accumulator = accumulator $ resElementSeparator $ currentPath[i];
    return accumulator;
}

//  Removes several last elements.
function NicePathBuilder RemoveMany(int howMuchToRemove){
    local int newLength;
    if(IsInvalid()) return self;
    newLength = currentPath.length - howMuchToRemove;
    if(newLength < 0)
        newLength = 0;
    currentPath.length = newLength;
    return self;
}

//  Removes last element, identical to 'RemoveMany(1)'.
function NicePathBuilder RemoveLast(){
    return RemoveMany(1);
}

//  Returns array of elements in the current path.
function array<string> GetElements(){
    return currentPath;
}

//  Clears current path and resets absolute path flag to 'false'.
function NicePathBuilder Flush(){
    currentPath.length  = 0;
    _isInvalid          = false;
    return self;
}

function NicePathBuilder Parse(string toParse){
    Flush();
    Split(toParse, resElementSeparator, currentPath);
    return self;
}

defaultproperties
{
    resElementSeparator="/"
}