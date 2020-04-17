class NiceXMV850Attachment extends NiceAttachment;
var byte NetBarrelSpeed;
var int BarrelTurn;
var float BarrelSpeed;
replication
{
    reliable if(Role == ROLE_Authority)       NetBarrelSpeed;
}
simulated event Tick(float dt){
    local Rotator bt;
    super.Tick(dt);
    if(Role == ROLE_Authority)       NetBarrelSpeed = byte(BarrelSpeed * float(255));
    else       BarrelSpeed = float(NetBarrelSpeed) / 255.00;
    if(Level.NetMode != NM_DedicatedServer){       BarrelTurn += int(BarrelSpeed * float(655360) * dt);       bt.Roll = BarrelTurn;       SetBoneRotation('Barrels', bt);
    }
}
defaultproperties
{    LaserAttachmentBone="Muzzle"    mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdMP'    mTracerClass=Class'KFMod.KFNewTracer'    mShellCaseEmitterClass=Class'KFMod.KFShellSpewer'    ShellEjectBoneName="ejector"    MovementAnims(0)="JogF_SCAR"    MovementAnims(1)="JogB_SCAR"    MovementAnims(2)="JogL_SCAR"    MovementAnims(3)="JogR_SCAR"    TurnLeftAnim="TurnL_SCAR"    TurnRightAnim="TurnR_SCAR"    CrouchAnims(0)="CHWalkF_SCAR"    CrouchAnims(1)="CHWalkB_SCAR"    CrouchAnims(2)="CHWalkL_SCAR"    CrouchAnims(3)="CHWalkR_SCAR"    WalkAnims(0)="WalkF_SCAR"    WalkAnims(1)="WalkB_SCAR"    WalkAnims(2)="WalkL_SCAR"    WalkAnims(3)="WalkR_SCAR"    CrouchTurnRightAnim="CH_TurnR_SCAR"    CrouchTurnLeftAnim="CH_TurnL_SCAR"    IdleCrouchAnim="CHIdle_SCAR"    IdleWeaponAnim="Idle_SCAR"    IdleRestAnim="Idle_SCAR"    IdleChatAnim="Idle_SCAR"    IdleHeavyAnim="Idle_SCAR"    IdleRifleAnim="Idle_SCAR"    FireAnims(0)="Fire_SCAR"    FireAnims(1)="Fire_SCAR"    FireAnims(2)="Fire_SCAR"    FireAnims(3)="Fire_SCAR"    FireAltAnims(0)="Fire_SCAR"    FireAltAnims(1)="Fire_SCAR"    FireAltAnims(2)="Fire_SCAR"    FireAltAnims(3)="Fire_SCAR"    FireCrouchAnims(0)="CHFire_SCAR"    FireCrouchAnims(1)="CHFire_SCAR"    FireCrouchAnims(2)="CHFire_SCAR"    FireCrouchAnims(3)="CHFire_SCAR"    FireCrouchAltAnims(0)="CHFire_SCAR"    FireCrouchAltAnims(1)="CHFire_SCAR"    FireCrouchAltAnims(2)="CHFire_SCAR"    FireCrouchAltAnims(3)="CHFire_SCAR"    HitAnims(0)="HitF_SCAR"    HitAnims(1)="HitB_SCAR"    HitAnims(2)="HitL_SCAR"    HitAnims(3)="HitR_SCAR"    PostFireBlendStandAnim="Blend_SCAR"    PostFireBlendCrouchAnim="CHBlend_SCAR"    MeshRef="HMG_A.XMV850_3rd"    bHeavy=True    bRapidFire=True    bAltRapidFire=True    SplashEffect=Class'ROEffects.BulletSplashEmitter'    CullDistance=5000.000000
}
