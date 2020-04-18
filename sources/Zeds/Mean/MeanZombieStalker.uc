class MeanZombieStalker extends NiceZombieStalker;
#exec OBJ LOAD FILE=MeanZedSkins.utx
simulated function Tick(float DeltaTime)
{
    Super(NiceMonster).Tick(DeltaTime);
    if(Role == ROLE_Authority && bShotAnim && !bWaitForAnim){
       if( LookTarget!=none ) {
           Acceleration = AccelRate * Normal(LookTarget.Location - Location);
       }
    }
    if(Level.NetMode == NM_DedicatedServer)
       return; // Servers aren't interested in this info.
    if(bZapped){
       // Make sure we check if we need to be cloaked as soon as the zap wears off
       NextCheckTime = Level.TimeSeconds;
    }
    else if( Level.TimeSeconds > NextCheckTime && Health > 0 )
    {
       NextCheckTime = Level.TimeSeconds + 0.5;

       if(LocalKFHumanPawn != none && LocalKFHumanPawn.Health > 0 && LocalKFHumanPawn.ShowStalkers() &&
           VSizeSquared(Location - LocalKFHumanPawn.Location) < LocalKFHumanPawn.GetStalkerViewDistanceMulti() * 640000.0) // 640000 = 800 Units
           bSpotted = True;
       else
           bSpotted = false;

       if(!bSpotted && !bCloaked && Skins[0] != Combiner'MeanZedSkins.stalker_cmb')
           UncloakStalker();
       else if (Level.TimeSeconds - LastUncloakTime > 1.2){
           // if we're uberbrite, turn down the light
           if( bSpotted && Skins[0] != Finalblend'KFX.StalkerGlow' ){
               bUnlit = false;
               CloakStalker();
           }
           else if(Skins[0] != Shader'MeanZedSkins.stalker_invisible')
               CloakStalker();
       }
    }
}
simulated function CloakStalker()
{
    // No cloaking if zapped
    if( bZapped )
    {
       return;
    }
    if ( bSpotted )
    {
       if( Level.NetMode == NM_DedicatedServer )
           return;

       Skins[0] = Finalblend'KFX.StalkerGlow';
       Skins[1] = Finalblend'KFX.StalkerGlow';
       bUnlit = true;
       return;
    }
    if ( !bDecapitated ) // No head, no cloak, honey.  updated :  Being charred means no cloak either :D Not.
    {
       Visibility = 1;
       bCloaked = true;

       if( Level.NetMode == NM_DedicatedServer )
           Return;

       Skins[0] = Shader'MeanZedSkins.stalker_invisible';
       Skins[1] = Shader'MeanZedSkins.stalker_invisible';

       // Invisible - no shadow
       if(PlayerShadow != none)
           PlayerShadow.bShadowActive = false;
       if(RealTimeShadow != none)
           RealTimeShadow.Destroy();

       // Remove/disallow projectors on invisible people
       Projectors.Remove(0, Projectors.Length);
       bAcceptsProjectors = false;
       SetOverlayMaterial(Material'KFX.FBDecloakShader', 0.25, true);
    }
}
simulated function UnCloakStalker()
{
    if( bZapped )
    {
       return;
    }
    if( !bCrispified )
    {
       LastUncloakTime = Level.TimeSeconds;

       Visibility = default.Visibility;
       bCloaked = false;
       bUnlit = false;

       // 25% chance of our Enemy saying something about us being invisible
       if( Level.NetMode!=NM_Client && !KFGameType(Level.Game).bDidStalkerInvisibleMessage && FRand()<0.25 && Controller.Enemy!=none &&
        PlayerController(Controller.Enemy.Controller)!=none )
       {
           PlayerController(Controller.Enemy.Controller).Speech('AUTO', 17, "");
           KFGameType(Level.Game).bDidStalkerInvisibleMessage = true;
       }
       if( Level.NetMode == NM_DedicatedServer )
           Return;

       if ( Skins[0] != Combiner'MeanZedSkins.stalker_cmb' )
       {
           Skins[1] = FinalBlend'MeanZedSkins.stalker_fb';
           Skins[0] = Combiner'MeanZedSkins.stalker_cmb';

           if (PlayerShadow != none)
               PlayerShadow.bShadowActive = true;

           bAcceptsProjectors = true;

           SetOverlayMaterial(Material'KFX.FBDecloakShader', 0.25, true);
       }
    }
}
simulated function SetZappedBehavior()
{
    super(NiceMonster).SetZappedBehavior();
    bUnlit = false;
    // Handle setting the zed to uncloaked so the zapped overlay works properly
    if( Level.Netmode != NM_DedicatedServer )
    {
       Skins[1] = FinalBlend'MeanZedSkins.stalker_fb';
       Skins[0] = Combiner'MeanZedSkins.stalker_cmb';

       if (PlayerShadow != none)
           PlayerShadow.bShadowActive = true;

       bAcceptsProjectors = true;
       SetOverlayMaterial(Material'KFZED_FX_T.Energy.ZED_overlay_Hit_Shdr', 999, true);
    }
}

