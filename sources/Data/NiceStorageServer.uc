//==============================================================================
//  NicePack / NiceStorageServer
//==============================================================================
//  Implements queue-related storage methods relevant only to server.
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceStorageServer extends NiceStorageServerBase
    config(NicePack);

function bool CanGrantWriteRights(  NiceServerData data,
                                    NicePlayerController clientRef){
    if(!super.CanGrantWriteRights(data, clientRef))
        return false;
    if(HasPendingChanges(data.GetID(), clientRef))
        return false;
    return true;
}

//  Checks if given data has some changes not yet replicated to the player.
//  Works only on a server.
function bool HasPendingChanges(string dataID, 
                                NicePlayerController nicePlayer){
    local NiceServerData    dataToCheck;
    local int               connectionIndex;
    local ClientConnection  connection;

    connectionIndex = FindConnection(nicePlayer);
    if(connectionIndex < 0)
        return false;
    connection = connections[connectionIndex];
    dataToCheck = NiceServerData(GetData(dataID));
    if(dataToCheck == none)
        return false;
    switch(dataToCheck.priority){
        case NSP_REALTIME:
            return false;
        case NSP_HIGH:
            return HasPendingChangesInQueue(dataID,
                                            connection.highPriorityQueue);
        default:
            return HasPendingChangesInQueue(dataID,
                                            connection.lowPriorityQueue);
    }
    return false;
}

protected function bool HasPendingChangesInQueue(   string dataID,
                                                    RequestQueue queue){
    local int i;
    for(i = queue.newIndex;i < queue.requests.length;i ++)
        if(queue.requests[i].dataID == dataID)
            return true;
    return false;
}

protected function bool DoesQueueContainRequest
    (
        RequestQueue queue,
        ReplicationRequest request
    ){
    local int i;
    for(i = queue.newIndex;i < queue.requests.length;i ++)
        if(queue.requests[i] == request)
            return true;
    return false;
}

//  Replicates most pressing request for given connection.
//  Returns 'true' if we were able to replicate something.
protected function bool ReplicateTopConnectionRequest
    (
        NicePlayerController clientRef
    ){
    local int               queueLength;
    local int               connectionIndex;
    local ClientConnection  connectionCopy;

    connectionIndex = FindConnection(clientRef);
    if(connectionIndex < 0)
        return false;
    connectionCopy = connections[connectionIndex];
    //  Try high priority queue
    queueLength = connectionCopy.highPriorityQueue.requests.length -
        connectionCopy.highPriorityQueue.newIndex;
    if(queueLength > 0){
        ReplicateTopQueueRequest(clientRef, connectionCopy.highPriorityQueue);
        connections[connectionIndex] = connectionCopy;
        return true;
    }
    //  Then, if high-priority one was empty, try low priority queue
    queueLength = connectionCopy.lowPriorityQueue.requests.length -
        connectionCopy.lowPriorityQueue.newIndex;
    if(queueLength > 0){
        ReplicateTopQueueRequest(clientRef, connectionCopy.lowPriorityQueue);
        connections[connectionIndex] = connectionCopy;
        return true;
    }
    return false;
}

//  Replicates top request of given queue and removes former from the latter.
//      - Requires queue to be non-empty.
//      - Doesn't check if client and queue are related.
protected function ReplicateTopQueueRequest(NicePlayerController clientRef,
                                            out RequestQueue queue){
    local ReplicationRequest    request;
    local NiceServerData        dataToReplicate;
    local bool                  replicationFinished;
    request = queue.requests[queue.newIndex];
    dataToReplicate = NiceServerData(GetData(request.dataID));
    if(dataToReplicate == none)
        return;

    //  Update queue index first, so that 'HasPendingChanges'
    //  can return an up-to-date result.
    queue.newIndex ++;
    replicationFinished = !HasPendingChanges(   dataToReplicate.GetID(),
                                                clientRef);
    dataToReplicate.ReplicateVariableToClient(  V(request.dataID),
                                                request.variable, clientRef,
                                                replicationFinished);
    //  Preserve invariant
    if(queue.newIndex >= queue.requests.length){
        queue.newIndex = 0;
        queue.requests.length = 0;
    }
}

protected function PushRequestToConnection
    (   ReplicationRequest request,
        NicePlayerController clientRef,
        NiceData.EDataPriority priority
    ){
    local int               connectionIndex;
    local RequestQueue      givenQueue;
    local ClientConnection  connectionCopy;
    if(priority == NSP_REALTIME) return;

    connectionIndex = FindConnection(clientRef);
    if(connectionIndex < 0)
        return;
    connectionCopy = connections[connectionIndex];
    //  Use appropriate queue
    switch(priority){
        case NSP_HIGH:
            givenQueue = connectionCopy.highPriorityQueue;
            if(!DoesQueueContainRequest(givenQueue, request)){
                connectionCopy.highPriorityQueue.
                    requests[givenQueue.requests.length] = request;
            }
            break;
        case NSP_LOW:
            givenQueue = connectionCopy.lowPriorityQueue;
            if(!DoesQueueContainRequest(givenQueue, request)){
                connectionCopy.lowPriorityQueue.
                    requests[givenQueue.requests.length] = request;
            }
            break;
        default:
            return;
    }
    connections[connectionIndex] = connectionCopy;
}

//  Pushes requests to replicate variable change to all active connections
//  #private
function PushRequestIntoQueues( NiceRemoteHack.DataRef dataRef,
                                string variableName,
                                NiceData.EDataPriority priority){
    local int                   i;
    local NiceServerData        data;
    local ReplicationRequest    request;
    data = NiceServerData(GetData(dataRef.ID));
    if(data == none)
        return;
    request.dataID      = data.GetID();
    request.variable    = variableName;
    for(i = 0;i < connections.length;i ++)
        if(data.IsListener(connections[i].player))
            PushRequestToConnection(request, connections[i].player, priority);
}

//  Pushes requests necessary to perform initial replication
//      of given 'updatedData' to given 'nicePlayer'
//  #private
function PushDataIntoQueue( NiceRemoteHack.DataRef dataRef,
                            NicePlayerController clientRef,
                            NiceData.EDataPriority priority){
    local int                   i;
    local NiceServerData        dataToPush;
    local ReplicationRequest    request;
    local array<string>         dataVariables;
    dataToPush = NiceServerData(GetData(dataRef.ID));
    if(dataToPush == none)
        return;
    request.dataID = dataToPush.GetID();
    dataVariables = dataToPush.GetVariableNames();
    for(i = 0;i < dataVariables.length;i ++){
        request.variable = dataVariables[i];
        PushRequestToConnection(request, clientRef, priority);
    }
}

function Tick(float delta){
    local int   i;
    local bool  didReplicate;
    for(i = 0;i < connections.length;i ++){
        if(connections[i].replicationCountdown > 0)
            connections[i].replicationCountdown -= delta;
        if(connections[i].replicationCountdown <= 0.0){
            didReplicate = ReplicateTopConnectionRequest(connections[i].player);
            if(didReplicate)
                connections[i].replicationCountdown = replicationCooldown;
        }
    }
}

defaultproperties
{
}