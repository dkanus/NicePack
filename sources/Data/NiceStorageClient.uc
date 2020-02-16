//==============================================================================
//  NicePack / NiceStorageClient
//==============================================================================
//  Implements storage methods relevant only to client.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceStorageClient extends NiceStorageBase
    config(NicePack);

var NiceRepInfoRemoteData remoteRI;

function bool ConnectData(string ID){
    if(ID == "")            return false;
    if(remoteRI == none)    return false;
    remoteRI.ServerAddListener(V(ID));
    return true;
}

function bool IsLinkEstablished(){
    return (remoteRI == none);
}

//  Requests a creation of remote data storage on server.
function bool CreateData(string ID, NiceData.EDataPriority priority){
    if(ID == "")                    return false;
    if(remoteRI == none)            return false;
    if(DoesDataExistLocally(ID))    return false;
    remoteRI.ServerCreateData(V(ID), priority);
    return true;
}

//  Checks if server has data with a given name.
//  Responds via calling 'DataExistResponse' event.
function DoesDataExistOnServer(string dataID){
    if(remoteRI == none) return;
    if(DoesDataExistLocally(dataID))
        events.static.CallDataExistResponse(dataID, true);
    else
        remoteRI.ServerAskDataExist(V(dataID));
}

//  Must be already connected to data to do this
function bool RequestWriteAccess(string dataID){
    if(remoteRI == none)                return false;
    if(!DoesDataExistLocally(dataID))   return false;
    remoteRI.ServerRequestWriteAccess(V(dataID));
    return true;
}

function bool GiveupWriteAccess(string dataID){
    local NiceClientData data;
    if(remoteRI == none)                return false;
    if(!DoesDataExistLocally(dataID))   return false;

    data = NiceClientData(GetData(dataID));
    if(data == none || !data.HasWriteRights())
        return false;
    data.SetWriteRights(V(dataID), false);
    remoteRI.ServerGiveupWriteAccess(V(dataID));
    return true;
}

//  #private
function CheckinData(DataRef dataRef, bool replicationFinished){
    local NiceClientData clientData;
    //  This shouldn't happen, but just in case
    if(DoesDataExistLocally(dataRef.ID)) return;
    //  Create data as requested
    clientData =
        NiceClientData(class'NiceClientData'.static.NewData(dataRef.ID));
    if(clientData == none)
        return;
    localStorage[localStorage.length] = clientData;
    clientData.SetOwnerStorage(dataRef, self);
    clientData.SetUpToDate(dataRef, replicationFinished);
}

//  #private
function CheckinBool(DataRef dataRef, bool value, bool replicationFinished){
    local NiceClientData clientData;

    clientData = NiceClientData(GetData(dataRef.ID));
    if(clientData == none)
        return;
    clientData.SetUpToDate(dataRef, replicationFinished);
    clientData._SetBool(dataRef, value);
    //  Events
    events.static.CallVariableUpdated(dataRef.ID, dataRef.variable);
    events.static.CallBoolVariableUpdated(dataRef.ID, dataRef.variable, value);
    if(replicationFinished)
        events.static.CallDataUpToDate(dataRef.ID);
}

function CheckinByte(DataRef dataRef, byte value, bool replicationFinished){
    local NiceClientData clientData;

    clientData = NiceClientData(GetData(dataRef.ID));
    if(clientData == none)
        return;
    clientData.SetUpToDate(dataRef, replicationFinished);
    clientData._SetByte(dataRef, value);
    //  Events
    events.static.CallVariableUpdated(dataRef.ID, dataRef.variable);
    events.static.CallByteVariableUpdated(dataRef.ID, dataRef.variable, value);
    if(replicationFinished)
        events.static.CallDataUpToDate(dataRef.ID);
}

function CheckinInt(DataRef dataRef, int value, bool replicationFinished){
    local NiceClientData clientData;

    clientData = NiceClientData(GetData(dataRef.ID));
    if(clientData == none)
        return;
    clientData.SetUpToDate(dataRef, replicationFinished);
    clientData._SetInt(dataRef, value);
    //  Events
    events.static.CallVariableUpdated(dataRef.ID, dataRef.variable);
    events.static.CallIntVariableUpdated(dataRef.ID, dataRef.variable, value);
    if(replicationFinished)
        events.static.CallDataUpToDate(dataRef.ID);
}

function CheckinFloat(DataRef dataRef, float value, bool replicationFinished){
    local NiceClientData clientData;

    clientData = NiceClientData(GetData(dataRef.ID));
    if(clientData == none)
        return;
    clientData.SetUpToDate(dataRef, replicationFinished);
    clientData._SetFloat(dataRef, value);
    //  Events
    events.static.CallVariableUpdated(dataRef.ID, dataRef.variable);
    events.static.CallFloatVariableUpdated(dataRef.ID, dataRef.variable, value);
    if(replicationFinished)
        events.static.CallDataUpToDate(dataRef.ID);
}

function CheckinString(DataRef dataRef, string value, bool replicationFinished){
    local NiceClientData clientData;

    clientData = NiceClientData(GetData(dataRef.ID));
    if(clientData == none)
        return;
    clientData.SetUpToDate(dataRef, replicationFinished);
    clientData._SetString(dataRef, value);
    //  Events
    events.static.CallVariableUpdated(dataRef.ID, dataRef.variable);
    events.static.CallStringVariableUpdated(dataRef.ID, dataRef.variable,
                                            value);
    if(replicationFinished)
        events.static.CallDataUpToDate(dataRef.ID);
}

function CheckinClass(  DataRef dataRef, class<Actor> value,
                        bool replicationFinished){
    local NiceClientData clientData;

    clientData = NiceClientData(GetData(dataRef.ID));
    if(clientData == none)
        return;
    clientData.SetUpToDate(dataRef, replicationFinished);
    clientData._SetClass(dataRef, value);
    //  Events
    events.static.CallVariableUpdated(dataRef.ID, dataRef.variable);
    events.static.CallClassVariableUpdated(dataRef.ID, dataRef.variable, value);
    if(replicationFinished)
        events.static.CallDataUpToDate(dataRef.ID);
}

//  NICETODO: to debug, remove later
function Print(NicePlayerController pc){
    local int i, j;
    local array<string> names;
    for(i = 0;i < localStorage.length;i ++){
        pc.ClientMessage("Data:"@localStorage[i].GetID());
        names = localStorage[i].GetVariableNames();
        for(j = 0;j < names.length;j ++){
            pc.ClientMessage(">" @ names[j] @ " = " @ String(localStorage[i].GetInt(names[j])));
        }
    }
}

defaultproperties
{
    dataClass=class'NiceClientData'
}