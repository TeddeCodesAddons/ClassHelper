-- Panel and editor
local alphabet={
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0",
    "_"
}
local editingMod={

}
local mode="data"
local panel=CreateFrame("FRAME",nil,UIParent)
panel:SetSize(1080,720)
panel:SetPoint("CENTER",0,0)
panel:SetFrameStrata("HIGH")
panel:SetFrameLevel(0)
local function panel_text(t,p,x,y)
    local titleText=panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
    titleText:SetText(t)
    titleText:SetPoint(p,x,y)
end
panel_text("ClassHelper v9.0","TOP",0,-5)
local closeButton=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
closeButton:SetText("x")
closeButton:SetSize(10,12)
closeButton:SetPoint("TOPRIGHT",-6,-4)
closeButton:SetScript("OnClick",function()ClassHelper:ToggleUI("hide")end)
local panelTexture=panel:CreateTexture(nil,"BORDER")
panelTexture:SetColorTexture(0.2,0.2,0.2,0.8)
panelTexture:SetSize(1080,720)
panelTexture:SetPoint("CENTER",0,0)
local editorPanel=CreateFrame("FRAME",nil,panel)
editorPanel:SetSize(800,680)
editorPanel:SetPoint("RIGHT",panelTexture,"RIGHT",-20,0)
editorPanel:SetFrameStrata("HIGH")
editorPanel:SetFrameLevel(1)
local editorPanelTexture=editorPanel:CreateTexture(nil,"BACKGROUND")
editorPanelTexture:SetPoint("CENTER")
editorPanelTexture:SetSize(800,680)
editorPanelTexture:SetColorTexture(0.1,0.1,0.1,0.8)
local editorNav=CreateFrame("FRAME",nil,panel,BackdropTemplateMixin and "BackdropTemplate")
editorNav:SetSize(240,40)
editorNav:SetPoint("TOPLEFT",20,-20)
editorNav:SetFrameStrata("HIGH")
editorNav:SetFrameLevel(2)
editorNav:SetBackdrop({
    bgFile="Interface/Buttons/WHITE8X8",
    edgeFile="Interface/Buttons/WHITE8X8",
    edgeSize=1
})
local currentPage=editorNav
editorNav:SetBackdropColor(0.4,0.1,0.1,1)
editorNav:SetBackdropBorderColor(1,1,1,1)
local editorNavButton=CreateFrame("BUTTON",nil,editorNav)
editorNavButton:SetSize(240,40)
editorNavButton:SetPoint("CENTER")
editorNavButton:SetScript("OnClick",function()ClassHelper:UI_OpenToPage("Mod Editor")currentPage=editorNav editorNav:SetBackdropColor(0.4,0.1,0.1,1)end)
local editorNavFont=editorNav:CreateFontString(nil,"ARTWORK","GameFontNormal")
editorNavFont:SetText("Mod Editor")
editorNavFont:SetPoint("CENTER",0,0)
local editorTexture=editorPanel:CreateTexture(nil,"ARTWORK")
editorTexture:SetColorTexture(0.05,0.05,0.05,0.8)
editorTexture:SetSize(610,460)
editorTexture:SetPoint("BOTTOMRIGHT",-50,20)
local scroll=CreateFrame("ScrollFrame",nil,editorPanel,"UIPanelScrollFrameTemplate")
scroll:SetSize(600,450)
scroll:SetPoint("BOTTOMRIGHT",-50,20)
local editor=CreateFrame("EditBox",nil,scroll)
editor:SetSize(600,450)
editor:SetMultiLine(true)
editor:SetAutoFocus(false)
editor:SetPoint("TOPLEFT")
editor:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",9)
editor:SetText([[-- No mod is currently selected. Please select a mod to use the editor.]])
editor:SetCursorPosition(0)
editor:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
editor:SetScript("OnTabPressed",function(self)self:Insert("    ")end)
local saveButton=CreateFrame("Button",nil,editorPanel,"UIPanelButtonTemplate")
saveButton:SetText("Save")
saveButton:SetWidth(100)
saveButton:SetPoint("LEFT",175,190)
local errorText
local checkButton=CreateFrame("Button",nil,editorPanel,"UIPanelButtonTemplate")
checkButton:SetText("Error check")
checkButton:SetWidth(100)
checkButton:SetPoint("LEFT",50,190)
checkButton:SetScript("OnClick",function()
    ClassHelper:SetEditorMode(mode)
    local data,init,unload,reinit=editingMod.data,editingMod.init,editingMod.unload,editingMod.reinit
    if data and init and unload and reinit and editingMod.title then
        local _
        _,data=loadstring(data,"Data")
        _,init=loadstring(init,"Init")
        _,unload=loadstring(unload,"Unload")
        _,reinit=loadstring(reinit,"Reinit")
        local errorText2=""
        if data then
            errorText2=errorText2.."\n"..data
        end
        if init then
            errorText2=errorText2.."\n"..init
        end
        if unload then
            errorText2=errorText2.."\n"..unload
        end
        if reinit then
            errorText2=errorText2.."\n"..reinit
        end
        if not(data or init or unload or reinit)then
            errorText2="No errors were found."
        end
        errorText:SetText((editingMod.title)..": "..errorText2)
    else
        ClassHelper:Print("Please select a mod before running an error check.")
    end
end)
local revertButton=CreateFrame("Button",nil,editorPanel,"UIPanelButtonTemplate")
revertButton:SetText("Revert")
revertButton:SetWidth(100)
revertButton:SetPoint("LEFT",300,190)
revertButton:SetScript("OnClick",function()ClassHelper:Print("All changes were reverted. (If you saved changes, these will not be reverted. Restore a backup instead)")ClassHelper:SetupEditor(ClassHelper:LoadModByName(editingMod.title))end)
local deleteButton=CreateFrame("Button",nil,editorPanel,"UIPanelButtonTemplate")
deleteButton:SetText("Delete mod")
deleteButton:SetWidth(100)
deleteButton:SetPoint("LEFT",425,190)
deleteButton:SetScript("OnClick",function(self)if self:GetText()=="\124cffff0000Really?"then self:SetText("Delete mod")ClassHelper:DeleteMod(editingMod.title)else ClassHelper:Print("Are you sure you want to delete these mods? This action cannot be undone unless you have a backup. (Type '/ch backup' to backup your AddOn)")self:SetText("\124cffff0000Really?")self:Disable()C_Timer.NewTimer(1,function()self:Enable()end)C_Timer.NewTimer(3,function()self:SetText("Delete mod")end)end end)
scroll:SetScrollChild(editor)
function ClassHelper:SetEditorMode(m)
    if mode=="data"then
        editingMod.data=editor:GetText()
    elseif mode=="init"then
        editingMod.init=editor:GetText()
    elseif mode=="unload"then
        editingMod.unload=editor:GetText()
    elseif mode=="reinit"then
        editingMod.reinit=editor:GetText()
    end
    mode=m
    if m=="data"then
        editor:SetText(editingMod.data)
    elseif m=="init"then
        editor:SetText(editingMod.init)
    elseif m=="unload"then
        editor:SetText(editingMod.unload)
    elseif m=="reinit"then
        editor:SetText(editingMod.reinit)
    end
