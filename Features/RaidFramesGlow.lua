-- -- [Basic raidframes example]
-- -- This will light up frames when their health is <50%.
-- local function func(t)
--     for i=1,getn(t)do
--         local f=t[i]
--         if f.hp.percent<50 then
--             if not f:IsGlowing()then
--                 f:Glow()
--             end
--         else
--             f:UnGlow()
--         end
--     end
-- end
-- ClassHelper:SetRaidFrameGlowFunction(func)
local raidframes_ticker=nil
function ClassHelper:SetRaidFrameGlowFunction(func)
    raidframes_ticker=func
end
local raidframeglows={
    
}
local unglow={

}
local function update()
    if not ClassHelper.is_healer then return end
    local tbl={

    }
    local i=1
    while _G["CompactRaidFrame"..i]do
        local u=_G["CompactRaidFrame"..i].unit
        if raidframeglows[i]==nil then
            raidframeglows[i]=false
        end
        local n=i
        local obj={
            hp={
                current=UnitHealth(u),
                max=UnitHealthMax(u),
                absorb=UnitGetTotalAbsorbs(u),
                healabsorb=UnitGetTotalHealAbsorbs(u),
                percent=100*UnitHealth(u)/UnitHealthMax(u)
            },
            unit=u
        }
        function obj:Glow()
            ActionButton_ShowOverlayGlow(_G["CompactRaidFrame"..i])
            local idx=tIndexOf(unglow,n)
            tremove(unglow,idx)
            raidframeglows[n]=true
        end
        function obj:UnGlow()
            tinsert(unglow,n)
            raidframeglows[n]=false
        end
        function obj:IsGlowing()
            return raidframeglows[n]
        end
        tinsert(tbl,obj)
        i=i+1
    end
    if raidframes_ticker then
        raidframes_ticker(tbl)
    else
        while _G["CompactRaidFrame"..i]do
            ActionButton_HideOverlayGlow(_G["CompactRaidFrame"..i])
        end
        unglow={

        }
        raidframeglows={
            
        }
    end
    for i=1,getn(unglow)do
        ActionButton_HideOverlayGlow(_G["CompactRaidFrame"..i])
    end
end
C_Timer.NewTicker(0.05,update)