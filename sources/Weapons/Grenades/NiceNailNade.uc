class NiceNailNade extends NiceNade;
var int                         numberOfShards;
var NiceFire.ShotType           shotParams;
var NiceFire.FireModeContext    fireContext;
simulated function ReleaseNails(optional bool bServerOnly){
    local byte i;
    local NicePack niceMut;
    fireContext.continiousBonus = 1.0;
    fireContext.burstLength = 1;
    fireContext.instigator = NiceHumanPawn(instigator);
    shotParams.bShouldBounce = true;
    shotParams.damage = 52;
    shotParams.projSpeed = 3500.0;
    shotParams.momentum = 50000;
    shotParams.shotDamageType = class'NicePack.NiceDamTypeNailGun';
    shotParams.bulletClass = class'NicePack.NiceNail';
    shotParams.bCausePain = true;
    if(fireContext.instigator != none)
       niceMut = class'NicePack'.static.Myself(fireContext.Instigator.Level);
    if(bServerOnly){
       if(niceMut == none)
           return;
       for(i = 0;i < niceMut.playersList.Length;i ++)
           niceMut.playersList[i].ClientNailsExplosion(numberOfShards, location, shotParams, fireContext,
               niceMut.playersList[i] != fireContext.Instigator.Controller);
    }
    else if(Role < Role_AUTHORITY)
       for(i = 0;i < numberOfShards;i ++)
           class'NiceProjectileSpawner'.static.MakeProjectile(location, RotRand(true), shotParams, fireContext);
}
// Overloaded to implement nade skills
simulated function Explode(vector HitLocation, vector HitNormal){
    local PlayerController LocalPlayer;
    // Variables for skill-detection
    local NiceHumanPawn nicePawn;
    local class<NiceVeterancyTypes> niceVet;
    nicePawn = NiceHumanPawn(Instigator);
    if(nicePawn != none)
       niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(nicePawn.PlayerReplicationInfo);
    bHasExploded = true;
    BlowUp(HitLocation);
    // null reference fix
    if(ExplodeSounds.length > 0)
       PlaySound(ExplodeSounds[rand(ExplodeSounds.length)],,2.0);
    // Real shrapnel
    ReleaseNails();
    if(EffectIsRelevant(Location,false)){
       Spawn(Class'KFmod.KFNadeExplosion',,, HitLocation, rotator(vect(0,0,1)));
       Spawn(ExplosionDecal, self,, HitLocation, rotator(-HitNormal));
    }
    // Shake nearby players screens
    LocalPlayer = Level.GetLocalPlayerController();
    if((LocalPlayer != none) && (VSize(Location - LocalPlayer.ViewTarget.Location) < (DamageRadius * 1.5)))
       LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
    Destroy();
}
function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex){
    if(Monster(instigatedBy) != none || instigatedBy == Instigator){
       if(DamageType == class'SirenScreamDamage'){
           ReleaseNails(true);
           Disintegrate(HitLocation, vect(0,0,1));
       }
       else
           Explode(HitLocation, vect(0,0,1));
    }
}

defaultproperties
{
     numberOfShards=50
     Damage=50.000000
}
