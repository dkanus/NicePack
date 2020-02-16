//==============================================================================
//  NicePack / NiceBulletSpawner
//==============================================================================
//  Class that is supposed to handle bullet spawning.
//  It's main purpose is to allow spawning of large amounts of bullets with
//  minimal replication between server and clients, which is supposed to be
//  achieved via commands that can spawn multiple bullets at once,
//  while 'syncing' any randomness by replicating seeds to it's own RNG.
//  Functionality:
//      - 'Xorshift' RNG implementation
//      - Ability to spawn both single bullets and groups of them
//          via single replication call
//==============================================================================
//  Class hierarchy: Object > Actor > NiceBulletSpawner
//==============================================================================
//  'Nice pack' source
//  Do whatever the fuck you want with it
//  Author: dkanus
//  E-mail: dkanus@gmail.com
//==============================================================================
class NiceBulletSpawner extends Actor
    dependson(NiceFire);


//==============================================================================
//==============================================================================
//  >   Random number generation
//  Variables and structures related to generating pseudo-random numbers, but
//  completly determined by a random state object ('NiceRandomState').
//  For that task we use xorshift algorithm, described here:
//  https://en.wikipedia.org/wiki/Xorshift
//  (page version as of 21 September 2016)
//
//  This class doesn't bother with replicating random states, and all the work
//  for their syncronization must be done via some other means.

//==============================================================================
//  >>  State of the psudo-random number generator
//  This structure contains four integer values used in our version of xorshift
struct NiceRandomState{
    var int x, y, z, w;
};


//==============================================================================
//==============================================================================
//  >   RNG-related functions

//  Generates new random state (seed).
//  This must be called on one machine only (server or client) and then
//  replicated to other meachines that are required to generate the same
//  sequence of random numbers.
//  Separetely calling it on different machines will produce different seeds
//  and different random sequences.
static function NiceRandomState GenerateRandomState(){
    local NiceRandomState newState;
    newState.x = Rand(MaxInt);
    newState.y = Rand(MaxInt);
    newState.z = Rand(MaxInt);
    newState.w = Rand(MaxInt);
    return newState;
}

//  Generates new random float between 0 and 'maxValue'
//  and modifies the used state as a result.
//  In case 'maxValue' is less than 1, - it'll be treated as 1.
static function int GetRandomInt(   out NiceRandomState randomState,
                                    int maxValue){
    local int t;
    local int randomValue;
    //  This part was taken from:
    //  https://en.wikipedia.org/wiki/Xorshift
    //  (page version as of 21 September 2016)
    t = randomState.x;
    t = t ^ (t << 11);
    t = t ^ (t >> 8);
    randomState.x = randomState.y;
    randomState.y = randomState.z;
    randomState.z = randomState.w;
    randomState.w = randomState.w ^ (randomState.w >> 19);
    randomState.w = randomState.w ^ t;
    //  This is the supposed output random value,
    //  but since it can be negative...
    randomValue = randomState.w;
    //  ...we will force it to be positive;
    //  (the case when 'randomValue' turns out to be the minimal possible value
    //  won't compromise anything for us)
    if(randomValue < 0)
        randomValue = -randomValue;
    //  Now quit if the value generated is indeed lower than 'maxValue'...
    maxValue = Max(maxValue, 1);
    if(randomState.w <= maxValue)
        return randomState.w;
    //  ...because this will mess things up when 'maxValue' == 'MaxInt'
    return (randomState.w % (maxValue + 1)) / maxValue;
}

//  Generates new random float between 0 and 1
//  and modifies the used state as a result.
static function float GetRandomFloat(out NiceRandomState randomState){
    return GetRandomInt(randomState, MaxInt) / MaxInt;
}


//==============================================================================
//==============================================================================
//  >   Bullet spawning-related functions

