function ClassHelper:NewWarningText(text,size,maxX,x,y,pt,r,g,b,a,...)
    local f=CreateFrame("FRAME",nil,UIParent)
    if maxX then
        f:SetSize(maxX,32)
    else
        f:SetSize(200,32)
    end
    if x and y and pt then
        f:SetPoint(pt,x,y,UIParent)
    else
        f:SetPoint("CENTER",0,0,UIParent)
    end
    local t1=f:CreateFontString(nil,"ARTWORK")
    t1:SetPoint("CENTER",f,"CENTER",0,0)
    t1:SetTextColor(1,1,1,0)
    t1:SetFont("Fonts\\FRIZQT__.TTF",10,...)
    t1:SetText(text)
    local t2=f:CreateFontString(nil,"OVERLAY")
    t2:SetPoint("CENTER",f,"CENTER",0,0)
    t2:SetFont("Fonts\\FRIZQT__.TTF",10,...)
    t2:SetTextColor(1,1,1,0)
    t2:SetText(text)
    t2:Hide()
    if not size then size=1 end
    t1:SetScale(size*2)
    t2:SetScale(size*2)
    if maxX then
        t1:SetSize(maxX,32)
        t2:SetSize(maxX,32)
    else
        t1:SetSize(200,32)
        t2:SetSize(200,32)
    end
    local textObj={
        text=text,
        size=size,
        width=maxX,
        frame=f
    }
    if r and g and b and a then
        t1:SetTextColor(r,g,b,a)
    elseif r and g and b then
        t1:SetTextColor(r,g,b,1)
    else
        t1:SetTextColor(1,1,1,1)
    end
    function textObj:SetPoint(...)
        f:SetPoint(...)
        return self
    end
    function textObj:SetSize(size)
        t1:SetScale(size*2)
        t2:SetScale(size*2)
        self.size=size
        return self
    end
    function textObj:SetWidth(width)
        f:SetSize(width,32)
        t1:SetWidth(width)
        t2:SetWidth(width)
        self.width=width
        return self
    end
    function textObj:SetColor(r,g,b,a)
        if r and g and b and a then
            t1:SetTextColor(r,g,b,a)
        elseif r and g and b then
            t1:SetTextColor(r,g,b,1)
        else
            t1:SetTextColor(1,1,1,1)
        end
        return self
    end
    function textObj:SetText(text)
        self.text=text
        t1:SetText(text)
        t2:SetText(text)
        return self
    end
    local isFlashing=false
    local isFlashing2=false
    local function updateFlash(a,inc)
        t2:SetTextColor(1,1,1,a/100)
        if a>=100 then
            inc=-5
        elseif a<=0 then
            inc=5
        end
        if t2:IsShown()then
            C_Timer.NewTimer(0.02,function()updateFlash(a+inc,inc)end)
        else
            isFlashing2=false
        end
    end
    function textObj:Flash()
        if not t1:IsShown()then
            return self
        end
        if t2:IsShown()then
            t2:Hide()
            isFlashing=false
        else
            isFlashing=true
            isFlashing2=true
            t2:Show()
            t2:SetTextColor(1,1,1,0)
            C_Timer.NewTimer(0.02,function()updateFlash(0,5)end)
        end
        return self
    end
    local isShaking=false
    local function shake()
        if not isShaking then return end
        local s=t1:GetScale()*100
        local x=math.random(-150,150)/s
        local y=math.random(-150,150)/s
        t1:SetPoint("CENTER",x,y)
        t2:SetPoint("CENTER",x,y)
        C_Timer.NewTimer(0.02,shake)
    end
    function textObj:Shake()
        isShaking=not isShaking
        if isShaking then
            C_Timer.NewTimer(0.02,shake)
        else
            t1:SetPoint("CENTER",0,0)
            t2:SetPoint("CENTER",0,0)
        end
        return self
    end
    function textObj:IsShaking()
        return isShaking
    end
    function textObj:IsFlashing()
        return isFlashing
    end
    function textObj:Hide()
        t1:Hide()
        t2:Hide()
        return self
    end
    function textObj:Show()
        t1:Show()
        if isFlashing and not isFlashing2 then
            isFlashing2=true
            t2:Show()
            C_Timer.NewTimer(0.02,function()updateFlash(0,5)end)
        end
        return self
    end
    return textObj:Show()
end