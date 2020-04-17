class NiceXMV850M extends NiceHeavyGun;
var float   DesiredSpeed;
var float   BarrelSpeed;
var int     BarrelTurn;
var Sound   BarrelSpinSound, BarrelStopSound, BarrelStartSound;
var String  BarrelSpinSoundRef, BarrelStopSoundRef, BarrelStartSoundRef;
static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount){
    local NiceXMV850M W;
    super.PreloadAssets(Inv, bSkipRefCount);
    if(default.BarrelSpinSound == none && default.BarrelSpinSoundRef != "")       default.BarrelSpinSound = sound(DynamicLoadObject(default.BarrelSpinSoundRef, class'sound', true));
    if(default.BarrelStopSound == none && default.BarrelStopSoundRef != "")       default.BarrelStopSound = sound(DynamicLoadObject(default.BarrelStopSoundRef, class'sound', true));
    if(default.BarrelStartSound == none && default.BarrelStartSoundRef != "")       default.BarrelStartSound = sound(DynamicLoadObject(default.BarrelStartSoundRef, class'sound', true));
    W = NiceXMV850M(Inv);
    if(W != none){       W.BarrelSpinSound = default.BarrelSpinSound;       W.BarrelStopSound = default.BarrelStopSound;       W.BarrelStartSound = default.BarrelStartSound;
    }
}
static function bool UnloadAssets(){
    if(super.UnloadAssets()){       default.BarrelSpinSound = none;       default.BarrelStopSound = none;       default.BarrelStartSound = none;
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
    if(FireMode[0].IsFiring()){       BarrelSpeed = BarrelSpeed + FClamp(DesiredSpeed - BarrelSpeed, -0.20 * dt, 0.40 * dt);       BarrelTurn += int(BarrelSpeed * float(655360) * dt);
    }
    else{       if(BarrelSpeed > 0){           BarrelSpeed = FMax(BarrelSpeed - 0.10 * dt, 0.01);           OldBarrelTurn = float(BarrelTurn);           BarrelTurn += int(BarrelSpeed * float(655360) * dt);           if(BarrelSpeed <= 0.03 && (int(OldBarrelTurn / 10922.67) < int(float(BarrelTurn) / 10922.67))){               BarrelTurn = int(float(int(float(BarrelTurn) / 10922.67)) * 10922.67);               BarrelSpeed = 0.00;               PlaySound(BarrelStopSound, SLOT_none, 0.50,, 32.00, 1.00, true);               AmbientSound = none;           }       }
    }
    if(BarrelSpeed > 0){       AmbientSound = BarrelSpinSound;       SoundPitch = byte(float(32) + float(96) * BarrelSpeed);
    }
    
    if(NiceXMV850Attachment(ThirdPersonActor) != none)       NiceXMV850Attachment(ThirdPersonActor).BarrelSpeed = BarrelSpeed;    
}
simulated function AltFire(float F){
    ToggleLaser();
}
simulated function ToggleLaser(){
    if(!Instigator.IsLocallyControlled())        return;
    // Will redo this bit later, but so far it'll have to do
    if(LaserType == 0)       LaserType = 3;
    else       LaserType = 0;
    ApplyLaserState();
}
defaultproperties
{    BarrelSpinSoundRef="HMG_S.XMV.XMV-BarrelSpinLoop"    BarrelStopSoundRef="HMG_S.XMV.XMV-BarrelSpinEnd"    BarrelStartSoundRef="HMG_S.XMV.XMV-BarrelSpinStart"    LaserAttachmentOffset=(X=120.000000,Z=-10.000000)    LaserAttachmentBone="Muzzle"    reloadPreEndFrame=0.201000    reloadEndFrame=0.729000    reloadChargeEndFrame=-1.000000    reloadMagStartFrame=0.340000    reloadChargeStartFrame=-1.000000    MagazineBone="BeltBone1"    MagCapacity=160    ReloadRate=4.400000    ReloadAnim="Reload"    ReloadAnimRate=1.000000    WeaponReloadAnim="Reload"    Weight=7.000000    StandardDisplayFOV=55.000000    TraderInfoTexture=Texture'HMG_T.XMV.Trader_XMV850'    MeshRef="HMG_A.XMV850Mesh"    SkinRefs(0)="HMG_T.XMV.XMV850_Main"    SkinRefs(1)="HMG_T.XMV.Hands_Shdr"    SkinRefs(2)="HMG_T.XMV.XMV850_Barrels_Shdr"    SelectSoundRef="HMG_S.XMV.XMV-Pullout"    HudImageRef="HMG_T.XMV.XMV850_Unselected"    SelectedHudImageRef="HMG_T.XMV.XMV850_Selected"    PlayerIronSightFOV=65.000000    ZoomedDisplayFOV=20.000000    FireModeClass(0)=Class'NicePack.NiceXMV850Fire'    FireModeClass(1)=Class'KFMod.NoFire'    PutDownAnim="Putaway"    SelectForce="SwitchToAssaultRifle"    AIRating=0.550000    CurrentRating=0.550000    bShowChargingBar=True    Description="Minigun with reduced fire rate down to 950RPM. But still badass and has laser sight."    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)    DisplayFOV=55.000000    Priority=135    CustomCrosshair=11    CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"    InventoryGroup=3    GroupOffset=7    PickupClass=Class'NicePack.NiceXMV850Pickup'    PlayerViewOffset=(X=30.000000,Y=20.000000,Z=-10.000000)    BobDamping=6.000000    AttachmentClass=Class'NicePack.NiceXMV850Attachment'    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)    ItemName="XMV850 Minigun"    TransientSoundVolume=0.625000
}