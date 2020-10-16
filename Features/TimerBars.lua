-- -- [Timer bars example 1]
-- local bar=ClassHelper:NewBar(60,"My custom bar")
-- bar:RegisterEvent(15,function()print("15 seconds left on the bar!")end)
-- bar:RegisterEvent(0,function()print("Bar expired!")end)
-- -- [Timer bars example 2]
-- ClassHelper:NewBar(5,"My custom bar"):RegisterEvent(0,function()print("Bar expired!")end)

local all_bars={

}
local numBars=0
local barAnchor=CreateFrame("Frame","Frame",UIParent)
barAnchor:SetSize(256,24)
barAnchor:SetPoint("CENTER",-10,-212,UIParent)
local backAnchor=barAnchor:CreateTexture(nil,"BACKGROUND")
backAnchor:SetColorTexture(0.1,0.1,0.1,0.7)
backAnchor:SetPoint("TOP")
backAnchor:SetSize(256,24)
barAnchor:Hide()
barAnchor:RegisterForDrag("LeftButton")
barAnchor:SetMovable(true)
barAnchor:SetScript("OnDragStart",function(self)self:ClearAllPoints()self:StartMoving()end)
barAnchor:SetScript("OnDragStop",function(self)self:StopMovingOrSizing()ClassHelper:SaveFrame(self,"Timer_Bars","Bar_Anchor")end)
local bars_unlocked=false
barAnchor:EnableMouse(false)
local function createBar()
    local bar=CreateFrame("Frame","Frame",UIParent)
    bar:SetSize(256,24)
    local back=bar:CreateTexture(nil,"BACKGROUND")
    back:SetColorTexture(0.1,0.1,0.1,0.4)
    back:SetPoint("TOP")
    back:SetSize(256,24)
    local t1=bar:CreateTexture(nil,"BORDER")
    t1:SetColorTexture(0,1,0,1)
    t1:SetPoint("LEFT")
    t1:SetSize(256,24)
    local t2=bar:CreateTexture(nil,"ARTWORK")
    t2:SetTexture("Interface\\AddOns\\ClassHelper\\Assets\\bar.blp")
    t2:SetPoint("LEFT")
    t2:SetAlpha(0.8)
    t2:SetSize(256,24)
    local t3=bar:CreateFontString(nil,"OVERLAY")
    t3:SetFontObject(GameFontNormal)
    t3:SetPoint("LEFT",6,0)
    t3:SetTextColor(1,1,1,1)
    t3:SetText("Text")
    t3:SetScale(1)
    local t4=bar:CreateFontString(nil,"OVERLAY")
    t4:SetFontObject(GameFontNormal)
    t4:SetPoint("RIGHT",bar,"RIGHT",-6,0)
    t4:SetTextColor(1,1,1,1)
    t4:SetText("0.0")
    t4:SetScale(1)
    bar:Hide()
    bar:SetPoint("TOP",barAnchor,"TOP",0,numBars*-24)
    numBars=numBars+1
    local barObject={
        start_time=0,
        end_time=0,
        current_time=0,
        last_update=0,
        text="",
        events={

        },
        enabled=false,
        idx=numBars,
        is_restricted=false,
        reserved=false,
        paused=false
    }
    function barObject:Start(totalTime,text,cooldown)
        if cooldown~=nil then
            self.cooldown=cooldown
        else
            self.cooldown=-1
        end
        totalTime=ClassHelper:ConvertTime(totalTime)
        local t=GetTime()
        self.color=nil
        if self.maxTime then
            self.start_time=t-(self.maxTime-totalTime)
        else
            self.start_time=t
        end
        self.end_time=totalTime+t
        self.current_time=t
        self.last_update=t
        self.text=text
        self.paused=false
        self.events={

        }
        self.enabled=true
        self:MoveToBarPosition(self.idx)
        t3:SetText(text)
        return self
    end
    function barObject:RegisterEvent(_time,_function)
        tinsert(self.events,{_time,_function,false})
        return self
    end
    function barObject:Resume()
        self.paused=false
        return self
    end
    function barObject:Stop()
        self.events={

        }
        self.enabled=false
        bar:Hide()
        self.text=""
        ClassHelper:RePositionBars(self.idx+1)
        self:MoveToBarPosition(getn(all_bars))
        return self
    end
    function barObject:MoveToBarPosition(pos)
        self.idx=pos
        pos=pos-1
        bar:ClearAllPoints()
        bar:SetPoint("TOP",barAnchor,"TOP",0,pos*-24)
    end
    function barObject:SetReserved(isReserved)
        self.reserved=isReserved
        return self
    end
    function barObject:ChangeTime(_time,setEqual)
        if setEqual and not(self.is_restricted and _time<self.current_time)then
            self.current_time=self.end_time-_time
        elseif not setEqual then
            self.current_time=self.current_time+_time
        end
        if self.current_time<self.start_time then
            self.start_time=self.current_time
            self.last_update=self.current_time
        end
        return self
    end
    function barObject:SetColor(r,g,b,a)
        if not a then a=1 end
        self.color={
            r,
            g,
            b,
            a
        }
        return self
    end
    function barObject:SetConstantMaxTime(maxTime)
        self.maxTime=maxTime
        return self
    end
    function barObject:RemoveConstantMaxTime()
        self.maxTime=nil
        return self
    end
    local function update()
        if barObject.paused then return end
        if barObject.enabled then
            bar:Show()
            if barObject.cooldown==-1 then
                barObject:ChangeTime(GetTime()-barObject.last_update,false)
            elseif barObject.last_update>barObject.start_time then
                local _time,CD=GetSpellCooldown(barObject.cooldown)
                barObject:ChangeTime(CD-(GetTime()-_time),true)
            end
            barObject.last_update=GetTime()
            local et=barObject.end_time-barObject.current_time
            t4:SetText(ClassHelper:FormatTime(math.ceil(et*10)/10))
            local st=barObject.current_time-barObject.start_time
            local tt=et+st
            t1:SetSize(1+((st/tt)*255),24)
            t2:SetSize(1+((st/tt)*255),24)
            st=st*2
            et=et*2
            if barObject.color then
                t1:SetColorTexture(barObject.color[1],barObject.color[2],barObject.color[3],barObject.color[4])
            else
                if st>tt then
                    t1:SetColorTexture(1,et/tt,0,1)
                else
                    t1:SetColorTexture(st/tt,1,0,1)
                end
            end
            if getn(barObject.events)>0 then
                for i=1,getn(barObject.events)do
                    if barObject.end_time-barObject.current_time<barObject.events[i][1]and not barObject.events[i][3]then
                        barObject.events[i][3]=true
                        barObject.events[i][2]()
                    end
                end
            end
            if barObject.current_time>=barObject.end_time then
                barObject:Stop()
            end
        end
    end
    function barObject:Pause()
        update()
        self.paused=true
        return self
    end
    C_Timer.NewTicker(0.05,update)
    update()
    tinsert(all_bars,barObject)
