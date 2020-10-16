SLASH_ALERTS1="/alert"
AlertSystem={
    alerts={

    },
    showChat=true
}
SlashCmdList["ALERTS"]=function(msg)
    AlertSystem:CreateAlert(msg)
end
C_Timer.NewTicker(0.1,function()AlertSystem:alert_tick()end)
function AlertSystem:CreateAlert(msg)
    tinsert(self.alerts,msg)
    if msg=="!delete"then
        self.alerts={
            
        }
        self:Print("Deleted all alerts.")
    else
        self:Print("Alert created. You have "..getn(self.alerts).." alerts active.")
    end
end
function AlertSystem:Print(msg)
    if self.showChat then
        print("\124cffff6600AlertSystem: \124cffffff00"..msg)
    end
end
local alert1=CreateFrame("Frame",nil,UIParent)
local alert_text=alert1:CreateFontString(nil,"OVERLAY","ZoneTextFont")
alert_text:SetWidth((GetScreenWidth()/3)-100)
AlertSystem:Print("Alerts are active! (To use, type '/alert <command>' and the command will run every 0.1 sec. To stop this, type '/alert !delete')")
alert_text:SetHeight(0)
alert_text:SetPoint("TOP",0,0)
alert1:SetFrameStrata("HIGH")
alert1:SetWidth(1)
alert1:SetHeight(1)
alert1:SetPoint("CENTER",UIParent,"CENTER",0,GetScreenHeight()/6)
alert_text:SetScale(3)
local frame_alpha=100
local script_running=false
function AlertSystem:MoveAlertText(anchor,x,y)
    alert1:ClearAllPoints()
    alert1:SetPoint(anchor,UIParent,anchor,x,y)
    ClassHelper:SaveFrame(alert1,"AlertSystem","AlertText")
end
function AlertSystem:ShowText(alertMsg,hideChat)
    alert_text:SetText("\124cffff6600"..alertMsg)
    alert_text:SetAlpha(1)
    frame_alpha=100
    local function updateText(alpha)
        frame_alpha=alpha
        alert_text:SetAlpha(frame_alpha/100)
        if frame_alpha>0 then
            C_Timer.NewTimer(0.05,function()updateText(frame_alpha-5)end)
            script_running=true
        else
            script_running=false
        end
    end
    C_Timer.NewTimer(1.5,function()if script_running==false then frame_alpha=100 updateText(frame_alpha)end end)
    if not hideChat then
        self:Print("\124cffff0000Warning: \124cffff6600"..alertMsg)
    end
end
function Airhorn()
    PlaySoundFile("Interface/AddOns/ClassHelper/Assets/AirHorn.ogg","master")
end
function AlertSystem:alert_tick()
    for i=1,getn(self.alerts)do
        RunScript(self.alerts[i])
    end
end
function AlertSystem:GetWarningTextPointer()
    return alert1
end
local f=CreateFrame("FRAME")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
local function handle(self,event,...)
    local p=ClassHelper:LoadFrame("AlertSystem","AlertText")
    if p then
        AlertSystem:MoveAlertText(p[1],p[4],p[5])
    else
        ClassHelper:SaveFrame(alert1,"AlertSystem","AlertText")
    end
    AlertSystem.showChat=ClassHelper:Load("AlertSystem","ShowChat")
end
f:SetScript("OnEvent",handle)