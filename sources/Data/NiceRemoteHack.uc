//==============================================================================
//  NicePack / NiceRemoteHack
//==============================================================================
//  Structure introduced for simple 'hack':
//      ~ We want our replication info class to call methods that
//          we would otherwise mark as 'protected';
//      ~ To make this possible we introduce this structure that would can only
//          be filled with valid data (non-empty name of relevant data)
//          by other protected methods of this class;
//      ~ Methods that that we wish only replication info to access will accept
//          this structure as a parameter and only function if
//          it's filled with valid data.
//      ~ This way users won't be able to actually make these methods
//          do any work, but replication info, that will be called from within
//          with valid 'DataRef' structure, will be able to invoke them.
//      ~ In addition we add the ability for this structure
//          to point at a specific variable.
//      ~ Such variables are marked with '#private' in comments.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceRemoteHack extends Object
    abstract;

struct DataRef{
    var protected string ID;
    var protected string variable;
};

//  Creates validation structure for data set with a given name
protected function DataRef V(string ID, optional string variable){
    local DataRef validRef;
    validRef.ID = ID;
    validRef.variable = variable;
    return validRef;
}

static function string GetDataRefID(DataRef dataRef){
    return dataRef.ID;
}

static function string GetDataRefVar(DataRef dataRef){
    return dataRef.variable;
}