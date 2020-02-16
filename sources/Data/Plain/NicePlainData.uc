//==============================================================================
//  NicePack / NicePlainData
//==============================================================================
//  Provides functionality for local data storage of named variables for
//      following types:
//      bool, byte, int, float, string, class<Object>.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NicePlainData extends Object;

struct DataPair{
    var string key;
    var string value;
};

struct Data{
    var array<DataPair> pairs;
};

// Returns index of variable with name 'varName', returns -1 if no entry found
static function int LookupVar(Data mySet, string varName){
    local int i;
    for(i = 0;i < mySet.pairs.length;i ++)
        if(mySet.pairs[i].key ~= varName)
            return i;
    return -1;
}

static function bool GetBool(   Data mySet,
                                string varName,
                                optional bool defaultValue){
    local int index;
    index = LookupVar(mySet, varName);
    if(index < 0)
        return defaultValue;
    else
        return bool(mySet.pairs[index].value);
}
 

static function SetBool(out Data mySet, string varName, bool varValue){
    local int       index;
    local DataPair  newPair;
    index = LookupVar(mySet, varName);
    if(index < 0){
        newPair.key     = varName;
        newPair.value   = string(varValue);
        mySet.pairs[mySet.pairs.length] = newPair;
    }
    else
        mySet.pairs[index].value = string(varValue);
}

static function byte GetByte(   Data mySet,
                                string varName,
                                optional byte defaultValue){
    local int index;
    index = LookupVar(mySet, varName);
    if(index < 0)
        return defaultValue;
    else
        return byte(mySet.pairs[index].value);
}

static function SetByte(out Data mySet, string varName, byte varValue){
    local int       index;
    local DataPair  newPair;
    index = LookupVar(mySet, varName);
    if(index < 0){
        newPair.key     = varName;
        newPair.value   = string(varValue);
        mySet.pairs[mySet.pairs.length] = newPair;
    }
    else
        mySet.pairs[index].value = string(varValue);
}

static function int GetInt( Data mySet,
                            string varName,
                            optional int defaultValue){
    local int index;
    index = LookupVar(mySet, varName);
    if(index < 0)
        return defaultValue;
    else
        return int(mySet.pairs[index].value);
}

static function SetInt(out Data mySet, string varName, int varValue){
    local int       index;
    local DataPair  newPair;
    index = LookupVar(mySet, varName);
    if(index < 0){
        newPair.key     = varName;
        newPair.value   = string(varValue);
        mySet.pairs[mySet.pairs.length] = newPair;
    }
    else
        mySet.pairs[index].value = string(varValue);
}

static function float GetFloat( Data mySet,
                                string varName,
                                optional float defaultValue){
    local int index;
    index = LookupVar(mySet, varName);
    if(index < 0)
        return defaultValue;
    else
        return float(mySet.pairs[index].value);
}

static function SetFloat(out Data mySet, string varName, float varValue){
    local int       index;
    local DataPair  newPair;
    index = LookupVar(mySet, varName);
    if(index < 0){
        newPair.key     = varName;
        newPair.value   = string(varValue);
        mySet.pairs[mySet.pairs.length] = newPair;
    }
    else
        mySet.pairs[index].value = string(varValue);
}

static function string GetString(   Data mySet,
                                    string varName,
                                    optional string defaultValue){
    local int index;
    index = LookupVar(mySet, varName);
    if(index < 0)
        return defaultValue;
    else
        return mySet.pairs[index].value;
}

static function SetString(out Data mySet, string varName, string varValue){
    local int       index;
    local DataPair  newPair;
    index = LookupVar(mySet, varName);
    if(index < 0){
        newPair.key     = varName;
        newPair.value   = varValue;
        mySet.pairs[mySet.pairs.length] = newPair;
    }
    else
        mySet.pairs[index].value = varValue;
}

static function class<Object> GetClass( Data mySet,
                                        string varName,
                                        optional class<Object> defaultValue){
    local int       index;
    local string    className;
    index = LookupVar(mySet, varName);
    if(index < 0)
        return defaultValue;
    className = mySet.pairs[index].value;
    return class<Object>(DynamicLoadObject(className, class'Class'));
}

static function SetClass(   out Data mySet,
                            string varName,
                            optional class<Object> varValue){
    local int       index;
    local DataPair  newPair;
    index = LookupVar(mySet, varName);
    if(index < 0){
        newPair.key     = varName;
        newPair.value   = string(varValue);
        mySet.pairs[mySet.pairs.length] = newPair;
    }
    else
        mySet.pairs[index].value = string(varValue);
}

defaultproperties
{
}