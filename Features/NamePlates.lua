local numNamePlates=0
local names={

}
local function getNamePlate(u)
    if numNamePlates>0 then
        for i=1,numNamePlates do
            if _G["NamePlate"..i].UnitFrame and _G["NamePlate"..i].UnitFrame.BuffFrame.unit=="nameplate"..u then
                return _G["NamePlate"..i]
            end
        end
    end
end
function ClassHelper:NewFrameOnNameplate(guid,frameId)
    local np=self:GetNameplate(guid)
    if not np then return end
    local c={np:GetChildren()}
    if c then
        for _,v in pairs(c)do
            if v.CH_fid and v:CH_fid()==frameId then
                return v
            end
        end
    end
    local f=CreateFrame("FRAME",nil,np)
    f.CH_fid=function()return frameId end
    f:SetPoint("CENTER")
    f:SetSize(1,1)
    return f
end
function ClassHelper:GetNameplate(guid)
    if names[guid]then
        local v={names[guid]:GetChildren()}
        for i=1,getn(v)do
            if v[i]and v[i].GetGUID and v[i]:GetGUID()==guid then
                v[i]:Show()
                if v[i] and v[i].IsRunningHideFunc then
                    if not v[i]:IsRunningHideFunc()then
                        v[i].IsRunningHideFunc=function()
                            return true
                        end
                    end
                else
                    v[i].IsRunningHideFunc=function()
                        return true
                    end
                end
                return v[i]
            end
        end
        local f=CreateFrame("FRAME",nil,names[guid])
        f:SetSize(1,1)
        f:SetPoint("CENTER")
        local function hideFunc()
            if f and f.IsRunningHideFunc and f:IsRunningHideFunc()then
                if not(names[guid]and names[guid].UnitFrame and UnitGUID(names[guid].UnitFrame.BuffFrame.unit)and UnitGUID(names[guid].UnitFrame.BuffFrame.unit)==guid)then
                    function f:IsRunningHideFunc()
                        return false
                    end
                    f:Hide()
                end
            end
        end
        function f:IsRunningHideFunc()
            return true
        end
        f.GetGUID=function()return guid end
        C_Timer.NewTicker(0.02,hideFunc)
        return f
    else
        return nil
    end
end
local function updateNamePlates()
    names={

    }
    local i=1
    while _G["NamePlate"..i]do
        i=i+1
    end
    if NamePlate1 then
        numNamePlates=i-1
    end
    if numNamePlates>0 then
        for i=1,numNamePlates do
            if UnitGUID("nameplate"..i)then
                names[UnitGUID("nameplate"..i)]=getNamePlate(i)
            end
        end
    end
end
local f=CreateFrame("FRAME")
f:RegisterEvent("NAME_PLATE_CREATED")
f:RegisterEvent("FORBIDDEN_NAME_PLATE_CREATED")
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED")
f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
f:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_REMOVED")
f:SetScript("OnEvent",updateNamePlates)