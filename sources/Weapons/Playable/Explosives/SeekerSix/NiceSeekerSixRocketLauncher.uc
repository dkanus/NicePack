class NiceSeekerSixRocketLauncher extends SeekerSixRocketLauncher;
//=============================================================================
// Functions
//=============================================================================
function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local NiceSeekerSixRocketProjectile Rocket;
    local NiceSeekerSixSeekingRocketProjectile SeekingRocket;
    bBreakLock = true;
    if (bLockedOn && SeekTarget != none)
    {
       SeekingRocket = Spawn(class'NiceSeekerSixSeekingRocketProjectile',,, Start, Dir);
       SeekingRocket.Seeking = SeekTarget;
       return SeekingRocket;
    }
    else
    {
       Rocket = Spawn(class'NiceSeekerSixRocketProjectile',,, Start, Dir);
       return Rocket;
    }
}
defaultproperties
{
    AppID=0
    FireModeClass(0)=Class'NicePack.NiceSeekerSixFire'
    FireModeClass(1)=Class'NicePack.NiceSeekerSixMultiFire'
    PickupClass=Class'NicePack.NiceSeekerSixPickup'
    ItemName="SeekerSix Rocket Launcher NW"
}
