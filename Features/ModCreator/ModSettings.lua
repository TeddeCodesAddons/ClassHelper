-- Proper usage of settings
-- yardsText: " yds"
-- immuneWarning: "\124cffff0000IMMUNE NOW!"
-- framerate: 60
-- disableYardsTextWhenOutOfRange: true
-- frameParent: UIParent
local editor
local editingTitle=""
local editingDefaults=""
local changesSaved=true
local function saveDefaults()
    ClassHelper:NewBackup()
    changesSaved=true
    local s=editor:GetText()
    local m=ClassHelper:LoadModByName(editingTitle)
    m.settings=editor:GetText()
    m.default_settings=editor:GetText()
    ClassHelper:Print("You overwrote the default settings. Because this operation is rarely recommended, a backup was created. If you are not the mod author, please restore to the old backup: '/ch backup -r <backup name>'. The backup name should be printed in chat. If you are the mod author, delete the backup by replacing '-r' with '-d'.")
end
local function resetToDefaults()
    changesSaved=true
    local m=ClassHelper:LoadModByName(editingTitle)
    editor:SetText(m.default_settings)
    ClassHelper:Print("Reset the mod settings to the defaults. If you overwrote the defaults, you will reset to these instead.")
end
local function save()
    changesSaved=true
    local s=editor:GetText()
    local m=ClassHelper:LoadModByName(editingTitle)
    m.settings=editor:GetText()
    ClassHelper:Print("Saved all changes to the mod settings. To use the new settings, type '/reload'.")
end
local function revert()
    local m=ClassHelper:LoadModByName(editingTitle)
    changesSaved=true
    editor:SetText(m.settings)
end
StaticPopupDialogs["CH_CONFIRM_EDIT_DEFAULT_SETTINGS"]={
    text="\124cffff0000WARNING: You are attempting to save these settings as the defaults for this mod. If anyone else downloads this mod, they will have these settings as their defaults.\nYOU SHOULD ONLY DO THIS IF YOU ARE THE MOD AUTHOR.\n\124rAre you sure you want to overwrite these settings?",
    button1="Yes",
    button2="No",
    OnAccept=saveDefaults,
    timeout=0,
    whileDead=true,
    hideOnEscape=true,
    preferredIndex=3
}
StaticPopupDialogs["CH_CONFIRM_RESET_MOD_SETTINGS"]={
    text="Are you sure you want to reset to the default settings? Note: If you or the mod author changed the defaults, you will reset to those instead.",
    button1="Yes",
    button2="No",
    OnAccept=resetToDefaults,
    timeout=0,
    whileDead=true,
    hideOnEscape=true,
    preferredIndex=3
}
local panel=ClassHelper:NewUIPanel("Mod Settings")
local scroll=CreateFrame("ScrollFrame",nil,panel,"UIPanelScrollFrameTemplate")
scroll:SetSize(600,450)
scroll:SetPoint("BOTTOMRIGHT",-50,20)
editor=CreateFrame("EditBox",nil,scroll)
local editorTexture=panel:CreateTexture(nil,"ARTWORK")
editorTexture:SetColorTexture(0.05,0.05,0.05,0.8)
editorTexture:SetSize(610,460)
editorTexture:SetPoint("BOTTOMRIGHT",-50,20)
editor:SetSize(600,450)
editor:SetMultiLine(true)
editor:SetAutoFocus(false)
editor:SetPoint("TOPLEFT")
editor:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",9)
editor:SetText("")
editor:SetCursorPosition(0)
editor:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
editor:SetScript("OnTabPressed",function()end)
local saveButton=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
saveButton:SetText("Save")
saveButton:SetWidth(100)
saveButton:SetPoint("LEFT",175,190)
local revertButton=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
revertButton:SetText("Revert")
revertButton:SetWidth(100)
revertButton:SetPoint("LEFT",300,190)
revertButton:SetScript("OnClick",function()ClassHelper:Print("Settings were reverted! (If you saved these settings, you will revert to the saved settings. To restore defaults, click the reset button instead)")revert()end)
local deleteButton=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
deleteButton:SetText("Reset")
deleteButton:SetWidth(100)
deleteButton:SetPoint("LEFT",425,190)
deleteButton:SetScript("OnClick",function()StaticPopup_Show("CH_CONFIRM_RESET_MOD_SETTINGS")end)
scroll:SetScrollChild(editor)
saveButton:SetScript("OnClick",save)
function ClassHelper:SetDefaultSettingsForCurrentMod()
    StaticPopup_Show("CH_CONFIRM_EDIT_DEFAULT_SETTINGS")
