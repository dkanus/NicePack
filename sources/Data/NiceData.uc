//==============================================================================
//  NicePack / NiceData
//==============================================================================
//  Base class for remote data, defines basic interface,
//      used by both server and client storages.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceData extends NiceRemoteHack
    abstract
    config(NicePack);

var const class<NiceRemoteDataEvents> events;

enum EValueType{
    VTYPE_BOOL,
    VTYPE_BYTE,
    VTYPE_INT,
    VTYPE_FLOAT,
    VTYPE_STRING,
    VTYPE_CLASS,
    VTYPE_NULL      //  Variable doesn't exist (in this storage)
};

struct Variable{
    var protected string        myName;
    //  Value of what type is currently stored in this struct
    var protected EValueType    currentType;

    //  Containers for various value types
    var protected byte          storedByte;
    var protected int           storedInt;
    var protected bool          storedBool;
    var protected float         storedFloat;
    var protected string        storedString;
    var protected class<Actor>  storedClass;
};

enum EDataPriority{ //  Data change messages from server to client are...
    //  ...sent immediately;
    NSP_REALTIME,
    //  ...sent with time intervals between them;
    NSP_HIGH,
    //  ...sent with time intervals between them,
    //      but only if high-priority queue is empty.
    NSP_LOW
    //  Data change messages from clients are always sent immediately.
};

var protected string            ID;
var protected array<Variable>   variables;

static function NiceData NewData(string newID){
    local NiceData newData;
    newData = new class'NiceData';
    newData.ID = newID;
    return newData;
}

function string GetID(){
    return ID;
}

function bool IsEmpty(){
    return variables.length <= 0;
}

function EValueType GetVariableType(string variableName){
    local int index;
    index = GetVariableIndex(variableName);
    if(index < 0)
        return VTYPE_NULL;
    return variables[index].currentType;
}

function array<string> GetVariableNames(){
    local int           i;
    local array<string> mapResult;
    for(i = 0;i < variables.length;i ++)
        mapResult[i] = variables[i].myName;
    return mapResult;
}

protected function int GetVariableIndex(string variableName){
    local int i;
    for(i = 0;i < variables.length;i ++)
        if(variables[i].myName ~= variableName)
            return i;
    return -1;
}

//==============================================================================
//  >   Setter / getters for variables that perform necessary synchronization.

function SetByte(string variableName, byte variableValue);
function byte GetByte(string variableName, optional byte defaultValue){
    local int index;
    index = GetVariableIndex(variableName);
    if(index < 0)
        return defaultValue;
    if(variables[index].currentType != EValueType.VTYPE_BYTE)
        return defaultValue;
    return variables[index].storedByte;
}

function SetInt(string variableName, int variableValue);
function int GetInt(string variableName, optional int defaultValue){
    local int index;
    index = GetVariableIndex(variableName);
    if(index < 0)
        return defaultValue;
    if(variables[index].currentType != EValueType.VTYPE_INT)
        return defaultValue;
    return variables[index].storedInt;
}

function SetBool(string variableName, bool variableValue);
function bool GetBool(string variableName, optional bool defaultValue){
    local int index;
    index = GetVariableIndex(variableName);
    if(index < 0)
        return defaultValue;
    if(variables[index].currentType != EValueType.VTYPE_BOOL)
        return defaultValue;
    return variables[index].storedBool;
}

function SetFloat(string variableName, float variableValue);
function float GetFloat(string variableName, optional float defaultValue){
    local int index;
    index = GetVariableIndex(variableName);
    if(index < 0)
        return defaultValue;
    if(variables[index].currentType != EValueType.VTYPE_FLOAT)
        return defaultValue;
    return variables[index].storedFloat;
}

function SetString(string variableName, string variableValue);
function string GetString(string variableName, optional string defaultValue){
    local int index;
    index = GetVariableIndex(variableName);
    if(index < 0)
        return defaultValue;
    if(variables[index].currentType != EValueType.VTYPE_STRING)
        return defaultValue;
    return variables[index].storedString;
}

function SetClass(string variableName, class<Actor> variableValue);
function class<Actor> GetClass( string variableName,
                                optional class<Actor> defaultValue){
    local int index;
    index = GetVariableIndex(variableName);
    if(index < 0)
        return defaultValue;
    if(variables[index].currentType != EValueType.VTYPE_CLASS)
        return defaultValue;
    return variables[index].storedClass;
}

//==============================================================================
//  >   Setter that records variables locally, without any synchronization work.
//  #private
function _SetByte(DataRef dataRef, byte variableValue){
    local int       index;
    local Variable  newValue;
    newValue.myName         = dataRef.variable;
    newValue.storedByte     = variableValue;
    newValue.currentType    = VTYPE_BYTE;
    index = GetVariableIndex(dataRef.variable);
    if(index < 0)
        index = variables.length;
    variables[index] = newValue;
}

function _SetInt(DataRef dataRef, int variableValue){
    local int       index;
    local Variable  newValue;
    newValue.myName         = dataRef.variable;
    newValue.storedInt      = variableValue;
    newValue.currentType    = VTYPE_INT;
    index = GetVariableIndex(dataRef.variable);
    if(index < 0)
        index = variables.length;
    variables[index] = newValue;
}

function _SetBool(DataRef dataRef, bool variableValue){
    local int       index;
    local Variable  newValue;
    newValue.myName         = dataRef.variable;
    newValue.storedBool     = variableValue;
    newValue.currentType    = VTYPE_BOOL;
    index = GetVariableIndex(dataRef.variable);
    if(index < 0)
        index = variables.length;
    variables[index] = newValue;
}

function _SetFloat(DataRef dataRef, float variableValue){
    local int       index;
    local Variable  newValue;
    newValue.myName         = dataRef.variable;
    newValue.storedFloat    = variableValue;
    newValue.currentType    = VTYPE_FLOAT;
    index = GetVariableIndex(dataRef.variable);
    if(index < 0)
        index = variables.length;
    variables[index] = newValue;
}

function _SetString(DataRef dataRef, string variableValue){
    local int       index;
    local Variable  newValue;
    newValue.myName         = dataRef.variable;
    newValue.storedString   = variableValue;
    newValue.currentType    = VTYPE_STRING;
    index = GetVariableIndex(dataRef.variable);
    if(index < 0)
        index = variables.length;
    variables[index] = newValue;
}

function _SetClass(DataRef dataRef, class<Actor> variableValue){
    local int       index;
    local Variable  newValue;
    newValue.myName         = dataRef.variable;
    newValue.storedClass    = variableValue;
    newValue.currentType    = VTYPE_CLASS;
    index = GetVariableIndex(dataRef.variable);
    if(index < 0)
        index = variables.length;
    variables[index] = newValue;
}

defaultproperties
{
    events=class'NiceRemoteDataEvents'
}