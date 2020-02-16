class NiceInteraction extends Interaction
    dependson(NicePack)
    dependson(NiceAbilityManager);
#exec OBJ LOAD FILE=KillingFloor2HUD.utx
var NicePack NicePackMutator;
var Material bleedIcon, poisonIcon;
var Texture greenBar, redBar;
var Texture shield;
var float size;
// Weapon box sizes
var float   InventoryBoxWidth;
var float   InventoryBoxHeight;
var float   BorderSize;
event NotifyLevelChange(){
    Master.RemoveInteraction(self);
}
function RegisterMutator(NicePack activePack){
    NicePackMutator = activePack;
}
function bool isPoisoned(ScrnHumanPawn pwn){
    local Inventory I;
    if(pwn.Inventory != none)       for(I = pwn.Inventory; I != none; I = I.Inventory)           if(I != none && MeanPoisonInventory(I) != none)               return true;
    return false;
}
function PostRender(Canvas C){
    local int i;
    local NicePack niceMutator;
    local NiceHumanPawn nicePawn;
    local class<NiceVeterancyTypes> niceVet;
    local MeanReplicationInfo szRI;
    local NiceWeapon niceWeap;
    local NicePlayerController nicePlayer;
    local ScrnHUD scrnHUDInstance;
    local Texture barTexture;
    local int x, y, center, barWidth, offset;
    local int missesWidth, missesHeight, missesSpace;
    local int missesX, missesY;
    if(C == none) return;
    if(C.ViewPort == none) return;
    if(C.ViewPort.Actor == none) return;
    if(C.ViewPort.Actor.Pawn == none) return;
    nicePlayer = NicePlayerController(C.ViewPort.Actor.Pawn.Controller);
    niceWeap = NiceWeapon(C.ViewPort.Actor.Pawn.Weapon);
    if(nicePlayer == none)       return;
    scrnHUDInstance = ScrnHUD(nicePlayer.myHUD);
    //// Draw bleed and poison icons
    C.SetDrawColor(255, 255, 255);
    szRI = class'MeanReplicationInfo'.static.findSZri(ViewportOwner.Actor.PlayerReplicationInfo);
    offset = 4;
    if(szRI != none){       if(szRI.isBleeding){           x = C.ClipX * 0.007;           y = C.ClipY * 0.93 - size * offset;           C.SetPos(x, y);           C.DrawTile(bleedIcon, size, size, 0, 0, bleedIcon.MaterialUSize(), bleedIcon.MaterialVSize());       }       offset++;       if(isPoisoned(ScrnHumanPawn(C.ViewPort.Actor.Pawn))){               x = C.ClipX * 0.007;               y = C.ClipY * 0.93 - size * offset;               C.SetPos(x, y);               C.DrawTile(poisonIcon, size, size, 0, 0, poisonIcon.MaterialUSize(), poisonIcon.MaterialVSize());       }
    }
    if(niceWeap != none && niceWeap.bShowSecondaryCharge && scrnHUDInstance != none){       C.ColorModulate.X = 1;       C.ColorModulate.Y = 1;       C.ColorModulate.Z = 1;       C.ColorModulate.W = scrnHUDInstance.HudOpacity / 255;       if(!scrnHUDInstance.bLightHud)           scrnHUDInstance.DrawSpriteWidget(C, scrnHUDInstance.SecondaryClipsBG);       scrnHUDInstance.DrawSpriteWidget(C, scrnHUDInstance.SecondaryClipsIcon);       scrnHUDInstance.SecondaryClipsDigits.value = niceWeap.secondaryCharge;       scrnHUDInstance.DrawNumericWidget(C, scrnHUDInstance.SecondaryClipsDigits, scrnHUDInstance.DigitsSmall);
    }
    niceMutator = class'NicePack'.static.Myself(C.ViewPort.Actor.Pawn.Level);
    if(niceMutator == none)           return;
    //// Draw counters
    if(nicePlayer != none && nicePlayer.bFlagDisplayCounters){       x = C.ClipX * 0.5 - (64 + 2) * niceMutator.GetVisibleCountersAmount();       y = C.ClipY * 0.01;       for(i = 0;i < niceMutator.niceCounterSet.Length;i ++)           if(niceMutator.niceCounterSet[i].value != 0 || niceMutator.niceCounterSet[i].bShowZeroValue){               DrawCounter(C, niceMutator.niceCounterSet[i], x, y, C.ViewPort.Actor.Pawn.PlayerReplicationInfo.Team);               x += 128 + 4;           }
    }
    //// Draw weapons progress bars
    if(nicePlayer != none && nicePlayer.bFlagDisplayWeaponProgress){       x = C.ClipX - InventoryBoxWidth * C.ClipX - 5;       y = C.ClipY * 0.5 - 0.5 * (InventoryBoxHeight * C.ClipX + 4) * niceMutator.niceWeapProgressSet.Length;       for(i = 0;i < niceMutator.niceWeapProgressSet.Length;i ++){           DrawWeaponProgress(C, niceMutator.niceWeapProgressSet[i], x, y,               C.ViewPort.Actor.Pawn.PlayerReplicationInfo.Team);           y += (InventoryBoxHeight * C.ClipX + 4);       }
    }
    //// Draw invincibility bar
    nicePawn = NiceHumanPawn(nicePlayer.pawn);
    if(nicePawn != none && nicePawn.invincibilityTimer != 0.0){       C.SetDrawColor(255, 255, 255);       if(nicePawn.invincibilityTimer > 0)           barTexture = greenBar;       else           barTexture = redBar;       center = C.ClipX * 0.5;       y = C.ClipY * 0.75;       barWidth = C.ClipX * 0.2;       niceVet = class'NiceVeterancyTypes'.static.           GetVeterancy(nicePawn.PlayerReplicationInfo);       if(niceVet != none){           if(nicePawn.invincibilityTimer > 0){               barWidth *= nicePawn.invincibilityTimer                   / niceVet.static.GetInvincibilityDuration(nicePawn.KFPRI);           }           else{               barWidth *= nicePawn.invincibilityTimer /                   class'NiceSkillZerkGunzerker'.default.cooldown;           }       }       else           barWidth = 0;       x = center - (barWidth / 2);       C.SetPos(x, y);       C.DrawTile(barTexture, barWidth, 32, 0, 0, barTexture.MaterialUSize(), barTexture.MaterialVSize());       if(nicePawn.safeMeleeMisses <= 0)           return;       missesSpace = 10;//64x64 => 16x16       missesHeight = 16;       missesWidth =   nicePawn.safeMeleeMisses * 16                   +   (nicePawn.safeMeleeMisses - 1) * missesSpace;       missesX = center - (missesWidth / 2);       missesY = y + (32 - missesHeight) * 0.5;       for(i = 0;i < nicePawn.safeMeleeMisses;i ++){           C.SetPos(missesX + i * (16 + missesSpace), missesY);           C.DrawTile(shield, 16, 16, 0, 0, shield.MaterialUSize(), shield.MaterialVSize());       }
    }
    //  Draw cooldowns
    if(nicePlayer.abilityManager == none)       return;
    for(i = 0;i < nicePlayer.abilityManager.currentAbilitiesAmount;i ++)       DrawAbilityCooldown(C, i);
}
function DrawCounter(Canvas C, NicePack.CounterDisplay counter, int x, int y, TeamInfo team){
    local float borderSpace;
    local Texture textureToDraw;
    local float textWidth, textHeight; 
    local string textToDraw;
    // Some per-defined values for drawing
    local int iconSize, backgroundWidth, backgroundHeight;
    // Fill some constants that will dictate how to display counter
    iconSize = 64;
    backgroundWidth = 128;
    backgroundHeight = 64;
    borderSpace = 8;
    // Reset color
    if(team.teamIndex == 0)       C.SetDrawColor(255, 64, 64);
    else       C.SetDrawColor(team.teamColor.R, team.teamColor.G, team.teamColor.B);
    // Draw background
    C.SetPos(x, y);
    textureToDraw = Texture(class'HUDKillingFloor'.default.HealthBG.WidgetTexture);
    C.DrawTile(textureToDraw, 128, 64, 0, 0, textureToDraw.MaterialUSize(), textureToDraw.MaterialVSize());
    // Draw appropriate icon
    C.SetPos(x + borderSpace, y + borderSpace);
    textureToDraw = counter.icon;
    C.DrawTile(textureToDraw, 64 - 2*borderSpace, 64 - 2 * borderSpace, 0, 0,       textureToDraw.MaterialUSize(), textureToDraw.MaterialVSize());
    // Draw numbers
    textToDraw = string(counter.value);
    C.Font = class'ROHUD'.Static.LoadSmallFontStatic(1);
    C.TextSize(textToDraw, textWidth, textHeight);
    C.SetPos(x + iconSize + (backgroundWidth - iconSize - textWidth) / 2, y + (backgroundHeight - textHeight) / 2 + 2);
    C.DrawText(textToDraw);
}
function DrawAbilityCooldown(Canvas C, int abilityIndex){
    local Texture skillTexture, backgroundTexture;
    local NiceHumanPawn nicePawn;
    local NicePlayerController nicePlayer;
    local class<NiceVeterancyTypes> niceVet;
    local int x, y;
    local string textToDraw;
    local float textWidth, textHeight; 
    local NiceAbilityManager.EAbilityState abilityState;
    if(C == none) return;
    if(C.ViewPort == none) return;
    if(C.ViewPort.Actor == none) return;
    nicePawn = NiceHumanPawn(C.ViewPort.Actor.Pawn);
    nicePlayer = NicePlayerController(C.ViewPort.Actor.Pawn.Controller);
    if(nicePawn == none)       return;
    if(nicePlayer == none || nicePlayer.abilityManager == none)       return;
    niceVet = class'NiceVeterancyTypes'.static.GetVeterancy(nicePawn.KFPRI);
    skillTexture =       nicePlayer.abilityManager.currentAbilities[abilityIndex].       description.icon;
    if(skillTexture == none)       return;
    // Set stuff up
    x = C.ClipX * 0.265;
    x += abilityIndex * (10 + 64);
    y = C.ClipY * 0.93;
    textToDraw = string(int(Ceil(nicePlayer.abilityManager.currentAbilities[abilityIndex].cooldown)));
    backgroundTexture = Texture'KillingFloorHUD.HUD.Hud_Box_128x64';
    // Reset color
    C.SetDrawColor(255, 64, 64);
    // Draw background
    C.SetPos(x, y);
    C.DrawTile(backgroundTexture, 64, 64, 0, 0, backgroundTexture.MaterialUSize(), backgroundTexture.MaterialVSize());
    C.SetPos(x, y);
    C.DrawTile(skillTexture, 64, 64, 0, 0, skillTexture.MaterialUSize(), skillTexture.MaterialVSize());
    //  Draw additional background
    abilityState =       nicePlayer.abilityManager.currentAbilities[abilityIndex].myState;
    if(abilityState == ASTATE_ACTIVE)       C.SetDrawColor(255, 0, 0, 128);
    if(abilityState == ASTATE_COOLDOWN)       C.SetDrawColor(0, 0, 0, 192);
    if(abilityState != ASTATE_READY){       C.SetPos(x, y);       C.DrawTileStretched(Material'KillingFloorHUD.HUD.WhiteTexture', 64, 64);
    }
    //  Draw cooldown stuff
    if(abilityState == ASTATE_COOLDOWN){       C.SetDrawColor(255, 192, 192);       C.Font = class'ROHUD'.static.LoadSmallFontStatic(1);       C.TextSize(textToDraw, textWidth, textHeight);       C.SetPos(x, y);       C.SetPos(x + (64 - textWidth) / 2, y + (64 - textHeight) / 2 + 2);       C.DrawText(textToDraw);
    }
    //  Draw calibration GUI
    DrawCalibrationStars(C);
}
function DrawCalibrationStars(Canvas C){
    local Texture starTexture;
    local int x, y, i;
    local int starsAmount;
    local NiceHumanPawn nicePawn;
    local NicePlayerController nicePlayer;
    if(C == none) return;
    if(C.ViewPort == none) return;
    if(C.ViewPort.Actor == none) return;
    nicePawn = NiceHumanPawn(C.ViewPort.Actor.Pawn);
    if(nicePawn == none)       return;
    if(nicePawn.currentCalibrationState == CALSTATE_NOABILITY)       return;
    nicePlayer = NicePlayerController(nicePawn.controller);
    if(nicePlayer == none)       return;
    starsAmount = nicePawn.calibrationScore;
    x = C.ClipX * 0.5;
    x -= 0.5 * (starsAmount * 32 + (starsAmount - 1) * 16);
    if(nicePawn.currentCalibrationState == CALSTATE_ACTIVE)       y = C.ClipY * 0.6;
    else       y = C.ClipY * 0.02;
    starTexture = Texture'KillingFloorHUD.HUD.Hud_Perk_Star';
    for(i = 0;i < starsAmount;i ++){       C.SetPos(x, y);       C.SetDrawColor(255, 255, 255);       C.DrawTile(starTexture, 32, 32, 0, 0, starTexture.MaterialUSize(), starTexture.MaterialVSize());       x += 32 + 16;
    }
}
function DrawWeaponProgress(Canvas C, NicePack.WeaponProgressDisplay weapProgress, int x, int y, TeamInfo team){
    local float textWidth, textHeight; 
    local string textToDraw;
    local float TempWidth, TempHeight, TempBorder;
    TempWidth   = InventoryBoxWidth * C.ClipX;
    TempHeight  = InventoryBoxHeight * C.ClipX;
    TempBorder  = BorderSize * C.ClipX;
    // Draw background bar
    if(team.teamIndex == 0)       C.SetDrawColor(255, 64, 64, 64);
    else       C.SetDrawColor(team.teamColor.R, team.teamColor.G, team.teamColor.B, 64);
    C.SetPos(x, y);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', TempWidth * weapProgress.progress, TempHeight, 0, 0, 2, 2);
    // Draw this item's Background
    if(team.teamIndex == 0)       C.SetDrawColor(255, 64, 64);
    else       C.SetDrawColor(team.teamColor.R, team.teamColor.G, team.teamColor.B);
    C.SetPos(x, y);
    C.DrawTileStretched(Texture'KillingFloorHUD.HUD.HUD_Rectangel_W_Stroke', TempWidth, TempHeight);
    // Draw the Weapon's Icon over the Background
    C.SetDrawColor(255, 255, 255);
    C.SetPos(x + TempBorder, y + TempBorder);
    if(weapProgress.weapClass.default.HudImage != none)       C.DrawTile(weapProgress.weapClass.default.HudImage,           TempWidth - (2.0 * TempBorder), TempHeight - (2.0 * TempBorder), 0, 0, 256, 192);
    // Draw counter, if needed
    if(team.teamIndex == 0)       C.SetDrawColor(255, 64, 64);
    else       C.SetDrawColor(team.teamColor.R, team.teamColor.G, team.teamColor.B);
    if(weapProgress.bShowCounter){       textToDraw = string(weapProgress.counter);       C.Font = class'ROHUD'.Static.LoadSmallFontStatic(5);       C.TextSize(textToDraw, textWidth, textHeight);       C.SetPos(x + TempWidth - TempBorder - textWidth, y + TempHeight - TempBorder - textHeight + 2);       C.DrawText(textToDraw);
    }
}
function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta){
    local bool bNeedsReload;
    local string Alias, LeftPart, RigthPart;
    local NiceWeapon niceWeap;
    local NicePlayerController nicePlayer;
    // Find controller and current weapon
    nicePlayer = NicePlayerController(ViewportOwner.Actor);
    if(nicePlayer == none)       return false;
    if(nicePlayer.Pawn != none)       niceWeap = NiceWeapon(nicePlayer.Pawn.Weapon);
    // If this is a button press - detect alias
    if(Action == IST_Press){       // Check for reload command       Alias = nicePlayer.ConsoleCommand("KEYBINDING" @ nicePlayer.ConsoleCommand("KEYNAME" @ Key));       if(nicePlayer.bAdvReloadCheck)           bNeedsReload = InStr(Caps(Alias), "RELOADMENOW") > -1 || InStr(Caps(Alias), "RELOADWEAPON") > -1;       if(Divide(Alias, " ", LeftPart, RigthPart))           Alias = LeftPart;       if(Key == IK_MouseWheelUp || Key == IK_MouseWheelDown){           nicePlayer.UpdateSelectors();           if(nicePlayer.hasZeroSelector && nicePlayer.bUsesMouseWheel && nicePlayer.bNiceWeaponManagement){               nicePlayer.ScrollSelector(0, nicePlayer.bMouseWheelLoops, Key == IK_MouseWheelUp);               return true;           }       }
    }
    // Open trader on movement
    if(Alias ~= "MoveForward" || Alias ~= "MoveBackward" || Alias ~= "TurnLeft" || Alias ~= "TurnRight"       || Alias ~= "StrafeLeft" || Alias ~= "StrafeRight" || Alias ~= "Axis"){
       // Open trader if it's a pre-game       if(NicePackMutator.bIsPreGame && NicePackMutator.bInitialTrader && (NicePackMutator.bStillDuringInitTrader || !nicePlayer.bOpenedInitTrader) && nicePlayer.Pawn != none){           nicePlayer.ShowBuyMenu("Initial trader", KFHumanPawn(nicePlayer.Pawn).MaxCarryWeight);           nicePlayer.bOpenedInitTrader = true;           return true;       }       //nicePlayer.ClientOpenMenu("NicePack.NiceGUIBuyMenu",,"Test stuff",string(15));
    }
    // Reload if we've detected a reload alias in this button's command
    if(niceWeap != none && !nicePlayer.bUseServerReload &&       (bNeedsReload || Alias ~= "ReloadMeNow" || Alias ~= "ReloadWeapon"))       niceWeap.ClientReloadMeNow();
    return false;
}
defaultproperties
{    bleedIcon=Texture'NicePackT.MeanZeds.bleedIcon'    poisonIcon=Texture'NicePackT.MeanZeds.poisonIcon'    greenBar=Texture'KFStoryGame_Tex.HUD.Batter_Fill'    redBar=Texture'KFStoryGame_Tex.HUD.BarFill_Red'    Shield=Texture'KillingFloorHUD.HUD.Hud_Shield'    Size=75.599998    InventoryBoxWidth=0.100000    InventoryBoxHeight=0.075000    BorderSize=0.005000    bVisible=True
}