//  When called on a server -
//  replicates to all players a message about spawned bullets
//  (to cause them to spawn their ghost versions);
//
//  'bSkipOwner' flag allows to skip replicating this information
//  to the owner (instigator) of the bullets,
//  which is useful when used in 'DoNiceFireEffect' in 'NiceFire' class that's
//  called on both client and server.
//
//  When called on a client - instantly terminates itself
static function ReplicateBullets(   int amount,
                                    Vector start,
                                    Rotator dir,
                                    float spread,
                                    NiceFire.NWFireType fireType,
                                    NiceFire.NWCFireState fireState,
                                    bool bSkipOwner){
    local int                   i;
    local NicePack              niceMut;
    local NicePlayerController  bulletOwner;
    if(fireState.base.instigator == none) return;
    if(fireState.base.instigator.role < ROLE_Authority) return;
    niceMut = class'NicePack'.static.Myself(fireState.base.instigator.level);
    bulletOwner = fireState.base.instigatorCtrl;
    for(i = 0;i < niceMut.playersList.length;i ++){
        if(niceMut.playersList[i] == bulletOwner && bSkipOwner)
            continue;
        niceMut.playersList[i].ClientSpawnGhosts(amount, start,
                                                 dir.pitch, dir.yaw, dir.roll,
                                                 spread, fireType, fireState);
    }
}
//  Spawns a single bullet with no spread, exactly in the specified direction
static function SpawnSingleBullet(  Vector start,
                                    Rotator dir,
                                    NiceFire.NWFireType fireType,
                                    NiceFire.NWCFireState fireState){
    local Actor other;
    local NiceBullet niceBullet;
    local Vector hitLocation, hitNormal, traceDir;
    if(fireType.movement.bulletClass == none) return;
    if(fireState.base.instigator == none) return;
    //  Try to spawn
    niceBullet = fireState.base.instigator.
        Spawn(fireType.movement.bulletClass,,, start, dir);
    //  If the first projectile spawn failed it's probably because we're trying
    //  to spawn inside the collision bounds of an object with properties that
    //  ignore zero extent traces.
    //  We need to do a non-zero extent trace so
    //  we can find a safe spawn loc for our projectile
    if(niceBullet == none){
        traceDir = fireState.base.instigator.location +
            fireState.base.instigator.EyePosition();
        other = fireState.base.instigator.Trace(hitLocation, hitNormal, start,
                                                traceDir, false, Vect(0,0,1));
        if(other != none)
            start = hitLocation;
        niceBullet = fireState.base.instigator.
            Spawn( fireType.movement.bulletClass,,, start, dir);
    }
    //  Give up if failed after these two attempts
    if(niceBullet == none)
        return;
    //  Initialize bullet's data
    niceBullet.fireType   = fireType;
    niceBullet.fireState  = fireState;
    niceBullet.InitBullet();
}

//  Spawns a several bullets at once from the same location, but possibly
//  spreads them in different directions (if 'spread' is greater than zero)
//  by at most 'spread' angle (given in rotator units).
static function SpawnBullets(   int amount,
                                Vector start,
                                Rotator dir,
                                float spread,
                                NiceFire.NWFireType fireType,
                                NiceFire.NWCFireState fireState){
    local int       i;
    local Vector    dirVector;
    local Rotator   randomRot;
    dirVector = Vector(dir);
    for(i = 0;i < amount;i ++){
        if(spread > 0.0){
            randomRot.yaw   = spread * (FRand() - 0.5); // NICETODO: replace with proper fucking RNG, after adding syncronization of seeds
            randomRot.pitch = spread * (FRand() - 0.5);
        }
        SpawnSingleBullet(  start, Rotator(dirVector >> randomRot),
                            fireType, fireState);
    }
}

//  A usability function;
//  it calls 'SpawnBullets' on client (instigator) and
//  'ReplicateBullets' on server, without duplicating shots on the client.
//
//  Just a shortcut to use to fire bullets from 'NiceFire' class
static function FireBullets(int amount,
                            Vector start,
                            Rotator dir,
                            float spread,
                            NiceFire.NWFireType fireType,
                            NiceFire.NWCFireState fireState){
    if(fireState.base.instigator == none) return;

    if(fireState.base.instigator.role == ROLE_Authority)
        ReplicateBullets(amount, start, dir, spread, fireType, fireState, true);
    else
        SpawnBullets(amount, start, dir, spread, fireType, fireState);
}