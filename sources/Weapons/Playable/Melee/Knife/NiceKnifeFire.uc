class NiceKnifeFire extends NiceMeleeFire;
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
    damageDelay=0.450000
    MeleeHitSounds(0)=SoundGroup'KF_KnifeSnd.Knife_HitFlesh'
    FireAnims(0)="Fire"
    FireAnims(1)="Fire2"
    FireAnims(2)="fire3"
    FireAnims(3)="Fire4"
    HitEffectClass=Class'KFMod.KnifeHitEffect'
    WideDamageMinHitAngle=0.750000
    DamageType=Class'NicePack.NiceDamTypeKnife'
    DamageMax=19
    FireRate=0.600000
    BotRefireRate=0.300000
}
