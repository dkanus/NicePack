//==============================================================================
//  NicePack / NiceRepInfoRemoteData
//==============================================================================
//  Replication info class for replicating messages needed by Storage system.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceRepInfoRemoteData extends ReplicationInfo
    dependson(NiceRemoteHack);

replication{
    reliable if(Role == ROLE_Authority)
        ClientConnectionResponse, ClientDataExistResponse,
        ClientOpenWriteRights, ClientCloseWriteRights, ClientRefuseWriteRights;
    reliable if(Role < ROLE_Authority)
        ServerCreateData, ServerAddListener, ServerAskDataExist,
        ServerRequestWriteAccess, ServerGiveupWriteAccess;
    //  For sending data
    reliable if(Role == ROLE_Authority)
        ClientSendBool, ClientSendByte, ClientSendInt, ClientSendFloat,
        ClientSendString, ClientSendClass;
    reliable if(Role < ROLE_Authority)
        ServerSendBool, ServerSendByte, ServerSendInt, ServerSendFloat,
        ServerSendString, ServerSendClass;
}

//  These variables are needed in almost every function in this class,
//  so they're declared in a scope of whole class and are setup via
//  'SetupVars' call.
var string                  dataID;
var string                  dataVarName;
var NiceData                remoteData;
var NiceStorageBase         storage;
var NiceStorageClient       storageClient;
var NiceStorageServer       storageServer;
var NicePlayerController    ownerPlayer;

simulated function SetupVars(NiceRemoteHack.DataRef dataRef){
    dataID          = class'NiceRemoteHack'.static.GetDataRefID(dataRef);
    dataVarName     = class'NiceRemoteHack'.static.GetDataRefVar(dataRef);
    storage         = class'NicePack'.static.GetStorage(level);
    ownerPlayer     = NicePlayerController(owner);
    if(level.netMode == NM_DedicatedServer)
        storageServer = NiceStorageServer(storage);
    else
        storageClient = NiceStorageClient(storage);
    if(storage != none)
        remoteData  = storage.GetData(dataID);
}

function ServerSendBool(NiceRemoteHack.DataRef dataRef, bool varValue){
    SetupVars(dataRef);
    if(remoteData == none) return;
    remoteData.SetBool(dataVarName, varValue);
}

function ServerSendByte(NiceRemoteHack.DataRef dataRef, byte varValue){
    SetupVars(dataRef);
    if(remoteData == none) return;
    remoteData.SetByte(dataVarName, varValue);
}

function ServerSendInt(NiceRemoteHack.DataRef dataRef, int varValue){
    SetupVars(dataRef);
    if(remoteData == none) return;
    remoteData.SetInt(dataVarName, varValue);
}

function ServerSendFloat(NiceRemoteHack.DataRef dataRef, float varValue){
    SetupVars(dataRef);
    if(remoteData == none) return;
    remoteData.SetFloat(dataVarName, varValue);
}

function ServerSendString(NiceRemoteHack.DataRef dataRef, string varValue){
    SetupVars(dataRef);
    if(remoteData == none) return;
    remoteData.SetString(dataVarName, varValue);
}

function ServerSendClass(NiceRemoteHack.DataRef dataRef, class<Actor> varValue){
    SetupVars(dataRef);
    if(remoteData == none) return;
    remoteData.SetClass(dataVarName, varValue);
}

simulated function ClientSendByte(  NiceRemoteHack.DataRef dataRef,
                                    byte varValue,
                                    bool replicationFinished){
    if(level.netMode == NM_DedicatedServer) return;
    //  Full 'SetupVars' is an overkill
    storageClient = NiceStorageClient(class'NicePack'.static.GetStorage(level));
    if(storageClient == none)   return;
    storageClient.CheckinByte(dataRef, varValue, replicationFinished);
}

simulated function ClientSendBool(  NiceRemoteHack.DataRef dataRef,
                                    bool varValue,
                                    bool replicationFinished){
    if(level.netMode == NM_DedicatedServer) return;
    //  Full 'SetupVars' is an overkill
    storageClient = NiceStorageClient(class'NicePack'.static.GetStorage(level));
    if(storageClient == none)   return;
    storageClient.CheckinBool(dataRef, varValue, replicationFinished);
}

simulated function ClientSendInt(   NiceRemoteHack.DataRef dataRef,
                                    int varValue,
                                    bool replicationFinished){
    if(level.netMode == NM_DedicatedServer) return;
    //  Full 'SetupVars' is an overkill
    storageClient = NiceStorageClient(class'NicePack'.static.GetStorage(level));
    if(storageClient == none)   return;
    storageClient.CheckinInt(dataRef, varValue, replicationFinished);
}

simulated function ClientSendFloat( NiceRemoteHack.DataRef dataRef,
                                    float varValue,
                                    bool replicationFinished){
    if(level.netMode == NM_DedicatedServer) return;
    //  Full 'SetupVars' is an overkill
    storageClient = NiceStorageClient(class'NicePack'.static.GetStorage(level));
    if(storageClient == none)   return;
    storageClient.CheckinFloat(dataRef, varValue, replicationFinished);
}

