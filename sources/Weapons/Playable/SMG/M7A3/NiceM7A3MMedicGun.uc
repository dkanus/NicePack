class NiceM7A3MMedicGun extends NiceMedicGun;
var localized   string  ReloadMessage;
var localized   string  EmptyMessage;
var Material        ScopeGreen;
var Material        ScopeRed;
var ScriptedTexture MyScriptedTexture;
var string          MyMessage;
var Font            MyFont;
var Font            MyFont2;
var Font            SmallMyFont;
var color           MyFontColor;
var color           MyFontColor2;
var int             OldValue;

static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount)
{
    if(default.ScopeGreen == none)
    if(default.ScopeRed == none)
    if(default.MyScriptedTexture == none)
    if(default.MyFont == none)
    if(default.MyFont2 == none)
    if(default.SmallMyFont == none)
    if(M7A3MMedicGun(Inv) != none){
    }
    super.PreloadAssets(Inv, bSkipRefCount);
}
static function bool UnloadAssets(){
    if(super.UnloadAssets()){
    }
    return false;
}
simulated final function SetTextColor(byte R, byte G, byte B){
    MyFontColor.R = R;
    MyFontColor.G = G;
    MyFontColor.B = B;
    MyFontColor.A = 255;
}
simulated final function SetTextColor2(byte R, byte G, byte B){
    MyFontColor2.R = R;
    MyFontColor2.G = G;
    MyFontColor2.B = B;
    MyFontColor2.A = 255;
 }
simulated function RenderOverlays(Canvas Canvas){
    if(medicCharge >= 50){
    }
    else{
    }
    if(AmmoAmount(0) <= 0){
    }
    else if(bIsReloading){
    }
    else if(OldValue != (MagAmmoRemaining + 1)){


    }
    MyScriptedTexture.Client = Self;
    Super.RenderOverlays(Canvas);
    MyScriptedTexture.Client = None;
}
simulated function RenderTexture(ScriptedTexture Tex){
    local int w, h;
    // Ammo
    Tex.TextSize( MyMessage, MyFont, w, h );
    Tex.DrawText( ( Tex.USize / 2 ) - ( w / 2 ), ( Tex.VSize / 2 ) - ( h / 1.2 ),MyMessage, MyFont, MyFontColor );
    // Health
    Tex.TextSize( int(medicCharge), MyFont2, w, h );
    Tex.DrawText( ( Tex.USize / 2 ) - ( w / 2 ), ( Tex.VSize / 2 ) - 8, int(medicCharge), MyFont2, MyFontColor2 );
}
defaultproperties
{
}