class NiceBossLAWProj extends LAWProj;
//-----------------------------------------------------------------------------
// PostBeginPlay
//-----------------------------------------------------------------------------
simulated function PostBeginPlay()
{
    // Difficulty Scaling
    if(Level.Game != none){       if(Level.Game.GameDifficulty >= 5.0) // Hell on Earth & Suicidal           damage = default.damage * 1.3;       else           damage = default.damage * 1.0;
    }
    super.PostBeginPlay();
}
defaultproperties
{    ArmDistSquared=0.000000    Damage=200.000000    MyDamageType=Class'KFMod.DamTypeFrag'
}
