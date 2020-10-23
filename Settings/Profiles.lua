local profile=ClassHelper:GetProfile()
StaticPopupDialogs["CH_CONFIRM_PROFILE_SWITCH"]={
    text="Are you sure you want to switch profiles? This requires a reload.",
    button1="Yes",
    button2="No",
    OnAccept=function()ClassHelper:ChangeProfile(profile)ClassHelper:Print("Automatically reloading UI...")ReloadUI()end,
    timeout=0,
    whileDead=true,
    hideOnEscape=true,
    preferredIndex=3
}
local disableChange=false
ClassHelper:CreateSlashCommand("new-profile","ClassHelper:NewProfile(arguments)","View the Profiles section of the UI for more info.")
ClassHelper:CreateSlashCommand("delete-profile","ClassHelper:DeleteProfile(arguments)","View the Profiles section of the UI for more info.")
ClassHelper:CreateSlashCommand("switch-profile","ClassHelper:ChangeProfile(arguments)","View the profiles section of the UI for more info.")
local panel=ClassHelper:NewUIPanel("Profiles")
local currentProfileTexture=panel:CreateTexture(nil,"ARTWORK")
currentProfileTexture:SetColorTexture(0.05,0.05,0.05,0.8)
currentProfileTexture:SetSize(500,20)
currentProfileTexture:SetPoint("BOTTOMRIGHT",-150,550)
local currentProfileBox=CreateFrame("EditBox",nil,panel)
currentProfileBox:SetSize(500,20)
currentProfileBox:SetAutoFocus(false)
currentProfileBox:SetPoint("BOTTOMRIGHT",-150,550)
currentProfileBox:SetFont("Interface\\AddOns\\ClassHelper\\Assets\\monaco.ttf",9)
currentProfileBox:SetCursorPosition(0)
currentProfileBox:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
local switchToButton=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
local createButton=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
local deleteButton=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
currentProfileBox:SetScript("OnEnterPressed",function(self)if disableChange then ClassHelper:Print("\124cffff0000Can't do that right now!")return end local t=self:GetText()profile=self:GetText()local p=ClassHelper:SearchProfiles(t)if getn(p)==0 then ClassHelper:Print("No results were found. You can create the profile instead.")deleteButton:Disable()switchToButton:Disable()createButton:Enable()return end self:SetText(p[1])ClassHelper:Print("Profile found.")createButton:Disable()profile=p[1]if profile==ClassHelper:GetProfile()then switchToButton:Disable()deleteButton:Disable()else switchToButton:Enable()deleteButton:Enable()end end)
switchToButton:SetText("Switch to")
switchToButton:SetWidth(100)
switchToButton:SetPoint("LEFT",175,190)
switchToButton:SetScript("OnClick",function()StaticPopup_Show("CH_CONFIRM_PROFILE_SWITCH")end)
createButton:SetText("Create")
createButton:SetWidth(100)
createButton:SetPoint("LEFT",300,190)
createButton:SetScript("OnClick",function()ClassHelper:NewProfile(profile)end)
deleteButton:SetText("Delete")
deleteButton:SetWidth(100)
deleteButton:SetPoint("LEFT",425,190)
deleteButton:SetScript("OnClick",function(self)if self:GetText()=="\124cffff0000Really?"then self:SetText("Delete")ClassHelper:Print("Attempting to delete profile...")ClassHelper:DeleteProfile(profile)else self:SetText("\124cffff0000Really?")self:Disable()disableChange=true C_Timer.NewTimer(1,function()self:Enable()end)C_Timer.NewTimer(3,function()disableChange=false self:SetText("Delete")end)end end)
switchToButton:Disable()
createButton:Disable()
local entered_world=false
local f=CreateFrame("FRAME")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent",function()if not entered_world then entered_world=true profile=ClassHelper:GetProfile()currentProfileBox:SetText(profile)end end)
local titleText=panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
titleText:SetText("\124cffff6600Profiles\n\n\124rTo edit a profile, type the profile name in the box.\nIf the profile doesn't exist, click create to make a profile with the name you typed instead.\nSlash commands: '/ch new-profile', '/ch delete-profile', '/ch switch-profile'.")
titleText:SetPoint("TOP",0,-20)
local f=CreateFrame("FRAME")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent",function()
    if ClassHelper:Load("ModEditor","SyncAcrossAllFrames")=="true"then
        currentProfileBox:SetFont("Interface\\AddOns\\ClassHelper\\Assets\\monaco.ttf",tonumber(ClassHelper:Load("ModEditor","TextSize")))
    end
end)