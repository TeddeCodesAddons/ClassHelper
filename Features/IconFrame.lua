function ClassHelper:NewIconFrame(parent)
    parent=parent or UIParent
    local cd=CreateFrame("FRAME",nil,parent)
    cd:SetPoint("CENTER")
    cd:SetSize(50,50)
    cd:SetScale(2)
    cd:SetFrameLevel(9999) -- Frontmost - 1
    local f=CreateFrame("Cooldown",nil,cd,"CooldownFrameTemplate")
    f:SetDrawEdge(false)
    f:SetSize(50,50)
    f:SetPoint("CENTER")
    f:SetHideCountdownNumbers(true)
    f:SetFrameLevel(10000) -- Frontmost
    local t1=f:CreateFontString(nil,"OVERLAY")
    t1:SetFontObject(GameFontNormal)
    t1:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-5,5)
    t1:SetTextColor(1,1,1,1)
    t1:SetText("")
    t1:SetScale(1)
    local t2=f:CreateFontString(nil,"OVERLAY")
    t2:SetFontObject(GameFontNormal)
    t2:SetPoint("CENTER",f,"CENTER",0,0)
    t2:SetTextColor(1,1,1,1)
    t2:SetText("")
    t2:SetScale(1)
    local debuff=cd:CreateTexture(nil,"ARTWORK")
    debuff:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    debuff:SetSize(50,50)
    debuff:SetPoint("CENTER")
    local border=cd:CreateTexture(nil,"BORDER")
    border:SetColorTexture(1,0,0,1)
    border:SetSize(53,53)
    border:SetPoint("CENTER")
    border:Hide()
    local size_=50
    local obj={

    }
    function obj:SetIcon(...)
        debuff:SetTexture(...)
        return self
    end
    local durationTable={

    }
    local function setDuration(start,duration,r,g,b,a)
        if not(start and duration)then return end
        f:SetCooldown(start,duration)
        if duration then
            local d=math.floor((duration-(GetTime()-start))*10)/10
            if d>=10 then
                d=math.floor(d)
            end
            local dur=d
            if d>=60 then
                dur=ClassHelper:FormatTime(d)
            end
            t2:SetText(dur)
            if d<=5 then
                t2:SetTextColor(1,0,0,1)
                t2:SetScale(1.25*(size_/50))
            elseif d<10 then
                t2:SetTextColor(1,1,0,1)
                t2:SetScale(1*(size_/50))
            else
                t2:SetTextColor(1,1,1,1)
                t2:SetScale(0.9*(size_/50))
            end
            if d<=0 then
                t2:SetText("")
            end
        end
        if r and g and b then
            t2:SetTextColor(r,g,b,a)
        end
    end
    C_Timer.NewTicker(0.05,function()setDuration(unpack(durationTable))end)
    function obj:SetDuration(...)
        durationTable={...}
        return self
    end
    function obj:Show()
        cd:Show()
        t1:Show()
        t2:Show()
        return self
    end
    function obj:Hide()
        cd:Hide()
        t1:Hide()
        t2:Hide()
        return self
    end
    function obj:IsShown()
        return cd:IsShown()
    end
    function obj:SetStacks(stacks)
        if type(stacks)~="number"or stacks>1 then
            t1:SetText(stacks)
        else
            t1:SetText("")
        end
        return self
    end
    function obj:SetPoint(...)
        cd:SetPoint(...)
        return self
    end
    function obj:SetSize(size)
        cd:SetSize(size,size)
        f:SetSize(size,size)
        debuff:SetSize(size,size)
        t1:SetScale(size/50)
        t2:SetScale(size/50)
        border:SetSize(size+3,size+3)
        size_=size
        return self
    end
    function obj:SetAlpha(...)
        cd:SetAlpha(...)
        return self
    end
    function obj:Glow(r,g,b,a)
        ClassHelper:GlowFrame(cd,{r,g,b,a})
        return self
    end
    function obj:UnGlow()
        ClassHelper:UnGlowFrame(cd)
        return self
    end
    function obj:SetGlowColor(r,g,b,a)
        ClassHelper:SetGlowFrameColor(cd,{r,g,b,a})
    end
    local isShaking=false
    local function shake()
        if not isShaking then return end
        local x=math.random(-1.5,1.5)
        local y=math.random(-1.5,1.5)
        f:SetPoint("CENTER",x,y)
        debuff:SetPoint("CENTER",x,y)
        C_Timer.NewTimer(0.02,shake)
    end
    function obj:Shake()
        isShaking=not isShaking
        if isShaking then
            C_Timer.NewTimer(0.02,shake)
        else
            f:SetPoint("CENTER",0,0)
            t2:SetPoint("CENTER",0,0)
            debuff:SetPoint("CENTER",0,0)
        end
        return self
    end
    function obj:IsShaking()
        return isShaking
    end
    function obj:SetBorder(...)
        local a=...
        if not a then
            border:Hide()
            return self
        end
        border:SetColorTexture(...)
        border:Show()
        return self
    end
    return obj:Show()
end