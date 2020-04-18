class NiceTSCLobbyFooter extends NiceLobbyFooter;
defaultproperties
{
    Begin Object Class=GUIButton Name=ReadyButton
        Caption="Ready"
        MenuState=MSAT_Disabled
        Hint="Click to indicate you are ready to play"
        WinTop=0.966146
        WinLeft=0.280000
        WinWidth=0.120000
        WinHeight=0.033203
        RenderWeight=2.000000
        TabOrder=4
        bBoundToParent=True
        bVisible=False
        ToolTip=None

        OnClick=TSCLobbyFooter.OnFooterClick
        OnKeyEvent=ReadyButton.InternalOnKeyEvent
    End Object
    b_Ready=GUIButton'NicePack.NiceTSCLobbyFooter.ReadyButton'
}
