class NiceM4203MMedicGun extends NiceM4203AssaultRifle
    config(user);
var localized   string  SuccessfulHealMessage;
var ScrnFakedHealingGrenade FakedNade;
replication
{
    reliable if( Role == ROLE_Authority )
       ClientSuccessfulHeal;
}
simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    if ( Level.NetMode != NM_DedicatedServer ) {
       SetBoneScale (58, 0.0, 'M203_EmptyShell');

       FakedNade = spawn(class'ScrnFakedHealingGrenade',self);
       if ( FakedNade != none ) {
           //FakedNade.SetDrawScale(4.0);
           SetBoneRotation('M203_Round', rot(0, 6000, 0));
           // bone must have a size to properly adjust rotation
           SetBoneScale (59, 0.0001, 'M203_Round');
           AttachToBone(FakedNade, 'M203_Round');
       }
    }
}

simulated function Destroyed()
{
    if ( FakedNade != none )
       FakedNade.Destroy();
    super.Destroyed();
}
// The server lets the client know they successfully healed someone
simulated function ClientSuccessfulHeal(int HealedPlayerCount, int HealedAmount)
{
    local string str;
    if( PlayerController(Instigator.Controller) != none ) {
       str = SuccessfulHealMessage;
       ReplaceText(str, "%c", String(HealedPlayerCount));
       ReplaceText(str, "%a", String(HealedAmount));
           PlayerController(Instigator.controller).ClientMessage(str, 'CriticalEvent');
    }
}
defaultproperties
{
    SuccessfulHealMessage="You healed %c player(-s) with %ahp"
    bIsTier2Weapon=False
    SkinRefs(0)="ScrnTex.Weapons.M4203M"
    FireModeClass(0)=Class'NicePack.NiceM4203MBulletFire'
    FireModeClass(1)=Class'NicePack.NiceM203MFire'
    Description="An assault rifle with an attached healing grenade launcher. Shoots in 3-bullet fixed-burst mode."
    Priority=70
    InventoryGroup=4
    PickupClass=Class'NicePack.NiceM4203MPickup'
    ItemName="M4-203M Medic Rifle NW"
}
