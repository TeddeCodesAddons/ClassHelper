local panel=ClassHelper:NewUIPanel("Settings")
StaticPopupDialogs["CH_CONFIRM_RELOAD_UI"]={
    text="This action requires a reload. Reload now?",
    button1="Yes",
    button2="No",
    OnAccept=function()ReloadUI()end,
    timeout=0,
    whileDead=true,
    hideOnEscape=true,
    preferredIndex=3
}
local function createSetting(name,toggleText,toggleReturns,appName,settingName,x,y,point,width,description,script)
    if not width then
        width=100
    end
    if not point then
        point="CENTER"
    end
    local button=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
    local default=ClassHelper:Load(appName,settingName)
    local idx=tIndexOf(toggleReturns,default)
    button:SetText(toggleText[idx])
    button:SetWidth(width)
    local toggleId=idx
    local function toggleButton()
        toggleId=toggleId+1
        if toggleId>getn(toggleText)then
            toggleId=1
        end
        button:SetText(toggleText[toggleId])
        ClassHelper:Save(appName,settingName,toggleReturns[toggleId])
        if script then
            script()
        end
    end
    button:SetScript("OnClick",toggleButton)
    local text=panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
    text:SetText(name)
    text:SetPoint(point,x,y)
    button:SetPoint("LEFT",text,"RIGHT",10,0)
    if description then
        local t2=panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
        t2:SetText("\124cffffffff"..description)
        t2:SetPoint("TOPLEFT",text,"BOTTOMLEFT",10,-10)
    end
end
local f=CreateFrame("FRAME")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
local entered_world=false
local function handle(self,event,...)
    if not entered_world then
        ClassHelper:DefaultSavedVariable("AlertSystem","ShowChat","true")
        ClassHelper:DefaultSavedVariable("ModEditor","SyntaxTypingDelay","short")
        ClassHelper:DefaultSavedVariable("ModEditor","SyntaxEnabled","true")
        ClassHelper:DefaultSavedVariable("ModEditor","TextSize","9")
        ClassHelper:DefaultSavedVariable("ModEditor","SyncAcrossAllFrames","true")
        if ClassHelper:Load("AlertSystem","ShowChat")=="false"then
            AlertSystem.showChat=false
        else
            AlertSystem.showChat=true
        end
        createSetting("AlertSystem show in chat",{"\124cff00ff00Enabled","\124cffff0000Disabled"},{"true","false"},"AlertSystem","ShowChat",20,-20,"TOPLEFT",100,"Toggles AlertSystem messages appearing in your chat window.\n(Only you can see these)",function()AlertSystem.showChat=not AlertSystem.showChat end)
        createSetting("Raidframes",{"\124cff00ff00Enabled","\124cffff0000Disabled"},{"true","false"},"Raidframes","Enabled",20,-100,"TOPLEFT",100,"Toggles on and off modded healer raid frames.\n(Type '/ch help raidframes' for more info)")
        createSetting("Mod editor show syntax",{"\124cff00ff00Enabled","\124cffff0000Disabled"},{"true","false"},"ModEditor","SyntaxEnabled",20,-180,"TOPLEFT",100,"Toggles syntax check in mod editor.\nKeywords will appear in different colors when enabled.\nEnabling this feature may greatly impact mod editor performance.",function()StaticPopup_Show("CH_CONFIRM_RELOAD_UI")end)
        createSetting("Mod editor typing delay",{"0.5 sec","\124cffff66001 sec"},{"short","long"},"ModEditor","SyntaxTypingDelay",20,-260,"TOPLEFT",100,"Makes the typing delay longer when typing in the mod editor EditBox.\n(Syntax check tends to lag)",function()StaticPopup_Show("CH_CONFIRM_RELOAD_UI")end)
        createSetting("Mod editor font size",{"\124cff00ff009","\124cff55ff0010","\124cffaaff0011","\124cffffff0012","\124cffffaa0013","\124cffff550014","\124cffff000015"},{"9","10","11","12","13","14","15"},"ModEditor","TextSize",20,-340,"TOPLEFT",100,"Makes the font bigger or smaller in the editor.\nDefault and lowest setting is 9.",function()StaticPopup_Show("CH_CONFIRM_RELOAD_UI")end)
        createSetting("Sync mod editor font with other frames",{"\124cff00ff00Enabled","\124cffff0000Disabled"},{"true","false"},"ModEditor","SyncAcrossAllFrames",20,-420,"TOPLEFT",100,"Syncs the font size in the editor with the mod search and conditions boxes.\nThis feature only applies to text boxes.",function()StaticPopup_Show("CH_CONFIRM_RELOAD_UI")end)
        entered_world=true
    end
end
f:SetScript("OnEvent",handle)