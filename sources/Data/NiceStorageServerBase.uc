//==============================================================================
//  NicePack / NiceStorageServerBase
//==============================================================================
//  Implements storage methods relevant only to server.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceStorageServerBase extends NiceStorageBase
    abstract
    config(NicePack);

struct ReplicationRequest{
    var string dataID;
    var string variable;
};

struct RequestQueue{
    //  Elements with indices below this one were already replicated
    var int                         newIndex;
    var array<ReplicationRequest>   requests;
    //  All changes must preserve following invariants:
    //  - newIndex >= 0
    //  - newIndex <= requests.length
};

struct ClientConnection{
    var NicePlayerController    player;
    var float                   replicationCountdown;
    var RequestQueue            lowPriorityQueue;
    var RequestQueue            highPriorityQueue;
};

//  List of all the players who are connected to any of our data
var protected array<ClientConnection> connections;

//  How much time needs to pass before we send new data;
//  Each client has it's own cooldowns;
//  Not applicable to 'NSP_REALTIME' priority
//      since everything is replicated immediately then.
var config float replicationCooldown;

//==============================================================================
//  >   Variables related to purging 'none' actors
//  After client disconnects - it's reference will only uselessly
//      clutter connection or listeners references, -
//      that's why we need to do periodic "clean ups".

//  Time between purges
var config float    cleanupCooldown;
//  We clear all lost connections every purge, but only this many data sets
var config int      cleanupPassesPerRound;

var protected float cleanupCountDown;
//  Next index of the next data to be cleaned
var protected int   cleanupNextDataIndex;

function bool CreateData(string ID, NiceData.EDataPriority priority){
    local NiceServerData serverData;
    if(ID == "")                    return false;
    if(DoesDataExistLocally(ID))    return false;
    serverData = NiceServerData(class'NiceServerData'.static.NewData(ID));
    if(!StoreData(serverData, priority))
        return false;
    return true;
}

//  Puts given with data in the storage without any synchronization work.
//  Can fail if data with the same ID already exists.
function bool StoreData(NiceData data, NiceData.EDataPriority priority){
    local string            ID;
    local NiceServerData    serverData;
    serverData = NiceServerData(data);
    if(serverData == none) return false;
    ID = serverData.GetID();
    if(DoesDataExistLocally(ID))
        return false;
    localStorage[localStorage.length] = serverData;
    serverData.SetOwnerStorage(V(ID), self);
    serverData.SetPriority(V(ID), priority);
    events.static.CallDataCreated(ID);
    return true;
}

function bool CanGrantWriteRights(  NiceServerData data,
                                    NicePlayerController clientRef){
    local bool isClientAdmin;
    if(data == none) return false;
    if(data.GetWriteRightsOwner() != none) return false;
    // Admin rights check
    isClientAdmin = false;
    if(clientRef != none && clientRef.PlayerReplicationInfo != none)
        isClientAdmin = clientRef.PlayerReplicationInfo.bAdmin;
    if(data.isAdminOnly && !isClientAdmin)
        return false;
    return true;
}

//  #private
function bool OpenWriteAccess(DataRef dataRef, NicePlayerController niceClient){
    local NiceServerData data;
    if(niceClient == none || niceClient.remoteRI == none) return false;

    data = NiceServerData(GetData(dataRef.ID));
    if(data == none)
        return false;
    if(CanGrantWriteRights(data, niceClient)){
        data.SetWriteRightsOwner(dataRef, niceClient);
        events.static.CallWriteAccessGranted(dataRef.ID, niceClient);
        niceClient.remoteRI.ClientOpenWriteRights(dataRef);
        return true;
    }
    events.static.CallWriteAccessRefused(   dataRef.ID,
                                            data.GetWriteRightsOwner());
    niceClient.remoteRI.ClientRefuseWriteRights(dataRef);
    return false;
}

//  #private
function bool CloseWriteAccess(DataRef dataRef){
    local NiceServerData        data;
    local NicePlayerController  oldOwner;

    data = NiceServerData(GetData(dataRef.ID));
    if(data == none)
        return false;
    oldOwner = data.GetWriteRightsOwner();
    if(oldOwner == none)
        return false;
    data.SetWriteRightsOwner(dataRef, none);
    events.static.CallWritingAccessRevoked(dataRef.ID, oldOwner);
    if(oldOwner.remoteRI != none)
        oldOwner.remoteRI.ClientCloseWriteRights(dataRef);
    return true;
}

function AddConnection(NicePlayerController clientRef){
    local int               i;
    local int               newIndex;
    local ClientConnection  newConnection;
    if(clientRef == none) return;
    for(i = 0;i < connections.length;i ++)
        if(connections[i].player == clientRef)
            return;
    newConnection.player                        = clientRef;
    newConnection.lowPriorityQueue.newIndex     = 0;
    newConnection.highPriorityQueue.newIndex    = 0;
    newIndex = connections.length;
    connections[newIndex] = newConnection;
}

//  Returns index for a connection for 'clientRef',
//      returns -1 if there's no connection for it.
protected function int FindConnection(NicePlayerController clientRef){
    local int i;
    //  Connection can contain 'none' values due to players disconnecting,
    if(clientRef == none)
        return -1;
    for(i = 0;i < connections.length;i ++)
        if(connections[i].player == clientRef)
            return i;
    return -1;
}

protected function CleanupConnections(){
    local int                       i;
    local array<ClientConnection>   newConnections;

    for(i = 0;i < connections.length;i ++)
        if(connections[i].player != none)
            newConnections[newConnections.length] = connections[i];
    connections = newConnections;
}

//  There might be a potentially huge number of data with listeners,
//      so we'll clean only a certain amount of the at a time.
protected function DoCleanupListenersRound(int passesAmount){
    local NiceServerData serverData;
    if(localStorage.length <= 0) return;
    if(cleanupNextDataIndex < 0 || cleanupNextDataIndex >= localStorage.length)
        cleanupNextDataIndex = 0;
    serverData = NiceServerData(localStorage[cleanupNextDataIndex]);
    if(serverData != none)
        serverData.PurgeNullListeners(V(serverData.GetID()));
    cleanupNextDataIndex ++;
    DoCleanupListenersRound(passesAmount - 1);
}

function Tick(float delta){
    cleanupCountDown -= delta;
    if(cleanupCountDown <= 0){
        cleanupCountDown = cleanupCooldown;
        CleanupConnections();
        DoCleanupListenersRound(cleanupPassesPerRound);
    }
}

defaultproperties
{
    dataClass=class'NiceServerData'
    cleanupCooldown=1.0
    cleanupPassesPerRound=10
    replicationCooldown=0.025
}