end
ClassHelper:CreateSlashCommand("overwrite-defaults","ClassHelper:SetDefaultSettingsForCurrentMod()","Overwrites the default settings for a mod. \124cffff0000YOU SHOULD ONLY DO THIS IF YOU ARE THE MOD AUTHOR.")
local modSelectTexture=panel:CreateTexture(nil,"ARTWORK")
modSelectTexture:SetColorTexture(0.05,0.05,0.05,0.8)
modSelectTexture:SetSize(500,20)
modSelectTexture:SetPoint("BOTTOMRIGHT",-150,550)
local modSelector=CreateFrame("EditBox",nil,panel)
modSelector:SetSize(500,20)
modSelector:SetAutoFocus(false)
modSelector:SetPoint("BOTTOMRIGHT",-150,550)
modSelector:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",9)
modSelector:SetCursorPosition(0)
modSelector:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
function ClassHelper:SetupSettingsEditor(m)
    local s=m.settings
    editingTitle=m.title
    editingDefaults=m.default_settings
    if s then
        editor:SetText(s)
    else
        s=""
        self:Print("There was no settings for this mod, so empty settings were loaded.")
    end
    editor:SetText(s)
end
local modAmount=0
modSelector:SetScript("OnTabPressed",function(self)if not changesSaved then ClassHelper:Print("Please save your changes before switching mods!")return end local m=self:GetText()m=ClassHelper:Search("")if getn(m)==0 then ClassHelper:Print("\124cffff0000You don't have any mods to search for!")return end modAmount=modAmount+1 self:SetText(m[modAmount])ClassHelper:SetupSettingsEditor(ClassHelper:LoadModByName(m[modAmount]))if modAmount>=getn(m)then modAmount=0 end end)
modSelector:SetScript("OnEnterPressed",function(self)if not changesSaved then ClassHelper:Print("Please save your changes before switching mods!")return end local m=self:GetText()m=ClassHelper:Search(m)if getn(m)==0 then ClassHelper:Print("No results were found.")return end self:SetText(m[1])ClassHelper:SetupSettingsEditor(ClassHelper:LoadModByName(m[1]))self:ClearFocus()end)
local function editor_text(t,p,x,y)
    local titleText=panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
    titleText:SetText(t)
    titleText:SetPoint(p,x,y)
end
editor_text("Mod name:","LEFT",80,220)
local f=CreateFrame("FRAME")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
local entered_world=false
f:SetScript("OnEvent",function()
    if not entered_world then
        entered_world=true
        ClassHelper:DefaultSavedVariable("ModEditor","SyntaxEnabled","true")
        ClassHelper:DefaultSavedVariable("ModEditor","TextSize","9")
        if ClassHelper:Load("ModEditor","SyntaxEnabled")=="true"then
            ClassHelper:DefineSyntaxBox(editor,function(self,key)if key=="BACKSPACE"and strsub(self:GetText(),self:GetCursorPosition()-3,self:GetCursorPosition())=="    "then self:HighlightText(self:GetCursorPosition()-4,self:GetCursorPosition())end if key=="S"and(IsLeftControlKeyDown()or IsRightControlKeyDown())then save()end end)
        end
        editor:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",tonumber(ClassHelper:Load("ModEditor","TextSize")))
        if ClassHelper:Load("ModEditor","SyncAcrossAllFrames")=="true"then
            modSelector:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",tonumber(ClassHelper:Load("ModEditor","TextSize")))
        end
    end
end)