end
local newButton=CreateFrame("Button",nil,editorPanel,"UIPanelButtonTemplate")
newButton:SetText("New mod")
newButton:SetWidth(100)
newButton:SetPoint("TOPRIGHT",-100,-10)
newButton:SetScript("OnClick",function()ClassHelper_NewModFrame:Show()end)
local dataCheckbox=CreateFrame("CheckButton",nil,editorPanel,"ChatConfigCheckButtonTemplate")
dataCheckbox:SetPoint("TOPRIGHT",-50,-50)
dataCheckbox.tooltip="The mod's data. This data runs on every combat log event."
local initCheckbox=CreateFrame("CheckButton",nil,editorPanel,"ChatConfigCheckButtonTemplate")
initCheckbox:SetPoint("TOPRIGHT",-50,-80)
initCheckbox.tooltip="The mod's initialization code. This code runs the first time you load the mod."
local unloadCheckbox=CreateFrame("CheckButton",nil,editorPanel,"ChatConfigCheckButtonTemplate")
unloadCheckbox:SetPoint("TOPRIGHT",-50,-110)
unloadCheckbox.tooltip="The mod's unloading code. This code runs when the mod unloads, if you created frames, hide them here for later use, then when it reloads, show them again. To confirm unload, use 'UNLOAD()'. This is in case you don't want the mod to unload in certain situations. (EX: Still in the same zone, but a subzone.)"
local reinitCheckbox=CreateFrame("CheckButton",nil,editorPanel,"ChatConfigCheckButtonTemplate")
reinitCheckbox:SetPoint("TOPRIGHT",-50,-140)
reinitCheckbox.tooltip="The mod's re-initialization code. This runs if the mod unloads and reloads, so you don't accidentally create frame duplicates."
dataCheckbox:SetScript("OnClick",function(self)self:SetChecked(true)initCheckbox:SetChecked(false)unloadCheckbox:SetChecked(false)reinitCheckbox:SetChecked(false)ClassHelper:SetEditorMode("data")end)
initCheckbox:SetScript("OnClick",function(self)self:SetChecked(true)dataCheckbox:SetChecked(false)unloadCheckbox:SetChecked(false)reinitCheckbox:SetChecked(false)ClassHelper:SetEditorMode("init")end)
unloadCheckbox:SetScript("OnClick",function(self)self:SetChecked(true)dataCheckbox:SetChecked(false)initCheckbox:SetChecked(false)reinitCheckbox:SetChecked(false)ClassHelper:SetEditorMode("unload")end)
reinitCheckbox:SetScript("OnClick",function(self)self:SetChecked(true)dataCheckbox:SetChecked(false)initCheckbox:SetChecked(false)unloadCheckbox:SetChecked(false)ClassHelper:SetEditorMode("reinit")end)
local modConditions=CreateFrame("EditBox",nil,editorPanel)
saveButton:SetScript("OnClick",function()editingMod.load=modConditions:GetText()ClassHelper:SetEditorMode(mode)ClassHelper:UpdateMod(editingMod)ClassHelper:Print("Saved \124cff0066ff"..(editingMod.title).."\124cffffff00 mods. To load the new mods, type '/reload'. This only needs to be done when you edit a mod.")end)
modConditions:SetSize(500,20)
modConditions:SetAutoFocus(false)
modConditions:SetPoint("BOTTOMRIGHT",-50,490)
modConditions:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",9)
modConditions:SetCursorPosition(0)
modConditions:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
local modConditionTexture=editorPanel:CreateTexture(nil,"ARTWORK")
modConditionTexture:SetColorTexture(0.05,0.05,0.05,0.8)
modConditionTexture:SetSize(500,20)
modConditionTexture:SetPoint("BOTTOMRIGHT",-50,490)
local enabledCheckbox=CreateFrame("CheckButton",nil,editorPanel,"ChatConfigCheckButtonTemplate")
enabledCheckbox:SetPoint("TOPRIGHT",-165,-140)
enabledCheckbox.tooltip="When unchecked, this mod will not function. To make it work again, check this box. You must save the mod after clicking this."
enabledCheckbox:SetScript("OnClick",function(self)editingMod.loadable=self:GetChecked()end)
function ClassHelper:SetupEditor(m)
    editor:SetText(m.data)
    editingMod=m
    mode="none"
    modConditions:SetText(m.load)
    dataCheckbox:Click()
    enabledCheckbox:SetChecked(m.loadable)
