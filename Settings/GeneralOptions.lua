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
    local toggleId=1
    if toggleReturns then
        local idx=tIndexOf(toggleReturns,default)
        button:SetText(toggleText[idx])
        toggleId=idx
    else
        local idx=tIndexOf(toggleText,default)
        button:SetText(default)
        if idx then
            toggleId=idx
        end
    end
    button:SetWidth(width)
    local function toggleButton()
        toggleId=toggleId+1
        if toggleId>getn(toggleText)then
            toggleId=1
        end
        button:SetText(toggleText[toggleId])
        if toggleReturns then
            ClassHelper:Save(appName,settingName,toggleReturns[toggleId])
        else
            ClassHelper:Save(appName,settingName,toggleText[toggleId])
        end
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
        ClassHelper:DefaultSavedVariable("Share","NotificationsEnabled","true")
        ClassHelper:DefaultSavedVariable("Share","MaxBytes",65536) -- 64 KB seems about right for most mods.
        ClassHelper:DefaultSavedVariable("CustomUnitFrames","Framerate","60")
        ClassHelper:DefaultSavedVariable("CustomUnitFrames","DebuffPoint","BOTTOMLEFT")
        ClassHelper:DefaultSavedVariable("CustomUnitFrames","BuffPoint","BOTTOMRIGHT")
        ClassHelper:DefaultSavedVariable("CustomUnitFrames","Showing","true")
        ClassHelper:DefaultSavedVariable("CustomUnitFrames","HideOldFrames","false")
        ClassHelper:DefaultSavedVariable("CustomUnitFrames","Attributes",{
            ["type1"]="target",
            ["shift-type1"]="target",
            ["alt-type1"]="target",
            ["ctrl-type1"]="target",
            ["ctrl-shift-type1"]="target",
            ["alt-shift-type1"]="target",
            ["alt-ctrl-type1"]="target",
            ["alt-ctrl-shift-type1"]="target",
            ["type2"]="togglemenu",
            ["shift-type2"]="target",
            ["alt-type2"]="target",
            ["ctrl-type2"]="target",
            ["ctrl-shift-type2"]="target",
            ["alt-shift-type2"]="target",
            ["alt-ctrl-type2"]="target",
            ["alt-ctrl-shift-type2"]="target"
        })
        ClassHelper:DefaultSavedVariable("CustomUnitFrames","Scale",1)
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
        createSetting("Sharing mods: Notifications enabled",{"\124cff00ff00Enabled","\124cffff0000Disabled"},{"true","false"},"Share","NotificationsEnabled",20,-500,"TOPLEFT",100,"Toggles notifications from recieving mods from other players.\nNote: Anyone on your realm can send you a mod. If you are getting spammed, you should most likely turn this off.")
        createSetting("Sharing mods: Maximum mod size",{"\124cff00ff0064 KB","\124cffffff00256 KB","\124cffff0000Unlimited","\124cffff0000Deny all"},{65536,262144,-1,0},"Share","MaxBytes",20,-580,"TOPLEFT",100,"Changes the maximum download size. (64 KB recommended).\nIf a mod is sent above this size, the request will be declined and the connection will be closed.\nThis is recommended to prevent players from filling up your memory.")
        createSetting("CustomRaidFrames",{"\124cff00ff00Enabled","\124cffff0000Disabled"},{"true","false"},"CustomUnitFrames","Showing",350,-370,"TOPLEFT",100,"Enables and disables ClassHelper CustomRaidFrames and CustomUnitFrames.",function()StaticPopup_Show("CH_CONFIRM_RELOAD_UI")end)
        createSetting("Hide old party and raid frames",{"\124cff00ff00Hide","\124cffff0000Show"},{"true","false"},"CustomUnitFrames","HideOldFrames",375,-410,"TOPLEFT",100,"",function()StaticPopup_Show("CH_CONFIRM_RELOAD_UI")end)
        createSetting("CustomUnitFrames scale",{0.25,0.5,0.75,1,1.25,1.5},nil,"CustomUnitFrames","Scale",350,-465,"TOPLEFT",100,"Changes the scale of the CustomUnitFrames. To make this more accurate,\nuse '/ch unitframe-scale'.",function()ClassHelper:UpdateUnitFrameScale()end)
        entered_world=true
    end
