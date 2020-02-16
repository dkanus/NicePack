class NiceInvasionLoginMenu extends ScrnInvasionLoginMenu;
var bool bShowScrnMenu;
// copy-pasted from ScrnInvasionLoginMenu to change change remove news tab and add skills tab
function InitComponent(GUIController MyController, GUIComponent MyOwner){
    local int i;
    local string s;
    local eFontScale FS;
    local SRMenuAddition M;
    local int indexAfterScrn;
    // Setup panel classes.
    Panels[0].ClassName = string(Class'ScrnBalanceSrv.ScrnTab_MidGamePerks');
    Panels[1].ClassName = string(Class'NicePack.NicePanelSkills');
    Panels[2].ClassName = string(Class'SRTab_MidGameVoiceChat');
    Panels[3].ClassName = string(Class'SRTab_MidGameStats');
    Panels[0].Caption = Class'KFInvasionLoginMenu'.Default.Panels[1].Caption;
    Panels[1].Caption = "Skills";
    Panels[2].Caption = Class'KFInvasionLoginMenu'.Default.Panels[2].Caption;
    Panels[0].Hint = Class'KFInvasionLoginMenu'.Default.Panels[1].Hint;
    Panels[1].Hint = "Customize your perk";
    Panels[2].Hint = Class'KFInvasionLoginMenu'.Default.Panels[2].Hint;
    b_Spec.Caption=class'KFTab_MidGamePerks'.default.b_Spec.Caption;
    b_MatchSetup.Caption=class'KFTab_MidGamePerks'.default.b_MatchSetup.Caption;
    b_KickVote.Caption=class'KFTab_MidGamePerks'.default.b_KickVote.Caption;
    b_MapVote.Caption=class'KFTab_MidGamePerks'.default.b_MapVote.Caption;
    b_Quit.Caption=class'KFTab_MidGamePerks'.default.b_Quit.Caption;
    b_Favs.Caption=class'KFTab_MidGamePerks'.default.b_Favs.Caption;
    b_Favs.Hint=class'KFTab_MidGamePerks'.default.b_Favs.Hint;
    b_Settings.Caption=class'KFTab_MidGamePerks'.default.b_Settings.Caption;
    b_Browser.Caption=class'KFTab_MidGamePerks'.default.b_Browser.Caption;
    // Other panels
    Panels[4].ClassName = "ScrnBalanceSrv.ScrnTab_Achievements";
    Panels[4].Caption = "Achievements";
    Panels[4].Hint = "ScrN server-side achievements";
    if(default.bShowScrnMenu){       Panels[5].ClassName = "ScrnBalanceSrv.ScrnTab_UserSettings";       Panels[5].Caption = "ScrN Features";       Panels[5].Hint = "ScrN Balance features, settings and info";       indexAfterScrn = 6;
    }
    else       indexAfterScrn = 5;
    Panels[indexAfterScrn].ClassName = "NicePack.NiceGUISettings";
    Panels[indexAfterScrn].Caption = "Nice settings";
    Panels[indexAfterScrn].Hint = "Settings specific to NicePack mutator";
    Panels.Length = indexAfterScrn + 1;
    Super(UT2K4PlayerLoginMenu).InitComponent(MyController, MyOwner);
    // Mod menus
    foreach MyController.ViewportOwner.Actor.DynamicActors(class'SRMenuAddition',M)       if( M.bHasInit )       {           AddOnList[AddOnList.Length] = M;           M.NotifyMenuOpen(Self,MyController);       }
      s = GetSizingCaption();
    for ( i = 0; i < Controls.Length; i++ )
    {       if (GUIButton(Controls[i]) != none)       {           GUIButton(Controls[i]).bAutoSize = true;           GUIButton(Controls[i]).SizingCaption = s;           GUIButton(Controls[i]).AutoSizePadding.HorzPerc = 0.04;           GUIButton(Controls[i]).AutoSizePadding.VertPerc = 0.5;       }
    }
    s = class'KFTab_MidGamePerks'.default.PlayerStyleName;
    PlayerStyle = MyController.GetStyle(s, fs);
    InitGRI();
}
defaultproperties
{
}
