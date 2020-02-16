//==============================================================================
//  NicePack / NiceResourceSet
//==============================================================================
//  Object for storing resource packs data for 'NicePack'.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceResourceSet extends Object
    dependson(NiceResources)
    PerObjectConfig
    config(NiceResources);

//  Name of .ini-file where resources are stored
//      for this class of resource sets.
//  If you want to separate resources for your mutator into a separate config -
//      you need to also change this variable.
var const string    iniName;
//  If two packs were loaded - on a remote end and locally
//      (only highest versions are relevant)
//      and either has this flag set to true - local set will be used.
var config bool     localAlwaysOverrides;

//  Title for this data set.
var NiceResources.Title                     myTitle;
//  ID (not expected to be human-readable) of this resource set;
//  Read from a name of the object it's stored as.
//var string                                  ID;
//  Name of object to which this set relates (like weapon's or zed's name/id).
//var config string                           subject;
//  Additional (optional) properties this resource set can store.
var config array<NicePlainData.DataPair>    data;
//  We wrap loaded properties into this data object for convenience.
var NicePlainData.Data                      properties;

//  Resources stored in a set.
var config array<NiceResources.NiceMeshData>        meshes;
var config array<NiceResources.NiceSoundData>       sounds;
var config array<NiceResources.NiceMaterialData>    materials;
var config array<NiceResources.NiceAnimationData>   animations;

defaultproperties
{
    iniName="NiceResources"
}