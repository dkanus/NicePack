class NiceM41AAssaultRifle extends NiceWeapon;

var string MyMessage;
var ScriptedTexture   AmmoDigitsScriptedTexture;
var Font              AmmoDigitsFont;
var color             AmmoDigitsColor, LowAmmoDigitsColor;
var int OldAmmoAmount;
var float MyYaw;

simulated function RenderOverlays( Canvas Canvas ){
    if(AmmoAmount(0) <= 0){
    }
    else if(bIsReloading){
    }
    else if(OldAmmoAmount!=(MagAmmoRemaining + 1)){
    }
    AmmoDigitsScriptedTexture.Client = Self;
    Super.RenderOverlays(Canvas);
    default.PlayerViewPivot.Yaw = 0;
    AmmoDigitsScriptedTexture.Client = None;
}

simulated function RenderTexture(ScriptedTexture Tex){
    local int w, h;
    Tex.TextSize( MyMessage, AmmoDigitsFont,  w, h );    
    Tex.DrawText( ( Tex.USize / 2 ) - ( w / 2.2 ), ( Tex.VSize / 2 ) - ( h / 2.0 ),MyMessage, AmmoDigitsFont, AmmoDigitsColor );
}

simulated function ZoomIn(bool bAnimateTransition){
    default.PlayerViewPivot.Yaw = 0;
    PlayerViewPivot.Yaw = 0;
    super.ZoomIn(bAnimateTransition);
}

simulated function ZoomOut(bool bAnimateTransition){
    default.PlayerViewPivot.Yaw = MyYaw; 
    PlayerViewPivot.Yaw = MyYaw;
    super.ZoomOut(bAnimateTransition);
}

simulated function PostBeginPlay(){
    local AutoReloadAnimDesc reloadDesc;
    autoReloadsDescriptions.Length = 0;
    reloadDesc.canInterruptFrame    = 0.05;
    reloadDesc.trashStartFrame      = 0.183;
    reloadDesc.resumeFrame          = 0.06;
    reloadDesc.speedFrame           = 0.04;
    reloadDesc.animName = 'AltFire';
    autoReloadsDescriptions[0] = reloadDesc;
    super.PostBeginPlay();
}

defaultproperties
{
    Weight=7.000000
}