Class NiceHopMineProj extends HopMineProj;
#exec obj load file="KF_GrenadeSnd.uax"
#exec OBJ LOAD FILE=ScrnWeaponPack_T.utx
#exec OBJ LOAD FILE=ScrnWeaponPack_SND.uax   
#exec OBJ LOAD FILE=ScrnWeaponPack_A.ukx   
state OnWall
{
    simulated function BeginState()
    {       if ( SmokeTrail != none )       {           SmokeTrail.HandleOwnerDestroyed();           SmokeTrail = none;       }       bCollideWorld = False;       bFixedRotationDir = false;       RotationRate = rot(0,0,0);       if( Level.NetMode!=NM_DedicatedServer )       {           TweenAnim('Down',0.05f);           PlaySound(Sound'ScrnWeaponPack_SND.mine.blade_cut');           DotLight = Spawn(Class'HopMineLight',,,Location + (vect(0,0,5) << Rotation));           if( DotLight!=none )           {               DotLight.SetBase(Self);               DotLight.SetRelativeLocation(vect(0,0,5));           }       }       if( Level.NetMode!=NM_Client )       {           NetUpdateFrequency = 1.f;           SetTimer(0.25+FRand()*0.25,true);       }
    }
    simulated function EndState()
    {       if( Level.NetMode!=NM_Client )       {           SetTimer(0,false);           NetUpdateFrequency = Default.NetUpdateFrequency;           NetUpdateTime = Level.TimeSeconds-1;       }
    }
    function Timer()
    {       local Controller C;       local vector X,Y,Z;       local float DotP;       local int ThreatLevel;       local bool bA,bB;           GetAxes(Rotation,X,Y,Z);       for( C=Level.ControllerList; C!=none; C=C.nextController )           if( C.Pawn!=none && C.Pawn.Health>0 && VSizeSquared(C.Pawn.Location-Location)<1000000.f )           {               X = C.Pawn.Location-Location;               DotP = (X Dot Z);               if( DotP<0 )                   continue;               DotP = VSizeSquared(X - (Z * DotP));               if( DotP>90000.f || !FastTrace(C.Pawn.Location,Location) )                   continue;               if( Monster(C.Pawn)!=none )               {                   bB = true;                   if( DotP<35500.f )                   {                       Y = C.Pawn.Location;                       ThreatLevel+=C.Pawn.HealthMax;                   }               }               else bA = true;           }       if( bA!=bWarningTarget || bB!=bCriticalTarget )       {           bWarningTarget = bA;           bCriticalTarget = bB;           if( DotLight!=none )               DotLight.SetMode(bA,bB);           NetUpdateTime = Level.TimeSeconds-1;       }       if( bB && ThreatLevel>400 )       {           bWarningTarget = false;           bCriticalTarget = false;           RepLaunchPos = Y;           GoToState('LaunchMine');       }       else if( InstigatorController==none || bNeedsDetonate || (WeaponOwner!=none && WeaponOwner.NumMinesOut>WeaponOwner.MaximumMines) )       {           bWarningTarget = false;           bCriticalTarget = false;           RepLaunchPos = Location + Z*(150.f+FRand()*250.f);           GoToState('LaunchMine');       }
    }
    simulated function PostNetReceive()
    {       if( RepLaunchPos!=vect(0,0,0) )           GoToState('LaunchMine');       else if( DotLight!=none )           DotLight.SetMode(bWarningTarget,bCriticalTarget);
    }
}
defaultproperties
{
}
