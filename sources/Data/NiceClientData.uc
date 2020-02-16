//==============================================================================
//  NicePack / NiceClientData
//==============================================================================
//  Adds data interface relevant only to client,
//      as well as client implementation of more general functions.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceClientData extends NiceData
    config(NicePack);

var protected NiceStorageClient ownerStorage;
//  Server has yet unsent changes to this data
//  (according to latest information from server)
var protected bool _isUpToDate;
//  We can currently send server changes in this data
var protected bool _hasWriteRights;

static function NiceData NewData(string newID){
    local NiceData newData;
    newData = new class'NiceClientData';
    newData.ID = newID;
    return newData;
}

//  #private
function SetOwnerStorage(   NiceRemoteHack.DataRef dataRef,
                            NiceStorageClient newOwner){
    if(ID ~= class'NiceRemoteHack'.static.GetDataRefID(dataRef))
        ownerStorage = newOwner;
}

function bool IsUpToDate(){
    return _isUpToDate;
}

//  #private
function SetUpToDate(NiceRemoteHack.DataRef dataRef, bool newStatus){
    if(ID ~= class'NiceRemoteHack'.static.GetDataRefID(dataRef))
        _isUpToDate = newStatus;
}

function bool HasWriteRights(){
    return _hasWriteRights;
}

//  #private
function SetWriteRights(NiceRemoteHack.DataRef dataRef, bool newRights){
    if(ID ~= class'NiceRemoteHack'.static.GetDataRefID(dataRef))
        _hasWriteRights = newRights;
}

//==============================================================================
//  >   Setter / getters for variables that perform necessary synchronization
function SetByte(string variableName, byte variableValue){
    if(!HasWriteRights())               return;
    if(ownerStorage == none)            return;
    if(ownerStorage.remoteRI == none)   return;

    _SetByte(V(ID, variableName), variableValue);
    events.static.CallVariableUpdated(ID, variableName);
    events.static.CallByteVariableUpdated(ID, variableName, variableValue);
    ownerStorage.remoteRI.ServerSendByte(V(ID, variableName), variableValue);
}

function SetInt(string variableName, int variableValue){
    if(!HasWriteRights())               return;
    if(ownerStorage == none)            return;
    if(ownerStorage.remoteRI == none)   return;

    _SetInt(V(ID, variableName), variableValue);
    events.static.CallVariableUpdated(ID, variableName);
    events.static.CallIntVariableUpdated(ID, variableName, variableValue);
    ownerStorage.remoteRI.ServerSendInt(V(ID, variableName), variableValue);
}

function SetBool(string variableName, bool variableValue){
    if(!HasWriteRights())               return;
    if(ownerStorage == none)            return;
    if(ownerStorage.remoteRI == none)   return;

    _SetBool(V(ID, variableName), variableValue);
    events.static.CallVariableUpdated(ID, variableName);
    events.static.CallBoolVariableUpdated(ID, variableName, variableValue);
    ownerStorage.remoteRI.ServerSendBool(V(ID, variableName), variableValue);
}

function SetFloat(string variableName, float variableValue){
    if(!HasWriteRights())               return;
    if(ownerStorage == none)            return;
    if(ownerStorage.remoteRI == none)   return;

    _SetFloat(V(ID, variableName), variableValue);
    events.static.CallVariableUpdated(ID, variableName);
    events.static.CallFloatVariableUpdated(ID, variableName, variableValue);
    ownerStorage.remoteRI.ServerSendFloat(V(ID, variableName), variableValue);
}

function SetString(string variableName, string variableValue){
    if(!HasWriteRights())               return;
    if(ownerStorage == none)            return;
    if(ownerStorage.remoteRI == none)   return;

    _SetString(V(ID, variableName), variableValue);
    events.static.CallVariableUpdated(ID, variableName);
    events.static.CallStringVariableUpdated(ID, variableName, variableValue);
    ownerStorage.remoteRI.ServerSendString(V(ID, variableName), variableValue);
}

function SetClass(string variableName, class<Actor> variableValue){
    if(!HasWriteRights())               return;
    if(ownerStorage == none)            return;
    if(ownerStorage.remoteRI == none)   return;

    _SetClass(V(ID, variableName), variableValue);
    events.static.CallVariableUpdated(ID, variableName);
    events.static.CallClassVariableUpdated(ID, variableName, variableValue);
    ownerStorage.remoteRI.ServerSendClass(V(ID, variableName), variableValue);
}

defaultproperties
{
}