function RangedAttack(Actor A) {
    if ( bShotAnim || Physics == PHYS_Swimming)
       return;
    else if ( CanAttack(A) ) {
       bShotAnim = true;
       SetAnimAction('ClawAndMove');
       //PlaySound(sound'Claw2s', SLOT_none); KFTODO: Replace this
       return;
    }
}
// Copied from the Gorefast code
// Overridden to handle playing upper body only attacks when moving
simulated event SetAnimAction(name NewAction) {
    if( NewAction=='' )
       Return;
    ExpectingChannel = AttackAndMoveDoAnimAction(NewAction);
    bWaitForAnim= false;
    
    if( Level.NetMode!=NM_Client ) {
       AnimAction = NewAction;
       bResetAnimAct = True;
       ResetAnimActTime = Level.TimeSeconds+0.3;
    }
}
// Copied from the Gorefast code, updated with the stalker attacks
// Handle playing the anim action on the upper body only if we're attacking and moving
simulated function int AttackAndMoveDoAnimAction( name AnimName ) {
    local int meleeAnimIndex;
    if( AnimName == 'ClawAndMove' ) {
       meleeAnimIndex = Rand(3);
       AnimName = meleeAnims[meleeAnimIndex];
    }
    if( AnimName=='StalkerSpinAttack' || AnimName=='StalkerAttack1' || AnimName=='JumpAttack') {
       AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
       PlayAnim(AnimName,, 0.1, 1);

       return 1;
    }
    return super.DoAnimAction( AnimName );
}
function bool MeleeDamageTarget(int hitdamage, vector pushdir) {
    local bool result;
    local float effectStrenght;
    local NiceHumanPawn targetPawn;
    result = Super(NiceMonster).MeleeDamageTarget(hitdamage, pushdir);
    targetPawn = NiceHumanPawn(Controller.Target);
    if(result && targetPawn != none && (targetPawn.hmgShieldLevel <= 0 ||
       !class'NiceVeterancyTypes'.static.HasSkill(NicePlayerController(targetPawn.Controller),
           class'NiceSkillEnforcerFullCounter')) ){
       if(targetPawn.ShieldStrength > 100)
           return result;
       else if(targetPawn.ShieldStrength < 0)
           effectStrenght = 1.0;
       else
           effectStrenght = (100 - targetPawn.ShieldStrength) * 0.01;
       class'MeanReplicationInfo'.static
               .findSZri(targetPawn.PlayerReplicationInfo)
               .setBleeding(Self, effectStrenght);
    }
    return result;
}
function RemoveHead()
{
    Super(NiceMonster).RemoveHead();
    if (!bCrispified)
    {
       Skins[1] = FinalBlend'MeanZedSkins.stalker_fb';
       Skins[0] = Combiner'MeanZedSkins.stalker_cmb';
    }
}
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    Super(NiceMonster).PlayDying(DamageType,HitLoc);
    if(bUnlit)
       bUnlit=!bUnlit;
    LocalKFHumanPawn = none;
    if (!bCrispified)
    {
       Skins[1] = FinalBlend'MeanZedSkins.stalker_fb';
       Skins[0] = Combiner'MeanZedSkins.stalker_cmb';
    }
}
static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
    myLevel.AddPrecacheMaterial(Combiner'MeanZedSkins.stalker_cmb');
    myLevel.AddPrecacheMaterial(Combiner'MeanZedSkins.stalker_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'MeanZedSkins.stalker_diff');
    myLevel.AddPrecacheMaterial(Texture'MeanZedSkins.stalker_spec');
    myLevel.AddPrecacheMaterial(Material'MeanZedSkins.stalker_invisible');
    myLevel.AddPrecacheMaterial(Combiner'MeanZedSkins.StalkerCloakOpacity_cmb');
    myLevel.AddPrecacheMaterial(Material'MeanZedSkins.StalkerCloakEnv_rot');
    myLevel.AddPrecacheMaterial(Material'MeanZedSkins.stalker_opacity_osc');
    myLevel.AddPrecacheMaterial(Material'KFCharacters.StalkerSkin');
}
defaultproperties
{
    MeleeDamage=6
    MenuName="Mean Stalker"
    Skins(0)=Shader'MeanZedSkins.stalker_invisible'
    Skins(1)=Shader'MeanZedSkins.stalker_invisible'
}
