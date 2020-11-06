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
editor:SetFont("Interface\\AddOns\\ClassHelper\\Assets\\monaco.ttf",9)
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
    button:SetScript("OnClick",function(self)editor:SetText(syntax)desc:SetText(description)self:Disable()if lastButton then lastButton:Enable()end lastButton=self end)
end
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
newCmd("ClassHelper:PlayWarningSound",[[ClassHelper:PlayWarningSound("sound name")]],[[Plays a sound. Available sounds are:
airhorn
warning
important
reminder
countdown:X (X must be 10 or less, and has a small delay if greater than 5)
any in-game sound (using PlaySound)
any sound file (using PlaySoundFile)
To play a voice coundown, instead use ClassHelper:VoiceCountdown(X) where X is your countdown.]],200)
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
newCmd("ClassHelper:ColorPartyRaidFrame",[[ClassHelper:ColorPartyRaidFrame(unitName,hasAura)]],[[Colors the raid frame in the modded raid frames.
* hasAura is either true or false. The color will update automatically.
   ** Filled in when above threshold HIGH.
   ** Filled in red when below threshold LOW, or below HIGH without an aura.
   ** Filled in black when above theshold LOW, and has an aura, but below threshold HIGH.
* unitName can be returned from destName in COMBAT_LOG_EVENT_UNFILTERED.
* If you aren't in a raid, the party frames will be directly colored green or red, reguardless of health.
]],210,"Raidframes")
newCmd("ClassHelper:LightUpSpell",[[ClassHelper:LightUpSpell("spellName"or spellId)]],"Lights up the spell on the action bar. Affects all instances of the spell.\n\124cffff0000ElvUI, and other AddOns that alter your action bars are NOT supported!",175,"Action buttons")
newCmd("ClassHelper:UnLightUpSpell",[[ClassHelper:UnLightUpSpell("spellName"or spellId)]],"Disables lighting on the spell on the action bar. Affects all instances of the spell.\n\124cffff0000ElvUI, and other AddOns that alter your action bars are NOT supported!",200)
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
ClassHelper.vars["onloadscript"]=function()C_Timer.NewTicker(0.05,function()
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
end)end
ClassHelper.vars["onloadscript"]()
-- unload
ClassHelper.vars["loaded"]=false
UNLOAD()
-- reinit
ClassHelper.vars["loaded"]=true
ClassHelper.vars["onloadscript"]()]],[[This feature allows you to create frames on enemy/friendly nameplates. Due to the accuracy of this feature, a GUID must be passed and stored somewhere. You should use |cffff6600ClassHelper.vars|r to store these guids.


|cffff6600The code below shows the proper use of the nameplates feature.

|rYou will need data in all four sections of the mod to use the nameplates feature! Watch for comments that say '-- init' and put the code below in init instead of data!]],230,"Nameplates")
local detectFontFrame=CreateFrame("FRAME")
detectFontFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
detectFontFrame:SetScript("OnEvent",function()
    editor:SetFont("Interface\\AddOns\\ClassHelper\\Assets\\monaco.ttf",tonumber(ClassHelper:Load("ModEditor","TextSize")))
end)