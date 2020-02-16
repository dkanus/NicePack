// Zombie Monster for KF Invasion gametype
class NiceZombieCrawler extends NiceZombieCrawlerBase;
//----------------------------------------------------------------------------
// NOTE: All Variables are declared in the base class to eliminate hitching
//----------------------------------------------------------------------------
function bool DoPounce()
{
    if (bZapped || bIsCrouched || bWantsToCrouch || (Physics != PHYS_Walking) || VSize(Location - Controller.Target.Location) > (MeleeRange * 5))       return false;
    Velocity = Normal(Controller.Target.Location-Location)*PounceSpeed;
    Velocity.Z = JumpZ;
    SetPhysics(PHYS_Falling);
    ZombieSpringAnim();
    bPouncing=true;
    return true;
}
function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamType, optional int HitIndex)
{
    local int OldHeadHealth;
    OldHeadHealth = HeadHealth;
    Super(NiceMonster).TakeDamage(Damage, instigatedBy, hitLocation, momentum, DamType);
    // If crawler's head was damaged, but not yet removed -- I say kill the goddamn thing
    if(HeadHealth < OldHeadHealth && HeadHealth > 0)       RemoveHead();
}
simulated function ZombieSpringAnim()
{
    SetAnimAction('ZombieSpring');
}
event Landed(vector HitNormal)
{
    bPouncing=false;
    super.Landed(HitNormal);
}
event Bump(actor Other)
{
    // TODO: is there a better way
    if(bPouncing && KFHumanPawn(Other)!=none )
    {       KFHumanPawn(Other).TakeDamage(((MeleeDamage - (MeleeDamage * 0.05)) + (MeleeDamage * (FRand() * 0.1))), self ,self.Location,self.velocity, class 'NicePack.NiceZedMeleeDamageType');       if (KFHumanPawn(Other).Health <=0)       {           //TODO - move this to humanpawn.takedamage? Also see KFMonster.MeleeDamageTarget           KFHumanPawn(Other).SpawnGibs(self.rotation, 1);       }       //After impact, there'll be no momentum for further bumps       bPouncing=false;
    }
}
// Blend his attacks so he can hit you in mid air.
simulated function int DoAnimAction( name AnimName )
{
    if( AnimName=='InAir_Attack1' || AnimName=='InAir_Attack2' )
    {       AnimBlendParams(1, 1.0, 0.0,, FireRootBone);       PlayAnim(AnimName,, 0.0, 1);       return 1;
    }
    if( AnimName=='HitF' )
    {       AnimBlendParams(1, 1.0, 0.0,, NeckBone);       PlayAnim(AnimName,, 0.0, 1);       return 1;
    }
    if( AnimName=='ZombieSpring' )
    {       PlayAnim(AnimName,,0.02);       return 0;
    }
    return Super.DoAnimAction(AnimName);
}
simulated event SetAnimAction(name NewAction)
{
    local int meleeAnimIndex;
    if( NewAction=='' )       Return;
    if(NewAction == 'Claw')
    {       meleeAnimIndex = Rand(2);       if( Physics == PHYS_Falling )       {           NewAction = MeleeAirAnims[meleeAnimIndex];       }       else       {           NewAction = meleeAnims[meleeAnimIndex];       }
    }
    ExpectingChannel = DoAnimAction(NewAction);
    if( AnimNeedsWait(NewAction) )
    {       bWaitForAnim = true;
    }
    if( Level.NetMode!=NM_Client )
    {       AnimAction = NewAction;       bResetAnimAct = True;       ResetAnimActTime = Level.TimeSeconds+0.3;
    }
}
// The animation is full body and should set the bWaitForAnim flag
simulated function bool AnimNeedsWait(name TestAnim)
{
    if( TestAnim == 'ZombieSpring' || TestAnim == 'DoorBash' )
    {       return true;
    }
    return false;
}
function bool FlipOver()
{
    return true;
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.crawler_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.crawler_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.crawler_diff');
}
defaultproperties
{    stunLoopStart=0.110000    stunLoopEnd=0.570000    idleInsertFrame=0.900000    EventClasses(0)="NicePack.NiceZombieCrawler"    MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Talk'    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_HitPlayer'    JumpSound=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Jump'    DetachedArmClass=Class'KFChar.SeveredArmCrawler'    DetachedLegClass=Class'KFChar.SeveredLegCrawler'    DetachedHeadClass=Class'KFChar.SeveredHeadCrawler'    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Pain'    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Death'    ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Acquire'    ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Acquire'    ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Acquire'    ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Crawler.Crawler_Acquire'    ControllerClass=Class'NicePack.NiceZombieCrawlerController'    AmbientSound=Sound'KF_BaseCrawler.Crawler_Idle'    Mesh=SkeletalMesh'KF_Freaks_Trip.Crawler_Freak'    Skins(0)=Combiner'KF_Specimens_Trip_T.crawler_cmb'
}