end
local modSelectTexture=editorPanel:CreateTexture(nil,"ARTWORK")
modSelectTexture:SetColorTexture(0.05,0.05,0.05,0.8)
modSelectTexture:SetSize(500,20)
modSelectTexture:SetPoint("BOTTOMRIGHT",-150,550)
local modSelector=CreateFrame("EditBox",nil,editorPanel)
modSelector:SetSize(500,20)
modSelector:SetAutoFocus(false)
modSelector:SetPoint("BOTTOMRIGHT",-150,550)
modSelector:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",9)
modSelector:SetCursorPosition(0)
modSelector:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
local scroll2=CreateFrame("ScrollFrame",nil,editorPanel,"UIPanelScrollFrameTemplate")
scroll2:SetSize(500,70)
scroll2:SetPoint("TOPLEFT",40,-20)
errorText=CreateFrame("EditBox",nil,scroll2)
errorText:SetSize(500,70)
errorText:SetAutoFocus(false)
errorText:SetPoint("TOPLEFT",0,0)
errorText:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",9)
errorText:SetCursorPosition(0)
errorText:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
errorText:SetMultiLine(true)
errorTextTexture=editorPanel:CreateTexture(nil,"ARTWORK")
errorTextTexture:SetColorTexture(0.05,0.05,0.05,0.8)
errorTextTexture:SetSize(500,70)
errorTextTexture:SetPoint("TOPLEFT",40,-20)
scroll2:SetScrollChild(errorText)
errorText:SetText("Errors in your code will appear here. You can press CTRL+A and CTRL+C to select all and copy the errors.")
local modAmount=0
modSelector:SetScript("OnTabPressed",function(self)local m=self:GetText()m=ClassHelper:Search("")if getn(m)==0 then ClassHelper:Print("\124cffff0000You don't have any mods to search for!")return end modAmount=modAmount+1 self:SetText(m[modAmount])ClassHelper:SetupEditor(ClassHelper:LoadModByName(m[modAmount]))if modAmount>=getn(m)then modAmount=0 end end)
modSelector:SetScript("OnEnterPressed",function(self)local m=self:GetText()m=ClassHelper:Search(m)if getn(m)==0 then ClassHelper:Print("No results were found.")return end self:SetText(m[1])ClassHelper:SetupEditor(ClassHelper:LoadModByName(m[1]))self:ClearFocus()end)
local indent=0
local function editor_text(t,p,x,y)
    local titleText=editorPanel:CreateFontString(nil,"ARTWORK","GameFontNormal")
    titleText:SetText(t)
    titleText:SetPoint(p,x,y)
