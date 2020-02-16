class NiceGUIPerkButton extends GUIButton;
var bool isAltSkill;
var int skillPerkIndex, skillIndex;
var class<NiceSkill> associatedSkill;
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    OnDraw = DrawSkillButton;
    OnClick = SkillChange; 
    Super.InitComponent(MyController, MyOwner);
}
function bool SkillChange(GUIComponent Sender){
    local byte newSkillChoice;
    local NicePlayerController skillOwner;
    if(isAltSkill)       newSkillChoice = 1;
    else       newSkillChoice = 0;
    skillOwner = NicePlayerController(PlayerOwner());
    if(skillOwner != none){       skillOwner.ServerSetSkill(skillPerkIndex, skillIndex, newSkillChoice);       skillOwner.SaveConfig();
    }
    return true;
}
function bool DrawSkillButton(Canvas cnvs){
    // Variables that contain information about this button's skill
    local NicePlayerController skillOwner;
    local bool bAvailable, bSelected, bPending;
    // Variables needed for text drawing
    local int descLineOffset;                                       // How much vertical space description took so far
    local string skillEffects, line;                                // 'line' is next line from description to be drawn, 'skillEffects' is a not-yet drawn part of skill's effect description
    local float textWidth, textHeight, nameHeight;                  // Variables for storing amount of space text uses
    local int horizontalOffset, verticalOffset, smVerticalOffset;   // Spaces between text and borders ('smVerticalOffset' is space between skill's name and description)
    // Old values for font and it's scale
    local Font oldFont;
    local float oldFontScaleX, oldFontScaleY;
    // Get skill parameters
    skillOwner = NicePlayerController(PlayerOwner());
    bAvailable = class'NiceVeterancyTypes'.static.CanUseSkill(skillOwner, associatedSkill);
    if(bAvailable)       bSelected = class'NiceVeterancyTypes'.static.HasSkill(skillOwner, associatedSkill);
    bPending = class'NiceVeterancyTypes'.static.IsSkillPending(skillOwner, associatedSkill);
    if(skillOwner == none || associatedSkill == none)       return true;
    // Text offset parameters that seem to give a good result
    horizontalOffset = 10;
    verticalOffset = 5;
    smVerticalOffset = 2;
    // Backup old font values and set the new ones
    oldFont = cnvs.Font;
    oldFontScaleX = cnvs.FontScaleX;
    oldFontScaleY = cnvs.FontScaleY;
    cnvs.Font = class'ROHUD'.Static.LoadSmallFontStatic(3);
    cnvs.FontScaleX = 1.0;
    cnvs.FontScaleY = 1.0;
    // Draw text
    // - Name
    cnvs.SetPos(ActualLeft() + horizontalOffset, ActualTop() + verticalOffset);
    if(!bAvailable)       cnvs.SetDrawColor(0, 0, 0);
    else if(bSelected)       cnvs.SetDrawColor(255, 255, 255);
    else       cnvs.SetDrawColor(128, 128, 128);
    cnvs.DrawText(associatedSkill.default.skillName);
    cnvs.TextSize(associatedSkill.default.skillName, textWidth, nameHeight);
    // - Description
    cnvs.Font = class'ROHUD'.Static.LoadSmallFontStatic(5);
    if(!bAvailable)       cnvs.SetDrawColor(0, 0, 0);
    else if(bSelected)       cnvs.SetDrawColor(220, 220, 220);//180
    else       cnvs.SetDrawColor(140, 140, 140);//100
    skillEffects = associatedSkill.default.skillEffects;
    while(Len(skillEffects) > 0){       cnvs.WrapText(skillEffects, line, ActualWidth() - horizontalOffset * 2, cnvs.Font, cnvs.FontScaleX);       cnvs.SetPos(ActualLeft() + horizontalOffset, ActualTop() + verticalOffset + nameHeight + smVerticalOffset + descLineOffset);       cnvs.DrawText(line);       cnvs.TextSize(line, textWidth, textHeight);       descLineOffset += textHeight;
    }
    // Draw border
    if(bAvailable && bSelected || bPending){       if(bAvailable && bSelected)           cnvs.SetDrawColor(255, 255, 255);       else           cnvs.SetDrawColor(64, 64, 64);       cnvs.SetPos(ActualLeft(), ActualTop());       cnvs.DrawLine(3, ActualWidth());       cnvs.DrawLine(1, ActualHeight());       cnvs.SetPos(ActualLeft() + ActualWidth() + 2, ActualTop() + ActualHeight());       cnvs.DrawLine(2, ActualWidth() + 2);       cnvs.SetPos(ActualLeft() + ActualWidth(), ActualTop() + ActualHeight() + 2);       cnvs.DrawLine(0, ActualHeight() + 2);
    }
    cnvs.Font = oldFont;
    cnvs.FontScaleX = oldFontScaleX;
    cnvs.FontScaleY = oldFontScaleY;
    return true;
}
defaultproperties
{
}