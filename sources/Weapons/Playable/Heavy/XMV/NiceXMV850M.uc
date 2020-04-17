class NiceXMV850M extends NiceHeavyGun;
var float   DesiredSpeed;
var float   BarrelSpeed;
var int     BarrelTurn;
var Sound   BarrelSpinSound, BarrelStopSound, BarrelStartSound;
var String  BarrelSpinSoundRef, BarrelStopSoundRef, BarrelStartSoundRef;
static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount){
    local NiceXMV850M W;
    super.PreloadAssets(Inv, bSkipRefCount);
    if(default.BarrelSpinSound == none && default.BarrelSpinSoundRef != "")
    if(default.BarrelStopSound == none && default.BarrelStopSoundRef != "")
    if(default.BarrelStartSound == none && default.BarrelStartSoundRef != "")
    W = NiceXMV850M(Inv);
    if(W != none){
    }
}
static function bool UnloadAssets(){
    if(super.UnloadAssets()){
    }
    return true;
}
// XMV uses custom hands
simulated function HandleSleeveSwapping(){}
simulated event WeaponTick(float dt){
    local Rotator bt;
    super.WeaponTick(dt);
    bt.Roll = BarrelTurn;
    SetBoneRotation('Barrels', bt);
    DesiredSpeed = 0.50;
}
simulated event Tick(float dt){
    local float OldBarrelTurn;
    super.Tick(dt);
    if(FireMode[0].IsFiring()){
    }
    else{
    }
    if(BarrelSpeed > 0){
    }
    
    if(NiceXMV850Attachment(ThirdPersonActor) != none)
}
simulated function AltFire(float F){
    ToggleLaser();
}
simulated function ToggleLaser(){
    if(!Instigator.IsLocallyControlled()) 
    // Will redo this bit later, but so far it'll have to do
    if(LaserType == 0)
    else
    ApplyLaserState();
}
defaultproperties
{
}