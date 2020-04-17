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
    {       M99SniperRifle(Inv).ZoomMat = default.ZoomMat;       M99SniperRifle(Inv).ScriptedTextureFallback = default.ScriptedTextureFallback;
    }
}
static function bool UnloadAssets()
{
    if ( super.UnloadAssets() )
    {       default.ZoomMat = none;       default.ScriptedTextureFallback = none;
    }
    return true;
}
exec function pfov(int thisFOV)
{
    if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )       return;
    scopePortalFOV = thisFOV;
}
exec function pPitch(int num)
{
    if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )       return;
    scopePitch = num;
    scopePitchHigh = num;
}
exec function pYaw(int num)
{
    if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )       return;
    scopeYaw = num;
    scopeYawHigh = num;
}
simulated exec function TexSize(int i, int j)
{
    if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )       return;
    ScopeScriptedTexture.SetSize(i, j);
}
simulated function bool ShouldDrawPortal()
{
    if( bAimingRifle )       return true;
    else       return false;
}
simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    KFScopeDetail = class'KFMod.KFWeapon'.default.KFScopeDetail;
    UpdateScopeMode();
}
simulated function UpdateScopeMode()
{
    if (Level.NetMode != NM_DedicatedServer && Instigator != none && Instigator.IsLocallyControlled() &&       Instigator.IsHumanControlled() )
    {       if( KFScopeDetail == KF_ModelScope )       {           scopePortalFOV = default.scopePortalFOV;           ZoomedDisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);           if (bAimingRifle)           {               PlayerViewOffset = XoffsetScoped;           }
           if( ScopeScriptedTexture == none )           {               ScopeScriptedTexture = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));           }
           ScopeScriptedTexture.FallBackMaterial = ScriptedTextureFallback;           ScopeScriptedTexture.SetSize(512,512);           ScopeScriptedTexture.Client = Self;
           if( ScriptedScopeCombiner == none )           {               ScriptedScopeCombiner = Combiner(Level.ObjectPool.AllocateObject(class'Combiner'));               ScriptedScopeCombiner.Material1 = Texture'KF_Weapons5_Scopes_Trip_T.Scope.MilDot';               ScriptedScopeCombiner.FallbackMaterial = Shader'ScopeShaders.Zoomblur.LensShader';               ScriptedScopeCombiner.CombineOperation = CO_Multiply;               ScriptedScopeCombiner.AlphaOperation = AO_Use_Mask;               ScriptedScopeCombiner.Material2 = ScopeScriptedTexture;           }
           if( ScopeScriptedShader == none )           {               ScopeScriptedShader = Shader(Level.ObjectPool.AllocateObject(class'Shader'));               ScopeScriptedShader.Diffuse = ScriptedScopeCombiner;               ScopeScriptedShader.SelfIllumination = ScriptedScopeCombiner;               ScopeScriptedShader.FallbackMaterial = Shader'ScopeShaders.Zoomblur.LensShader';           }
           bInitializedScope = true;       }       else if( KFScopeDetail == KF_ModelScopeHigh )       {           scopePortalFOV = scopePortalFOVHigh;           ZoomedDisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOVHigh);           if (bAimingRifle)           {               PlayerViewOffset = XoffsetHighDetail;           }
           if( ScopeScriptedTexture == none )           {               ScopeScriptedTexture = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));           }           ScopeScriptedTexture.FallBackMaterial = ScriptedTextureFallback;           ScopeScriptedTexture.SetSize(1024,1024);           ScopeScriptedTexture.Client = Self;
           if( ScriptedScopeCombiner == none )           {               ScriptedScopeCombiner = Combiner(Level.ObjectPool.AllocateObject(class'Combiner'));               ScriptedScopeCombiner.Material1 = Texture'KF_Weapons5_Scopes_Trip_T.Scope.MilDot';               ScriptedScopeCombiner.FallbackMaterial = Shader'ScopeShaders.Zoomblur.LensShader';               ScriptedScopeCombiner.CombineOperation = CO_Multiply;               ScriptedScopeCombiner.AlphaOperation = AO_Use_Mask;               ScriptedScopeCombiner.Material2 = ScopeScriptedTexture;           }
           if( ScopeScriptedShader == none )           {               ScopeScriptedShader = Shader(Level.ObjectPool.AllocateObject(class'Shader'));               ScopeScriptedShader.Diffuse = ScriptedScopeCombiner;               ScopeScriptedShader.SelfIllumination = ScriptedScopeCombiner;               ScopeScriptedShader.FallbackMaterial = Shader'ScopeShaders.Zoomblur.LensShader';           }
           bInitializedScope = true;       }       else if (KFScopeDetail == KF_TextureScope)       {           ZoomedDisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);           PlayerViewOffset.X = default.PlayerViewOffset.X;
           bInitializedScope = true;       }
    }
}
simulated event RenderTexture(ScriptedTexture Tex)
{
    local rotator RollMod;
    RollMod = Instigator.GetViewRotation();
    if(Owner != none && Instigator != none && Tex != none && Tex.Client != none)       Tex.DrawPortal(0,0,Tex.USize,Tex.VSize,Owner,(Instigator.Location + Instigator.EyePosition()), RollMod,  scopePortalFOV );
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
    if( KFHumanPawn(Instigator)!=none )       KFHumanPawn(Instigator).SetAiming(True);
    if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )
    {       if( AimInSound != none )       {           PlayOwnedSound(AimInSound, SLOT_Interact,,,,, false);       }
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
    if( KFHumanPawn(Instigator)!=none )       KFHumanPawn(Instigator).SetAiming(False);
    if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )
    {       if( AimOutSound != none )       {           PlayOwnedSound(AimOutSound, SLOT_Interact,,,,, false);       }       KFPlayerController(Instigator.Controller).TransitionFOV(KFPlayerController(Instigator.Controller).DefaultFOV,0.0);
    }
}
simulated event OnZoomInFinished()
{
    local name anim;
    local float frame, rate;
    GetAnimParams(0, anim, frame, rate);
    if (ClientState == WS_ReadyToFire)
    {       if (anim == IdleAnim)       {          PlayIdle();       }
    }
    if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none &&       KFScopeDetail == KF_TextureScope )
    {       KFPlayerController(Instigator.Controller).TransitionFOV(PlayerIronSightFOV,0.0);
    }
}
simulated event RenderOverlays(Canvas Canvas)
{
    local int m;
    local PlayerController PC;
    if (Instigator == none)       return;
    PC = PlayerController(Instigator.Controller);
    if(PC == none)       return;
    if(!bInitializedScope && PC != none )
    {         UpdateScopeMode();
    }
    Canvas.DrawActor(none, false, true);
    for (m = 0; m < NUM_FIRE_MODES; m++)
    {       if (FireMode[m] != none)       {           FireMode[m].DrawMuzzleFlash(Canvas);       }
    }

    SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
    SetRotation( Instigator.GetViewRotation() + ZoomRotInterp);
    PreDrawFPWeapon();
    if(bAimingRifle && PC != none && (KFScopeDetail == KF_ModelScope || KFScopeDetail == KF_ModelScopeHigh))    {        if (ShouldDrawPortal())        {           if ( ScopeScriptedTexture != none )           {               Skins[LenseMaterialID] = ScopeScriptedShader;               ScopeScriptedTexture.Client = Self;               ScopeScriptedTexture.Revision = (ScopeScriptedTexture.Revision +1);           }        }
       bDrawingFirstPerson = true;        Canvas.DrawBoundActor(self, false, false,DisplayFOV,PC.Rotation,rot(0,0,0),Instigator.CalcZoomedDrawOffset(self));         bDrawingFirstPerson = false;
    }
    else if( KFScopeDetail == KF_TextureScope && PC.DesiredFOV == PlayerIronSightFOV && bAimingRifle)
    {       Skins[LenseMaterialID] = ScriptedTextureFallback;
       SetZoomBlendColor(Canvas);
       Canvas.Style = ERenderStyle.STY_Normal;       Canvas.SetPos(0, 0);       Canvas.DrawTile(ZoomMat, (Canvas.SizeX - Canvas.SizeY) / 2, Canvas.SizeY, 0.0, 0.0, 8, 8);       Canvas.SetPos(Canvas.SizeX, 0);       Canvas.DrawTile(ZoomMat, -(Canvas.SizeX - Canvas.SizeY) / 2, Canvas.SizeY, 0.0, 0.0, 8, 8);
       Canvas.Style = 255;       Canvas.SetPos((Canvas.SizeX - Canvas.SizeY) / 2,0);       Canvas.DrawTile(ZoomMat, Canvas.SizeY, Canvas.SizeY, 0.0, 0.0, 1024, 1024);
       Canvas.Font = Canvas.MedFont;       Canvas.SetDrawColor(200,150,0);
       Canvas.SetPos(Canvas.SizeX * 0.16, Canvas.SizeY * 0.43);       Canvas.DrawText("Zoom: 3.0");
       Canvas.SetPos(Canvas.SizeX * 0.16, Canvas.SizeY * 0.47);
    }    else    {       Skins[LenseMaterialID] = ScriptedTextureFallback;       bDrawingFirstPerson = true;       Canvas.DrawActor(self, false, false, DisplayFOV);       bDrawingFirstPerson = false;    }
}
simulated function float CalcAspectRatioAdjustedFOV(float AdjustFOV)
{
    local KFPlayerController KFPC;
    local float ResX, ResY;
    local float AspectRatio;
    KFPC = KFPlayerController(Level.GetLocalPlayerController());
    if( KFPC == none )
    {       return AdjustFOV;
    }
    ResX = float(GUIController(KFPC.Player.GUIController).ResX);
    ResY = float(GUIController(KFPC.Player.GUIController).ResY);
    AspectRatio = ResX / ResY;
    if ( KFPC.bUseTrueWideScreenFOV && AspectRatio >= 1.60 ) //1.6 = 16/10 which is 16:10 ratio and 16:9 comes to 1.77
    {       return CalcFOVForAspectRatio(AdjustFOV);
    }
    else
    {       return AdjustFOV;
    }
}
simulated function AdjustIngameScope()
{
    local PlayerController PC;
    if(Instigator == none || PlayerController(Instigator.Controller) == none)       return;
    PC = PlayerController(Instigator.Controller);
    if( !bHasScope )       return;
    switch (KFScopeDetail)
    {       case KF_ModelScope:           if( bAimingRifle )               DisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);           if ( PC.DesiredFOV == PlayerIronSightFOV && bAimingRifle )           {               if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )               {                   KFPlayerController(Instigator.Controller).TransitionFOV(KFPlayerController(Instigator.Controller).DefaultFOV,0.0);
}           }           break;
       case KF_TextureScope:           if( bAimingRifle )               DisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);           if ( bAimingRifle && PC.DesiredFOV != PlayerIronSightFOV )           {               if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )               {                   KFPlayerController(Instigator.Controller).TransitionFOV(PlayerIronSightFOV,0.0);               }           }           break;
       case KF_ModelScopeHigh:           if( bAimingRifle )           {               if( ZoomedDisplayFOVHigh > 0 )               {                   DisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOVHigh);               }               else               {                   DisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);               }           }           if ( bAimingRifle && PC.DesiredFOV == PlayerIronSightFOV )           {               if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )               {                   KFPlayerController(Instigator.Controller).TransitionFOV(KFPlayerController(Instigator.Controller).DefaultFOV,0.0);               }           }           break;
    }
    UpdateScopeMode();
}
simulated event Destroyed()
{
    if (ScopeScriptedTexture != none)
    {       ScopeScriptedTexture.Client = none;       Level.ObjectPool.FreeObject(ScopeScriptedTexture);       ScopeScriptedTexture=none;
    }
    if (ScriptedScopeCombiner != none)
    {       ScriptedScopeCombiner.Material2 = none;       Level.ObjectPool.FreeObject(ScriptedScopeCombiner);       ScriptedScopeCombiner = none;
    }
    if (ScopeScriptedShader != none)
    {       ScopeScriptedShader.Diffuse = none;       ScopeScriptedShader.SelfIllumination = none;       Level.ObjectPool.FreeObject(ScopeScriptedShader);       ScopeScriptedShader = none;
    }
    Super.Destroyed();
}
simulated function PreTravelCleanUp()
{
    if (ScopeScriptedTexture != none)
    {       ScopeScriptedTexture.Client = none;       Level.ObjectPool.FreeObject(ScopeScriptedTexture);       ScopeScriptedTexture=none;
    }
    if (ScriptedScopeCombiner != none)
    {       ScriptedScopeCombiner.Material2 = none;       Level.ObjectPool.FreeObject(ScriptedScopeCombiner);       ScriptedScopeCombiner = none;
    }
    if (ScopeScriptedShader != none)
    {       ScopeScriptedShader.Diffuse = none;       ScopeScriptedShader.SelfIllumination = none;       Level.ObjectPool.FreeObject(ScopeScriptedShader);       ScopeScriptedShader = none;
    }
}
state PendingClientWeaponSet
{
    simulated function Timer()
    {       if ( Pawn(Owner) != none && !bIsReloading )       {           ClientWeaponSet(bPendingSwitch);       }
       if ( IsInState('PendingClientWeaponSet') )       {           SetTimer(0.1, false);       }
    }
    simulated function BeginState()
    {       SetTimer(0.1, false);
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
    {       fog = Instigator.Region.Zone.DistanceFogColor;       val = 0;       val = Max( val, fog.R);       val = Max( val, fog.G);       val = Max( val, fog.B);       if( val > 128 )       {           val -= 128;           clr.R -= val;           clr.G -= val;           clr.B -= val;       }
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
    {         Super.AnimEnd(channel);
    }
}
simulated function WeaponTick(float dt)
{
  Super.WeaponTick(dt);
}
simulated function bool StartFire(int Mode)
{
    if( Mode == 0 )       return super.StartFire(Mode);
    if( !super.StartFire(Mode) )      return false;
  
    if( AmmoAmount(0) <= 0 )
    {       return false;
    }
    AnimStopLooping();
    if( !FireMode[Mode].IsInState('FireLoop') && (AmmoAmount(0) > 0) )
    {       FireMode[Mode].StartFiring();       return true;
    }
    else
    {       return false;
    }
    return true;
}
defaultproperties
{    lenseMaterialID=3    scopePortalFOVHigh=22.000000    scopePortalFOV=12.000000    ZoomMatRef="KillingFloorWeapons.Xbow.CommandoCrossFinalBlend"    ScriptedTextureFallbackRef="NicePackT.HFR.CBLens_cmb"    bHasScope=True    ZoomedDisplayFOVHigh=35.000000    MagCapacity=10    ReloadRate=3.000000    ReloadAnim="Reload"    ReloadAnimRate=0.600000    WeaponReloadAnim="Reload_M4"    bSteadyAim=True    Weight=7.000000    bHasAimingMode=True    IdleAimAnim="Idle"    StandardDisplayFOV=60.000000    bModeZeroCanDryFire=True    SleeveNum=0    TraderInfoTexture=Texture'NicePackT.HFR.AAR525S_Trader'    bIsTier2Weapon=True    MeshRef="NicePackA.HFR"    SkinRefs(0)="KF_Weapons_Trip_T.hands.hands_1stP_military_cmb"    SkinRefs(1)="NicePackT.HFR.AAR525S_TEX_cmb"    SkinRefs(2)="KF_Weapons_Trip_T.Rifles.crossbow_cmb"    SelectSoundRef="KF_AK47Snd.AK47_Select"    HudImageRef="NicePackT.HFR.AAR525S_unselected"    SelectedHudImageRef="NicePackT.HFR.AAR525S_selected"    PlayerIronSightFOV=65.000000    ZoomedDisplayFOV=32.000000    FireModeClass(0)=Class'NicePack.NiceHFRPFire'    FireModeClass(1)=Class'NicePack.NiceHFRBurstFire'    PutDownAnim="PutDown"    AIRating=0.700000    CurrentRating=0.700000    Description="Advanced horzine flame rifle."    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)    DisplayFOV=60.000000    Priority=145    CustomCrosshair=11    CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"    InventoryGroup=4    GroupOffset=8    PickupClass=Class'NicePack.NiceHFRPickup'    PlayerViewOffset=(X=18.000000,Y=15.000000,Z=-6.000000)    BobDamping=6.000000    AttachmentClass=Class'NicePack.NiceHFRAttachment'    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)    ItemName="Horzine flame rifle"    DrawScale=0.900000    TransientSoundVolume=1.250000
}
