class NiceScopedWeapon extends NiceWeapon
    abstract;
#exec OBJ LOAD FILE=ScopeShaders.utx
#exec OBJ LOAD FILE=..\Textures\NicePackT.utx
#exec OBJ LOAD FILE=ScrnWeaponPack_T.utx
#exec OBJ LOAD FILE=ScrnWeaponPack_A.ukx    
var() Material ZoomMat;
var() Sound ZoomSound;
var()   int                 lenseMaterialID;            // used since material id's seem to change alot
var()   float               scopePortalFOVHigh;         // The FOV to zoom the scope portal by.
var()   float               scopePortalFOV;             // The FOV to zoom the scope portal by.
var()   vector              XoffsetScoped;
var()   vector              XoffsetHighDetail;
var()   int                 tileSize;
// 3d Scope vars
var     ScriptedTexture     ScopeScriptedTexture;       // Scripted texture for 3d scopes
var     Shader              ScopeScriptedShader;        // The shader that combines the scripted texture with the sight overlay
var     Material            ScriptedTextureFallback;    // The texture to render if the users system doesn't support shaders
// new scope vars
var     Combiner            ScriptedScopeCombiner;
var     texture             TexturedScopeTexture;
var     bool                bInitializedScope;          // Set to true when the scope has been initialized
var     string              ZoomMatRef;
var     string              ScriptedTextureFallbackRef;
var     texture             CrosshairTex;
var     string              CrosshairTexRef;    
static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount){
    local NiceScopedWeapon W;
    super.PreloadAssets(Inv, bSkipRefCount);
    if(default.ZoomMat == none && default.ZoomMatRef != ""){       // Try to load as various types of materials       default.ZoomMat = FinalBlend(DynamicLoadObject(default.ZoomMatRef, class'FinalBlend', true));       if(default.ZoomMat == none)           default.ZoomMat = Combiner(DynamicLoadObject(default.ZoomMatRef, class'Combiner', true));       if(default.ZoomMat == none)           default.ZoomMat = Shader(DynamicLoadObject(default.ZoomMatRef, class'Shader', true));       if(default.ZoomMat == none)           default.ZoomMat = Texture(DynamicLoadObject(default.ZoomMatRef, class'Texture', true));       if(default.ZoomMat == none)           default.ZoomMat = Material(DynamicLoadObject(default.ZoomMatRef, class'Material'));
    }
    if(default.ScriptedTextureFallback == none && default.ScriptedTextureFallbackRef != "")       default.ScriptedTextureFallback = texture(DynamicLoadObject(default.ScriptedTextureFallbackRef, class'texture'));
    if(default.CrosshairTex == none && default.CrosshairTexRef != "")       default.CrosshairTex = Texture(DynamicLoadObject(default.CrosshairTexRef, class'texture'));
    W = NiceScopedWeapon(Inv);
    if(W != none){       W.ZoomMat = default.ZoomMat;       W.ScriptedTextureFallback = default.ScriptedTextureFallback;       W.CrosshairTex = default.CrosshairTex;
    }
}
static function bool UnloadAssets(){
    if(super.UnloadAssets()){       default.ZoomMat = none;       default.ScriptedTextureFallback = none;       default.CrosshairTex = none;
    }
    return true;
}
simulated function bool ShouldDrawPortal()
{
    if(bAimingRifle)       return true;
    else       return false;
}
simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    // Get new scope detail value from KFWeapon
    KFScopeDetail = class'KFMod.KFWeapon'.default.KFScopeDetail;
    UpdateScopeMode();
}
// Handles initializing and swithing between different scope modes
simulated function UpdateScopeMode()
{
    if (Level.NetMode != NM_DedicatedServer && Instigator != none && Instigator.IsLocallyControlled() && Instigator.IsHumanControlled()){       if(KFScopeDetail == KF_ModelScope){           scopePortalFOV = default.scopePortalFOV;           ZoomedDisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);
           if (bUsingSights || bAimingRifle)               PlayerViewOffset = XoffsetScoped;
           if(ScopeScriptedTexture == none)               ScopeScriptedTexture = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));
           ScopeScriptedTexture.FallBackMaterial = ScriptedTextureFallback;           ScopeScriptedTexture.SetSize(512,512);           ScopeScriptedTexture.Client = Self;
           if(ScriptedScopeCombiner == none){               ScriptedScopeCombiner = Combiner(Level.ObjectPool.AllocateObject(class'Combiner'));               ScriptedScopeCombiner.Material1 = CrosshairTex;               ScriptedScopeCombiner.FallbackMaterial = Shader'ScopeShaders.Zoomblur.LensShader';               ScriptedScopeCombiner.CombineOperation = CO_Multiply;               ScriptedScopeCombiner.AlphaOperation = AO_Use_Mask;               ScriptedScopeCombiner.Material2 = ScopeScriptedTexture;           }           if(ScopeScriptedShader == none){               ScopeScriptedShader = Shader(Level.ObjectPool.AllocateObject(class'Shader'));               ScopeScriptedShader.Diffuse = ScriptedScopeCombiner;               ScopeScriptedShader.SelfIllumination = ScriptedScopeCombiner;               ScopeScriptedShader.FallbackMaterial = Shader'ScopeShaders.Zoomblur.LensShader';           }
           bInitializedScope = true;       }       else if( KFScopeDetail == KF_ModelScopeHigh )       {           scopePortalFOV = scopePortalFOVHigh;           ZoomedDisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOVHigh);           if(bUsingSights || bAimingRifle)               PlayerViewOffset = XoffsetHighDetail;
           if(ScopeScriptedTexture == none)               ScopeScriptedTexture = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));           ScopeScriptedTexture.FallBackMaterial = ScriptedTextureFallback;           ScopeScriptedTexture.SetSize(1024,1024);           ScopeScriptedTexture.Client = Self;
           if(ScriptedScopeCombiner == none){               ScriptedScopeCombiner = Combiner(Level.ObjectPool.AllocateObject(class'Combiner'));               ScriptedScopeCombiner.Material1 = CrosshairTex;               ScriptedScopeCombiner.FallbackMaterial = Shader'ScopeShaders.Zoomblur.LensShader';               ScriptedScopeCombiner.CombineOperation = CO_Multiply;               ScriptedScopeCombiner.AlphaOperation = AO_Use_Mask;               ScriptedScopeCombiner.Material2 = ScopeScriptedTexture;           }
           if(ScopeScriptedShader == none){               ScopeScriptedShader = Shader(Level.ObjectPool.AllocateObject(class'Shader'));               ScopeScriptedShader.Diffuse = ScriptedScopeCombiner;               ScopeScriptedShader.SelfIllumination = ScriptedScopeCombiner;               ScopeScriptedShader.FallbackMaterial = Shader'ScopeShaders.Zoomblur.LensShader';           }
           bInitializedScope = true;       }       else if (KFScopeDetail == KF_TextureScope){           ZoomedDisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);           PlayerViewOffset.X = default.PlayerViewOffset.X;
           bInitializedScope = true;       }
    }
}
simulated event RenderTexture(ScriptedTexture Tex)
{
    local rotator RollMod;
    RollMod = Instigator.GetViewRotation();
    if(Owner != none && Instigator != none && Tex != none && Tex.Client != none)       Tex.DrawPortal(0,0,Tex.USize,Tex.VSize,Owner,(Instigator.Location + Instigator.EyePosition()), RollMod,  scopePortalFOV );
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
    if(Instigator.Region.Zone.bDistanceFog){       fog = Instigator.Region.Zone.DistanceFogColor;       val = 0;       val = Max(val, fog.R);       val = Max(val, fog.G);       val = Max(val, fog.B);       if(val > 128){           val -= 128;           clr.R -= val;           clr.G -= val;           clr.B -= val;       }
    }
    c.DrawColor = clr;
}
//Handles all the functionality for zooming in including
// setting the parameters for the weapon, pawn, and playercontroller
simulated function ZoomIn(bool bAnimateTransition)
{
    default.ZoomTime    = default.recordedZoomTime;
    PlayerIronSightFOV  = default.PlayerIronSightFOV;
    scopePortalFOVHigh  = default.scopePortalFOVHigh;
    scopePortalFOV      = default.scopePortalFOV;
    PlayerIronSightFOV  = default.PlayerIronSightFOV;
    if(instigator != none && instigator.bIsCrouched && class'NiceVeterancyTypes'.static.hasSkill(NicePlayerController(Instigator.Controller), class'NiceSkillSharpshooterHardWork')){       default.ZoomTime    *= class'NiceSkillSharpshooterHardWork'.default.zoomSpeedBonus;       if(instigator != none && instigator.bIsCrouched){           PlayerIronSightFOV  *= class'NiceSkillSharpshooterHardWork'.default.zoomBonus;           scopePortalFOVHigh  *= class'NiceSkillSharpshooterHardWork'.default.zoomBonus;           scopePortalFOV      *= class'NiceSkillSharpshooterHardWork'.default.zoomBonus;           PlayerIronSightFOV  *= class'NiceSkillSharpshooterHardWork'.default.zoomBonus;       }
    }
    super(BaseKFWeapon).ZoomIn(bAnimateTransition);
    bAimingRifle = True;
    if(KFHumanPawn(Instigator) != none)       KFHumanPawn(Instigator).SetAiming(True);
    if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none ){       if(AimInSound != none)           PlayOwnedSound(AimInSound, SLOT_Interact,,,,, false);
    }
}
// Handles all the functionality for zooming out including
// setting the parameters for the weapon, pawn, and playercontroller
simulated function ZoomOut(bool bAnimateTransition)
{
    default.ZoomTime    = default.recordedZoomTime;
    PlayerIronSightFOV  = default.PlayerIronSightFOV;
    scopePortalFOVHigh  = default.scopePortalFOVHigh;
    scopePortalFOV      = default.scopePortalFOV;
    PlayerIronSightFOV  = default.PlayerIronSightFOV;
    if(class'NiceVeterancyTypes'.static.hasSkill(NicePlayerController(Instigator.Controller), class'NiceSkillSharpshooterHardWork')){       default.ZoomTime    *= class'NiceSkillSharpshooterHardWork'.default.zoomSpeedBonus;       PlayerIronSightFOV  *= class'NiceSkillSharpshooterHardWork'.default.zoomBonus;       scopePortalFOVHigh  *= class'NiceSkillSharpshooterHardWork'.default.zoomBonus;       scopePortalFOV      *= class'NiceSkillSharpshooterHardWork'.default.zoomBonus;       PlayerIronSightFOV  *= class'NiceSkillSharpshooterHardWork'.default.zoomBonus;
    }
    super.ZoomOut(bAnimateTransition);
    bAimingRifle = False;
    if( KFHumanPawn(Instigator)!=none )       KFHumanPawn(Instigator).SetAiming(False);
    if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )
    {       if( AimOutSound != none )       {           PlayOwnedSound(AimOutSound, SLOT_Interact,,,,, false);       }       KFPlayerController(Instigator.Controller).TransitionFOV(KFPlayerController(Instigator.Controller).DefaultFOV,0.0);
    }
}
simulated function WeaponTick(float dt)
{
    super.WeaponTick(dt);
    if(bAimingRifle && ForceZoomOutTime > 0 && Level.TimeSeconds - ForceZoomOutTime > 0)
    {       ForceZoomOutTime = 0;
       ZoomOut(false);
       if(Role < ROLE_Authority)           ServerZoomOut(false);
    }
}
// Called by the native code when the interpolation of the first person weapon to the zoomed position finishes
simulated event OnZoomInFinished()
{
    local name anim;
    local float frame, rate;
    GetAnimParams(0, anim, frame, rate);
    if (ClientState == WS_ReadyToFire)
    {       // Play the iron idle anim when we're finished zooming in       if (anim == IdleAnim)       {          PlayIdle();       }
    }
    if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none &&       KFScopeDetail == KF_TextureScope )
    {       KFPlayerController(Instigator.Controller).TransitionFOV(PlayerIronSightFOV,0.0);
    }
}
simulated function bool CanZoomNow()
{
    Return (!FireMode[0].bIsFiring && !FireMode[1].bIsFiring && Instigator!=none && Instigator.Physics!=PHYS_Falling);
}
simulated event RenderOverlays(Canvas Canvas)
{
    local int m;
    local PlayerController PC;
    if (Instigator == none)       return;
    PC = PlayerController(Instigator.Controller);
    if(PC == none)       return;
    if(!bInitializedScope && PC != none )
    {       UpdateScopeMode();
    }
    Canvas.DrawActor(none, false, true);
    for (m = 0; m < NUM_FIRE_MODES; m++)
    {       if (FireMode[m] != none)       {           FireMode[m].DrawMuzzleFlash(Canvas);       }
    }

    SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
    SetRotation( Instigator.GetViewRotation() + ZoomRotInterp);
    PreDrawFPWeapon();
    if(bAimingRifle && PC != none && (KFScopeDetail == KF_ModelScope || KFScopeDetail == KF_ModelScopeHigh)){       if(ShouldDrawPortal()){           if(ScopeScriptedTexture != none){               Skins[LenseMaterialID] = ScopeScriptedShader;               ScopeScriptedTexture.Client = Self;               ScopeScriptedTexture.Revision = (ScopeScriptedTexture.Revision + 1);           }       }
       bDrawingFirstPerson = true;       Canvas.DrawBoundActor(self, false, false,DisplayFOV,PC.Rotation,rot(0,0,0),Instigator.CalcZoomedDrawOffset(self));       bDrawingFirstPerson = false;
    }
    else if(KFScopeDetail == KF_TextureScope && PC.DesiredFOV == PlayerIronSightFOV && bAimingRifle){       Skins[LenseMaterialID] = ScriptedTextureFallback;
       SetZoomBlendColor(Canvas);
       Canvas.Style = ERenderStyle.STY_Normal;       Canvas.SetPos(0, 0);       Canvas.DrawTile(ZoomMat, (Canvas.SizeX - Canvas.SizeY) / 2, Canvas.SizeY, 0.0, 0.0, 8, 8);       Canvas.SetPos(Canvas.SizeX, 0);       Canvas.DrawTile(ZoomMat, -(Canvas.SizeX - Canvas.SizeY) / 2, Canvas.SizeY, 0.0, 0.0, 8, 8);
       Canvas.Style = 255;       Canvas.SetPos((Canvas.SizeX - Canvas.SizeY) / 2,0);       Canvas.DrawTile(ZoomMat, Canvas.SizeY, Canvas.SizeY, 0.0, 0.0, tileSize, tileSize);
       Canvas.Font = Canvas.MedFont;       Canvas.SetDrawColor(200,150,0);
       Canvas.SetPos(Canvas.SizeX * 0.16, Canvas.SizeY * 0.43);       Canvas.DrawText(" ");
       Canvas.SetPos(Canvas.SizeX * 0.16, Canvas.SizeY * 0.47);
    }
    else{       Skins[LenseMaterialID] = ScriptedTextureFallback;       bDrawingFirstPerson = true;       Canvas.DrawActor(self, false, false, DisplayFOV);       bDrawingFirstPerson = false;
    }
}
// Adjust a single FOV based on the current aspect ratio. Adjust FOV is the default NON-aspect ratio adjusted FOV to adjust
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
// AdjustIngameScope(RO) - Takes the changes to the ScopeDetail variable and
// sets the scope to the new detail mode. Called when the player switches the
// scope setting ingame, or when the scope setting is changed from the menu
simulated function AdjustIngameScope()
{
    local PlayerController PC;
    if(Instigator == none || PlayerController(Instigator.Controller) == none)       return;
    PC = PlayerController(Instigator.Controller);
    if(!bHasScope)       return;
    switch (KFScopeDetail)
    {       case KF_ModelScope:           if(bAimingRifle)               DisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);           if (PC.DesiredFOV == PlayerIronSightFOV && bAimingRifle){               if(Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none)                   KFPlayerController(Instigator.Controller).TransitionFOV(KFPlayerController(Instigator.Controller).DefaultFOV,0.0);           }       break;
       case KF_TextureScope:           if(bAimingRifle)               DisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);           if (bAimingRifle && PC.DesiredFOV != PlayerIronSightFOV){               if(Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none)                   KFPlayerController(Instigator.Controller).TransitionFOV(PlayerIronSightFOV,0.0);           }       break;
       case KF_ModelScopeHigh:           if(bAimingRifle){               if(default.ZoomedDisplayFOVHigh > 0)                   DisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOVHigh);               else                   DisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);           }           if ( bAimingRifle && PC.DesiredFOV == PlayerIronSightFOV )           {               if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )               {                   KFPlayerController(Instigator.Controller).TransitionFOV(KFPlayerController(Instigator.Controller).DefaultFOV,0.0);               }           }           break;
    }
    // Make any chagned to the scope setup
    UpdateScopeMode();
}
simulated event Destroyed()
{
    PreTravelCleanUp();
    Super.Destroyed();
}
simulated function PreTravelCleanUp()
{
    if(ScopeScriptedTexture != none){       ScopeScriptedTexture.Client = none;       Level.ObjectPool.FreeObject(ScopeScriptedTexture);       ScopeScriptedTexture=none;
    }
    if(ScriptedScopeCombiner != none){       ScriptedScopeCombiner.Material2 = none;       Level.ObjectPool.FreeObject(ScriptedScopeCombiner);       ScriptedScopeCombiner = none;
    }
    if(ScopeScriptedShader != none){       ScopeScriptedShader.Diffuse = none;       ScopeScriptedShader.SelfIllumination = none;       Level.ObjectPool.FreeObject(ScopeScriptedShader);       ScopeScriptedShader = none;
    }
}
defaultproperties
{    tileSize=1024
}
