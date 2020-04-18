class NiceCollisionManager extends Actor;
struct SphereCollision{
    var int         ID;
    var float       radius;
    var NiceMonster base;
    var bool        bDiscarded;
    var float       endTime;
};
var float lastCleanupTime;
var array<SphereCollision>  collisionSpheres;
function bool IsCollisionSpoiled(SphereCollision collision){
    return (collision.base == none || collision.base.health <= 0 || collision.bDiscarded || Level.TimeSeconds > collision.endTime);
}
function bool CubeCheck(Vector a, Vector b, float minX, float minY, float minZ, float cubeSide){
    if( (a.x < minX && b.x < minX) || (a.x > minX + 2 * cubeSide && b.x > minX + 2 * cubeSide) )
       return false;
    if( (a.y < minY && b.y < minY) || (a.y > minY + 2 * cubeSide && b.y > minY + 2 * cubeSide) )
       return false;
    if( (a.z < minZ && b.z < minZ) || (a.z > minZ + 2 * cubeSide && b.z > minZ + 2 * cubeSide) )
       return false;
    return true;
}
function AddSphereCollision(int ID, float radius, NiceMonster colOwner, float endTiming){
    local SphereCollision newCollision;
    newCollision.ID         = ID;
    newCollision.radius     = radius;
    newCollision.base       = colOwner;
    newCollision.endTime    = endTiming;
    CleanCollisions();
    collisionSpheres[collisionSpheres.Length] = newCollision;
}
function RemoveSphereCollision(int ID){
    local int i;
    for(i = 0;i < collisionSpheres.Length;i ++)
       if(collisionSpheres[i].ID == ID)
           collisionSpheres[i].bDiscarded = true;
    CleanCollisions();
}
function bool CheckSphereCollision(Vector a, Vector b, SphereCollision collision){
    local Vector    segmentVector;
    local float     sqDistToProjCenter;
    local float     squaredRadius;
    if(IsCollisionSpoiled(collision))
       return false;
    if(!CubeCheck(a, b, collision.base.location.x - collision.radius,
                       collision.base.location.y - collision.radius,
                       collision.base.location.z - collision.radius, collision.radius))
       return false;
    squaredRadius = collision.radius ** 2;
    if(VSizeSquared(a - collision.base.location) <= squaredRadius)
       return true;
    if(VSizeSquared(b - collision.base.location) <= squaredRadius)
       return true;
    segmentVector       = b - a;
    sqDistToProjCenter  = (collision.base.location - a) dot segmentVector;
    if(sqDistToProjCenter < 0)
       return false;
    sqDistToProjCenter = sqDistToProjCenter ** 2;
    sqDistToProjCenter = sqDistToProjCenter / (segmentVector dot segmentVector);
    if(sqDistToProjCenter < squaredRadius)
       return true;
    return false;
}
function bool IsCollidingWithAnything(Vector a, Vector b){
    local int i;
    for(i = 0;i < collisionSpheres.Length;i ++)
       if(CheckSphereCollision(a, b, collisionSpheres[i]))
           return true;
    return false;
}
function CleanCollisions(){
    local int                       i;
    local bool                      bNeedsCleaning;
    local array<SphereCollision>    newSpheresArray;
    if(lastCleanupTime + 1.0 > Level.TimeSeconds)
       return;
    lastCleanupTime = Level.TimeSeconds;
    for(i = 0;i < collisionSpheres.Length;i ++)
       if(IsCollisionSpoiled(collisionSpheres[i])){
           bNeedsCleaning = true;
           break;
       }
    if(bNeedsCleaning){
       for(i = 0;i < collisionSpheres.Length;i ++)
           if(!IsCollisionSpoiled(collisionSpheres[i]))
               newSpheresArray[newSpheresArray.Length] = collisionSpheres[i];
    }
    collisionSpheres = newSpheresArray;
}
defaultproperties
{
    bHidden=True
}
