class NiceSkillSharpshooterKillConfirmed extends NiceSkill
    abstract;
var float damageBonus;
var float stackDelay;
var int maxStacks;
function static SkillSelected(NicePlayerController nicePlayer){
    local NicePack niceMutator;
    super.SkillSelected(nicePlayer);
    niceMutator = class'NicePack'.static.Myself(nicePlayer.Level);
    if(niceMutator == none || niceMutator.Role == Role_AUTHORITY)
       return;
    niceMutator.AddCounter("npSharpConfirmed", Texture'NicePackT.HudCounter.zedHeadStreak', false, default.class);
}
function static SkillDeSelected(NicePlayerController nicePlayer){
    local NicePack niceMutator;
    super.SkillDeSelected(nicePlayer);
    niceMutator = class'NicePack'.static.Myself(nicePlayer.Level);
    if(niceMutator == none || niceMutator.Role == Role_AUTHORITY)
       return;
    niceMutator.RemoveCounter("npSharpConfirmed");
}
function static int UpdateCounterValue(string counterName, NicePlayerController nicePlayer){
    local NiceHumanPawn nicePawn;
    local NiceWeapon niceWeap;
    local NiceFire niceF;
    local float lockOnTickRate;
    local int lockonTicks;
    if(nicePlayer == none || counterName != "npSharpConfirmed")
       return 0;
    nicePawn = NiceHumanPawn(nicePlayer.pawn);
    if(nicePawn != none)
       niceWeap = NiceWeapon(nicePawn.weapon);
    if(niceWeap != none)
       niceF = niceWeap.GetMainFire();
    if(niceF == none)
       return 0;
    lockOnTickRate = class'NiceSkillSharpshooterKillConfirmed'.default.stackDelay;
    lockonTicks = Ceil(niceF.fireState.lockon.time / lockOnTickRate) - 1;
    lockonTicks = Min(class'NiceSkillSharpshooterKillConfirmed'.default.maxStacks, lockonTicks);
    lockonTicks = Max(lockonTicks, 0);
    return lockonTicks;
}
defaultproperties
{
    damageBonus=1.000000
    stackDelay=1.000000
    maxStacks=1
    SkillName="Kill confirmed"
    SkillEffects="Aiming at zed's head for a second doubles the damage of the shot."
}
