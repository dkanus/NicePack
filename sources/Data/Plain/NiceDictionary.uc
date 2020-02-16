//==============================================================================
//  NicePack / NiceDictionary
//==============================================================================
//      Stores pair of variable names and their shorteners for `NiceArchivator`.
//==============================================================================
//  Class hierarchy: Object > NiceDictionary
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================

class NiceDictionary extends Object
    abstract;

struct Definition
{
    var string fullName;
    var string shortName;
};

var public const array<Definition> definitions;

defaultproperties
{
    definitions(0)=(fullName="Location",shortName="L")
    definitions(1)=(fullName="Momentum",shortName="M")
    definitions(2)=(fullName="HeadshotLevel",shortName="H")
    definitions(3)=(fullName="Damage",shortName="D")
    definitions(4)=(fullName="LockonTime",shortName="T")
    definitions(5)=(fullName="Spread",shortName="S")
    definitions(6)=(fullName="ContiniousFire",shortName="C")
}