end
function ClassHelper:UnlockBars(toggle)
    if strlower(toggle)=="reset"then
        self:Print("Resetting bar positions.")
        barAnchor:ClearAllPoints()
        barAnchor:SetPoint("CENTER",-10,-212)
        self:SaveFrame(barAnchor,"Timer_Bars","Bar_Anchor")
        return
    end
    local b=self:TextToBool(toggle)
    if b==0 then
        bars_unlocked=false
    elseif b==1 then
        bars_unlocked=true
    elseif bars_unlocked then
        bars_unlocked=false
    else
        bars_unlocked=true
    end
    if bars_unlocked then
        self:Print("Bar anchors are now \124cffff0000UNLOCKED")
        barAnchor:Show()
    else
        self:Print("Bar anchors are now \124cff00ff00LOCKED")
        barAnchor:Hide()
    end
    barAnchor:EnableMouse(bars_unlocked)
end
function ClassHelper:RePositionBars(index)
    if index<=getn(all_bars)then
        for i=1,getn(all_bars)do
            if all_bars[i].idx>=index then
                all_bars[i]:MoveToBarPosition(all_bars[i].idx-1)
            end
        end
    end
end
function ClassHelper:DeleteBar(name)
    self:NewBar(0,name):Stop()
end
function ClassHelper:NewBar(_time,text,cooldown)
    if getn(all_bars)>0 then
        local barObject="none"
        for i=1,getn(all_bars)do
            if all_bars[i].text==text or not all_bars[i].enabled then
                if barObject=="none"or all_bars[i].idx<barObject.idx then
                    if not all_bars[i].reserved then
                        barObject=all_bars[i]
                    end
                end
            end
        end
        if barObject~="none"then
            barObject:Start(_time,text,cooldown)
            return barObject
        end
    end
    createBar()
    all_bars[getn(all_bars)]:Start(_time,text,cooldown)
    return all_bars[getn(all_bars)]
end
function ClassHelper:Slash_NewBar(args)
    local a1=strsplit(" ",args)
    local a2=strsub(args,strlen(a1)+2,strlen(args))
    self:NewBar(a1,a2)
end
ClassHelper:CreateSlashCommand("newbar","ClassHelper:Slash_NewBar(arguments)","/ch newbar <time> <text>: Creates a timer bar for the specified duration.",{"More bar options can be programmed with the in-game interface."})
ClassHelper:CreateSlashCommand("bar-anchors","ClassHelper:UnlockBars(arguments)","/ch bar-anchors <on/off>: Toggles bar anchors so you can reposition them.")
local f=CreateFrame("FRAME")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
local function handle(self,event,...)
    local pos=ClassHelper:LoadFrame("Timer_Bars","Bar_Anchor")
    if pos then
        if pos[2]then
            pos[2]=_G[pos[2]]
        end
        barAnchor:SetPoint(pos[1],pos[2],pos[3],pos[4],pos[5])
    end
end
f:SetScript("OnEvent",handle)