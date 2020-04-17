class NiceDualiesAttachment extends NiceAttachment;
var bool bIsOffHand, bMyFlashTurn;
var NiceDualiesAttachment brother;
var Mesh BrotherMesh;
replication{
    reliable if(Role == ROLE_Authority)
      brother;
}
simulated function DoFlashEmitter(){
    if(bIsOffHand)
       return;
    if(bMyFlashTurn)
       ActuallyFlash();
    else if(brother != none)
       brother.ActuallyFlash();
}
simulated function ActuallyFlash(){
    super.DoFlashEmitter();
}
simulated event ThirdPersonEffects(){
    local NicePlayerController PC;
    if((Level.NetMode == NM_DedicatedServer) || (Instigator == none))
       return;
    PC = NicePlayerController(Level.GetLocalPlayerController());
    if(FiringMode == 0){
       if(OldSpawnHitCount != SpawnHitCount){
           OldSpawnHitCount = SpawnHitCount;
           GetHitInfo();
           if(((Instigator != none) && (Instigator.Controller == PC)) || (VSize(PC.ViewTarget.Location - mHitLocation) < 4000)){
               if(PC != Instigator.Controller){
                   if(mHitActor != none)
                       Spawn(class'ROBulletHitEffect',,, mHitLocation, Rotator(-mHitNormal));
                   CheckForSplash();
                   SpawnTracer();
               }
           }
       }
    }
    if(FlashCount > 0){
       if(KFPawn(Instigator) != none){
           if(bMyFlashTurn)
               KFPawn(Instigator).StartFiringX(false, bRapidFire);
           else
               KFPawn(Instigator).StartFiringX(true, bRapidFire);
       }
       if(bDoFiringEffects){
           if((Level.TimeSeconds - LastRenderTime > 0.2) && (Instigator.Controller != PC))
               return;
           if(bSpawnLight)
               WeaponLight();
           DoFlashEmitter();
           if(!bIsOffHand){
               if(!bMyFlashTurn)
                   ThirdPersonShellEject();
               else if(brother != none)
                   brother.ThirdPersonShellEject();
           }
       }
    }
    else{
       GotoState('');
       if(KFPawn(Instigator) != none)
           KFPawn(Instigator).StopFiring();
    }
}
simulated function vector GetTracerStart(){
    local Pawn p;
    p = Pawn(Owner);
    if((p != none) && p.IsFirstPerson() && p.Weapon != none)
       return p.Weapon.GetEffectStart();
    if(mMuzFlash3rd != none && bMyFlashTurn)
       return mMuzFlash3rd.Location;
    else if(brother != none && brother.mMuzFlash3rd != none && !bMyFlashTurn)
       return brother.mMuzFlash3rd.Location;
}

defaultproperties
{
     bMyFlashTurn=True
     BrotherMesh=SkeletalMesh'KF_Weapons3rd_Trip.Dual9mm_3rd'
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdPistol'
     mTracerClass=Class'KFMod.KFNewTracer'
     mShellCaseEmitterClass=Class'KFMod.KFShellSpewer'
     MovementAnims(0)="JogF_Dual9mm"
     MovementAnims(1)="JogB_Dual9mm"
     MovementAnims(2)="JogL_Dual9mm"
     MovementAnims(3)="JogR_Dual9mm"
     TurnLeftAnim="TurnL_Dual9mm"
     TurnRightAnim="TurnR_Dual9mm"
     CrouchAnims(0)="CHwalkF_Dual9mm"
     CrouchAnims(1)="CHwalkB_Dual9mm"
     CrouchAnims(2)="CHwalkL_Dual9mm"
     CrouchAnims(3)="CHwalkR_Dual9mm"
     WalkAnims(0)="WalkF_Dual9mm"
     WalkAnims(1)="WalkB_Dual9mm"
     WalkAnims(2)="WalkL_Dual9mm"
     WalkAnims(3)="WalkR_Dual9mm"
     CrouchTurnRightAnim="CH_TurnR_Dual9mm"
     CrouchTurnLeftAnim="CH_TurnL_Dual9mm"
     IdleCrouchAnim="CHIdle_Dual9mm"
     IdleWeaponAnim="Idle_Dual9mm"
     IdleRestAnim="Idle_Dual9mm"
     IdleChatAnim="Idle_Dual9mm"
     IdleHeavyAnim="Idle_Dual9mm"
     IdleRifleAnim="Idle_Dual9mm"
     FireAnims(0)="DualiesAttackRight"
     FireAnims(1)="DualiesAttackRight"
     FireAnims(2)="DualiesAttackRight"
     FireAnims(3)="DualiesAttackRight"
     FireAltAnims(0)="DualiesAttackLeft"
     FireAltAnims(1)="DualiesAttackLeft"
     FireAltAnims(2)="DualiesAttackLeft"
     FireAltAnims(3)="DualiesAttackLeft"
     FireCrouchAnims(0)="CHDualiesAttackRight"
     FireCrouchAnims(1)="CHDualiesAttackRight"
     FireCrouchAnims(2)="CHDualiesAttackRight"
     FireCrouchAnims(3)="CHDualiesAttackRight"
     FireCrouchAltAnims(0)="CHDualiesAttackLeft"
     FireCrouchAltAnims(1)="CHDualiesAttackLeft"
     FireCrouchAltAnims(2)="CHDualiesAttackLeft"
     FireCrouchAltAnims(3)="CHDualiesAttackLeft"
     HitAnims(0)="HitF_Dual9mmm"
     HitAnims(1)="HitB_Dual9mm"
     HitAnims(2)="HitL_Dual9mm"
     HitAnims(3)="HitR_Dual9mm"
     PostFireBlendStandAnim="Blend_Dual9mm"
     PostFireBlendCrouchAnim="CHBlend_Dual9mm"
}