end
f:SetScript("OnEvent",handle)
local text=panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
text:SetText("CustomUnitFrames attributes \124cffff6600(Autosaves)")
text:SetPoint("TOPLEFT",430,-10)
local scroll=CreateFrame("ScrollFrame",nil,panel,"UIPanelScrollFrameTemplate")
scroll:SetSize(775,670)
scroll:SetPoint("RIGHT",-25,0)
local panel2=CreateFrame("FRAME",nil,panel)
panel2:SetSize(775,670)
panel2:SetPoint("RIGHT",panel,"RIGHT",0,0)
scroll:SetScrollChild(panel2)
local button=CreateFrame("Button",nil,panel2,"UIPanelButtonTemplate")
button:SetText("Update")
button:SetWidth(100)
button:SetPoint("TOPLEFT",panel2,"TOPLEFT",420,-20)
local scroll2=CreateFrame("ScrollFrame",nil,panel2,"UIPanelScrollFrameTemplate")
scroll2:SetSize(290,290)
scroll2:SetPoint("TOPRIGHT",-50,-55)
scroll2:SetFrameLevel(500)
local editor=CreateFrame("EditBox",nil,scroll2)
editor:SetSize(290,290)
editor:SetMultiLine(true)
editor:SetAutoFocus(false)
editor:SetPoint("TOPLEFT")
editor:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",9)
editor:SetText([[-- Type an attribute in the box above to edit it.]])
editor:SetCursorPosition(0)
editor:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
editor:SetScript("OnTabPressed",function(self)self:Insert("    ")end)
local editorTexture=panel2:CreateTexture(nil,"ARTWORK")
editorTexture:SetColorTexture(0.05,0.05,0.05,0.8)
editorTexture:SetSize(300,300)
editorTexture:SetPoint("TOPRIGHT",-50,-50)
scroll2:SetScrollChild(editor)
local selector=CreateFrame("EditBox",nil,panel2)
selector:SetSize(200,20)
selector:SetAutoFocus(false)
selector:SetPoint("TOPLEFT",525,-20)
selector:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",9)
selector:SetCursorPosition(0)
selector:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
local selectTexture=panel2:CreateTexture(nil,"ARTWORK")
selectTexture:SetColorTexture(0.05,0.05,0.05,0.8)
selectTexture:SetSize(200,20)
selectTexture:SetPoint("TOPLEFT",525,-20)
local i=0
local function saveAttribute(x)
    if x==""or not x then return end
    local t=ClassHelper:Load("CustomUnitFrames","Attributes")
    local e=editor:GetText()
    if e==""or strlower(e)=="<no data>"then
        t[x]=nil
    else
        t[x]=e
    end
    ClassHelper:Save("CustomUnitFrames","Attributes",t)
end
local function updateEditor()
    local t=ClassHelper:Load("CustomUnitFrames","Attributes")
    local x=t[selector:GetText()]
    editor:SetText(x)
end
local attrib=""
selector:SetScript("OnTabPressed",function(self)i=i+1 local t=ClassHelper:Load("CustomUnitFrames","Attributes")local t2={}for i,v in pairs(t)do tinsert(t2,i)end if i>getn(t2)then i=1 end saveAttribute(attrib)self:SetText(t2[i])attrib=t2[i]updateEditor()end)
selector:SetScript("OnEnterPressed",function(self)local t=ClassHelper:Load("CustomUnitFrames","Attributes")saveAttribute(attrib)attrib=self:GetText()local x=self:GetText()if t[x]then editor:SetText(t[x])else editor:SetText("<No data>")end end)
button:SetScript("OnClick",function()saveAttribute(attrib)ClassHelper:UpdateAllUnitFrameAttributes()end)
local detectFontFrame=CreateFrame("FRAME")
detectFontFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
detectFontFrame:SetScript("OnEvent",function()
    editor:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",tonumber(ClassHelper:Load("ModEditor","TextSize")))
    selector:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",tonumber(ClassHelper:Load("ModEditor","TextSize")))
end)