simulated function ClientSendString(NiceRemoteHack.DataRef dataRef,
                                    string varValue,
                                    bool replicationFinished){
    if(level.netMode == NM_DedicatedServer) return;
    //  Full 'SetupVars' is an overkill
    storageClient = NiceStorageClient(class'NicePack'.static.GetStorage(level));
    if(storageClient == none)   return;
    storageClient.CheckinString(dataRef, varValue, replicationFinished);
}

simulated function ClientSendClass( NiceRemoteHack.DataRef dataRef,
                                    class<Actor> varValue,
                                    bool replicationFinished){
    if(level.netMode == NM_DedicatedServer) return;
    //  Full 'SetupVars' is an overkill
    storageClient = NiceStorageClient(class'NicePack'.static.GetStorage(level));
    if(storageClient == none)   return;
    storageClient.CheckinClass(dataRef, varValue, replicationFinished);
}

function ServerCreateData(  NiceRemoteHack.DataRef dataRef,
                            NiceData.EDataPriority priority){
    local NiceServerData serverData;
    SetupVars(dataRef);
    if(ownerPlayer == none)     return;
    if(storageServer == none)   return;
    if(storageServer.CreateData(dataID, priority))
        ClientConnectionResponse(dataRef, NSCDR_CREATED, true);
    else{
        if(remoteData != none)
            //  We've failed to create new data because it already exists;
            ClientConnectionResponse(   dataRef, NSCDR_ALREADYEXISTS,
                                        remoteData.IsEmpty());
        else
            //  We've failed to create new data for some other reason.
            ClientConnectionResponse(dataRef, NSCDR_DOESNTEXIST, true);
    }
    serverData = NiceServerData(remoteData);
    if(serverData != none)
        serverData.AddListener(ownerPlayer);
}

function ServerAddListener(NiceRemoteHack.DataRef dataRef){
    local NiceServerData serverData;
    SetupVars(dataRef);
    if(ownerPlayer == none)     return;
    if(storageServer == none)   return;
    serverData = NiceServerData(remoteData);
    if(serverData != none){
        ClientConnectionResponse(   dataRef, NSCDR_CONNECTED,
                                    serverData.IsEmpty());
    }
    else
        ClientConnectionResponse(dataRef, NSCDR_DOESNTEXIST, true);
    if(serverData != none)
        serverData.AddListener(ownerPlayer);
}

function ServerAskDataExist(NiceRemoteHack.DataRef dataRef){
    SetupVars(dataRef);
    if(storage == none) return;
    ClientDataExistResponse(dataRef, storage.DoesDataExistLocally(dataID));
}

simulated function ClientDataExistResponse( NiceRemoteHack.DataRef dataRef,
                                            bool doesExist){
    if(level.netMode == NM_DedicatedServer) return;
    SetupVars(dataRef);
    if(storage == none) return;
    storage.events.static.CallDataExistResponse(dataID, doesExist);
}

simulated function ClientConnectionResponse
    (
        NiceRemoteHack.DataRef dataRef,
        NiceStorageBase.ECreateDataResponse response,
        bool replicationFinished
    ){
    if(level.netMode == NM_DedicatedServer) return;
    SetupVars(dataRef);
    if(storageClient == none) return;
    if(response != NSCDR_DOESNTEXIST)
        storageClient.CheckinData(dataRef, replicationFinished);
    storageClient.events.static.CallConnectionRequestResponse(dataID, response);
}

simulated function ClientOpenWriteRights(NiceRemoteHack.DataRef dataRef){
    local NiceClientData clientData;
    if(level.netMode == NM_DedicatedServer) return;
    SetupVars(dataRef);
    clientData = NiceClientData(remoteData);
    if(clientData == none)
        return;
    clientData.SetWriteRights(dataRef, true);
    storageClient.events.static.CallWriteAccessGranted(dataID, ownerPlayer);
}

simulated function ClientCloseWriteRights(NiceRemoteHack.DataRef dataRef){
    local NiceClientData clientData;
    if(level.netMode == NM_DedicatedServer) return;
    SetupVars(dataRef);
    clientData = NiceClientData(remoteData);
    if(clientData == none)
        return;
    clientData.SetWriteRights(dataRef, false);
    storageClient.events.static.CallWritingAccessRevoked(dataID, ownerPlayer);
}

simulated function ClientRefuseWriteRights(NiceRemoteHack.DataRef dataRef){
    if(level.netMode == NM_DedicatedServer) return;
    SetupVars(dataRef);
    storageClient.events.static.CallWriteAccessRefused(dataID, ownerPlayer);
}

function ServerRequestWriteAccess(NiceRemoteHack.DataRef dataRef){
    SetupVars(dataRef);
    if(storageServer == none) return;
    storageServer.OpenWriteAccess(dataRef, ownerPlayer);
}

function ServerGiveupWriteAccess(NiceRemoteHack.DataRef dataRef){
    SetupVars(dataRef);
    if(storageServer == none) return;
    storageServer.CloseWriteAccess(dataRef);
}

defaultproperties
{
}