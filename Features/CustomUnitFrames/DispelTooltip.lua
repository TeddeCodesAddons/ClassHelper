ClassHelper.dispelTooltipLoaded=true -- Show that this file was loaded...
ClassHelper.colorDispels=true -- For now...
if not ClassHelper.dispelBlacklist then
    ClassHelper.dispelBlacklist={

    }
end
local dispelTooltipData={

}
function ClassHelper:SetDispelTooltipData(data)
    if data=="#disabled"then
        dispelTooltipData={

        }
        return
    end
    local d={strsplit("\n",data)}
    for i=1,getn(d)do
        local idx,val=strsplit(";",d[i])
        if idx then
            if val then
                if strlen(val)<8 then
                    val="ff"..val
                end
                dispelTooltipData[idx]=val
            else
                dispelTooltipData[idx]="ffffffff"
            end
        end
    end
end
local function GetDispelCooldown(effectType)
    for i,v in pairs(ClassHelper.DISPEL_ABILITY)do
        if ClassHelper.util:GetCooldown(i)==0 and not tContains(ClassHelper.dispelBlacklist,i)then -- Since 9.0, you can call GetSpellCooldown() on a string.
            if tContains(v,effectType)then
                return true
            end
        end
    end
    return false
end
local function IsDispelOffCooldown(effects)
    for i=1,getn(effects)do
        if GetDispelCooldown(strupper(effects[i][5]or ""))then
            return true
        end
    end
    return false
end
local funcs={
    ["arena"]=IsActiveBattlefieldArena,
    ["warmode"]=C_PvP.IsWarModeDesired,
    ["battleground"]=function()return not not UnitInBattleground("player")end, -- Prevents "nil~=false" from outputting false
    ["pvp"]=function()return not not(IsActiveBattlefieldArena()or UnitInBattleground("player"))end,
    ["pvporwarmode"]=function()return not not(IsActiveBattlefieldArena()or UnitInBattleground("player")or C_PvP.IsWarModeDesired())end,
    ["instance"]=IsInInstance,
    ["raid"]=IsInRaid,
    ["party"]=function()return IsInGroup()and(not IsInRaid())end,
    ["group"]=IsInGroup,
    ["always"]=function()return true end,
    ["cooldown"]=IsDispelOffCooldown
}
local dispelTooltipConditions={

}
function ClassHelper:SetDispelTooltipConditions(conditions)
    if conditions=="#disabled"then
        dispelTooltipConditions={
            [1]={"always",false}
        }
        return
    end
    local c={strsplit("\n",conditions)}
    for i=1,getn(c)do
        local term,enabled=strsplit(":",c[i])
        if strsub(enabled,1,1)==" "then
            enabled=strsub(enabled,2)
        end
        if enabled then
            if self:TextToBool(enabled)==1 then
                enabled=true
            else
                enabled=false
            end
        else
            enabled=true
        end
        if term and funcs[term]then
            tinsert(dispelTooltipConditions,{term,enabled})
        elseif term then
            if strsub(term,1,1)=="!"and funcs[strsub(term,2)]then
                tinsert(dispelTooltipConditions,{term,enabled})
            else
                self:Print("\124cffff0000Error: Unknown condition for dispel tooltip: "..term)
            end
        end
    end
end
local function getData(t,a)
    if not(funcs[t]or funcs[strsub(t,2)])then
        return false
    end
    if not a then
        return funcs[t]()
    end
    return funcs[t](a)
end
local function canShowTooltip(effects)
    for x=1,getn(dispelTooltipConditions)do
        local i,v=unpack(dispelTooltipConditions[x])
        local inv=false
        if strsub(i,1,1)=="!"then
            i=strsub(i,2)
            inv=true
        end
        if i=="cooldown"then
            if getData("cooldown",effects)~=inv then
                return v
            end
        elseif getData(i)~=inv then -- Basic XOR for the inversed output
            return v
        end
    end
    return false
end
local function anchorToMouse(f)
	local x,y=GetCursorPosition()
	local s=f:GetEffectiveScale()
	f:ClearAllPoints()
	f:SetPoint("BOTTOMRIGHT",UIParent,"BOTTOMLEFT",x/s,y/s)
end
local tooltip=CreateFrame("FRAME",nil,UIParent)
tooltip:SetSize(94,18)
tooltip:SetScale(1)
tooltip:SetPoint("CENTER",UIParent,"CENTER",0,0)
tooltip:SetFrameStrata("TOOLTIP")
tooltip:SetFrameLevel(10000)
C_Timer.NewTicker(0,function() -- Run on every frame
    anchorToMouse(tooltip)
end)
local tex=tooltip:CreateTexture(nil,"BACKGROUND")
tex:SetColorTexture(0.05,0.05,0.05,0.8)
tex:SetPoint("BOTTOMRIGHT",tooltip,"BOTTOMRIGHT",0,0)
tex:SetSize(94,18)
local fontStringTable={

}
local function newFontString(idx)
    local fs=tooltip:CreateFontString(nil,"OVERLAY")
    fs:SetPoint("BOTTOMRIGHT",tooltip,"BOTTOMRIGHT",-3,(idx-0.8)*15)
    fs:SetFontObject(GameFontNormal)
    fs:SetTextColor(1,1,1,1)
    fs:SetText("")
    fs:SetScale(1)
    return fs
end
local function addFontStrings(t) -- Add the FontStrings to the tooltip.
    local i=1
    local m=94
    local n=getn(t)
    local g=getn(fontStringTable)
    while i<=n do
        if i>g then
            tinsert(fontStringTable,newFontString(i))
        end
        fontStringTable[i]:SetText(t[i])
        fontStringTable[i]:Show()
        local w=fontStringTable[i]:GetStringWidth()
        if w and w>m then
            m=w
        end
        i=i+1
    end
    while i<=g do
        fontStringTable[i]:Hide()
        i=i+1
    end
    if n>0 then
        tex:SetSize(m+6,(n*15)+3)
        tooltip:Show()
    else
        tooltip:Hide()
    end
end
local tooltipShown=0
local colors={
    ["Curse"]="ffa000ff",
    ["Disease"]="ffa06600",
    ["Magic"]="ff3399ff",
    ["Poison"]="ff009900"
}
function ClassHelper:ShowDispelTooltip(a)
    tooltipShown=GetTime()
    local s={

    }
    if canShowTooltip(a)then
        for i=1,getn(a)do
            local aura=a[i][1]
            local dispelType=a[i][5]
            if dispelTooltipData[aura]then
                tinsert(s,"\124c"..dispelTooltipData[aura]..aura.."\124r")
            elseif self.colorDispels and dispelType and colors[dispelType]then
                tinsert(s,"\124c"..colors[dispelType]..aura.."\124r")
            elseif dispelType then
                tinsert(s,"\124cffffffff"..aura.."\124r")
            end
        end
    end
    addFontStrings(s) -- If the tooltip can't be shown, still show an empty table because we need to hide the FontStrings in case it WAS enabled before.
end
function ClassHelper:HideDispelTooltip()
    if GetTime()-tooltipShown>0.05 then
        tooltip:Hide()
    end
end