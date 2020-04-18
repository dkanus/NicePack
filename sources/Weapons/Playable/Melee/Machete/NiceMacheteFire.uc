class NiceMacheteFire extends NiceMeleeFire;
var name LastFireAnim;
function name GetCorrectAnim(bool bLoop, bool bAimed){
    FireAnim = super.GetCorrectAnim(bLoop, bAimed);
    if( LastFireAnim == FireAnims[1] && FireAnim == FireAnims[2]
       || LastFireAnim == FireAnims[2] && FireAnim == FireAnims[1]
       || LastFireAnim == FireAnims[2] && FireAnim == FireAnims[2])
       FireAnim = FireAnims[0];
    LastFireAnim = FireAnim;
    return FireAnim;
}
defaultproperties
{
    weaponRange=95.000000
    damageDelay=0.570000
    FireAnims(0)="Fire"
    FireAnims(1)="Fire2"
    FireAnims(2)="fire3"
    FireAnims(3)="Fire4"
    HitEffectClass=Class'KFMod.KnifeHitEffect'
    MeleeHitSoundRefs(0)="KF_AxeSnd.Axe_HitFlesh"
    DamageType=Class'NicePack.NiceDamTypeMachete'
    DamageMax=70
    FireAnimRate=0.893333
    FireRate=0.710000
    BotRefireRate=0.710000
}