end
editor_text("Mod name:","LEFT",80,220)
editor_text("Conditions:","LEFT",175,160)
editor_text("Reinit","LEFT",680,190)
editor_text("Unload","LEFT",680,220)
editor_text("Init","LEFT",680,250)
editor_text("Data","LEFT",680,280)
editor_text("Enabled","LEFT",560,190)
local function getNumIndentationsForPos(text,pos)
    local streak=""
    indent=0
    local i=1
    pos=pos+1
    local bracket=0
    local equals=0
    local commentLine=false
    while i<pos do
        if not commentLine then -- If commented out, ignore.
            if tContains(alphabet,strupper(strsub(text,i,i)))then
                streak=streak..strsub(text,i,i)
            elseif strsub(text,i,i)=="{"then -- Tables
                indent=indent+1
            elseif strsub(text,i,i)=="}"then
                indent=indent-1
            else
                if streak=="then"or streak=="do"or streak=="function"then -- Indentation keywords
                    indent=indent+1
                elseif streak=="end"or streak=="elseif"then
                    indent=indent-1
                end
                streak=""
            end
            if strsub(text,i,i)=="\""or strsub(text,i,i)=="'"then -- Strings
                i=i+1
                local n=strsub(text,i,i)
                while strsub(text,i,i)~=n and i<pos and i<strlen(text)do
                    if strsub(text,i,i)=="\\"then
                        i=i+1
                    end
                    i=i+1
                end
                i=i-1
            end
        end
        if strsub(text,i,i+1)=="--"then -- Comments
            commentLine=true
        end
        if strsub(text,i,i)=="\n"then
            commentLine=false
        end
        if bracket>0 and(strsub(text,i,i)=="="or strsub(text,i,i)=="[")then -- Bracket multiline strings
            if strsub(text,i,i)=="["then -- Also works with multiline comments.
                bracket=2
            elseif strsub(text,i,i)=="="then
                equals=equals+1
            end
        elseif strsub(text,i,i)=="["then
            bracket=1
        else
            bracket=0
        end
        if bracket==2 then -- If 2 brackets ('[[') or equals in between, look for the closer.
            local brackets=bracket
            local equalsTotal=equals
            i=i+1
            while i<strlen(text)and i<pos and(bracket>0 or equals>0)do
                if strsub(text,i,i)=="]"then
                    bracket=bracket-1
                elseif strsub(text,i,i)=="="and bracket==1 then
                    equals=equals-1
                else
                    bracket=brackets
                    equals=equalsTotal
                end
                i=i+1
            end
            i=i-1
            commentLine=false -- String/multiline comment ended.
        end
        i=i+1
    end
    if streak=="then"or streak=="do"or streak=="function"then -- Indentation keywords
        indent=indent+1
    elseif streak=="end"or streak=="elseif"then
        indent=indent-1
    end
