//==============================================================================
//  NicePack / NiceServerData
//==============================================================================
//  Adds data interface relevant only to server,
//      as well as server implementation of more general functions.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceServerData extends NiceData
    config(NicePack);

var NiceStorageServer               ownerStorage;
var EDataPriority                   priority;
//  Priority should only be set once, otherwise it can lead to issues
var bool                            wasPrioritySet;
//  List of players who've requested replication of relevant Data set
var array<NicePlayerController>     listeners;
//  We can currently send server changes in this data
var protected NicePlayerController  writeRightsOwner;
//  Only admin players can get writing access to this data
//  (but once writing access is given
//      it won't close until player closes it or disconnects)
var bool                            isAdminOnly;

static function NiceData NewData(string newID){
    local NiceData newData;
    newData = new class'NiceServerData';
    newData.ID = newID;
    return newData;
}

function EDataPriority GetPriority(){
    return priority;
}

//  #private
function SetOwnerStorage(   NiceRemoteHack.DataRef dataRef,
                            NiceStorageServerBase newOwner){
    if(ID ~= class'NiceRemoteHack'.static.GetDataRefID(dataRef))
        ownerStorage = NiceStorageServer(newOwner);//NICETODO: temp hack
}

//  #private
function SetPriority(   NiceRemoteHack.DataRef dataRef,
                        EDataPriority newPriority){
    if(wasPrioritySet) return;
    if(ID ~= class'NiceRemoteHack'.static.GetDataRefID(dataRef)){
        priority = newPriority;
        wasPrioritySet = true;
    }
}

function NicePlayerController GetWriteRightsOwner(){
    return writeRightsOwner;
}

//  #private
function SetWriteRightsOwner(   NiceRemoteHack.DataRef dataRef,
                                NicePlayerController newOwner){
    if(ID ~= class'NiceRemoteHack'.static.GetDataRefID(dataRef))
        writeRightsOwner = newOwner;
}

//  Add 'NicePlayerController' referencing a player that should
//  start listening to changes in this data set
function AddListener(NicePlayerController niceClient){
    local int   i;
    if(ownerStorage == none) return;
    if(niceClient == none || niceClient.remoteRI == none) return;

    //  Make sure this client isn't already added
    for(i = 0;i < listeners.length;i ++)
        if(listeners[i] == niceClient)
            return;
    listeners[listeners.length] = niceClient;
    ownerStorage.AddConnection(niceClient);
    //  Replicate all the current data to this client
    if(priority == NSP_REALTIME)
        ReplicateToClient(V(ID), niceClient);
    else
        ownerStorage.PushDataIntoQueue(V(ID), niceClient, priority);
}

function bool IsListener(NicePlayerController niceClient){
    local int i;
    if(niceClient == none) return false;
    for(i = 0;i < listeners.length;i ++)
        if(niceClient == listeners[i])
            return true;
    return false;
}

//  When the client disconnects - references to it's PC become 'null'.
//  This function gets gets rid of them.
//  #private
function PurgeNullListeners(DataRef dataRef){
    local int                           i;
    local array<NicePlayerController>   newListeners;
    if(dataRef.ID != ID) return;
    for(i = 0;i < listeners.length;i ++)
        if(listeners[i] != none)
            newListeners[newListeners.length] = listeners[i];
    listeners = newListeners;
}

//  #private
function ReplicateToClient( NiceRemoteHack.DataRef dataRef,
                    NicePlayerController nicePlayer){
    local int i;
    if(nicePlayer == none || nicePlayer.remoteRI == none) return;
    //  Replication is only finished with last variable
    for(i = 0;i < variables.length - 1;i ++)
        ReplicateVariableToClient(V(ID), variables[i].myName, nicePlayer, false);
    ReplicateVariableToClient(V(ID), variables[variables.length - 1].myName,
                                nicePlayer, true);
}

//  #private
function ReplicateVariableToAll(NiceRemoteHack.DataRef dataRef,
                                string variable){
    local int i;
    if(ID ~= class'NiceRemoteHack'.static.GetDataRefID(dataRef)){
        for(i = 0;i < listeners.length;i ++)
            ReplicateVariableToClient(V(ID), variable, listeners[i], true);
    }
}

