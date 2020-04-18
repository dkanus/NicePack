class MeanVoting extends ScrnVotingOptions;
var NicePack Mut;
function int GetGroupVoteIndex(PlayerController Sender, string Group, string Key, out string Value, out string VoteInfo)
{
    local int ZedNumber;
    local int BoolValue;
    local bool bEnable;
    ZedNumber = Mut.ZedNumber(Key);
    BoolValue = TryStrToBool(Value);
    if(BoolValue == -1)
       return VOTE_ILLEGAL;
    bEnable = (BoolValue == 1);
    if(Key ~= "ALL")
       return 0;
    if (ZedNumber == -1)
       return VOTE_UNKNOWN;
    if(bEnable == Mut.ZedDatabase[ZedNumber].bNeedsReplacement)
       return VOTE_NOEFECT;
    else
       return ZedNumber + 1;
    return VOTE_UNKNOWN;
}
function ApplyVoteValue(int VoteIndex, string VoteValue)
{
    local int i;
    local int BoolValue;
    local bool bEnable;
    local bool bAffectsAll;
    bAffectsAll = false;
    if(VoteIndex == 0)
       bAffectsAll  = true;
    else
       VoteIndex --;
    BoolValue = TryStrToBool(VoteValue);
    if ( BoolValue == -1 )
       return;
    bEnable = (BoolValue == 1);
    if(!bAffectsAll)
       Mut.ZedDatabase[VoteIndex].bNeedsReplacement = bEnable;
    else{
       for(i = 0; i <= Mut.lastStandardZed;i ++)
           Mut.ZedDatabase[i].bNeedsReplacement = bEnable;
    }
    if(Mut.ZedDatabase[VoteIndex].ZedName ~= "CLOT" || bAffectsAll)
       Mut.bReplaceClot = bEnable;
    if(Mut.ZedDatabase[VoteIndex].ZedName ~= "CRAWLER" || bAffectsAll)
       Mut.bReplaceCrawler = bEnable;
    if(Mut.ZedDatabase[VoteIndex].ZedName ~= "STALKER" || bAffectsAll)
       Mut.bReplaceStalker = bEnable;
    if(Mut.ZedDatabase[VoteIndex].ZedName ~= "GOREFAST" || bAffectsAll)
       Mut.bReplaceGorefast = bEnable;
    if(Mut.ZedDatabase[VoteIndex].ZedName ~= "BLOAT" || bAffectsAll)
       Mut.bReplaceBloat = bEnable;
    if(Mut.ZedDatabase[VoteIndex].ZedName ~= "SIREN" || bAffectsAll)
       Mut.bReplaceSiren = bEnable;
    if(Mut.ZedDatabase[VoteIndex].ZedName ~= "HUSK" || bAffectsAll)
       Mut.bReplaceHusk = bEnable;
    if(Mut.ZedDatabase[VoteIndex].ZedName ~= "SCRAKE" || bAffectsAll)
       Mut.bReplaceScrake = bEnable;
    if(Mut.ZedDatabase[VoteIndex].ZedName ~= "FLESHPOUND" || bAffectsAll)
       Mut.bReplaceFleshpound = bEnable;
    Mut.SaveConfig();
    VotingHandler.BroadcastMessage(strRestartRequired);
}
function SendGroupHelp(PlayerController Sender, string Group)
{
    local string s;
    local int i;
    local int ln;
    ln = 1;
    s $= "ALL";
    for ( i=0; i <= Mut.lastStandardZed; ++i ) {
       if ( Mut.ZedDatabase[i].bNeedsReplacement )  
           s @= "%g";
       else
           s @= "%r";
       s $= Caps(Mut.ZedDatabase[i].ZedName);        if ( len(s) > 80 ) {
           // move to new line
           GroupInfo[ln++] = VotingHandler.ParseHelpLine(default.GroupInfo[1] @ s);
           s = "";
       }     }
    GroupInfo[ln] = VotingHandler.ParseHelpLine(default.GroupInfo[1] @ s);
    super.SendGroupHelp(Sender, Group);
}
defaultproperties
{
    DefaultGroup="MEAN"
    HelpInfo(0)="%pMEAN %y<zed_name> %gON%w|%rOFF %w Add|Remove mean zeds from the game. Type %bMVOTE MEAN HELP %w for more info."
    GroupInfo(0)="%MEAN %y<zed_name> %gON%w|%rOFF %w Add or remove mean zeds from the game."
    GroupInfo(1)="%wAvaliable mean zeds:"
}
