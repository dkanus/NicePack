//==============================================================================
//  NicePack / NiceRemoteDataAdapter
//==============================================================================
//  Temporary stand-in for future functionality.
//  Use this class to catch events from storages.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceRemoteDataAdapter extends Object
    dependson(NiceStorageBase);

var LevelInfo level;

static function DataCreated(string dataID);

//  Called on clients the moment client storage connects to the server one.
static function LinkEstablished();

//  Called on client after server responds to his request
//      to check if certain data exists.
static function DataExistResponse(string dataID, bool doesExist);

//  Called on client after server responds to his connection request.
static function ConnectionRequestResponse
    (   string dataID,
        NiceStorageBase.ECreateDataResponse response
    );

//  Fired-off when writing rights to a certain data were granted.
//  Always called on server.
//  Only called on client that gained writing rights.
static function WriteAccessGranted( string dataID,
                                    NicePlayerController newOwner);

//  Fired-off when server refused to grant writing rights to data.
//  Always called on server.
//  Only called on client that tried to gain writing rights.
static function WriteAccessRevoked( string dataID,
                                    NicePlayerController newOwner);

//  Fired-off when writing rights to a certain data were revoked.
//  Always called on server.
//  Only called on client that lost writing rights.
static function WriteAccessRefused( string dataID,
                                    NicePlayerController newOwner);

//  Fired off on client when server finished sending him all the info about
//      particular data set.
static function DataUpToDate(string dataID);

//  Fire off on server and listening clients when
//      a particular variable was updated.
static function VariableUpdated(    string dataID,
                                    string varName);
static function BoolVariableUpdated(string dataID,
                                    string varName,
                                    bool newValue);
static function ByteVariableUpdated(string dataID,
                                    string varName,
                                    byte newValue);
static function IntVariableUpdated( string dataID,
                                    string varName,
                                    int newValue);
static function FloatVariableUpdated(   string dataID,
                                        string varName,
                                        float newValue);
static function StringVariableUpdated(  string dataID,
                                        string varName,
                                        string newValue);
static function ClassVariableUpdated(   string dataID,
                                        string varName,
                                        class<Actor> newValue);

defaultproperties
{
}