//  Guaranteed to check that 'niceClient' and it's 'remoteRI' are '!= none'.
//  #private
function ReplicateVariableToClient( NiceRemoteHack.DataRef dataRef,
                                    string variable,
                                    NicePlayerController niceClient,
                                    bool replicationFinished){
    local int index;
    if(niceClient == none || niceClient.remoteRI == none) return;
    index = GetVariableIndex(variable);
    if(index < 0)
        return;
    //  NICETODO: change replication function based on variable's type
    switch(variables[index].currentType){
        case VTYPE_BOOL:
            niceClient.remoteRI.ClientSendBool(  V(ID, variables[index].myName),
                                                variables[index].storedBool,
                                                replicationFinished);
            break;
        case VTYPE_BYTE:
            niceClient.remoteRI.ClientSendBYTE( V(ID, variables[index].myName),
                                                variables[index].storedByte,
                                                replicationFinished);
            break;
        case VTYPE_INT:
            niceClient.remoteRI.ClientSendInt(  V(ID, variables[index].myName),
                                                variables[index].storedInt,
                                                replicationFinished);
            break;
        case VTYPE_FLOAT:
            niceClient.remoteRI.ClientSendFloat(V(ID, variables[index].myName),
                                                variables[index].storedFloat,
                                                replicationFinished);
            break;
        case VTYPE_STRING:
            niceClient.remoteRI.ClientSendString(V(ID, variables[index].myName),
                                                variables[index].storedString,
                                                replicationFinished);
            break;
        case VTYPE_CLASS:
            niceClient.remoteRI.ClientSendClass(V(ID, variables[index].myName),
                                                variables[index].storedClass,
                                                replicationFinished);
            break;
        default:
            break;
    }
}

//==============================================================================
//  >   Setter / getters for variables that perform necessary synchronization
function SetByte(string variableName, byte variableValue){
    if(writeRightsOwner != none) return;

    _SetByte(V(ID, variableName), variableValue);
    events.static.CallVariableUpdated(ID, variableName);
    events.static.CallByteVariableUpdated(ID, variableName, variableValue);

    if(priority == NSP_REALTIME)
        ReplicateVariableToAll(V(ID), variableName);
    else
        ownerStorage.PushRequestIntoQueues(V(ID), variableName, priority);
}

function SetInt(string variableName, int variableValue){
    if(writeRightsOwner != none) return;

    _SetInt(V(ID, variableName), variableValue);
    events.static.CallVariableUpdated(ID, variableName);
    events.static.CallIntVariableUpdated(ID, variableName, variableValue);

    if(priority == NSP_REALTIME)
        ReplicateVariableToAll(V(ID), variableName);
    else
        ownerStorage.PushRequestIntoQueues(V(ID), variableName, priority);
}

function SetBool(string variableName, bool variableValue){
    if(writeRightsOwner != none) return;

    _SetBool(V(ID, variableName), variableValue);
    events.static.CallVariableUpdated(ID, variableName);
    events.static.CallBoolVariableUpdated(ID, variableName, variableValue);

    if(priority == NSP_REALTIME)
        ReplicateVariableToAll(V(ID), variableName);
    else
        ownerStorage.PushRequestIntoQueues(V(ID), variableName, priority);
}

function SetFloat(string variableName, float variableValue){
    if(writeRightsOwner != none) return;

    _SetFloat(V(ID, variableName), variableValue);
    events.static.CallVariableUpdated(ID, variableName);
    events.static.CallFloatVariableUpdated(ID, variableName, variableValue);

    if(priority == NSP_REALTIME)
        ReplicateVariableToAll(V(ID), variableName);
    else
        ownerStorage.PushRequestIntoQueues(V(ID), variableName, priority);
}

function SetString(string variableName, string variableValue){
    if(writeRightsOwner != none) return;

    _SetString(V(ID, variableName), variableValue);
    events.static.CallVariableUpdated(ID, variableName);
    events.static.CallStringVariableUpdated(ID, variableName, variableValue);

    if(priority == NSP_REALTIME)
        ReplicateVariableToAll(V(ID), variableName);
    else
        ownerStorage.PushRequestIntoQueues(V(ID), variableName, priority);
}

function SetClass(string variableName, class<Actor> variableValue){
    if(writeRightsOwner != none) return;

    _SetClass(V(ID, variableName), variableValue);
    events.static.CallVariableUpdated(ID, variableName);
    events.static.CallClassVariableUpdated(ID, variableName, variableValue);

    if(priority == NSP_REALTIME)
        ReplicateVariableToAll(V(ID), variableName);
    else
        ownerStorage.PushRequestIntoQueues(V(ID), variableName, priority);
}

defaultproperties
{
    wasPrioritySet=false
}