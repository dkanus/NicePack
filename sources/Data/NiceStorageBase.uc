//==============================================================================
//  NicePack / NiceStorageBase
//==============================================================================
//  Basic storage interface for creating and fetching data instances,
//      relevant on both client and server.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceStorageBase extends NiceRemoteHack
    abstract
    config(NicePack);

var const class<NiceRemoteDataEvents>   events;
//  Type of actor variables used on this storage to collect data
var const class<NiceData>               dataClass;
//  Data collected so far
var protected array<NiceData>           localStorage;

enum ECreateDataResponse{
    NSCDR_CONNECTED,
    NSCDR_ALREADYEXISTS,
    NSCDR_CREATED,
    NSCDR_DOESNTEXIST
};

function bool CreateData(string ID, NiceData.EDataPriority priority);

function bool DoesDataExistLocally(string ID){
    if(GetData(ID) == none)
        return false;
    return true;
}

function NiceData GetData(string ID){
    local int i;
    for(i = 0;i < localStorage.length;i ++){
        if(localStorage[i] == none) continue;
        if(localStorage[i].GetID() ~= ID)
            return localStorage[i];
    }
    return none;
}

defaultproperties
{
    dataClass=class'NiceData'
    events=class'NiceRemoteDataEvents'
}