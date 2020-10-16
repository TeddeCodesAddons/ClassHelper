ClassHelper.lit_spells={

}
function ClassHelper:LightUpSpell(spell)
    if tonumber(spell)then
        local b=self:SearchActionBar(tonumber(spell),false)
        for i=1,getn(b)do
            ActionButton_ShowOverlayGlow(_G[b[i]])
            tinsert(self.lit_spells,b[i])
        end
    else
        local b=self:SearchActionBar(spell,true)
        for i=1,getn(b)do
            ActionButton_ShowOverlayGlow(_G[b[i]])
            tinsert(self.lit_spells,b[i])
        end
    end
end
function ClassHelper:UnLightUpSpell(spell)
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
                        end
                    end
                end
            end
        end
    end
    return r
end