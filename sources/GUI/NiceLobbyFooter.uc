class NiceLobbyFooter extends ScrnLobbyFooter;
function bool OnFooterClick(GUIComponent Sender)
{
    if (Sender == b_Perks){
       PlayerOwner().ClientOpenMenu(string(Class'NicePack.NiceInvasionLoginMenu'), false);
       return false;
    }
    else if(Sender == b_ViewMap){
       if(KF_StoryGRI(PlayerOwner().Level.GRI) == none){
           LobbyMenu(PageOwner).bAllowClose = true;
           PlayerOwner().ClientCloseMenu(true, false);    
           LobbyMenu(PageOwner).bAllowClose = false;
       }
    }
    else if(Sender == b_Ready){
       return super(LobbyFooter).OnFooterClick(Sender); // bypass serverperks
    }
    else
       return super.OnFooterClick(Sender);
}
defaultproperties
{
}
