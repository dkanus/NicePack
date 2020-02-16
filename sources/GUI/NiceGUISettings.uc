class NiceGUISettings extends Settings_Tabs;
//var automated   GUIButton   skillButtonA;
var array<string>   ForceProjItems;
var automated     moCheckBox                ch_WeapManagement;
var automated     moCheckBox                ch_AltSwitches;
var automated     moCheckBox                ch_DispCounters;
var automated     moCheckBox                ch_DisWeapProgress;
var automated     moCheckBox                ch_ShowHLMessages;
var automated     moCheckBox                ch_CancelFire;
var automated     moCheckBox                ch_CancelSwitching;
var automated     moCheckBox                ch_CancelNades;
var automated     moCheckBox                ch_CancelAiming;
var automated     moCheckBox                ch_ReloadWontWork;
var automated   GUISectionBackground    bg_WEAP;
var automated   GUISectionBackground    bg_RELOAD;
function InitComponent(GUIController MyController, GUIComponent MyOwner){
    super.InitComponent(MyController, MyOwner);
}    
function InternalOnLoadINI(GUIComponent sender, string s){
    local NicePlayerController nicePlayer;
    nicePlayer = NicePlayerController(PlayerOwner());
    if(nicePlayer == none)       return;
    switch(sender){
    case ch_WeapManagement:       ch_WeapManagement.Checked(nicePlayer.bNiceWeaponManagement);       break;
    case ch_AltSwitches:       ch_AltSwitches.Checked(nicePlayer.bFlagAltSwitchesModes);       break;
    case ch_DispCounters:       ch_DispCounters.Checked(nicePlayer.bFlagDisplayCounters);       break;
    case ch_DisWeapProgress:       ch_DisWeapProgress.Checked(nicePlayer.bFlagDisplayWeaponProgress);       break;
    case ch_ShowHLMessages:       ch_ShowHLMessages.Checked(nicePlayer.bFlagShowHLMessages);       break;
    case ch_CancelFire:       ch_CancelFire.Checked(nicePlayer.bRelCancelByFire);       break;
    case ch_CancelSwitching:       ch_CancelSwitching.Checked(nicePlayer.bRelCancelBySwitching);       break;
    case ch_CancelNades:       ch_CancelNades.Checked(nicePlayer.bRelCancelByNades);       break;
    case ch_CancelAiming:       ch_CancelAiming.Checked(nicePlayer.bRelCancelByAiming);       break;
    case ch_ReloadWontWork:       ch_ReloadWontWork.Checked(nicePlayer.bFlagUseServerReload);       break;
    }
}
function InternalOnChange(GUIComponent Sender){
    local NicePlayerController nicePlayer;
    super.InternalOnChange(Sender);
    nicePlayer = NicePlayerController(PlayerOwner());
    if(nicePlayer == none)       return;
    switch(sender){
    case ch_WeapManagement:       nicePlayer.bNiceWeaponManagement = ch_WeapManagement.IsChecked();       break;
    case ch_AltSwitches:       nicePlayer.ServerSetAltSwitchesModes(ch_AltSwitches.IsChecked());       break;
    case ch_DispCounters:       nicePlayer.ServerSetDisplayCounters(ch_DispCounters.IsChecked());       break;
    case ch_DisWeapProgress:       nicePlayer.ServerSetDisplayWeaponProgress(ch_DisWeapProgress.IsChecked());       break;
    case ch_ShowHLMessages:       nicePlayer.ServerSetHLMessages(ch_ShowHLMessages.IsChecked());       break;
    case ch_CancelFire:       nicePlayer.bRelCancelByFire = ch_CancelFire.IsChecked();       break;
    case ch_CancelSwitching:       nicePlayer.bRelCancelBySwitching = ch_CancelSwitching.IsChecked();       break;
    case ch_CancelNades:       nicePlayer.bRelCancelByNades = ch_CancelNades.IsChecked();       break;
    case ch_CancelAiming:       nicePlayer.bRelCancelByAiming = ch_CancelAiming.IsChecked();       break;
    case ch_ReloadWontWork:       nicePlayer.ServerSetUseServerReload(ch_ReloadWontWork.IsChecked());       break;
    }
    nicePlayer.ClientSaveConfig();
}
// size = (x=0.0125, y=0.0) ; (w=1.0, h=0.865)
// tab order
defaultproperties
{    Begin Object Class=moCheckBox Name=WeaponManagement        CaptionWidth=0.955000        Caption="Nice weapon management"        ComponentClassName="ScrnBalanceSrv.ScrnGUICheckBoxButton"        OnCreateComponent=WeaponManagement.InternalOnCreateComponent        IniOption="@Internal"        Hint="If checked, NicePack will use it's own system to manage weapon switching"        WinTop=0.050000        WinLeft=0.012500        WinWidth=0.278000        TabOrder=4        OnChange=NiceGUISettings.InternalOnChange        OnLoadINI=NiceGUISettings.InternalOnLoadINI    End Object    ch_WeapManagement=moCheckBox'NicePack.NiceGUISettings.WeaponManagement'
    Begin Object Class=moCheckBox Name=AltSwitches        CaptionWidth=0.955000        Caption="Alt fire switches modes"        ComponentClassName="ScrnBalanceSrv.ScrnGUICheckBoxButton"        OnCreateComponent=AltSwitches.InternalOnCreateComponent        IniOption="@Internal"        Hint="Assault-rifle only; if enabled - alt fire button switches between fire modes, otherwise - acts as an alt fire"        WinTop=0.100000        WinLeft=0.012500        WinWidth=0.278000        TabOrder=6        OnChange=NiceGUISettings.InternalOnChange        OnLoadINI=NiceGUISettings.InternalOnLoadINI    End Object    ch_AltSwitches=moCheckBox'NicePack.NiceGUISettings.AltSwitches'
    Begin Object Class=moCheckBox Name=DispCounters        CaptionWidth=0.955000        Caption="Display counters"        ComponentClassName="ScrnBalanceSrv.ScrnGUICheckBoxButton"        OnCreateComponent=DispCounters.InternalOnCreateComponent        IniOption="@Internal"        Hint="Toggles display of the various counters used by skills"        WinTop=0.150000        WinLeft=0.012500        WinWidth=0.278000        TabOrder=7        OnChange=NiceGUISettings.InternalOnChange        OnLoadINI=NiceGUISettings.InternalOnLoadINI    End Object    ch_DispCounters=moCheckBox'NicePack.NiceGUISettings.DispCounters'
    Begin Object Class=moCheckBox Name=DispWeapProgress        CaptionWidth=0.955000        Caption="Display weapon progress"        ComponentClassName="ScrnBalanceSrv.ScrnGUICheckBoxButton"        OnCreateComponent=DispWeapProgress.InternalOnCreateComponent        IniOption="@Internal"        Hint="Displays weapon progress rate, whoever it's defined by a skill that's using this functionality"        WinTop=0.200000        WinLeft=0.012500        WinWidth=0.278000        TabOrder=8        OnChange=NiceGUISettings.InternalOnChange        OnLoadINI=NiceGUISettings.InternalOnLoadINI    End Object    ch_DisWeapProgress=moCheckBox'NicePack.NiceGUISettings.DispWeapProgress'
    Begin Object Class=moCheckBox Name=ShowHLMessages        CaptionWidth=0.955000        Caption="Show Hardcore Level messages"        ComponentClassName="ScrnBalanceSrv.ScrnGUICheckBoxButton"        OnCreateComponent=ShowHLMessages.InternalOnCreateComponent        IniOption="@Internal"        Hint="Enable to be notified each time Hardcore Level is changed"        WinTop=0.300000        WinLeft=0.012500        WinWidth=0.278000        TabOrder=9        OnChange=NiceGUISettings.InternalOnChange        OnLoadINI=NiceGUISettings.InternalOnLoadINI    End Object    ch_ShowHLMessages=moCheckBox'NicePack.NiceGUISettings.ShowHLMessages'
    Begin Object Class=moCheckBox Name=CancelFire        CaptionWidth=0.955000        Caption="Cancel reload by shooting"        ComponentClassName="ScrnBalanceSrv.ScrnGUICheckBoxButton"        OnCreateComponent=CancelFire.InternalOnCreateComponent        IniOption="@Internal"        Hint="If checked, you'll be able to cancel reload of converted weapons by shooting (when you have ammo)"        WinTop=0.050000        WinLeft=0.517500        WinWidth=0.287000        TabOrder=11        OnChange=NiceGUISettings.InternalOnChange        OnLoadINI=NiceGUISettings.InternalOnLoadINI    End Object    ch_CancelFire=moCheckBox'NicePack.NiceGUISettings.CancelFire'
    Begin Object Class=moCheckBox Name=CancelSwitching        CaptionWidth=0.955000        Caption="Cancel reload by switching weapons"        ComponentClassName="ScrnBalanceSrv.ScrnGUICheckBoxButton"        OnCreateComponent=CancelSwitching.InternalOnCreateComponent        IniOption="@Internal"        Hint="If checked, you'll be able to cancel reload of converted weapons by switching to different weapon"        WinTop=0.100000        WinLeft=0.517500        WinWidth=0.287000        TabOrder=12        OnChange=NiceGUISettings.InternalOnChange        OnLoadINI=NiceGUISettings.InternalOnLoadINI    End Object    ch_CancelSwitching=moCheckBox'NicePack.NiceGUISettings.CancelSwitching'
    Begin Object Class=moCheckBox Name=CancelNades        CaptionWidth=0.955000        Caption="Cancel reload by throwing grenades"        ComponentClassName="ScrnBalanceSrv.ScrnGUICheckBoxButton"        OnCreateComponent=CancelNades.InternalOnCreateComponent        IniOption="@Internal"        Hint="If checked, you'll be able to cancel reload of converted weapons by throwing a grenade"        WinTop=0.150000        WinLeft=0.517500        WinWidth=0.287000        TabOrder=13        OnChange=NiceGUISettings.InternalOnChange        OnLoadINI=NiceGUISettings.InternalOnLoadINI    End Object    ch_CancelNades=moCheckBox'NicePack.NiceGUISettings.CancelNades'
    Begin Object Class=moCheckBox Name=CancelAiming        CaptionWidth=0.955000        Caption="Cancel reload by aiming"        ComponentClassName="ScrnBalanceSrv.ScrnGUICheckBoxButton"        OnCreateComponent=CancelAiming.InternalOnCreateComponent        IniOption="@Internal"        Hint="If checked, you'll be able to cancel reload of converted weapons by going into iron sights (when you have ammo)"        WinTop=0.200000        WinLeft=0.517500        WinWidth=0.287000        TabOrder=14        OnChange=NiceGUISettings.InternalOnChange        OnLoadINI=NiceGUISettings.InternalOnLoadINI    End Object    ch_CancelAiming=moCheckBox'NicePack.NiceGUISettings.CancelAiming'
    Begin Object Class=moCheckBox Name=ServerReload        CaptionWidth=0.955000        Caption="My reload doesn't work"        ComponentClassName="ScrnBalanceSrv.ScrnGUICheckBoxButton"        OnCreateComponent=ServerReload.InternalOnCreateComponent        IniOption="@Internal"        Hint="Check this option ONLY in case converted weapons don't reload at all for you; this option should fix the problem, but then latency will affect both reload and active reload"        WinTop=0.250000        WinLeft=0.517500        WinWidth=0.287000        TabOrder=15        OnChange=NiceGUISettings.InternalOnChange        OnLoadINI=NiceGUISettings.InternalOnLoadINI    End Object    ch_ReloadWontWork=moCheckBox'NicePack.NiceGUISettings.ServerReload'
    Begin Object Class=GUISectionBackground Name=WEAPBG        Caption="General weapon settings"        WinTop=0.012500        WinWidth=0.495000        WinHeight=0.287500        RenderWeight=0.100100        OnPreDraw=WeaponsBG.InternalPreDraw    End Object    bg_WEAP=GUISectionBackground'NicePack.NiceGUISettings.WEAPBG'
    Begin Object Class=GUISectionBackground Name=RELOADBG        Caption="Weapon reload settings"        WinTop=0.012500        WinLeft=0.505000        WinWidth=0.495000        WinHeight=0.287500        RenderWeight=0.100100        OnPreDraw=WeaponsBG.InternalPreDraw    End Object    bg_RELOAD=GUISectionBackground'NicePack.NiceGUISettings.RELOADBG'
}
