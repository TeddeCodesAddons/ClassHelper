ClassHelper.lit_spells={

}
ClassHelper.lit_spell_ids={
    
}
function ClassHelper:LightUpSpell(spell)
    if not tContains(self.lit_spell_ids,spell)then
        if tonumber(spell)then
            tinsert(self.lit_spell_ids,spell)
        elseif GetSpellInfo(spell)then
            local s=select(7,GetSpellInfo(spell))
            if not tContains(self.lit_spell_ids,s)then
                tinsert(self.lit_spell_ids,s)
            end
        end
    end
    if tonumber(spell)then
        local b=self:SearchActionBar(tonumber(spell),false)
        for i=1,getn(b)do
            ActionButton_ShowOverlayGlow(_G[b[i]])
            if not tContains(self.lit_spells,b[i])then
                tinsert(self.lit_spells,b[i])
            end
        end
    else
        local b=self:SearchActionBar(spell,true)
        for i=1,getn(b)do
            ActionButton_ShowOverlayGlow(_G[b[i]])
            if not tContains(self.lit_spells,b[i])then
                tinsert(self.lit_spells,b[i])
            end
        end
    end
end
function ClassHelper:UnLightUpSpell(spell)
    local ididx=nil
    if tonumber(spell)then
        ididx=tIndexOf(self.lit_spell_ids,spell)
    elseif GetSpellInfo(spell)then
        local s=select(7,GetSpellInfo(spell))
        ididx=tIndexOf(self.lit_spell_ids,s)
    end
    if ididx then
        tremove(self.lit_spell_ids,ididx)
    end
    if tonumber(spell)then
        local b=self:SearchActionBar(tonumber(spell),false)
        for i=1,getn(b)do
            ActionButton_HideOverlayGlow(_G[b[i]])
            local idx=tIndexOf(self.lit_spells,b[i])
            if idx then
                tremove(self.lit_spells,idx)
            end
        end
    else
        local b=self:SearchActionBar(spell,true)
        for i=1,getn(b)do
            ActionButton_HideOverlayGlow(_G[b[i]])
            local idx=tIndexOf(self.lit_spells,b[i])
            if idx then
                tremove(self.lit_spells,idx)
            end
        end
    end
end
function ClassHelper:SearchActionBar(id,convertToId)
    if convertToId then
        id=select(7,GetSpellInfo(id))
    end
    local r={

    }
    local l={
        "ActionButton",
        "MultiBarBottomLeftButton",
        "MultiBarBottomRightButton",
        "MultiBarLeftButton",
        "MultiBarRightButton"
    }
    for n=1,getn(l)do
        local p=l[n]
        for i=1,12 do
            if _G[p..i]then
                if _G[p..i].action then
                    if GetActionInfo(_G[p..i].action)then
                        local t,s=GetActionInfo(_G[p..i].action)
                        if t=="spell"and s==id then
                            tinsert(r,p..i)
                        elseif t=="macro"then
                            s=GetMacroSpell(s)
                            if s then
                                s=select(7,GetSpellInfo(s))
                                if s and s==id then
                                    tinsert(r,p..i)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return r
end
local f=CreateFrame("FRAME")
f:RegisterEvent("ACTIONBAR_HIDEGRID")
f:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
f:RegisterEvent("ACTIONBAR_SHOWGRID")
f:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
f:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
f:RegisterEvent("ACTIONBAR_UPDATE_STATE")
f:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
f:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
f:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
f:RegisterEvent("SPELL_DATA_LOAD_RESULT")
local function updateBar()
    local l={
        "ActionButton",
        "MultiBarBottomLeftButton",
        "MultiBarBottomRightButton",
        "MultiBarLeftButton",
        "MultiBarRightButton"
    }
    for n=1,getn(l)do
        local p=l[n]
        for i=1,12 do
            if _G[p..i]then
                if _G[p..i].action then
                    if GetActionInfo(_G[p..i].action)then
                        local t,s=GetActionInfo(_G[p..i].action)
                        if t=="spell"and s then
                            if tContains(ClassHelper.lit_spell_ids,s)then
                                ActionButton_ShowOverlayGlow(_G[p..i])
                                if not tContains(ClassHelper.lit_spells,p..i)then
                                    tinsert(ClassHelper.lit_spells,p..i)
                                end
                            elseif tContains(ClassHelper.lit_spells,p..i)then
                                ActionButton_HideOverlayGlow(_G[p..i])
                                local idx=tIndexOf(ClassHelper.lit_spells,p..i)
                                tremove(ClassHelper.lit_spells,idx)
                            end
                        elseif t=="macro"and s then
                            s=GetMacroSpell(s)
                            if s then
                                s=select(7,GetSpellInfo(s))
                                if s and tContains(ClassHelper.lit_spell_ids,s)then
                                    ActionButton_ShowOverlayGlow(_G[p..i])
                                    if not tContains(ClassHelper.lit_spells,p..i)then
                                        tinsert(ClassHelper.lit_spells,p..i)
                                    end
                                elseif s and tContains(ClassHelper.lit_spells,p..i)then
                                    ActionButton_HideOverlayGlow(_G[p..i])
                                    local idx=tIndexOf(ClassHelper.lit_spells,p..i)
                                    tremove(ClassHelper.lit_spells,idx)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
f:SetScript("OnEvent",updateBar)
GameTooltip:HookScript("OnTooltipSetSpell",updateBar) -- Why couldn't blizz add an event for this?
function ClassHelper:FlashSpell(spell)
    local b={
        
    }
    if tonumber(spell)then
        b=self:SearchActionBar(tonumber(spell),false)
    else
        b=self:SearchActionBar(spell,true)
    end
    if getn(b)==0 then return end
    for i=1,getn(b)do
        local t=_G[b[i]].CH_FlashFrame
        if not t then local f=CreateFrame("FRAME",nil,_G[b[i]])f:SetPoint("CENTER")f:SetSize(1,1)t=f:CreateTexture(nil,"OVERLAY")_G[b[i]].CH_FlashFrame=t end
        t:SetTexture(_G[b[i]].icon:GetTexture())
        t:SetPoint("CENTER")
        local L,W=_G[b[i]]:GetSize()
        local function flash(alpha)
            t:SetSize(L*(101-alpha)/50,W*(101-alpha)/50)
            t:SetAlpha(alpha/100)
            if alpha>0 then
                C_Timer.NewTimer(0.02,function()flash(alpha-5)end)
            else
                t:Hide()
            end
        end
        flash(100)
        t:Show()
    end
end