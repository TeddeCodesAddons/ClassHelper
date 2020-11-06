-- Templates (For user-created templates to make it easier and faster to create things you already created in other mods)
-- Most of this code was copied from Panel.lua (Same directory you found this in)
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
local panel=ClassHelper:NewUIPanel("Templates")
local editorTexture=panel:CreateTexture(nil,"ARTWORK")
editorTexture:SetColorTexture(0.05,0.05,0.05,0.8)
editorTexture:SetSize(610,460)
editorTexture:SetPoint("BOTTOMRIGHT",-50,20)
local scroll=CreateFrame("ScrollFrame",nil,panel,"UIPanelScrollFrameTemplate")
scroll:SetSize(600,450)
scroll:SetPoint("BOTTOMRIGHT",-50,20)
local editor=CreateFrame("EditBox",nil,scroll)
editor:SetSize(600,450)
editor:SetMultiLine(true)
editor:SetAutoFocus(false)
editor:SetPoint("TOPLEFT")
editor:SetFont("Interface\\AddOns\\ClassHelper\\Assets\\monaco.ttf",9)
editor:SetText([[-- No template is currently selected. Please select a template to use the editor.]])
editor:SetCursorPosition(0)
editor:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
editor:SetScript("OnTabPressed",function(self)self:Insert("    ")end)
local saveButton=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
saveButton:SetText("Save")
saveButton:SetWidth(100)
saveButton:SetPoint("LEFT",175,190)
local revertButton=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
revertButton:SetText("Revert")
revertButton:SetWidth(100)
revertButton:SetPoint("LEFT",300,190)
revertButton:SetScript("OnClick",function()ClassHelper:Print("All changes were reverted. (If you saved changes, these will not be reverted. Restore a backup instead)")ClassHelper:SetupTemplateEditor(ClassHelper:LoadTemplateByName(editingMod.title))end)
local deleteButton=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
deleteButton:SetText("Delete")
deleteButton:SetWidth(100)
deleteButton:SetPoint("LEFT",425,190)
deleteButton:SetScript("OnClick",function(self)if self:GetText()=="\124cffff0000Really?"then self:SetText("Delete")ClassHelper:DeleteTemplate(editingMod.title)else ClassHelper:Print("Are you sure you want to delete this template? This action cannot be undone unless you have a backup. (Type '/ch backup' to backup your AddOn)")self:SetText("\124cffff0000Really?")self:Disable()C_Timer.NewTimer(1,function()self:Enable()end)C_Timer.NewTimer(3,function()self:SetText("Delete")end)end end)
scroll:SetScrollChild(editor)
local newButton=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
newButton:SetText("New template")
newButton:SetWidth(100)
newButton:SetPoint("TOPRIGHT",-100,-10)
newButton:SetScript("OnClick",function()ClassHelper_NewTemplateFrame:Show()end)
local modSelectTexture=panel:CreateTexture(nil,"ARTWORK")
modSelectTexture:SetColorTexture(0.05,0.05,0.05,0.8)
modSelectTexture:SetSize(500,20)
modSelectTexture:SetPoint("BOTTOMRIGHT",-150,550)
local modSelector=CreateFrame("EditBox",nil,panel)
modSelector:SetSize(500,20)
modSelector:SetAutoFocus(false)
modSelector:SetPoint("BOTTOMRIGHT",-150,550)
modSelector:SetFont("Interface\\AddOns\\ClassHelper\\Assets\\monaco.ttf",9)
modSelector:SetCursorPosition(0)
modSelector:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
local modAmount=0
function ClassHelper:SetupTemplateEditor(m)
    editor:SetText(m.data)
    editingMod=m
end
function ClassHelper:CreateNewTemplate(modName)
    local m={

    }
    m.data="-- Type any code here. This code will be saved, but won't run. You can copy and paste this code into your mods. Also useful if you want to transfer a mod from a profile to another profile."
    m.title=modName
    self:NewTemplate(m)
end
modSelector:SetScript("OnTabPressed",function(self)local m=self:GetText()m=ClassHelper:SearchTemplates("")if getn(m)==0 then ClassHelper:Print("\124cffff0000You don't have any templates to search for!")return end modAmount=modAmount+1 self:SetText(m[modAmount])ClassHelper:SetupTemplateEditor(ClassHelper:LoadTemplateByName(m[modAmount]))if modAmount>=getn(m)then modAmount=0 end end)
modSelector:SetScript("OnEnterPressed",function(self)local m=self:GetText()m=ClassHelper:SearchTemplates(m)if getn(m)==0 then ClassHelper:Print("No results were found.")return end self:SetText(m[1])ClassHelper:SetupTemplateEditor(ClassHelper:LoadTemplateByName(m[1]))self:ClearFocus()end)
saveButton:SetScript("OnClick",function()editingMod.data=editor:GetText()ClassHelper:UpdateTemplate(editingMod)ClassHelper:Print("Saved \124cff0066ff"..(editingMod.title).."\124cffffff00 templates.")end)
local indent=0
local function editor_text(t,p,x,y)
    local titleText=panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
    titleText:SetText(t)
    titleText:SetPoint(p,x,y)
end
editor_text("Template name:","LEFT",50,220)
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
local f=CreateFrame("FRAME")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
local entered_world=false
f:SetScript("OnEvent",function()
    if not entered_world then
        entered_world=true
        ClassHelper:DefaultSavedVariable("ModEditor","SyntaxEnabled","true")
        if ClassHelper:Load("ModEditor","SyntaxEnabled")=="true"then
            ClassHelper:DefineSyntaxBox(editor,function(self,key)if key=="BACKSPACE"and strsub(self:GetText(),self:GetCursorPosition()-3,self:GetCursorPosition())=="    "then self:HighlightText(self:GetCursorPosition()-4,self:GetCursorPosition())end if key=="S"and(IsLeftControlKeyDown()or IsRightControlKeyDown())then editingMod.data=editor:GetText()ClassHelper:UpdateTemplate(editingMod)ClassHelper:Print("Saved \124cff0066ff"..(editingMod.title).."\124cffffff00 templates.")end if key=="F"and(IsLeftControlKeyDown()or IsRightControlKeyDown())then ClassHelper_FindAndReplaceTemplateFrame:Show()end end)
        end
        editor:SetFont("Interface\\AddOns\\ClassHelper\\Assets\\monaco.ttf",tonumber(ClassHelper:Load("ModEditor","TextSize")))
    end
end)
function ClassHelper:FocusTemplateEditor()
    editor:SetFocus()
end
function ClassHelper:FindTextInTemplateEditor(replace,replaceAll,posStart,iters)
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
    local f=ClassHelper_InsertFindAndReplaceTemplate_FindBox:GetText()
    local r=ClassHelper_InsertFindAndReplaceTemplate_ReplaceBox:GetText()
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
                self:FindTextInTemplateEditor(true,true,editor:GetCursorPosition(),iters+1)
            end
        end
    elseif replaceAll==false then
        self:Print("No match found.")
    end
end