end
local function autoIndentLine()
    local indentation=""
    if indent>0 then
        for i=1,indent do
            indentation=indentation.."    "
        end
    end
    editor:Insert(indentation)
end
editor:SetScript("OnEnterPressed",function(self)getNumIndentationsForPos(self:GetText(),self:GetCursorPosition())self:Insert("\n")autoIndentLine()end)
panel:Hide()
editorPanel:Show()
local ui_showing=false
function ClassHelper:ToggleUI(toggle)
    toggle=strlower(toggle)
    if toggle=="show"then
        ui_showing=true
        panel:Show()
    elseif toggle=="hide"then
        ui_showing=false
        panel:Hide()
    elseif ui_showing then
        ui_showing=false
        panel:Hide()
    else
        ui_showing=true
        panel:Show()
    end
end
local panelTitles={
    ["Mod Editor"]=editorPanel
}
function ClassHelper:UI_OpenToPage(page)
    currentPage:SetBackdropColor(0.1,0.1,0.1,1)
    for i,v in pairs(panelTitles)do
        if i==page then
            v:Show()
        else
            v:Hide()
        end
    end
end
function ClassHelper:FocusEditor()
    editor:SetFocus()
end
function ClassHelper:FindTextInEditor(replace,replaceAll,posStart,iters)
    if posStart=="!default"then
        posStart=editor:GetCursorPosition()
    end
    if posStart=="!cursor"then
        posStart=editor:GetCursorPosition()-1
    end
    if iters>1000 then
        self:Print("Maximum number of iterations were reached when finding and replacing. (1000)")
        return
    end
    local f=ClassHelper_InsertFindAndReplace_FindBox:GetText()
    local r=ClassHelper_InsertFindAndReplace_ReplaceBox:GetText()
    if f==""then
        self:Print("Cannot find and replace when find is blank!")
        return
    end
    local pos=strfind(editor:GetText(),f,posStart,true)
    if pos then
        pos=pos-1
        editor:SetCursorPosition(pos+strlen(f))
        editor:HighlightText(pos,pos+strlen(f))
        if replace then
            editor:Insert(r)
            if replaceAll then
                self:FindTextInEditor(true,true,editor:GetCursorPosition(),iters+1)
            end
        end
    elseif replaceAll==false then
        self:Print("No match found.")
    end
end
function ClassHelper:CreateNewMod(modName)
    local m={

    }
    m.data=[[-- ClassHelper mod template
local timestamp,subevent,_,_,sourceName,_,_,guid,destName=CombatLogGetCurrentEventInfo()
local spellId,spellName,spellSchool,amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing,isOffHand=select(12,CombatLogGetCurrentEventInfo())
-- ^ These lines are defining variables used by the combat log. ^
if subevent=="SPELL_AURA_APPLIED"and sourceName==UnitName("player")then -- If YOU apply an aura...
    if spellName=="My spell"then -- If it's the correct spell...
        -- Do something here, check API for proper use.
    end
end]]
    m.init=[[-- POWER_BAR=ClassHelper:NewPowerBar("MANA") -- Create a mana bar (If you need one)]]
    m.reinit=[[-- POWER_BAR:Show() -- Show the power bar again]]
    m.unload=[[-- POWER_BAR:Hide() -- Hide the power bar when unloaded.]]
    m.load=[[CONDITION HERE (If you want this to load anywhere, type 'all' instead)]]
    m.loadable=true -- Default is enabled.
    m.title=modName
    self:NewMod(m)
