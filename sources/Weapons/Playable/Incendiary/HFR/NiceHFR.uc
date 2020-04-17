// Modification of the AAR525 weapons by: [B.R]HekuT
class NiceHFR extends KFWeapon;
#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax
#exec OBJ LOAD FILE=KF_Weapons5_Scopes_Trip_T.utx
var() Material ZoomMat;
var()        int            lenseMaterialID;
var()        float        scopePortalFOVHigh;
var()        float        scopePortalFOV;
var()       vector      XoffsetScoped;
var()       vector      XoffsetHighDetail;
var()        int            scopePitch;
var()        int            scopeYaw;
var()        int            scopePitchHigh;
var()        int            scopeYawHigh;
var   ScriptedTexture   ScopeScriptedTexture;
var      Shader            ScopeScriptedShader;
var   Material          ScriptedTextureFallback;
var     Combiner            ScriptedScopeCombiner;
var     Combiner            ScriptedScopeStatic;
var     texture             TexturedScopeTexture;
var        bool                bInitializedScope;
var        string ZoomMatRef;
var        string ScriptedTextureFallbackRef;
static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount)
{
    super.PreloadAssets(Inv, bSkipRefCount);
    default.ZoomMat = FinalBlend(DynamicLoadObject(default.ZoomMatRef, class'FinalBlend', true));
    default.ScriptedTextureFallback = texture(DynamicLoadObject(default.ScriptedTextureFallbackRef, class'texture', true));
    if ( M99SniperRifle(Inv) != none )
    {
    }
}
static function bool UnloadAssets()
{
    if ( super.UnloadAssets() )
    {
    }
    return true;
}
exec function pfov(int thisFOV)
{
    if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
    scopePortalFOV = thisFOV;
}
exec function pPitch(int num)
{
    if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
    scopePitch = num;
    scopePitchHigh = num;
}
exec function pYaw(int num)
{
    if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
    scopeYaw = num;
    scopeYawHigh = num;
}
simulated exec function TexSize(int i, int j)
{
    if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
    ScopeScriptedTexture.SetSize(i, j);
}
simulated function bool ShouldDrawPortal()
{
    if( bAimingRifle )
    else
}
simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    KFScopeDetail = class'KFMod.KFWeapon'.default.KFScopeDetail;
    UpdateScopeMode();
}
simulated function UpdateScopeMode()
{
    if (Level.NetMode != NM_DedicatedServer && Instigator != none && Instigator.IsLocallyControlled() &&
    {










    }
}
simulated event RenderTexture(ScriptedTexture Tex)
{
    local rotator RollMod;
    RollMod = Instigator.GetViewRotation();
    if(Owner != none && Instigator != none && Tex != none && Tex.Client != none)
}
/**
 * Handles all the functionality for zooming in including
 * setting the parameters for the weapon, pawn, and playercontroller
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
simulated function ZoomIn(bool bAnimateTransition)
{
    super(BaseKFWeapon).ZoomIn(bAnimateTransition);
    bAimingRifle = True;
    if( KFHumanPawn(Instigator)!=none )
    if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )
    {
    }
}
/**
 * Handles all the functionality for zooming out including
 * setting the parameters for the weapon, pawn, and playercontroller
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
simulated function ZoomOut(bool bAnimateTransition)
{
    super.ZoomOut(bAnimateTransition);
    bAimingRifle = False;
    if( KFHumanPawn(Instigator)!=none )
    if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )
    {
    }
}
simulated event OnZoomInFinished()
{
    local name anim;
    local float frame, rate;
    GetAnimParams(0, anim, frame, rate);
    if (ClientState == WS_ReadyToFire)
    {
    }
    if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none &&
    {
    }
}
simulated event RenderOverlays(Canvas Canvas)
{
    local int m;
    local PlayerController PC;
    if (Instigator == none)
    PC = PlayerController(Instigator.Controller);
    if(PC == none)
    if(!bInitializedScope && PC != none )
    {
    }
    Canvas.DrawActor(none, false, true);
    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
    }

    SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
    SetRotation( Instigator.GetViewRotation() + ZoomRotInterp);
    PreDrawFPWeapon();


    }
    else if( KFScopeDetail == KF_TextureScope && PC.DesiredFOV == PlayerIronSightFOV && bAimingRifle)
    {






    }
}
simulated function float CalcAspectRatioAdjustedFOV(float AdjustFOV)
{
    local KFPlayerController KFPC;
    local float ResX, ResY;
    local float AspectRatio;
    KFPC = KFPlayerController(Level.GetLocalPlayerController());
    if( KFPC == none )
    {
    }
    ResX = float(GUIController(KFPC.Player.GUIController).ResX);
    ResY = float(GUIController(KFPC.Player.GUIController).ResY);
    AspectRatio = ResX / ResY;
    if ( KFPC.bUseTrueWideScreenFOV && AspectRatio >= 1.60 ) //1.6 = 16/10 which is 16:10 ratio and 16:9 comes to 1.77
    {
    }
    else
    {
    }
}
simulated function AdjustIngameScope()
{
    local PlayerController PC;
    if(Instigator == none || PlayerController(Instigator.Controller) == none)
    PC = PlayerController(Instigator.Controller);
    if( !bHasScope )
    switch (KFScopeDetail)
    {
}


    }
    UpdateScopeMode();
}
simulated event Destroyed()
{
    if (ScopeScriptedTexture != none)
    {
    }
    if (ScriptedScopeCombiner != none)
    {
    }
    if (ScopeScriptedShader != none)
    {
    }
    Super.Destroyed();
}
simulated function PreTravelCleanUp()
{
    if (ScopeScriptedTexture != none)
    {
    }
    if (ScriptedScopeCombiner != none)
    {
    }
    if (ScopeScriptedShader != none)
    {
    }
}
state PendingClientWeaponSet
{
    simulated function Timer()
    {

    }
    simulated function BeginState()
    {
    }
    simulated function EndState()
    {
    }
}
simulated function SetZoomBlendColor(Canvas c)
{
    local Byte    val;
    local Color   clr;
    local Color   fog;
    clr.R = 255;
    clr.G = 255;
    clr.B = 255;
    clr.A = 255;
    if( Instigator.Region.Zone.bDistanceFog )
    {
    }
    c.DrawColor = clr;
}
function bool RecommendRangedAttack()
{
    return true;
}
function float SuggestAttackStyle()
{
    return -1.0;
}
function bool RecommendLongRangedAttack()
{
    return true;
}
simulated function AnimEnd(int channel)
{
    if(!FireMode[1].IsInState('FireLoop'))
    {
    }
}
simulated function WeaponTick(float dt)
{
  Super.WeaponTick(dt);
}
simulated function bool StartFire(int Mode)
{
    if( Mode == 0 )
    if( !super.StartFire(Mode) )
  
    if( AmmoAmount(0) <= 0 )
    {
    }
    AnimStopLooping();
    if( !FireMode[Mode].IsInState('FireLoop') && (AmmoAmount(0) > 0) )
    {
    }
    else
    {
    }
    return true;
}
defaultproperties
{
}