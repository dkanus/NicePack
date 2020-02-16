class NiceFFVoting extends ScrnVotingOptions;
var NicePack Mut;
const VOTE_CHANGE = 1;
const VOTE_RESET = 2;
function int GetGroupVoteIndex(PlayerController Sender, string Group, string Key, out string Value, out string VoteInfo){
    local TeamGame TG;
    local float ffScale;
    local bool bCanIncrease;
    ffScale = float(Value);
    TG = TeamGame(Level.Game);
    bCanIncrease = true;
    if(Mut != none){
       bCanIncrease = !Mut.bFFWasIncreased || !Mut.bOneFFIncOnly;
       if(Mut.ScrnGT != none)
           bCanIncrease = bCanIncrease && (!Mut.bNoLateFFIncrease || (Mut.ScrnGT.WaveNum < 1 || (Mut.ScrnGT.WaveNum == 2 && Mut.ScrnGT.bTradingDoorsOpen)));
    }
    if(Key ~= "CHANGE"){
       if(ffScale < 0.0 || ffScale > 1.0)
           return VOTE_ILLEGAL;
       if(TG != none && (ffScale <= TG.FriendlyFireScale || bCanIncrease))
           return VOTE_CHANGE;
       else
           return VOTE_ILLEGAL;
    }
    else if(Key ~= "RESET")
       return VOTE_RESET;
    return VOTE_UNKNOWN;
}
function ApplyVoteValue(int VoteIndex, string VoteValue){
    local TeamGame TG;
    local float ffScale;
    TG = TeamGame(Level.Game);
    if(VoteIndex == VOTE_CHANGE){
       ffScale = float(VoteValue);
       ffScale = FMax(0.0, FMin(1.0, ffScale));
    }
    else if(VoteIndex == VOTE_RESET)
       ffScale = TG.default.FriendlyFireScale;
    if(TG != none){
       if(ffScale > TG.FriendlyFireScale)
           Mut.bFFWasIncreased = true;
       TG.FriendlyFireScale = ffScale;
    }
}
function SendGroupHelp(PlayerController Sender, string Group){
    super.SendGroupHelp(Sender, Group);
}
defaultproperties
{
    DefaultGroup="FF"
    HelpInfo(0)="%pFF %gRESET%w|%rCHANGE %y<ff_scale> %wChanges friendly fire scale."
    GroupInfo(0)="%pFF %gRESET%w|%rCHANGE %y<ff_scale> %wChanges friendly fire scale."
}