end
ClassHelper:CreateSlashCommand("ui","ClassHelper:ToggleUI(arguments)","Toggles the display of the UI.")
ClassHelper:CreateSlashCommand("interface","ClassHelper:ToggleUI(arguments)","Toggles the display of the UI.")
local lastPane=editorNav
function ClassHelper:NewUIPanel(title)
    if panelTitles[title]then
        return nil
    end
    local Nav=CreateFrame("FRAME",nil,panel,BackdropTemplateMixin and "BackdropTemplate")
    Nav:SetSize(240,40)
    Nav:SetPoint("TOPLEFT",lastPane,"TOPLEFT",0,-40)
    lastPane=Nav
    Nav:SetFrameStrata("HIGH")
    Nav:SetFrameLevel(2)
    Nav:SetBackdrop({
        bgFile="Interface/Buttons/WHITE8X8",
        edgeFile="Interface/Buttons/WHITE8X8",
        edgeSize=1
    })
    Nav:SetBackdropColor(0.1,0.1,0.1,1)
    Nav:SetBackdropBorderColor(1,1,1,1)
    local NavButton=CreateFrame("BUTTON",nil,Nav)
    NavButton:SetSize(240,40)
    NavButton:SetPoint("CENTER")
    NavButton:SetScript("OnClick",function()ClassHelper:UI_OpenToPage(title)currentPage=Nav Nav:SetBackdropColor(0.4,0.1,0.1,1)end)
    local NavFont=Nav:CreateFontString(nil,"ARTWORK","GameFontNormal")
    NavFont:SetText(title)
    NavFont:SetPoint("CENTER",0,0)
    local Panel=CreateFrame("FRAME",nil,panel)
    Panel:SetSize(800,680)
    Panel:SetPoint("RIGHT",panelTexture,"RIGHT",-20,0)
    Panel:SetFrameStrata("HIGH")
    Panel:SetFrameLevel(1)
    local PanelTexture=Panel:CreateTexture(nil,"BACKGROUND")
    PanelTexture:SetPoint("CENTER")
    PanelTexture:SetSize(800,680)
    PanelTexture:SetColorTexture(0.1,0.1,0.1,0.8)
    panelTitles[title]=Panel
    Panel:Hide() -- All panels are hidden, open to editor by default.
    return Panel
end
local f=CreateFrame("FRAME")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
local entered_world=false
f:SetScript("OnEvent",function()
    if not entered_world then
        entered_world=true
        ClassHelper:DefaultSavedVariable("ModEditor","SyntaxEnabled","true")
        ClassHelper:DefaultSavedVariable("ModEditor","TextSize","9")
        if ClassHelper:Load("ModEditor","SyntaxEnabled")=="true"then
            ClassHelper:DefineSyntaxBox(editor,function(self,key)if key=="BACKSPACE"and strsub(self:GetText(),self:GetCursorPosition()-3,self:GetCursorPosition())=="    "then self:HighlightText(self:GetCursorPosition()-4,self:GetCursorPosition())end if key=="S"and(IsLeftControlKeyDown()or IsRightControlKeyDown())then editingMod.load=modConditions:GetText()ClassHelper:SetEditorMode(mode)ClassHelper:UpdateMod(editingMod)ClassHelper:Print("Saved \124cff0066ff"..(editingMod.title).."\124cffffff00 mods. To load the new mods, type '/reload'. This only needs to be done when you edit a mod.")end if key=="F"and(IsLeftControlKeyDown()or IsRightControlKeyDown())then ClassHelper_FindAndReplaceFrame:Show()end end)
        end
        editor:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",tonumber(ClassHelper:Load("ModEditor","TextSize")))
        if ClassHelper:Load("ModEditor","SyncAcrossAllFrames")=="true"then
            modSelector:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",tonumber(ClassHelper:Load("ModEditor","TextSize")))
            modConditions:SetFont("Interface\\AddOns\\"..(ClassHelper.ADDON_PATH_NAME).."\\Assets\\monaco.ttf",tonumber(ClassHelper:Load("ModEditor","TextSize")))
        end
    end
end)