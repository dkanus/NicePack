//==============================================================================
//  NicePack / NiceResourceManager
//==============================================================================
//  Manages resource loading in a way that would allow to avoid loading
//      the same resource over and over.
//==============================================================================
//  Class hierarchy: Object > NiceResourceManager
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceResourceManager extends Object
    dependson(NiceResources);

//  Structures and arrays used for storing already loaded resources.
struct PathMeshPair{
    var Mesh    myMesh;
    var string  path;
};
var array<PathMeshPair>     loadedMeshes;

struct PathSoundPair{
    var Sound   mySound;
    var string  path;
};
var array<PathSoundPair>    loadedSounds;

struct PathMaterialPair{
    var Material    myMaterial;
    var string      path;
};
var array<PathMaterialPair> loadedMaterials;

//  Used to convert strings to names via 'SetPropertyText'
var name nameProperty;

//  Low-level method for loading meshes.
function Mesh LoadMeshObject(string path){
    local int           i;
    local Mesh          myMesh;
    local Object        loadO;
    local PathMeshPair  newPair;
    for(i = 0;i < default.loadedMeshes.length;i ++)
        if(loadedMeshes[i].path ~= path)
            return loadedMeshes[i].myMesh;
    loadO   = DynamicLoadObject(path, class'SkeletalMesh');
    myMesh  = SkeletalMesh(loadO);
    newPair.myMesh  = myMesh;
    newPair.path    = path;
    loadedMeshes[loadedMeshes.length] = newPair;
    return myMesh;
}

//  Low-level method for loading sounds.
function Sound LoadSoundObject(string path){
    local int           i;
    local Sound         mySound;
    local Object        loadO;
    local PathSoundPair newPair;
    for(i = 0;i < loadedSounds.length;i ++)
        if(loadedSounds[i].path ~= path)
            return loadedSounds[i].mySound;
    loadO   = DynamicLoadObject(path, class'Sound');
    mySound = Sound(loadO);
    newPair.mySound = mySound;
    newPair.path    = path;
    loadedSounds[loadedSounds.length] = newPair;
    return mySound;
}

//  Low-level method for loading materials.
function Material LoadMaterialObject
    (
        string path,
        optional out NiceResources.MaterialType materialType
    ){
    local int               i;
    local bool              isTypeUnknown;
    local Material          myMaterial;
    local Object            loadO;
    local PathMaterialPair  newPair;
    for(i = 0;i < loadedMaterials.length;i ++)
        if(loadedMaterials[i].path ~= path)
            return loadedMaterials[i].myMaterial;
    isTypeUnknown = (materialType == MT_Unknown);
    if(isTypeUnknown || materialType == MT_Combiner){
        loadO = DynamicLoadObject(path, class'Combiner');
        myMaterial = Combiner(loadO);
        materialType = MT_Combiner;
    }
    if(myMaterial == none && (isTypeUnknown || materialType == MT_FinalBlend)){
        loadO = DynamicLoadObject(path, class'FinalBlend');
        myMaterial = FinalBlend(loadO);
        materialType = MT_FinalBlend;
    }
    if(myMaterial == none && (isTypeUnknown || materialType == MT_Shader)){
        loadO = DynamicLoadObject(path, class'Shader');
        myMaterial = Shader(loadO);
        materialType = MT_Shader;
    }
    if(myMaterial == none && (isTypeUnknown || materialType == MT_Texture)){
        loadO = DynamicLoadObject(path, class'Texture');
        myMaterial = Texture(loadO);
        materialType = MT_Texture;
    }
    if(myMaterial == none && (isTypeUnknown || materialType == MT_Material)){
        loadO = DynamicLoadObject(path, class'Material');
        myMaterial = Material(loadO);
        materialType = MT_Material;
    }
    if(myMaterial == none)
        materialType = MT_Unknown;
    newPair.myMaterial  = myMaterial;
    newPair.path        = path;
    loadedMaterials[loadedMaterials.length] = newPair;
    return myMaterial;
}

//  Loads actual mesh resources for given 'NiceMesh'.
function LoadMesh(out NiceResources.NiceMesh myMesh){
    if(myMesh.meshObject != none) return;
    myMesh.meshObject = LoadMeshObject(myMesh.data.reference);
}

//  Loads actual sound resources for given 'NiceSound'.
function LoadSound(out NiceResources.NiceSound mySound){
    if(mySound.soundObject != none) return;
    mySound.soundObject = LoadSoundObject(mySound.data.reference);
}

//  Loads actual animation name for given 'NiceAnimation'.
function LoadAnimation(out NiceResources.NiceAnimation myAnimation){
    if(myAnimation.loadedName != '') return;
    SetPropertyText("nameProperty", myAnimation.data.nameRef);
    myAnimation.loadedName = nameProperty;
}

//  Loads actual texture resources for given 'NiceMaterial'.
function LoadMaterial(out NiceResources.NiceMaterial myMaterial){
    if(myMaterial.materialObject != none) return;
    myMaterial.materialObject = LoadMaterialObject(
                                                myMaterial.data.reference,
                                                myMaterial.data.materialType);
}