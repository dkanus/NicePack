//==============================================================================
//  NicePack / NiceResources
//==============================================================================
//  Class that:
//      1. Contains definitions for resources
//          formats as they're used in a NicePack;
//      2. Manages loading resource sets from config files.
//==============================================================================
//  Class hierarchy: Object > NiceResources
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceResources extends Object
    dependson(NicePlainData);

//  Mesh data used in NicePack.
struct NiceMeshData{
    //  ID of this sound;
    //  IDs are aliases necessary to allow us to
    //      reference particular types of resources,
    //      while preserving an ability to swap actual resources on the fly.
    var string ID;
    //  Reference to the mesh object.
    var string reference;
};

//  Mesh instance used in NicePack.
struct NiceMesh{
    //  Sound parameters.
    var NiceMeshData    data;
    //  Variable into which we will load our sound.
    var Mesh            meshObject;
};

//  Sound data used in NicePack.
struct NiceSoundData{
    //  ID of this sound;
    //  IDs are aliases necessary to allow us to
    //      reference particular types of resources,
    //      while preserving an ability to swap actual resources on the fly.
    var string  ID;
    //  Reference to the sound object.
    var string  reference;
    //  Obvious sound parameters.
    var float   volume;
    var float   radius;
    var float   pitch;
};

//  Sound instance used in NicePack.
struct NiceSound{
    //  Sound parameters.
    var NiceSoundData   data;
    //  Variable into which we will load our sound.
    var Sound           soundObject;
};

//  Animation data used in NicePack.
struct NiceAnimationData{
    //  ID of this animation;
    //  IDs are aliases necessary to allow us to
    //      reference particular types of resources,
    //      while preserving an ability to swap actual resources on the fly.
    var string  ID;
    //  String representation of this animation's name.
    var string  nameRef;
    //  Starting point to play animation from.
    var float   start;
    //  End point at which we stop playing the animation;
    //  if 'end' <= 'start' - we consider this animation empty.
    var float   end;
    //  Default rate at which this animation will be played;
    //  '<= 0.0' means '1.0'.
    var float   rate;
    //  Channel on which animation will be played by default.
    var int     defaultChannel;
};
    
//  Animation instance used in NicePack.
//  Doesn't correspond 1-to-1 to Unreal Engine's counterpart as it can
//      consist of only a part of Unreal's animation.
//  This is to allow us construction of animation that correspond to
//      subset of existing ones that have a meaning distinctive from
//      all animation (example is segmented weapon reloadings,
//          - magazine extraction, insertion, etc.)
struct NiceAnimation{
    //  Animation parameters.
    var NiceAnimationData   data;
    //  Name of animation from which we'll be playing a segment.
    var name                loadedName;
};

//  Type to use to load a particular paint when loading 'NicePaint'.
enum MaterialType{
    MT_Combiner,
    MT_FinalBlend,
    MT_Shader,
    MT_Texture,
    MT_Material,
    MT_Unknown
};

//  Material data used in NicePack;
//  can represent more complex things that actual material, including Combiners.
struct NiceMaterialData{
    //  ID of this material;
    //  IDs are aliases necessary to allow us to
    //      reference particular types of resources,
    //      while preserving an ability to swap actual resources on the fly.
    var string          ID;
    //  First-person skin textures
    var string          reference;
    var MaterialType    materialType;
};

//  Material instance used in NicePack;
//  can represent more complex things that actual material, including Combiners.
struct NiceMaterial{
    //  Material parameters.
    var NiceMaterialData    data;
    //  Variable into which we will load our material.
    var Material            materialObject;
};

//  Each set is uniquely determined by 'Title':
//      ~ a combination 'ID' and 'subject';
//      ~ further more each such combination can come and
//          be stored with different versions.
//  Read from a name of the object it's stored as.
struct Title{
    //  ID (not expected to be human-readable) of this resource set;
    var string          ID;
    //  Name of object to which this set relates
    //      (like weapon's or zed's name/id).
    var config string   subject;
};

//  We introduce following structures to group loaded resources
//      via subject and ID:
// - Resource sets with same subject and ID
struct IDCase{
    var string          ID;
    var NiceResourceSet resourceSet;
};
//  - Resource sets with same subject, grouped by ID;
struct SubjectCase{
    var string          subject;
    var array<IDCase>   cases;
};
//  NICETODO: have to track updates of these things and sync them with server.
//  Available resource packs:
//      - loaded from config or define by user during the game;
var protected array<SubjectCase> localResourceCases;
//      - received from the server.
var protected array<SubjectCase> remoteResourceCases;

