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
    if(default.ScopeGreen == none)       default.ScopeGreen = Material(DynamicLoadObject("KF_Weapons5_Scopes_Trip_T.M7A3.Scope_Finall", class'Material', true));
    if(default.ScopeRed == none)       default.ScopeRed = Material(DynamicLoadObject("KF_Weapons5_Scopes_Trip_T.M7A3.ScopeRed_Shader", class'Material', true));
    if(default.MyScriptedTexture == none)       default.MyScriptedTexture = ScriptedTexture(DynamicLoadObject("KF_Weapons5_Scopes_Trip_T.M7A3_Ammo_Script.AmmoNumber", class'ScriptedTexture', true));
    if(default.MyFont == none)       default.MyFont = Font(DynamicLoadObject("IJCFonts.DigitalBig", class'Font', true));
    if(default.MyFont2 == none)       default.MyFont2 = Font(DynamicLoadObject("IJCFonts.DigitalBig", class'Font', true));
    if(default.SmallMyFont == none)       default.SmallMyFont = Font(DynamicLoadObject("IJCFonts.DigitalMed", class'Font', true));
    if(M7A3MMedicGun(Inv) != none){       M7A3MMedicGun(Inv).ScopeGreen = default.ScopeGreen;       M7A3MMedicGun(Inv).ScopeRed = default.ScopeRed;       M7A3MMedicGun(Inv).MyScriptedTexture = default.MyScriptedTexture;       M7A3MMedicGun(Inv).MyFont = default.MyFont;       M7A3MMedicGun(Inv).MyFont2 = default.MyFont2;       M7A3MMedicGun(Inv).SmallMyFont = default.SmallMyFont;
    }
    super.PreloadAssets(Inv, bSkipRefCount);
}
static function bool UnloadAssets(){
    if(super.UnloadAssets()){       default.ScopeGreen = none;       default.ScopeRed = none;       default.MyScriptedTexture = none;       default.MyFont = none;       default.MyFont2 = none;       default.SmallMyFont = none;       return true;
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
    if(medicCharge >= 50){       SetTextColor2(76,148,177);       MyScriptedTexture.Revision ++;
    }
    else{       SetTextColor2(218,18,18);       MyScriptedTexture.Revision ++;
    }
    if(AmmoAmount(0) <= 0){       if(OldValue != -5){           OldValue = -5;           Skins[2] = ScopeRed;           MyFont = SmallMyFont;           SetTextColor(218,18,18);           MyMessage = EmptyMessage;           MyScriptedTexture.Revision ++;       }
    }
    else if(bIsReloading){       if(OldValue != -4){           OldValue = -4;           MyFont = SmallMyFont;           SetTextColor(32,187,112);           MyMessage = ReloadMessage;           ++MyScriptedTexture.Revision;       }
    }
    else if(OldValue != (MagAmmoRemaining + 1)){       OldValue = MagAmmoRemaining+1;       Skins[2] = ScopeGreen;       MyFont = Default.MyFont;
       if(MagAmmoRemaining <= (MagCapacity/2))           SetTextColor(32,187,112);       if(MagAmmoRemaining <= (MagCapacity / 3)){           SetTextColor(218,18,18);           Skins[2] = ScopeRed;       }       if(MagAmmoRemaining >= (MagCapacity/2))           SetTextColor(76,148,177);       MyMessage = String(MagAmmoRemaining);
       MyScriptedTexture.Revision ++;
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
{    ReloadMessage="REL"    EmptyMessage="Empty"    MyFontColor=(B=177,G=148,R=76,A=255)    MyFontColor2=(B=177,G=148,R=76,A=255)    reloadPreEndFrame=0.148000    reloadEndFrame=0.519000    reloadChargeEndFrame=0.740000    reloadMagStartFrame=0.222000    reloadChargeStartFrame=0.531000    MagCapacity=30    ReloadRate=3.066000    ReloadAnim="Reload"    ReloadAnimRate=1.000000    WeaponReloadAnim="Reload_M7A3"    Weight=5.000000    bHasAimingMode=True    IdleAimAnim="Idle_Iron"    StandardDisplayFOV=55.000000    SleeveNum=3    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_M7A3'    bIsTier3Weapon=True    MeshRef="KF_Wep_M7A3.M7A3"    SkinRefs(0)="KF_Weapons5_Trip_T.Weapons.M7A3_cmb"    SkinRefs(1)="KF_Weapons5_Scopes_Trip_T.M7A3_Ammo_Script.AmmoShader"    SkinRefs(2)="KF_Weapons5_Scopes_Trip_T.M7A3.Scope_Finall"    SelectSoundRef="KF_M7A3Snd.M7A3_Select"    HudImageRef="KillingFloor2HUD.WeaponSelect.M7A3_unselected"    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.M7A3"    PlayerIronSightFOV=65.000000    ZoomedDisplayFOV=45.000000    FireModeClass(0)=Class'NicePack.NiceM7A3MFire'    FireModeClass(1)=Class'NicePack.NiceM7A3MAltFire'    PutDownAnim="PutDown"    SelectForce="SwitchToAssaultRifle"    AIRating=0.550000    CurrentRating=0.550000    bShowChargingBar=True    Description="An advanced Horzine prototype assault rifle. Modified to fire healing darts."    EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)    DisplayFOV=55.000000    Priority=100    InventoryGroup=4    GroupOffset=13    PickupClass=Class'NicePack.NiceM7A3MPickup'    PlayerViewOffset=(X=20.000000,Y=15.000000,Z=-5.000000)    BobDamping=6.000000    AttachmentClass=Class'NicePack.NiceM7A3MAttachment'    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)    ItemName="M7A3 Medic Gun"    TransientSoundVolume=1.250000
}
