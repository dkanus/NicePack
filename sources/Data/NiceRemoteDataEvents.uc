//==============================================================================
//  NicePack / NiceRemoteDataEvents
//==============================================================================
//  Temporary stand-in for future functionality.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceRemoteDataEvents extends Object
    dependson(NiceStorageBase);

var array< class<NiceRemoteDataAdapter> > adapters;

//  If adapter was already added also returns 'false'.
static function bool AddAdapter(class<NiceRemoteDataAdapter> newAdapter,
                                optional LevelInfo level){
    local int i;
    if(newAdapter == none) return false;
    for(i = 0;i < default.adapters.length;i ++)
        if(default.adapters[i] == newAdapter)
            return false;
    newAdapter.default.level = level;
    default.adapters[default.adapters.length] = newAdapter;
    return true;
}

//  If adapter wasn't even present also returns 'false'.
static function bool RemoveAdapter(class<NiceRemoteDataAdapter> adapter){
    local int i;
    if(adapter == none) return false;
    for(i = 0;i < default.adapters.length;i ++){
        if(default.adapters[i] == adapter){
            default.adapters.Remove(i, 1);
            return true;
        }
    }
    return false;
}

static function CallLinkEstablished(){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.LinkEstablished();
}

static function CallDataCreated(string dataID){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.DataCreated(dataID);
}

static function CallDataExistResponse(string dataID, bool doesExist){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.DataExistResponse(dataID, doesExist);
}

static function CallConnectionRequestResponse
    (   string dataID,
        NiceStorageBase.ECreateDataResponse response
    ){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.ConnectionRequestResponse(dataID, response);
}

static function CallVariableUpdated(string dataID, string variableName){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.VariableUpdated(dataID, variableName);
}

static function CallBoolVariableUpdated(string dataID, string variableName,
                                        bool newValue){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.BoolVariableUpdated( dataID, variableName,
                                                        newValue);
}

static function CallByteVariableUpdated(string dataID, string variableName,
                                        byte newValue){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.ByteVariableUpdated( dataID, variableName,
                                                        newValue);
}

static function CallIntVariableUpdated( string dataID, string variableName,
                                        int newValue){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.IntVariableUpdated(  dataID, variableName,
                                                        newValue);
}

static function CallFloatVariableUpdated(   string dataID, string variableName,
                                            float newValue){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.FloatVariableUpdated(dataID, variableName,
                                                        newValue);
}

static function CallStringVariableUpdated(  string dataID, string variableName,
                                            string newValue){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.StringVariableUpdated(   dataID,
                                                            variableName,
                                                            newValue);
}

static function CallClassVariableUpdated(   string dataID, string variableName,
                                            class<Actor> newValue){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.ClassVariableUpdated(dataID, variableName,
                                                        newValue);
}

static function CallDataUpToDate(string dataID){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.DataUpToDate(dataID);
}

static function CallWriteAccessGranted( string dataID,
                                        NicePlayerController newOwner){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.WriteAccessGranted(dataID, newOwner);
}

static function CallWritingAccessRevoked( string dataID,
                                        NicePlayerController newOwner){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.WriteAccessRevoked(dataID, newOwner);
}

static function CallWriteAccessRefused( string dataID,
                                        NicePlayerController newOwner){
    local int i;
    for(i = 0;i < default.adapters.length;i ++)
        default.adapters[i].static.WriteAccessRefused(dataID, newOwner);
}  