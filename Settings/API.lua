local f=CreateFrame("FRAME")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
local function handle(self,event,...)
    if event=="COMBAT_LOG_EVENT_UNFILTERED"then
        ClassHelper:DebugCombatEvent()
    else
        ClassHelper:Error("Spell debugger","Registered event","Unknown event",event)
    end
end
f:SetScript("OnEvent",handle)
function ClassHelper:DebugCombatEvent()
    local timestamp,subevent,_,_,sourceName,_,_,guid,destName=CombatLogGetCurrentEventInfo()
    local spellId,spellName,spellSchool,amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing,isOffHand=select(12,CombatLogGetCurrentEventInfo())
    if self.debug_next_spell and sourceName==UnitName("player")then
        self:Print(subevent.." | The spell ID for "..spellName.." is: "..spellId)
    end
end
function ClassHelper:DebugNextSpell()
    if self.debug_next_spell then
        self:Print("Please wait to use this command!")
        return
    end
    self.debug_next_spell=true
    self:Print("Spell debugging: \124cff00ff00ON")
    C_Timer.NewTimer(3,function()ClassHelper.debug_next_spell=false;ClassHelper:Print("Spell debugging: \124cffff0000OFF")end)
end
ClassHelper:CreateSlashCommand("debug","ClassHelper:DebugNextSpell()","Gets the spell ID of all the spells, auras, and anything else you use in the next 3 seconds.")
local panel=ClassHelper:NewUIPanel("API")
local scroll=CreateFrame("ScrollFrame",nil,panel,"UIPanelScrollFrameTemplate")
scroll:SetSize(775,670)
scroll:SetPoint("RIGHT",-25,0)
local panel2=CreateFrame("FRAME",nil,panel)
panel2:SetSize(775,670)
panel2:SetPoint("RIGHT",panel,"RIGHT",0,0)
scroll:SetScrollChild(panel2)
local scroll2=CreateFrame("ScrollFrame",nil,panel,"UIPanelScrollFrameTemplate")
scroll2:SetSize(450,450)
scroll2:SetPoint("BOTTOMRIGHT",-50,20)
scroll2:SetFrameLevel(500)
local editor=CreateFrame("EditBox",nil,scroll2)
editor:SetSize(450,450)
editor:SetMultiLine(true)
editor:SetAutoFocus(false)
editor:SetPoint("TOPLEFT")
editor:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",9)
editor:SetText([[-- Select a command to view it's syntax.]])
editor:SetCursorPosition(0)
editor:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
editor:SetScript("OnTabPressed",function(self)self:Insert("    ")end)
local editorTexture=panel:CreateTexture(nil,"ARTWORK")
editorTexture:SetColorTexture(0.05,0.05,0.05,0.8)
editorTexture:SetSize(460,460)
editorTexture:SetPoint("BOTTOMRIGHT",-50,20)
scroll2:SetScrollChild(editor)
local desc=panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
desc:SetText("Select a command to view it's description.")
desc:SetPoint("TOPLEFT",280,-15)
desc:SetJustifyH("LEFT")
desc:SetWidth(500)
local lastPos=0
local lastButton
local function newCmd(commandName,syntax,description,width,header)
    local button=CreateFrame("Button",nil,panel2,"UIPanelButtonTemplate")
    button:SetText(commandName)
    if width then
        button:SetWidth(width)
    else
        button:SetWidth(100)
    end
    lastPos=lastPos-30
    if header then
        local head=panel2:CreateFontString(nil,"ARTWORK","GameFontNormal")
        head:SetText(header)
        head:SetPoint("TOPLEFT",20,lastPos)
        lastPos=lastPos-30
        button:SetPoint("TOPLEFT",40,lastPos)
    else
        button:SetPoint("TOPLEFT",40,lastPos)
    end
    button:SetScript("OnClick",function(self)editor:SetText("-- @syntax: off\n"..syntax)desc:SetText(description)self:Disable()if lastButton then lastButton:Enable()end lastButton=self end)
end
newCmd("ClassHelper:GetSpellInfo",[=[local itemInfo=ClassHelper:GetSpellInfo("spellName"or spellId or"itemName"or itemId)
--[[
itemInfo={
    actionButtons={}, -- <Pointers to the action buttons this spell appears on>,
    name="<spell name>",
    isSpell=true or false,
    isItem=true or false,
    learned=true or false, -- This will also return true for items if you have them in your bag.
    isLearnedByPet=true or false, -- This checks if the spell is known by your pet(s).
    icon=spellIconID, -- Number for the ID of the spell's icon.
    cooldown={
        max=0, -- The spell's maximum cooldown
        remaining=0, -- The spell's remaining cooldown
        lastCastTime -- The timestamp when you last cast the spell. (Used in IconFrames)
    },
    info={
        -- Blizzard's GetSpellInfo() output or GetItemInfo() output.
    }
}
]]]=],[[This will return the ALL of the spell's useful information. Make sure to select the right attribute.
EX: You want to get the spell's cooldown to put it into an icon frame, use .cooldown.max/remaining/lastCastTime, however if you want to check if the spell is learned, use .learned,
this function makes everything a lot more efficient, instead of having to look for the correct blizzard function to get what you want.]],200,"\124cffff6600IMPORTANT!")
newCmd("ClassHelper:GetGUID",[[local guid=ClassHelper:GetGUID("nameplateX" or unitId)]],[[Will get the unit GUID of a certain nameplate, or unit.
Use ClassHelper:GetGUID("nameplateX") where X is the nameplate ID to get GUIDs from nameplates.]],200)
newCmd("ClassHelper:GetNPCID",[=[local npcTable=ClassHelper:GetNPCID("guid")
--[[
npcTable={
    type=<unit's type>, --"Creature" or "Player" (etc...)
    server_id="server", -- The server's ID.
    instance_id="instance", -- The instance's ID.
    zone_uid="zone", -- The zone's unit ID.
    npc_id=npc, -- The NPC's ID. (Can be used to track NPCs spawning)
    spawn_id="spawn" -- The spawn ID (kind-of useless, is different for each NPC of the same type)
}
]]
]=],[[Gets the NPC's info from it's GUID. Can also be done with: local type,_,server,instance,zone,npc,spawn=strsplit("-",guid)]],175)
newCmd("ClassHelper:GetNearbyEnemies",[=[local unitTable=ClassHelper:GetNearbyEnemies(range)
--[[
unitTable={
    amount=0, -- Integer, number of units on nameplates within the specified range.
    units={
        -- Unit GUIDs of selected units.
    }
}
]]]=],[[Will return a list of enemy units or aggroed neutral units within the specified range. Make sure to include .amount if you only want the number of units in range. Only detects units on displayed nameplates.]],200,"Unit detection")
newCmd("ClassHelper:GetNearbyFriends",[=[local unitTable=ClassHelper:GetNearbyEnemies(range)
--[[
unitTable={
    amount=0, -- Integer, number of units on nameplates within the specified range.
    units={
        -- Unit GUIDs of selected units.
    }
}
]]]=],[[Will return a list of friendly units within the specified range. Make sure to include .amount if you only want the number of units in range. Only detects units on displayed nameplates.]],200)
newCmd("ClassHelper:GetNearbyUnits",[=[local allUnits=ClassHelper:GetNearbyEnemies(range)
--[[
allUnits={
    OOR=<UNIT_TABLE>, -- Units that were out of range. (Not sorted, use another range query to find these units.)
    aggroNeutral=<UNIT_TABLE>, -- Neutral units that were in range and aggroed. UNIT_TABLE syntax is used.
    aggroHostile=<UNIT_TABLE>, -- Hostile units that were in range and aggroed.
    aggroFriendly=<UNIT_TABLE>, -- Friendly units can affect combat when you benefit them with healing or other effects.
    neutral=<UNIT_TABLE>, -- Neutral units that were in range and NOT aggroed.
    hostile=<UNIT_TABLE>, -- Hostile units that were in range and NOT aggroed.
    friendly=<UNIT_TABLE>, -- Friendly units that were in range and NOT "aggroed".
    units=<UNIT_TABLE> -- ALL units that were in range. (Friendly, hostile, and neutral)
}
UNIT_TABLE={
    amount=0, -- Integer, number of units on nameplates within the specified range.
    units={
        -- Unit GUIDs of selected units.
    }
}
]]]=],[[Returns a complex range check of all nearby units. Units can only be found if they have a nameplate.]],200)
newCmd("ClassHelper:NewBar",[[local bar=ClassHelper:NewBar(time,"text",spellCD)]],[[Creates a new timer bar.
This bar can be used to track a cooldown, if specified, but MUST be a spell ID.
(If you don't know, use '/ch debug' and cast the spell to get the ID.)
If you are tracking an aura, this does not need to be specified, but is important
if tracking a cooldown. (Reduction and haste reduce time)]],150,"Creating objects and warnings")
newCmd("<Bar functions>",[[-- Examples
bar:RegisterEvent(0,function()print("Bar expired!")end)
bar:SetColor(1,0,0.5,1)
bar:SetReserved(true)
local function countdownFunc()
    ClassHelper:VoiceCountdown(5)
end
bar:RegisterEvent(5,countdownFunc)
bar:Pause()
bar:SetConstantMaxTime(10) -- Force the bar to be 10 sec or less...
C_Timer.NewTimer(1,function()bar:Resume()end)]],[[bar:RegisterEvent(time,func) will cause the bar to run the function when the time hits the set time. (Useful for countdowns, and expirations)
bar:SetColor(r,g,b[,a]) will change the bar's color permanently to the selected color. It will no longer update to time remaining.
bar:Pause() and bar:Resume() will pause and resume the countdown on a bar. EX: You want the bar to freeze, it will stop until resumed.
bar:SetConstantMaxTime(max_time) will prevent the bar from going above the maximum time.
bar:RemoveConstantMaxTime() will remove this.]],150)
newCmd("bar:SetReserved",[[local bar=ClassHelper:NewBar(1,"Custom reserved bar"):SetReserved(true):Delete()
ClassHelper.vars["my reserved bar"]=bar
bar:SetReserved(true)]],[[If you want to always have the same bar available for using for one thing, you may want to make a reserved bar.
This is in case your bar expires, and is marked as free memory. Another mod could then use this bar, and mark it as used. When your mod tries to reference this bar again, it will override the old bar, and hide it permanently.
To fix this, use bar:SetReserved(true), and if you don't want to use it anymore, use bar:SetReserved(false)]],150)
newCmd("ClassHelper:PlayWarningSound",[[ClassHelper:PlayWarningSound("sound name",channel,countdownVoice)]],[[Plays a sound. Available sounds are:
airhorn
warning
important
reminder
countdown:X (X must be 10 or less, and has a small delay if greater than 5)
any in-game sound (using PlaySound)
any sound file (using PlaySoundFile)
To play a voice countdown, instead use ClassHelper:VoiceCountdown(X) where X is your countdown.
If you want to play a countdown number in a different voice, specify a voice under countdownVoice. (See ClassHelper:VoiceCountdown for more info)]],200)
newCmd("ClassHelper:PlayTTSWarning",[[ClassHelper:PlayTTSWarning("text",voice,volume)]],"Plays text-to-speech. Change voice and volume to what you want to play it on. Beware that if the voice doesn't exist, will default to voice 0. There is only voice 0 and voice 1 as of patch 9.1.",175)
newCmd("ClassHelper:VoiceCountdown",[[ClassHelper:VoiceCountdown(countdown,channel,voice)]],[[Creates a countdown using the specified voice in the sound channel.
If no channel is specified, default is 'master'.
If no voice is specified, default is 'Corsica'.
|cffff6600Current supported voices are: Corsica, Koltrane, Smooth.]],200)
newCmd("AlertSystem:ShowText",[[AlertSystem:ShowText("text",hideChat)]],[[Displays warning text. Colors are supported in this format:
\124cffff0000 - Red
\124cffff6600 - Orange (Default)
\124cffffff00 - Yellow
\124cff00ff00 - Green
If you look for HTML color picker online, you can find hexcodes for other colors.
EX: \124cff + whatever you find. ('ff' for the alpha channel)
By setting hideChat (optional argument) to true, you will hide the text showing in the chat. (Shown by "AlertSystem: Warning: <your warning>")
* If AlertSystem show in chat is turned off, nothing can print, so even if hideChat isn't specified, it will still be hidden.]],150)
newCmd("ClassHelper:NewWarningText",[[ClassHelper.vars["warningtext1"]=ClassHelper:NewWarningText("text"[,size,width,x,y,point,r,g,b,a])
warningTextObj=ClassHelper.vars["warningtext1"]
warningTextObj:SetText("text") -- Sets text
:SetSize(size)
:Shake() -- Shakes
:IsShaking() -- Returns whether the object is shaking or not
:IsFlashing() -- Returns whether the object is flashing or not
:Flash() -- Flashes white and selected color repeatedly
:Show() -- Shows the object
:Hide() -- Hides the object
:SetWidth(width) -- Sets the width of the text.
:SetPoint(point) -- See frame:SetPoint() in the WoW API.
:SetColor(red,green,blue[,alpha]) -- Sets the text color.]],[[Creates a warning text object. This object can be put anywhere on the screen and/or resized, unlike AlertSystem's text.
If you want to be able to show multiple warnings at once, or show a warning for s duration, use this feature instead.
Extra features - warningObj:Shake() - Shakes the warning. (EX: You could do this and change the color if a countdown is about to expire)
warningObj:Flash() - Flashes the warning.
warningObj:SetColor() - Changes the warning's color. (Using \124c[color] in the text will prevent color from changing)]],200)
newCmd("ClassHelper:NewIconFrame",[[local iconFrame=ClassHelper:NewIconFrame(parent)
iconFrame:Show()
iconFrame:Hide()
local isShown=iconFrame:IsShown()
iconFrame:SetStacks(stacks)
iconFrame:SetPoint("point",rel,"relPt",x,y)
iconFrame:SetAlpha(alpha) -- Useful if you want the icon half-faded
iconFrame:Glow(r,g,b,a) -- Edit the RBGA values to change the color of the glow.
iconFrame:UnGlow()
iconFrame:SetGlowColor(r,g,b,a) -- Sets the glow's color without unglowing and reglowing.
iconFrame:Shake() -- Toggles shaking, use again to disable.
iconFrame:IsShaking()
iconFrame:SetBorder(r,g,b,a) -- Changes the IconFrame's border color.
iconFrame:SetDuration(start,duration,r,g,b,a) -- You MUST specify a start time and a duration. RGBA override will prevent the timer from changing color when it is going to expire.
iconFrame:SetIcon(icon) -- Specify an icon ID. Can be found with ClassHelper:GetSpellInfo("spell").icon]],[[Creates an IconFrame with the specified methods.
You can glow this IconFrame and change it's timer, color, and stacks.]],200)
newCmd("ClassHelper:NewPowerBar",[[GLOBAL_BAR_OBJECT=ClassHelper:NewPowerBar("powerType")]],"Creates a new (mana) bar. This bar can be customized. It can display any power type. EX: \124cffff6600COMBOPOINTS\124r, \124cffff6600COMBO_POINTS\124r are both combo points, \124cffff6600SOUL_SHARDS\124r and \124cffff6600SOUL_SHARD_FRAGMENTS\124r is for soul shards and their fragments. You can create multiple bars. Just make sure to make them a global variable, or a global function that can access them, otherwise you can't hide them when the mod unloads.",200,"Power bars")
newCmd("ClassHelper:DoManaAlerts",[[ClassHelper:DoManaAlerts()]],[[Alerts if you have gone below 50%, 35%, or 15% mana.
Plays a sound and shows a message at the same time.]],200)
newCmd("<Power bar commands>",[[barObject:DisplayPercent()
barObject:DisplayNumber()
barObject:SetDisplayMode(mode)
barObject:SetSize(length,height)
barObject:SetPoint(point,x,y,relative)
barObject:SetColor(r,g,b,a)
barObject:Fade(priority,condition,amount,r,g,b,a)
barObject:ClearFade()
barObject:Show()
barObject:Hide()
barObject:ToggleDynamicDisplay(toggle) -- Not included in the basic API.
barObject:DynamicUpdate(additionalPower) -- Not included in the basic API.
barObject:SetDynamicColor()
barObject:Unlock()
barObject:Lock()
barObject:GetPosition()
barObject:Update() -- Automatic if bar isn't dynamic.
barObject:SetReserved(isReserved) -- See the FAQ on reserved timer bars.]],[[DisplayNumber(), DisplayPercent(), SetDisplayMode() - Changes the way the bar displays power, if it's PERCENT, and you have 400/500 mana, you will see 80%, if it's NUMBER, you will see 400.
SetSize(), SetColor(), Show(), Hide(), Unlock(), Lock(), GetPosition(), ClearFade() do exactly as they say.
**When using SetColor(), keep in mind colors cannot be 0-255 and MUST be 0-1, with decimals if needed.
**When using SetPoint(), the only syntax accepted is point,x,y,relative. Point can be CENTER, TOP, BOTTOM, etc... Default relative is UIParent.
Fade() allows the bar to change color, based on the amount of power you have. You must specify a priority, as higher numbers will be displayed instead of lower numbers. EX: If less than 50% but also greater than 10%, do the higher priority.
**When using fade, accepted conditions are (LESS/GREATER)THAN(PERCENT), and EQUALS(PERCENT) EX: "LESSTHAN",45 makes it change color when LESS than 45, "EQUALS",5 makes it change color when exactly 5.
**When using fade, color syntax is the same as SetColor()]],150)
newCmd("<CustomRaidFrames functions>",[=[-- CustomRaidFrames Glimmer Tracker (EXAMPLE)
local varsPointer=ClassHelper.vars
ClassHelper.vars["raidframesfunc"]=function(t)
    for i=1,getn(t)do
        local f=t[i]
        local b=f.auras.buffs
        local glimmer=false
        for x=1,getn(b)do
            if b[x][1]=="Glimmer of Light"then
                glimmer=true
            end
        end
        if glimmer then
            f:SetBackgroundColor(0.05,0.05,0.05,0.9)
        else
            f:SetBackgroundColor(0.9,0,0,0.9)
        end
    end
end
ClassHelper:SetCustomRaidFramesUpdateFunction(varsPointer["raidframesfunc"])
-- SAMPLE RAID FRAMES TABLE
--[[
{
    [1]={
        auras={
            buffs={
                {<buff name>,<buff ID>,<buff duration>,<buff expiration time>},
                -- and so on...
            },
            debuffs={
                {<debuff name>,<debuff ID>,<debuff duration>,<debuff expiration time>},
                -- and so on...
            }
        },
        dispellable=true or false,
        unit="player" or "partyX" or "raidX",
        health={
            current=<number>,
            max=<number>,
            absorb=<number>,
            healing_absorb=<number>
        },
        colors={
            health={r,g,b,a},
            background={r,g,b,a}
        }
    },
    [2]={
        auras={
            buffs={
                {<buff name>,<buff ID>,<buff duration>,<buff expiration time>},
                -- and so on...
            },
            debuffs={
                {<debuff name>,<debuff ID>,<debuff duration>,<debuff expiration time>},
                -- and so on...
            }
        },
        dispellable=true or false,
        unit="player" or "partyX" or "raidX",
        health={
            current=<number>,
            max=<number>,
            absorb=<number>,
            healing_absorb=<number>
        },
        colors={
            health={r,g,b,a},
            background={r,g,b,a}
        }
    },
    -- and so on...
}
]]
-- FUNCTIONS: 
-- :SetHealthColor(r,g,b,a)
-- :Glow()
-- :UnGlow()
-- :SetBackgroundColor(r,g,b,a)
-- :Flash(r,g,b,a) -- obj:Flash(nil) removes flashing
-- :IsGlowing() -- returns true or false
-- :IsFlashing() -- returns true or false]=],[[FUNCTION SYNTAX: ClassHelper:SetCustomRaidFramesUpdateFunction(func)
You pass a function as an argument. This function must be cleared on spec swaps. Make sure to define the function under ClassHelper.vars so you can put it in the reinit too. Read the help text and see how the |cffff6600sample table (below)|cffffff00 works for more info on this function.]],210,"CustomUnitFrames")
newCmd("ClassHelper:LightUpSpell",[[ClassHelper:LightUpSpell("spellName"or spellId)]],"Lights up the spell on the action bar. Affects all instances of the spell.\n\124cffff0000ElvUI, and other AddOns that alter your action bars are NOT supported!",175,"Action buttons")
newCmd("ClassHelper:UnLightUpSpell",[[ClassHelper:UnLightUpSpell("spellName"or spellId)]],"Disables lighting on the spell on the action bar. Affects all instances of the spell.\n\124cffff0000ElvUI, and other AddOns that alter your action bars are NOT supported!",200)
newCmd("ClassHelper:FlashSpell",[[ClassHelper:FlashSpell("spellName"or spellId)
-- Try me! '/run ClassHelper:FlashSpell("Regrowth")']],"Flashes a spell on your action bar. This is a new animation, much less visible and only happens once. Affects all instanced of the spell.\n\124cffff0000ElvUI, and other AddOns that alter your action bars are NOT supported!",175)
newCmd("<Mod loading conditions>",[[-- If using CUSTOM, use something like this to load your mod.
if not (CONDITION_TO_LOAD) then return end LOAD()
-- This will only load the mod if CONDITION_TO_LOAD is true.]],[[|cffff6600This information goes in the 'Conditions' box. (Above the editor box)|r
If any of these conditions are true, the mod will load.
'all' can be used to load the mod at all times, no matter what. (Can still be ended by Task Manager)

class:YOUR_CLASS
spec:YOUR_CLASS+YOUR_SPEC
specid:YOUR_CLASS+YOUR_SPEC_ID
zone:YOUR_CURRENT_ZONE
zoneid:YOUR_CURRENT_ZONE_ID
all

* 'custom' can be used to load the mod in a custom situation. You must run LOAD() to load the mod when using this.
* Otherwise, the mod will automatically load for you.
|cffff6600Example: |rspec:Warlock Destruction |cffff6600will load on Destruction Warlock spec.]],175,"Loading a mod")
newCmd("<Unloading a mod>",[[-- To unload your mods, use UNLOAD(), if the mod is still needed, don't run this.
UNLOAD()]],"This command confirms the unloading of the mod. A common error is to unload the mod anyway, but not run this command. The data will still run unless unloaded.",150)
newCmd("ClassHelper.vars",[[-- You could do this
ClassHelper.vars["power_text_frame"]=myFrame
-- Or you could...
ClassHelper.vars["last_timestamp"]=GetTime()
-- The possibilities are endless, you can use these as though they were local variables, and they won't interfere with other mods.
-- EX: if another mod had ClassHelper.vars["power_text_frame"]=myFrame2
-- This would not affect the first mod. (Stored in a separate table)]],[[The |cffff6600ClassHelper.vars|r feature allows the user to create local variables.
These are shared between m.data, m.init, m.unload, and m.reinit, but are not shared by other mods.
If you want two mods to use the same variable, define it under |cffff6600_G|r (The well-known global table)]],150,"Local variables")
newCmd("\124cffff6600<Mod settings>",[[-- Proper usage of settings (You can use them in these ways)
yardsText: " yds"
immuneWarning: "\124cffff0000IMMUNE NOW!"
framerate: 60
disableYardsTextWhenOutOfRange: true
frameParent: UIParent
-- Initialization code
warningText:SetText(ClassHelper.vars["immuneWarning"])
-- To retrieve any of these settings, use ClassHelper.vars["settingName"]
-- Make sure to put quotes around the setting name.]],[[Settings are put into ClassHelper.vars, but there's a slight twist to the syntax.
To separate an index from a value, use ':'. Indexes cannot contain ':' in them.
Indexes CAN contain spaces, and any other characters except for ':'.
When making text in a setting, make sure to surround it with quotes ("")
If you want to insert a quote in the text, use \", so it would look like this (Next line)
|cffff6600saying: "As they always say, \"You learn when you fail\"."|r
You can insert colors in the text too, by using "\124cffff0000Warning Text :)", which in this case turns the text color red.
To access these settings, use ClassHelper.vars["index"], and the value will be returned.]],150)
newCmd("ClassHelper:NewFrameOnNameplate",[[-- data
local timestamp,subevent,_,_,sourceName,_,_,guid,destName=CombatLogGetCurrentEventInfo()
local spellId,spellName,spellSchool,amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing,isOffHand=select(12,CombatLogGetCurrentEventInfo())
if sourceName==UnitName("player")then
    if subevent=="SPELL_AURA_APPLIED"then
        if spellName=="Reckoning"and destName~=UnitName("player")then
            ClassHelper.vars["guidreckonings"][guid]=GetTime()
            local a=ClassHelper:NewFrameOnNameplate(guid,"RETRIBUTION_PALADIN_PVP_RECKONING")
            if a then
                if a.f then
                    a.f:Show()
                else
                    local f=a:CreateFontString(nil,"OVERLAY")
                    f:SetFontObject(GameFontNormal)
                    f:SetText("Reckoning!")
                    f:SetPoint("CENTER",0,20)
                    f:SetTextColor(1,0.5,0,1)
                    a.f=f
                end
            end
            ClassHelper.vars["guidreckoninghides"][guid]=a.f
        end
    elseif subevent=="SPELL_AURA_REMOVED"then
        if spellName=="Reckoning"and destName~=UnitName("player")then
            ClassHelper.vars["guidreckonings"][guid]=nil
            ClassHelper.vars["guidreckoninghides"][guid]:Hide()
            local a=ClassHelper:NewFrameOnNameplate(guid,"RETRIBUTION_PALADIN_PVP_RECKONING")
            if a and a.f then
                a.f:Hide()
            end
        end
    elseif subevent=="SPELL_AURA_REFRESH"then
        if spellName=="Reckoning"and destName~=UnitName("player")then
            ClassHelper.vars["guidreckonings"][guid]=GetTime()
        end
    end
end
-- init
ClassHelper.vars["guidreckonings"]={
    
}
ClassHelper.vars["guidreckoninghides"]={
    
}
ClassHelper.vars["loaded"]=true
local varsPointer=ClassHelper.vars
C_Timer.NewTicker(0.05,function()
    if not varsPointer["loaded"]then return end
    for guid,v in pairs(varsPointer["guidreckonings"])do
        if v then
            if GetTime()-v>15 then
                varsPointer["guidreckonings"][guid]=nil
                varsPointer["guidreckoninghides"][guid]:Hide()
                varsPointer["guidreckoninghides"][guid]=nil
            end
            local a=ClassHelper:NewFrameOnNameplate(guid,"RETRIBUTION_PALADIN_PVP_RECKONING")
            if a then
                if a.f then
                    a.f:Show()
                else
                    local f=a:CreateFontString(nil,"OVERLAY")
                    f:SetFontObject(GameFontNormal)
                    f:SetText("Reckoning!")
                    f:SetPoint("CENTER",0,20)
                    f:SetTextColor(1,0.5,0,1)
                    a.f=f
                end
            end
        end
    end
end)
-- unload
ClassHelper.vars["loaded"]=false
UNLOAD()
-- reinit
ClassHelper.vars["loaded"]=true]],[[This feature allows you to create frames on enemy/friendly nameplates. Due to the accuracy of this feature, a GUID must be passed and stored somewhere. You should use |cffff6600ClassHelper.vars|r to store these guids.


|cffff6600The code below shows the proper use of the nameplates feature.

|rYou will need data in all four sections of the mod to use the nameplates feature! Watch for comments that say '-- init' and put the code below in init instead of data!]],230,"Nameplates")
newCmd("C_Timer.NewTimer",[[-- C_Timer.NewTimer(seconds,func)
C_Timer.NewTimer(1,function()print("1 second delay!")end)]],[[C_Timer is used for scheduling events in WoW.
To use this, simply type '|cffff6600/run C_Timer.NewTimer(1,function()print("1 second delay!")end)|r'.
This should print "|cffffffff1 second delay!|r" in chat, after 1 second. You can change this statement from here.
Changing 1 to 5 would make the delay 5 seconds instead of 1. The code you insert must be put inside |cffff6600function()|r<code here>|cffff6600end|r or it won't run. (It will run immediately, and input its return value into C_Timer.NewTimer)
This is a common mistake, so try to avoid it and don't type 'C_Timer.NewTimer(1,print("1 second delay"))', as this will not only generate a bug, but 99% of the time a LUA error will fire as well.]],170,"Basic utility")
newCmd("GetTime",[[local t=GetTime()]],[[GetTime() returns the current time in the local system.
|cffff0000COMMON ERRORS: This is NOT the same as 'timestamp' returned by COMBAT_LOG_EVENT_UNFILTERED.
|cffff6600Make sure to use GetTime() instead of timestamp in that situation, unless you are using timestamp as a reference.]],80)
newCmd("SendChatMessage",[[-- SendChatMessage("text","channel","language","recipient")
if IsInInstance()then
    SendChatMessage("My addon sent this!")
end]],[[This sends a message if you are in an instance saying |cffffffffMy addon sent this!|r
This can be very useful if you want to call out abilities, but sadly for spam reasons can only be used inside an instance unless you are sending through the PARTY channel, or the WHISPER channel.
The recipient is used in WHISPER to tell the addon who to send the message to. When using language, usually just set it to nil, unless you want to chat in a specific language.]],150)
newCmd("GetSpellCooldown",[[local _time,CD=GetSpellCooldown(spellId)]],[[This gets a spell's current cooldown. This command isn't really necessary since ClassHelper will automatically increase a bar's maximum time if the cooldown recovery rate gets reduced so the cooldown is above the number you typed in.
However, this only accepts spell IDs, and for identity confusion reasons. If you want to use spellName to filter it, simply use the predefined spellId variable from |cffff6600CombatLogGetCurrentEventInfo()|r.]],150)
newCmd("UnitName",[[local name,realm=UnitName("target")
name=name.."-"..realm
if name==sourceName then
    print("The source was your target!")
end]],[[UnitName returns the unit's name. Not much else to say. Accepted units and be found on the WoW API.
A basic list of some of them are:
"player" -- you
"target" -- your target
"focus" -- your focus
"party1" -- first party member, party2 would be the second, and so on...
"raid1" -- first raid member, raid2 would be the second, and so on...
"targettarget" -- the target of your target.
"focustarget" -- your focus's target.
"raid10target" -- the target of the 10th raid member.
"party2target" -- the target of the 2nd party member.
|cffff0000Remember that this won't return a name like "Name-Realm", it will return "Name","Realm" instead.  |rTo get the realm, use |cffff6600name.."-"..realm|r instead of |cffff6600name|r.
|cffffffffname=name.."-"..realm|r is often a good way to avoid this. (Shown in the code below)]],100)
local detectFontFrame=CreateFrame("FRAME")
detectFontFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
detectFontFrame:SetScript("OnEvent",function()
    if ClassHelper:Load("ModEditor","SyntaxEnabled")=="true"then
        ClassHelper:DefineSyntaxBox(editor,function(self,key)if key=="BACKSPACE"and strsub(self:GetText(),self:GetCursorPosition()-3,self:GetCursorPosition())=="    "then self:HighlightText(self:GetCursorPosition()-4,self:GetCursorPosition())end end)
    end
    editor:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",tonumber(ClassHelper:Load("ModEditor","TextSize")))
end)