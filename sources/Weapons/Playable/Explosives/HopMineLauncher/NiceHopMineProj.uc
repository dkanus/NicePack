Class NiceHopMineProj extends HopMineProj;
#exec obj load file="KF_GrenadeSnd.uax"
#exec OBJ LOAD FILE=ScrnWeaponPack_T.utx
#exec OBJ LOAD FILE=ScrnWeaponPack_SND.uax   
#exec OBJ LOAD FILE=ScrnWeaponPack_A.ukx   
state OnWall
{
    simulated function BeginState()
    {
    }
    simulated function EndState()
    {
    }
    function Timer()
    {
    }
    simulated function PostNetReceive()
    {
    }
}
defaultproperties
{
}