class NicePanelSkills extends Settings_Tabs;
var automated   NiceGUIPerkButton   skillButtonA[5], skillButtonB[5];
function ShowPanel(bool bShow){
    local int i;
    local class<NiceVeterancyTypes> niceVet;
    local NicePlayerController nicePlayer;
    Super.ShowPanel(bShow);
    nicePlayer = NicePlayerController(PlayerOwner());
    if(nicePlayer != none)
       niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(nicePlayer.PlayerReplicationInfo);
    if(niceVet != none){
       for(i = 0;i < 5;i ++){
           skillButtonA[i].skillIndex = i;
           skillButtonB[i].skillIndex = i;
           skillButtonA[i].skillPerkIndex = niceVet.default.PerkIndex;
           skillButtonB[i].skillPerkIndex = niceVet.default.PerkIndex;
           skillButtonA[i].isAltSkill = false;
           skillButtonB[i].isAltSkill = true;
           skillButtonA[i].associatedSkill = niceVet.default.SkillGroupA[i];
           skillButtonB[i].associatedSkill = niceVet.default.SkillGroupB[i];
       }
    }
}
// size = (x=0.0125, y=0.0) ; (w=1.0, h=0.865)
// setup caption
defaultproperties
{
    Begin Object Class=NiceGUIPerkButton Name=btn1A
        WinTop=0.012500
        WinWidth=0.495000
        WinHeight=0.160000
        RenderWeight=2.000000
        TabOrder=1
        bBoundToParent=True
        bScaleToParent=True
        bMouseOverSound=False
        OnClickSound=CS_None
        OnKeyEvent=btn1A.InternalOnKeyEvent
    End Object
    skillButtonA(0)=NiceGUIPerkButton'NicePack.NicePanelSkills.btn1A'

    Begin Object Class=NiceGUIPerkButton Name=btn2A
        WinTop=0.188500
        WinWidth=0.495000
        WinHeight=0.160000
        RenderWeight=2.000000
        TabOrder=3
        bBoundToParent=True
        bScaleToParent=True
        bMouseOverSound=False
        OnClickSound=CS_None
        OnKeyEvent=btn2A.InternalOnKeyEvent
    End Object
    skillButtonA(1)=NiceGUIPerkButton'NicePack.NicePanelSkills.btn2A'

    Begin Object Class=NiceGUIPerkButton Name=btn3A
        WinTop=0.364500
        WinWidth=0.495000
        WinHeight=0.160000
        RenderWeight=2.000000
        TabOrder=5
        bBoundToParent=True
        bScaleToParent=True
        bMouseOverSound=False
        OnClickSound=CS_None
        OnKeyEvent=btn3A.InternalOnKeyEvent
    End Object
    skillButtonA(2)=NiceGUIPerkButton'NicePack.NicePanelSkills.btn3A'

    Begin Object Class=NiceGUIPerkButton Name=btn4A
        WinTop=0.540500
        WinWidth=0.495000
        WinHeight=0.160000
        RenderWeight=2.000000
        TabOrder=7
        bBoundToParent=True
        bScaleToParent=True
        bMouseOverSound=False
        OnClickSound=CS_None
        OnKeyEvent=btn4A.InternalOnKeyEvent
    End Object
    skillButtonA(3)=NiceGUIPerkButton'NicePack.NicePanelSkills.btn4A'

    Begin Object Class=NiceGUIPerkButton Name=btn5A
        WinTop=0.716500
        WinWidth=0.495000
        WinHeight=0.160000
        RenderWeight=2.000000
        TabOrder=9
        bBoundToParent=True
        bScaleToParent=True
        bMouseOverSound=False
        OnClickSound=CS_None
        OnKeyEvent=btn5A.InternalOnKeyEvent
    End Object
    skillButtonA(4)=NiceGUIPerkButton'NicePack.NicePanelSkills.btn5A'

    Begin Object Class=NiceGUIPerkButton Name=btn1B
        WinTop=0.012500
        WinLeft=0.505000
        WinWidth=0.495000
        WinHeight=0.160000
        RenderWeight=2.000000
        TabOrder=2
        bBoundToParent=True
        bScaleToParent=True
        bMouseOverSound=False
        OnClickSound=CS_None
        OnKeyEvent=btn1B.InternalOnKeyEvent
    End Object
    skillButtonB(0)=NiceGUIPerkButton'NicePack.NicePanelSkills.btn1B'

    Begin Object Class=NiceGUIPerkButton Name=btn2B
        WinTop=0.188500
        WinLeft=0.505000
        WinWidth=0.495000
        WinHeight=0.160000
        RenderWeight=2.000000
        TabOrder=4
        bBoundToParent=True
        bScaleToParent=True
        bMouseOverSound=False
        OnClickSound=CS_None
        OnKeyEvent=btn2B.InternalOnKeyEvent
    End Object
    skillButtonB(1)=NiceGUIPerkButton'NicePack.NicePanelSkills.btn2B'

    Begin Object Class=NiceGUIPerkButton Name=btn3B
        WinTop=0.364500
        WinLeft=0.505000
        WinWidth=0.495000
        WinHeight=0.160000
        RenderWeight=2.000000
        TabOrder=6
        bBoundToParent=True
        bScaleToParent=True
        bMouseOverSound=False
        OnClickSound=CS_None
        OnKeyEvent=btn3B.InternalOnKeyEvent
    End Object
    skillButtonB(2)=NiceGUIPerkButton'NicePack.NicePanelSkills.btn3B'

    Begin Object Class=NiceGUIPerkButton Name=btn4B
        WinTop=0.540500
        WinLeft=0.505000
        WinWidth=0.495000
        WinHeight=0.160000
        RenderWeight=2.000000
        TabOrder=8
        bBoundToParent=True
        bScaleToParent=True
        bMouseOverSound=False
        OnClickSound=CS_None
        OnKeyEvent=btn4B.InternalOnKeyEvent
    End Object
    skillButtonB(3)=NiceGUIPerkButton'NicePack.NicePanelSkills.btn4B'

    Begin Object Class=NiceGUIPerkButton Name=btn5B
        WinTop=0.716500
        WinLeft=0.505000
        WinWidth=0.495000
        WinHeight=0.160000
        RenderWeight=2.000000
        TabOrder=10
        bBoundToParent=True
        bScaleToParent=True
        bMouseOverSound=False
        OnClickSound=CS_None
        OnKeyEvent=btn5B.InternalOnKeyEvent
    End Object
    skillButtonB(4)=NiceGUIPerkButton'NicePack.NicePanelSkills.btn5B'
}
