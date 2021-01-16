function ClassHelper:NewIconFrame(parent)
    parent=parent or UIParent
    local cd=CreateFrame("FRAME",nil,parent)
    cd:SetPoint("CENTER")
    cd:SetSize(50,50)
    cd:SetScale(2)
    local f=CreateFrame("Cooldown",nil,cd,"CooldownFrameTemplate")
    f:SetDrawEdge(false)
    f:SetSize(50,50)
    f:SetPoint("CENTER")
    f:SetHideCountdownNumbers(true)
    local t1=cd:CreateFontString(nil,"OVERLAY")
    t1:SetFontObject(GameFontNormal)
    t1:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-5,5)
    t1:SetTextColor(1,1,1,1)
    t1:SetText("")
    t1:SetScale(1)
    local t2=cd:CreateFontString(nil,"OVERLAY")
    t2:SetFontObject(GameFontNormal)
    t2:SetPoint("CENTER",f,"CENTER",0,0)
    t2:SetTextColor(1,1,1,1)
    t2:SetText("")
    t2:SetScale(1)
    local debuff=cd:CreateTexture(nil,"ARTWORK")
    debuff:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    debuff:SetSize(50,50)
    debuff:SetPoint("CENTER")
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
            t2:SetText(ClassHelper:FormatTime(d))
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
    function obj:SetStacks(stacks)
        if stacks>1 then
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
        size_=size
        return self
    end
    function obj:SetAlpha(...)
        cd:SetAlpha(...)
        return self
    end
    function obj:Glow()
        ActionButton_ShowOverlayGlow(cd)
        return self
    end
    function obj:UnGlow()
        ActionButton_HideOverlayGlow(cd)
        return self
    end
    return obj:Show()
end