//  Points at the particular resource set collection (array<NiceResourceSet>)
//      in our cases, made to avoid passing tons of indices and hide details.
//  Always point at a full (not filtered) resource set.
//  For internal use only.
//  Considered invalid if at least one index is pointing at inexistent array.
struct CollectionPointer{
    //  Indices for arrays of cases that lead us to
    //      the particular resource set collection (array<NiceResourceSet>).
    var int     subjectIndex;
    var int     idIndex;
    //  Do we point at collection in the local storage?
    var bool    isLocal;
};
//  As 'CollectionPointer' is a set of pointers into nested arrays,
//      depending on how much of these indices are valid,
//      we can distinguish several validity levels:
//      ~ pointer is completely invalid;
//          (guaranteed to be lowest in value validity value)
var const int ptrCompletelyInvalid;
//      ~ pointer has valid subject index, but invalid id index;
//          (guaranteed to be between
//              'ptrCompletelyInvalid' and 'ptrCompletelyValid')
var const int ptrValidSubject;
//      ~ pointer is completely valid.
//          (guaranteed to be highest validity value)
var const int ptrCompletelyValid;

//  Filtered resource packs, - possibly incomplete copies of
//      'localResourceCases' and 'remoteResourceCases'
//      that are used as temporary storages to
//      facilitate filters for search queues.
var protected array<SubjectCase> localFilteredCases;
var protected array<SubjectCase> remoteFilteredCases;
/*
//  Returns level of pointer's validity
//      (see below definition of 'CollectionPointer').
private function int GetPointerValidity(CollectionPointer ptr){
    local array<SubjectCase> relevantCases;
    if(isLocal)
        relevantCases = localResourceCases;
    else
        relevantCases = remoteResourceCases;
    if(ptr.subjectIndex < 0)
        return ptrCompletelyInvalid;
    if(relevantCases.length <= ptr.subjectIndex)
        return ptrCompletelyInvalid;
    if(ptr.idIndex < 0)
        return ptrValidSubject;
    if(relevantCases[ptr.subjectIndex].cases.length <= ptr.idIndex)
        return ptrValidSubject;
    return ptrCompletelyValid;
}

//  Validates given pointer with given set:
//      - creates new cases in given collection,
//          allowing 'toValidate' to point at something;
//      - subject and id for new cases are taken from 'resourceSet';
//      - result isn't written in a collection itself, but into a passed array.
//  Assumes pointers at all cases, not the filtered collections.
//  Previously invalid indices are overwritten with new ones.
private function ValidatePointer(   out CollectionPointer toValidate,
                                    NiceResourceSet resourceSet,
                                    out array<SubjectCase> relevantCases){
    local int                   pointerValidityLevel;
    local SubjectCase           newSubjectCase;
    local IDCase                newIDCase;
    pointerValidityLevel = GetPointerValidity(toValidate);
    if(pointerValidityLevel < ptrValidSubject){
        toValidate.subjectIndex = relevantCases.length;
        newSubjectCase.subject = resourceSet.subject;
        relevantCases[toValidate.subjectIndex] = newSubjectCase;
    }
    if(pointerValidityLevel < ptrCompletelyValid){
        toValidate.idIndex =
            relevantCases[toValidate.subjectIndex].cases.length;
        newIDCase.ID = resourceSet.ID;
        relevantCases[toValidate.subjectIndex].cases[toValidate.idIndex] =
            newIDCase;
    }
}

//  Updates given pointer to point at given subject in all cases.
//  Wipes indices for id case, making pointer invalid.
private function CollectionPointer UpdateSubjectIndex
    (
        CollectionPointer toUpdate,
        string subjectName
    ){
    local int                   i;
    local array<SubjectCase>    relevantCases;
    toUpdate.subjectIndex   = -1;
    toUpdate.idIndex        = -1;
    if(toUpdate.isLocal)
        relevantCases = localResourceCases;
    else
        relevantCases = remoteResourceCases;
    for(i = 0;i < relevantCases.length;i ++){
        if(relevantCases[i].subject ~= subjectName){
            toUpdate.subjectIndex = i;
            break;
        }
    }
    return toUpdate;
}

//  Updates given pointer to point at given id in all cases.
//  Fails if it points at invalid subject.
private function CollectionPointer UpdateIDIndex
    (
        CollectionPointer toUpdate,
        string id
    ){
    local int                   i;
    local array<SubjectCase>    relevantCases;
    toUpdate.idIndex = -1;
    if(GetPointerValidity(toUpdate) < ptrValidSubject)
        return toUpdate;
    if(toUpdate.isLocal)
        relevantCases = localResourceCases[toUpdate.subjectIndex].cases;
    else
        relevantCases = remoteResourceCases[toUpdate.subjectIndex].cases;
    for(i = 0;i < relevantCases.length;i ++){
        if(relevantCases[i].id ~= id){
            toUpdate.idIndex = i;
            break;
        }
    }
    return toUpdate;
}

//  Returns indices for subject cases corresponding to
//      subject and id names given by 'NiceResourceSet' argument.
//  Returns invalid pointer if indices weren't found.
private function CollectionPointer FindCaseIndicies(NiceResourceSet resourceSet,
                                                    bool isLocal){
    local CollectionPointer ptr;
    ptr.isLocal = isLocal;
    ptr.idIndex = -1;
    ptr = UpdateSubjectIndex(ptr, resourceSet.myTitle.subject);
    ptr = UpdateIDIndex(ptr, resourceSet.myTitle.id);
    return ptr;
}

//  Inserts given data set into our storage.
//  If a set with the same subject and ID already exists, - method replaces it.
private function UpdateResourceSet(NiceResourceSet updatedSet, bool isLocal){
    local CollectionPointer     setPointer;
    local array<SubjectCase>    relevantCases;
    if(isLocal)
        relevantCases = localResourceCases;
    else
        relevantCases = remoteResourceCases;
    setPointer = FindCaseIndicies(updatedSet, isLocal);
    ValidatePointer(setPointer, updatedSet, relevantCases);
    relevantCases[setPointer.subjectIndex]
        .cases[setPointer.idIndex].resourceSet = updatedSet;
    if(isLocal)
        localResourceCases = relevantCases;
    else
        remoteResourceCases = relevantCases;
}

//  Forms resource set name as '<subject>/<ID>/<version>'.
private function string FormResourceSetName(Title myTitle){
    local NicePathBuilder pathBuilder;
    pathBuilder = class'NicePack'.static.GetPathBuilder();
    return pathBuilder.Flush().AddElement(myTitle.subject)
                .AddElement(myTitle.ID)
                .ToString();
}


//  Parses resource set name in the form '<subject>/<ID>/<version>'.
//  If there isn't enough fields, 'version' will contain '-1'.
private function ParseResourceSetName
    (
        string resourceSetName,
        out Title myTitle
    ){
    local array<string>     pathLiterals;
    local NicePathBuilder   pathBuilder;
    pathBuilder = class'Nicepack'.static.GetPathBuilder();
    pathBuilder.Parse(resourceSetName);
    myTitle.subject = "";
    myTitle.ID      = "";
    pathLiterals = pathBuilder.GetElements();
    if(pathLiterals.length >= 1)
        myTitle.subject = pathLiterals[0];
    if(pathLiterals.length >= 2)
        myTitle.ID = pathLiterals[1];
}

//  Loads resource set with a given name without checking if it already exist.
private function LoadNamedResourceSetFromConfig(string setName){
    local NicePlainData.Data    newData;
    local NiceResourceSet       newSet;
    newSet = new(none, setName) class'NiceResourceSet';
    ParseResourceSetName(setName, newSet.myTitle);
    newData.pairs       = newSet.data;
    newSet.properties   = newData;
    UpdateResourceSet(newSet, true);
}

function LoadResourceSetsFromConfig
    (
        optional class<NiceResourceSet> resourceClass
    ){
    local int           i;
    local array<string> names;
    if(localResourceCases.length > 0) return;
    if(resourceClass == none)
        resourceClass = class'NiceResourceSet';

    names = GetPerObjectNames(  resourceClass.default.iniName,
                                string(class'NiceResourceSet'.name));
    for(i = 0;i < names.length;i ++)
        LoadNamedResourceSetFromConfig(names[i]);
}

//  Wraps mesh data into unloaded mesh object.
function static NiceMesh MeshFromData(NiceMeshData data){
    local NiceMesh newMesh;
    newMesh.data = data;
    return newMesh;
}

//  Wraps animation data into unloaded animation object.
function static NiceSound SoundFromData(NiceSoundData data){
    local NiceSound newSounds;
    newSounds.data = data;
    return newSounds;
}

//  Wraps sound data into unloaded sound object.
function static NiceAnimation AnimationFromData(NiceAnimationData data){
    local NiceAnimation newAnimation;
    newAnimation.data = data;
    return newAnimation;
}

//  Wraps material data into unloaded material object.
function static NiceMaterial MaterialFromData(NiceMaterialData data){
    local NiceMaterial newMaterial;
    newMaterial.data = data;
    return newMaterial;
}

//  Starts new search through data sets.
//  NOTE: adding any new data sets requires you to create new search.
function NiceResources NewSearch(){
    localFilteredCases  = localResourceCases;
    remoteFilteredCases = remoteResourceCases;
    return self;
}

//  Leaves only local resource sets in current search.
//  'LocalOnly().RemoteOnly()' removes all possible sets from current search.
function NiceResources LocalOnly(){
    remoteFilteredCases.length = 0;
}

//  Leaves only remote resource sets in current search.
//  'LocalOnly().RemoteOnly()' removes all possible sets from current search.
function NiceResources RemoteOnly(){
    localFilteredCases.length = 0;
}

//  Leaves only resource sets with given subject in the current search.
function NiceResources OnlySubject(string subject){
    local int   i;
    local bool  foundGoodCase;
    foundGoodCase = false;
    for(i = 0;i < localFilteredCases.length;i ++){
        if(localFilteredCases[i].subject ~= subject){
            localFilteredCases[0] = localFilteredCases[i];
            localFilteredCases.length = 1;
            foundGoodCase = true;
            break;
        }
    }
    if(!foundGoodCase)
        localFilteredCases.length = 0;
    foundGoodCase = false;
    for(i = 0;i < remoteFilteredCases.length;i ++){
        if(remoteFilteredCases[i].subject ~= subject){
            remoteFilteredCases[0] = remoteFilteredCases[i];
            remoteFilteredCases.length = 1;
            foundGoodCase = true;
            break;
        }
    }
    if(!foundGoodCase)
        remoteFilteredCases.length = 0;
}

//  Leaves only resource sets with given subject in the current search.
function NiceResources OnlyID(string id){
    local int i;
    for(i = 0;i < localFilteredCases.length;i ++){
        localFilteredCases[i].cases =
            FilterIDCases(localFilteredCases[i].cases, id);
    }
    for(i = 0;i < localFilteredCases.length;i ++){
        remoteFilteredCases[i].cases =
            FilterIDCases(remoteFilteredCases[i].cases, id);
    }
}

//  Filters given array of 'IDCase's by leaving only case with given ID.
private function array<SubjectCase> FilterIDCases(  array<IDCase> toFilter,
                                                    string id){
    local int   i;
    local bool  foundGoodCase;
    foundGoodCase = false;
    for(i = 0;i < toFilter.length;i ++){
        if(toFilter[i].id ~= id){
            toFilter[0] = toFilter[i];
            toFilter.length = 1;
            foundGoodCase = true;
            break;
        }
    }
    if(!foundGoodCase)
        toFilter.length = 0;
    return toFilter;
}

function array<NiceResourceSet> ToArray(){
    local int                       i, j;
    local array<NiceResourceSet>    resultSets;
    for(i = 0;i < localFilteredCases.length;i ++){
        for(j = 0;j < localFilteredCases[i].cases.length;j ++){
            resultSets[resultSets.length] =
                localFilteredCases[i].cases[j].resourceSet;
        }
    }
    for(i = 0;i < remoteFilteredCases.length;i ++){
        for(j = 0;j < remoteFilteredCases[i].cases.length;j ++){
            resultSets[resultSets.length] =
                remoteFilteredCases[i].cases[j].resourceSet;
        }
    }
    return resultSets;
}*/

private function bool RemoteShouldReplace(  NiceResourceSet localSet,
                                            NiceResourceSet remoteSet){
    if(localSet.localAlwaysOverrides || remoteSet.localAlwaysOverrides)
        return false;
    return true;
}

defaultproperties
{
    ptrCompletelyInvalid    = 0
    ptrValidSubject         = 1
    ptrCompletelyValid      = 2
}