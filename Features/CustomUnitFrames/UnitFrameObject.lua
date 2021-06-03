local HealComm
if WOW_PROJECT_ID==WOW_PROJECT_MAINLINE then
    isClassic=false
else
    isClassic=true
    HealComm=LibStub("LibHealComm-4.0")
end
local betaFeaturesEnabled=false -- !DEBUG
local unitFrames={

}
local secure_buttons={

}
local unithp={
    hp=UnitHealth,
    hpmax=UnitHealthMax,
    absorb=UnitGetTotalAbsorbs, -- HealComm will overwrite these functions in classic.
    healabsorb=UnitGetTotalHealAbsorbs,
    incomingheals=UnitGetIncomingHeals
}
local blacklist={
    buffs={

    },
    debuffs={

    },
    auras={

    }
}
local whitelist={
    buffs={

    },
    debuffs={

    },
    auras={

    },
    enabled=false
}
local priorityDebuffs={

}
local enabledElements={

}
local function isBuffBlacklisted(b)
    if tContains(blacklist.buffs,b)or tContains(blacklist.auras,b)then
        return true
    end
    if whitelist.enabled then
        if not(tContains(whitelist.buffs,b)or tContains(whitelist.auras,b))then
            return true
        end
    end
    return false
end
local function isDebuffBlacklisted(b)
    if tContains(blacklist.debuffs,b)or tContains(blacklist.auras,b)then
        return true
    end
    if whitelist.enabled then
        if not(tContains(whitelist.debuffs,b)or tContains(whitelist.auras,b))then
            return true
        end
    end
    return false
end
local function texturepath(n)
    return "Interface/AddOns/"..(ClassHelper.ADDON_PATH_NAME).."/Assets/RaidFrames/"..n..".blp"
end
local readyTable={

}
local function setReady(isReady)
    if not tContains(enabledElements,"ready")then
        isReady=-1
    end
    if isReady==1 then
        if IsInRaid()then
            for i=1,GetNumGroupMembers()do
                local s=GetReadyCheckStatus("raid"..i)
                if s=="ready"then
                    readyTable["raid"..i]:SetTexture(texturepath("READY"))
                elseif s=="notready"then
                    readyTable["raid"..i]:SetTexture(texturepath("NOT_READY"))
                end
            end
        else
            local s=GetReadyCheckStatus("player")
            if s=="ready"then
                readyTable["player"]:SetTexture(texturepath("READY"))
            elseif s=="notready"then
                readyTable["player"]:SetTexture(texturepath("NOT_READY"))
            end
            for i=1,GetNumGroupMembers()-1 do
                local s=GetReadyCheckStatus("party"..i)
                if s=="ready"then
                    readyTable["party"..i]:SetTexture(texturepath("READY"))
                elseif s=="notready"then
                    readyTable["party"..i]:SetTexture(texturepath("NOT_READY"))
                end
            end
        end
    elseif isReady==-1 then
        C_Timer.NewTimer(5,function()
            for i,v in pairs(readyTable)do
                v:Hide()
            end
        end)
    elseif isReady==2 then
        for i,v in pairs(readyTable)do
            v:SetTexture(texturepath("WAITING"))
            v:Show()
        end
    end
end
local anchor_background=CreateFrame("FRAME",nil,UIParent)
anchor_background:SetPoint("CENTER",0,0)
anchor_background:SetSize(GetScreenWidth(),GetScreenHeight())
local anchor=CreateFrame("FRAME",nil,anchor_background)
anchor:SetPoint("CENTER",-400,250)
anchor:SetSize(200,50)
ClassHelper_UnitFrameContainer=CreateFrame("FRAME",nil,anchor)
ClassHelper_UnitFrameContainer:SetSize(1600,500)
ClassHelper_UnitFrameContainer:SetPoint("TOPLEFT",anchor,"BOTTOMLEFT",0,0)
ClassHelper_UnitFrameContainer:SetScale(0.5)
anchor:RegisterForDrag("LeftButton")
anchor:SetMovable(true)
anchor:SetScript("OnDragStart",function(self)self:ClearAllPoints()self:StartMoving()end)
anchor:SetScript("OnDragStop",function(self)self:StopMovingOrSizing()ClassHelper:SaveFrame(self,"CustomUnitFrames","UnitFrameContainer")end)
anchor:EnableMouse(false)
local container_unlocked=false
function ClassHelper:UnlockCustomUnitFrames(toggle)
    if strlower(toggle)=="reset"then
        self:Print("Resetting unit frame positions.")
        anchor:ClearAllPoints()
        anchor:SetPoint("CENTER",-400,-250)
        self:SaveFrame(anchor,"CustomUnitFrames","UnitFrameContainer")
        return
    end
    local b=self:TextToBool(toggle)
    if b==0 then
        container_unlocked=false
    elseif b==1 then
        container_unlocked=true
    elseif container_unlocked then
        container_unlocked=false
    else
        container_unlocked=true
    end
    if container_unlocked then
        self:Print("Unit frame anchors are now \124cffff0000UNLOCKED")
    else
        self:Print("Unit frame anchors are now \124cff00ff00LOCKED")
        self:SaveFrame(anchor,"CustomUnitFrames","UnitFrameContainer")
    end
    anchor:EnableMouse(container_unlocked)
end
ClassHelper:CreateSlashCommand("unitframe-anchors","ClassHelper:UnlockCustomUnitFrames(arguments)","/ch unitframe-anchors <on/off>: Toggles unit frame anchors so you can reposition them.")
local t=ClassHelper_UnitFrameContainer:CreateTexture(nil,"BACKGROUND")
t:SetColorTexture(0.1,0.1,0.1,0.6)
t:SetPoint("BOTTOMLEFT",ClassHelper_UnitFrameContainer,"TOPLEFT",0,0)
t:SetSize(200,50)
local ufcTitle=ClassHelper_UnitFrameContainer:CreateFontString(nil,"OVERLAY")
ufcTitle:SetPoint("BOTTOMLEFT",ClassHelper_UnitFrameContainer,"TOPLEFT",10,10)
C_Timer.NewTicker(1,function()
    ufcTitle:SetText("Group ("..GetNumGroupMembers().." players)")
end)
ufcTitle:SetFontObject(GameFontNormal)
ufcTitle:SetTextColor(1,0.8,0,1)
ufcTitle:SetText("Group (? players)")
ufcTitle:SetScale(1.5)
local LOADED_VARS={
    framerate=60, -- 60 fps, can be changed in settings.
    buff_size=10,
    debuff_size=20,
    max_buffs=7,
    max_debuffs=4
}
local rowCounter=0
local columnCounter=0
ClassHelper.CLASS_DISPELS={
    
}
ClassHelper.DISPEL_ABILITY={}
local function newUnitFrame(unit)
    local isRaidFrame=false
    if strsub(unit,1,4)=="raid"then
        isRaidFrame=true
    end
    local buffSize=LOADED_VARS.buff_size
    local debuffSize=LOADED_VARS.debuff_size
    local f=CreateFrame("FRAME","ClassHelper_UnitFrame_"..unit,ClassHelper_UnitFrameContainer)
    local overlay=CreateFrame("FRAME",nil,ClassHelper_UnitFrameContainer)
    overlay:SetSize(200,100)
    f:SetSize(200,100)
    if isRaidFrame then
        f:SetFrameLevel(4)
        overlay:SetFrameLevel(6)
    else
        f:SetFrameLevel(1)
        overlay:SetFrameLevel(3)
    end
    if rowCounter<5 then
        f:SetPoint("TOPLEFT",ClassHelper_UnitFrameContainer,"TOPLEFT",200*columnCounter,-100*rowCounter)
        rowCounter=rowCounter+1
    else
        rowCounter=1
        columnCounter=columnCounter+1
        f:SetPoint("TOPLEFT",ClassHelper_UnitFrameContainer,"TOPLEFT",200*columnCounter,0)
    end
    overlay:SetAllPoints(f)
    local debuffs={
        
    }
    local buffs={

    }
    local numDebuffs=0
    local numBuffs=0
    local function newDebuffIcon(icon,start,duration,s)
        local cd=CreateFrame("FRAME",nil,f)
        cd:SetSize(debuffSize,debuffSize)
        cd:SetScale(2)
        if isRaidFrame then
            cd:SetFrameLevel(5)
        else
            cd:SetFrameLevel(2)
        end
        local pt=LOADED_VARS.debuffPoint
        if pt=="BOTTOMLEFT"or pt=="TOPLEFT"then
            cd:SetPoint(pt,numDebuffs*debuffSize,0)
        else
            cd:SetPoint(pt,numDebuffs*(0-debuffSize),0)
        end
        local f2=CreateFrame("Cooldown",nil,cd,"CooldownFrameTemplate")
        f2:SetDrawEdge(false)
        f2:SetSize(debuffSize,debuffSize)
        f2:SetPoint("CENTER")
        f2:SetCooldown(start,duration)
        f2:SetHideCountdownNumbers(true)
        local t1=cd:CreateFontString(nil,"OVERLAY")
        t1:SetFontObject(GameFontNormal)
        t1:SetPoint("BOTTOMRIGHT",f2,"BOTTOMRIGHT",0,0)
        t1:SetTextColor(1,1,1,1)
        t1:SetText("")
        t1:SetScale(0.75)
        local debuff=cd:CreateTexture(nil,"ARTWORK")
        debuff:SetTexture(icon)
        debuff:SetSize(debuffSize,debuffSize)
        debuff:SetPoint("CENTER")
        numDebuffs=numDebuffs+1
        local obj={
            isGlowing=false
        }
        function obj:SetTexture(...)
            debuff:SetTexture(...)
        end
        function obj:SetCooldown(...)
            f2:SetCooldown(...)
        end
        function obj:Show()
            cd:Show()
            t1:Show()
        end
        function obj:Hide()
            cd:Hide()
            t1:Hide()
        end
        function obj:SetStacks(stacks)
            if stacks>1 then
                t1:SetText(stacks)
            else
                t1:SetText("")
            end
        end
        function obj:SetPriority(isPriority,color)
            if isPriority and color[1]then
                if not self.isGlowing then
                    ClassHelper:GlowFrame(cd,color)
                    self.isGlowing=true
                end
                ClassHelper:SetGlowFrameColor(cd,color)
            else
                if self.isGlowing then
                    ClassHelper:UnGlowFrame(cd)
                    self.isGlowing=false
                end
            end
        end
        obj:SetStacks(s)
        tinsert(debuffs,obj)
        return obj -- Priority list needs object returned.
    end
    local function newBuffIcon(icon,start,duration,s)
        local cd=CreateFrame("FRAME",nil,f)
        cd:SetSize(buffSize,buffSize)
        cd:SetScale(3)
        if isRaidFrame then
            cd:SetFrameLevel(5)
        else
            cd:SetFrameLevel(2)
        end
        local pt=LOADED_VARS.buffPoint
        if pt=="BOTTOMLEFT"or pt=="TOPLEFT"then
            cd:SetPoint(pt,numBuffs*buffSize,0)
        else
            cd:SetPoint(pt,numBuffs*(0-buffSize),0)
        end
        local f2=CreateFrame("Cooldown",nil,cd,"CooldownFrameTemplate")
        f2:SetDrawEdge(false)
        f2:SetSize(buffSize,buffSize)
        f2:SetPoint("CENTER")
        f2:SetCooldown(start,duration)
        f2:SetHideCountdownNumbers(true)
        local t1=cd:CreateFontString(nil,"OVERLAY")
        t1:SetFontObject(GameFontNormal)
        t1:SetPoint("BOTTOMRIGHT",f2,"BOTTOMRIGHT",0,0)
        t1:SetTextColor(1,1,1,1)
        t1:SetText("")
        t1:SetScale(0.75)
        local buff=cd:CreateTexture(nil,"ARTWORK")
        buff:SetTexture(icon)
        buff:SetSize(buffSize,buffSize)
        buff:SetPoint("CENTER")
        numBuffs=numBuffs+1
        local obj={

        }
        function obj:SetTexture(...)
            buff:SetTexture(...)
        end
        function obj:SetCooldown(...)
            f2:SetCooldown(...)
        end
        function obj:Show()
            cd:Show()
            t1:Show()
        end
        function obj:Hide()
            cd:Hide()
            t1:Hide()
        end
        function obj:SetStacks(stacks)
            if stacks>1 then
                t1:SetText(stacks)
            else
                t1:SetText("")
            end
        end
        obj:SetStacks(s)
        tinsert(buffs,obj)
    end
    local b=CreateFrame("BUTTON","ClassHelper_SecureUnitFrame_"..unit,ClassHelper_UnitFrameContainer,"SecureUnitButtonTemplate,SecureHandlerStateTemplate")
    b:SetSize(200,100)
    b:SetPoint(f:GetPoint(1))
    if isRaidFrame then
        b:SetFrameLevel(2)
    else
        b:SetFrameLevel(1)
    end
    local back=f:CreateTexture(nil,"BACKGROUND")
    back:SetColorTexture(0.05,0.05,0.05,0.9)
    back:SetPoint("CENTER")
    back:SetSize(200,100)
    local health=f:CreateTexture(nil,"BORDER")
    health:SetColorTexture(0,1,0,1)
    health:SetPoint("LEFT")
    health:SetSize(200,100)
    local health2=f:CreateTexture(nil,"ARTWORK")
    health2:SetTexture(texturepath("HP_BAR"),true)
    health2:SetAlpha(0.8)
    health2:SetPoint("LEFT")
    health2:SetSize(200,100)
    local absorb2=f:CreateTexture(nil,"ARTWORK")
    absorb2:SetTexture(texturepath("SHIELD_FILL"),true)
    absorb2:SetSize(0,100)
    absorb2:Hide()
    local absorb=overlay:CreateTexture(nil,"BACKGROUND")
    absorb:SetTexture(texturepath("SHIELD"),true)
    absorb:SetPoint("LEFT",health,"RIGHT",0,0)
    absorb:SetSize(0,100)
    absorb:Hide()
    absorb2:SetAllPoints(absorb)
    local incoming=overlay:CreateTexture(nil,"BORDER")
    incoming:SetTexture(texturepath("HP_BAR"),true)
    incoming:SetAlpha(0.4)
    incoming:SetPoint("LEFT",health2,"RIGHT",0,0)
    incoming:SetSize(0,100)
    incoming:Hide()
    local incomingTable={
        incoming
    }
    local healabsorb=f:CreateTexture(nil,"ARTWORK")
    healabsorb:SetTexture(texturepath("HEALING_ABSORB"),true)
    healabsorb:SetPoint("RIGHT",health,"RIGHT",0,0)
    healabsorb:SetSize(0,100)
    healabsorb:Hide()
    local overhealingabsorb=overlay:CreateTexture(nil,"ARTWORK")
    overhealingabsorb:SetTexture(texturepath("ABSORB_OVER"),true)
    overhealingabsorb:SetPoint("LEFT",-5,0)
    overhealingabsorb:SetSize(0,100)
    overhealingabsorb:Hide()
    local overshield=overlay:CreateTexture(nil,"OVERLAY")
    overshield:SetTexture(texturepath("SHIELD_OVER"),true)
    overshield:SetPoint("RIGHT",5,0)
    overshield:SetSize(0,100)
    overshield:Hide()
    local t1=overlay:CreateFontString(nil,"ARTWORK")
    t1:SetFontObject(GameFontNormal)
    t1:SetPoint("CENTER")
    t1:SetTextColor(0.5,0.5,0.5,1)
    t1:SetText("100%")
    t1:SetScale(2)
    local t2=overlay:CreateFontString(nil,"ARTWORK")
    t2:SetFontObject(GameFontNormal)
    t2:SetPoint("TOPLEFT",3,-3)
    t2:SetTextColor(1,1,1,1)
    t2:SetText("Unknown")
    t2:SetScale(1.5)
    local debuffType1=overlay:CreateTexture(nil,"OVERLAY")
    debuffType1:SetTexture(texturepath("CURSE"),true)
    debuffType1:SetPoint("TOP",0,-20)
    debuffType1:SetSize(30,30)
    debuffType1:Hide()
    local debuffType2=overlay:CreateTexture(nil,"OVERLAY")
    debuffType2:SetTexture(texturepath("DISEASE"),true)
    debuffType2:SetPoint("TOP",0,-20)
    debuffType2:SetSize(30,30)
    debuffType2:Hide()
    local debuffType3=overlay:CreateTexture(nil,"OVERLAY")
    debuffType3:SetTexture(texturepath("MAGIC"),true)
    debuffType3:SetPoint("TOP",0,-20)
    debuffType3:SetSize(30,30)
    debuffType3:Hide()
    local debuffType4=overlay:CreateTexture(nil,"OVERLAY")
    debuffType4:SetTexture(texturepath("POISON"),true)
    debuffType4:SetPoint("TOP",0,-20)
    debuffType4:SetSize(30,30)
    debuffType4:Hide()
    local aggro=overlay:CreateTexture(nil,"ARTWORK")
    aggro:SetTexture(texturepath("AGGRO"),true)
    aggro:SetTexCoord(0,0.78125,0,0.390625)
    aggro:SetPoint("TOPLEFT",0,0)
    aggro:SetSize(200,100)
    aggro:Hide()
    local lowaggro=overlay:CreateTexture(nil,"ARTWORK")
    lowaggro:SetTexture(texturepath("LOWAGGRO"),true)
    lowaggro:SetTexCoord(0,0.78125,0,0.390625)
    lowaggro:SetPoint("TOPLEFT",0,0)
    lowaggro:SetSize(200,100)
    lowaggro:Hide()
    local selection=overlay:CreateTexture(nil,"OVERLAY")
    selection:SetTexture(texturepath("SELECTED"),true)
    selection:SetTexCoord(0,0.78125,0,0.390625) -- transform the 256x256 BLP to a 200x100 image
    selection:SetPoint("TOPLEFT",0,0)
    selection:SetSize(200,100)
    selection:Hide()
    local rangeindicator=overlay:CreateTexture(nil,"OVERLAY")
    rangeindicator:SetColorTexture(0.25,0.25,0.25,0.5)
    rangeindicator:SetSize(200,100)
    rangeindicator:SetPoint("TOPLEFT",0,0)
    rangeindicator:Hide()
    local roletexture=overlay:CreateTexture(nil,"OVERLAY")
    roletexture:SetTexture(texturepath("DAMAGER"),true)
    roletexture:SetPoint("TOPRIGHT",0,0)
    roletexture:SetSize(35,35)
    roletexture:Hide()
    local assisttexture=overlay:CreateTexture(nil,"OVERLAY")
    assisttexture:SetTexture(texturepath("LEADER"),true)
    assisttexture:SetPoint("TOPRIGHT",-35,0)
    assisttexture:SetSize(20,20)
    assisttexture:Hide()
    local resurrection=overlay:CreateTexture(nil,"OVERLAY")
    resurrection:SetTexture(texturepath("BREZ"),true)
    resurrection:SetPoint("CENTER",0,0)
    resurrection:SetSize(50,50)
    resurrection:Hide()
    local readycheck=overlay:CreateTexture(nil,"OVERLAY")
    readycheck:SetTexture(texturepath("WAITING"),true)
    readycheck:SetPoint("CENTER",0,0)
    readycheck:SetSize(45,45)
    readycheck:Hide()
    readyTable[unit]=readycheck
    local summoning=overlay:CreateTexture(nil,"OVERLAY")
    summoning:SetTexture(texturepath("SUMMON_PENDING"),true)
    summoning:SetPoint("CENTER",0,0)
    summoning:SetSize(50,50)
    summoning:Hide()
    local phased=overlay:CreateTexture(nil,"OVERLAY")
    phased:SetTexture(texturepath("PHASED"),true)
    phased:SetPoint("CENTER",0,0)
    phased:SetSize(50,50)
    phased:SetAlpha(0.75)
    phased:Hide()
    local phased2=overlay:CreateTexture(nil,"OVERLAY")
    phased2:SetTexture(texturepath("IN_INSTANCE"),true)
    phased2:SetPoint("CENTER",0,0)
    phased2:SetSize(50,50)
    phased2:Hide()
    local offline=overlay:CreateTexture(nil,"OVERLAY")
    offline:SetTexture(texturepath("OFFLINE"),true)
    offline:SetPoint("CENTER",0,0)
    offline:SetSize(128,128)
    offline:Hide()
    local dispellable=false
    local function registerDebuffs(debuffs)
        dispellable=false
        if getn(debuffs)>0 then
            for i=1,getn(debuffs)do
                if tContains(ClassHelper.CLASS_DISPELS,debuffs[i])then
                    dispellable=true
                end
            end
        end
        local x=getn(debuffs)
        if getn(debuffs)==0 then
            debuffType1:Hide()
            debuffType2:Hide()
            debuffType3:Hide()
            debuffType4:Hide()
            return
        end
        if getn(debuffs)>=1 then
            debuffType1:SetTexture(texturepath(debuffs[1]))
            debuffType1:Show()
        else
            debuffType1:Hide()
        end
        if getn(debuffs)>=2 then
            debuffType2:SetTexture(texturepath(debuffs[2]))
            debuffType2:Show()
        else
            debuffType2:Hide()
        end
        if getn(debuffs)>=3 then
            debuffType3:SetTexture(texturepath(debuffs[3]))
            debuffType3:Show()
        else
            debuffType3:Hide()
        end
        if getn(debuffs)>=4 then
            debuffType4:SetTexture(texturepath(debuffs[4]))
            debuffType4:Show()
        else
            debuffType4:Hide()
        end
        if getn(debuffs)==1 then
            debuffType1:SetPoint("TOP",0,-20)
        elseif getn(debuffs)==2 then
            debuffType1:SetPoint("TOP",-8,-20)
            debuffType2:SetPoint("TOP",8,-20)
        elseif getn(debuffs)==3 then
            debuffType1:SetPoint("TOP",-16,-20)
            debuffType2:SetPoint("TOP",0,-20)
            debuffType3:SetPoint("TOP",16,-20)
        elseif getn(debuffs)==4 then
            debuffType1:SetPoint("TOP",-24,-20)
            debuffType2:SetPoint("TOP",-8,-20)
            debuffType3:SetPoint("TOP",8,-20)
            debuffType4:SetPoint("TOP",24,-20)
        end
    end
    b:RegisterForClicks("AnyUp")
    b:SetAttribute("type1","target")
    b:SetAttribute("shift-type1","target")
    b:SetAttribute("alt-type1","target")
    b:SetAttribute("ctrl-type1","target")
    b:SetAttribute("ctrl-shift-type1","target")
    b:SetAttribute("alt-shift-type1","target")
    b:SetAttribute("alt-ctrl-type1","target")
    b:SetAttribute("alt-ctrl-shift-type1","target")
    b:SetAttribute("unit",unit)
    b:SetAttribute("type2","togglemenu")
    b:SetAttribute("shift-type2","target")
    b:SetAttribute("alt-type2","target")
    b:SetAttribute("ctrl-type2","target")
    b:SetAttribute("ctrl-shift-type2","target")
    b:SetAttribute("alt-shift-type2","target")
    b:SetAttribute("alt-ctrl-type2","target")
    b:SetAttribute("alt-ctrl-shift-type2","target")
    b.unit=unit -- For OmniCD and other AddOns that require obj.unit to be an attribute.
    tinsert(secure_buttons,b)
    if betaFeaturesEnabled then
        if isRaidFrame then
            RegisterUnitWatch(b)
        else -- Should fix the bug where ClassHelper_SecureUnitFrame_player never hides and causes it to glow in the background.
            RegisterStateDriver(b,"visibility","[@"..unit..",exists,noraid]show;[@"..unit..",noexists]hide;[raid]hide")
        end
    else
        RegisterUnitWatch(b)
    end
    local obj={
        unit=unit,
        colors={
            health={0,1,0,1},
            background={0.05,0.05,0.05,0.9}
        },
        health={
            current=1,
            max=1,
            absorb=1,
            healing_absorb=1
        },
        auras={
            buffs={
                
            },
            debuffs={

            }
        }
    }
    local incomingNum=0
    local amountHP=0
    local function displayInc(h,max_)
        if amountHP+h>max_ then
            h=max_-amountHP
        end
        amountHP=amountHP+h
        incomingNum=incomingNum+1
        local x=incomingTable[incomingNum]
        if not x then
            x=f:CreateTexture(nil,"BORDER")
            x:SetTexture(texturepath("HP_BAR"),true)
            x:SetAlpha(0.4)
            x:SetPoint("LEFT",incomingTable[getn(incomingTable)],"RIGHT",0,0)
            x:Hide()            
            incomingTable[incomingNum]=x
        end
        if h*200/max_>0 then
            x:SetSize(h*200/max_,100)
            x:Show()
        else
            x:Hide()
        end
    end
    local function getIncoming(max_,current)
        if isClassic then
            amountHP=current
            incomingNum=0
            local t={

            }
            local actualTotal=HealComm:GetHealAmount(UnitGUID(obj.unit),HealComm.ALL_HEALS)or 0 -- If it's classic, use HealComm.
            if actualTotal then
                displayInc(actualTotal,max_)
            end
            incomingNum=incomingNum+1
            while incomingNum<=getn(incomingTable)do
                if incomingTable[incomingNum]then
                    incomingTable[incomingNum]:Hide()
                end
                incomingNum=incomingNum+1
            end
        else
            amountHP=current
            incomingNum=0
            local t={

            }
            for i=1,GetNumGroupMembers()do
                local h=unithp.incomingheals(obj.unit,"raid"..i)
                if h and h>0 then
                    t[i]=h
                end
            end
            local total=0
            for i,v in pairs(t)do
                displayInc(v,max_)
                total=total+v
            end
            local actualTotal=unithp.incomingheals(obj.unit)
            if actualTotal then
                displayInc(actualTotal-total,max_)
            end
            incomingNum=incomingNum+1
            while incomingNum<=getn(incomingTable)do
                if incomingTable[incomingNum]then
                    incomingTable[incomingNum]:Hide()
                end
                incomingNum=incomingNum+1
            end
        end
    end
    local flashing={

    }
    local ticker=false
    function obj:Update()
        if IsInRaid()and not isRaidFrame then
            if not InCombatLockdown()then
                b:Hide()
            end
        end
        local u=self.unit
        if u and strsub(u,1,5)=="party"then -- Some old code to hide the frames, though the secure frames still show... Should be fixed now anyway
            if _G["ClassHelper_UnitFrame_raid"..strsub(u,6,6)]and _G["ClassHelper_UnitFrame_raid"..strsub(u,6,6)].IsShown and _G["ClassHelper_UnitFrame_raid"..strsub(u,6,6)]:IsShown()then
                f:Hide()
                overlay:Hide()
                return self
            end
        end
        if u and u=="player"and IsInRaid()then
            f:Hide()
            overlay:Hide()
            return self
        end
        if not UnitName(u)then
            f:Hide()
            overlay:Hide()
            return self
        end
        local phasedReason=UnitPhaseReason and UnitPhaseReason(u)
        if tContains(enabledElements,"phased")then
            if not phasedReason then
                phased:Hide()
            elseif phasedReason==0 then
                phased:Show()
            elseif phasedReason==1 then
                phased:Show()
            elseif phasedReason==2 then
                phased:Show()
            elseif phasedReason==3 then
                phased:Show()
            end
        else
            phased:Hide()
        end
        local otherParty=UnitInOtherParty(u)
        if tContains(enabledElements,"instancegroup")then
            if otherParty then
                phased2:Show()
            else
                phased2:Hide()
            end
        end
        local isOver=GetMouseFocus()==b -- MouseIsOver(b)
        if isOver then
            GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
            GameTooltip:SetUnit(u)
            if phasedReason==0 then
                GameTooltip:AddLine("\124cffff0000This player is in a different phase.")
            elseif phasedReason==1 then
                GameTooltip:AddLine("\124cffff0000This player is in a different shard.")
            elseif phasedReason==2 then
                GameTooltip:AddLine("\124cffff0000This player is in opposite war mode.")
            elseif phasedReason==3 then
                GameTooltip:AddLine("\124cffff0000This player is doing a timewalking campaign.")
            end
            if otherParty then
                GameTooltip:AddLine("\124cffff0000This player is in an instance group.")
            end
            GameTooltip:Show()
        end
            local brez=UnitHasIncomingResurrection(u)
            if brez and tContains(enabledElements,"brez")then
                resurrection:Show()
            else
                resurrection:Hide()
            end
        local threat=UnitThreatSituation(u)
        if UnitInRange(u)or u=="player"then
            rangeindicator:Hide()
        elseif tContains(enabledElements,"inrange")then
            rangeindicator:Show()
        else
            rangeindicator:Hide()
        end
        local role=UnitGroupRolesAssigned and UnitGroupRolesAssigned(u)
        if role and role~="NONE"and tContains(enabledElements,"role")then
            roletexture:SetTexture(texturepath(role),true)
            roletexture:Show()
        else
            roletexture:Hide()
        end
        local isAssist=UnitIsGroupAssistant(u)
        local isLead=UnitIsGroupLeader(u)
        if isLead then
            if tContains(enabledElements,"leader")then
                assisttexture:SetTexture(texturepath("LEADER"),true)
                assisttexture:Show()
            else
                assisttexture:Hide()
            end
        elseif isAssist then
            if tContains(enabledElements,"assist")then
                assisttexture:SetTexture(texturepath("ASSIST"),true)
                assisttexture:Show()
            else
                assisttexture:Hide()
            end
        else
            assisttexture:Hide()
        end
        local summoningInfo=C_IncomingSummon and C_IncomingSummon.IncomingSummonStatus(u)
        if summoningInfo and tContains(enabledElements,"incomingsummon")then
            if summoningInfo==0 then
                summoning:Hide()
            elseif summoningInfo==1 then
                summoning:SetTexture(texturepath("SUMMON_PENDING"),true)
                summoning:Show()
            elseif summoningInfo==2 then
                summoning:SetTexture(texturepath("SUMMON_ACCEPTED"),true)
            elseif summoningInfo==3 then
                summoning:SetTexture(texturepath("SUMMON_DECLINED"),true)
            end
        else
            summoning:Hide()
        end
        if threat and tContains(enabledElements,"aggro")then
            if threat==0 then
                aggro:Hide()
                lowaggro:Hide()
            elseif threat==1 then
                aggro:Hide()
                lowaggro:Show()
            elseif threat==2 then
                aggro:Hide()
                lowaggro:Show()
            elseif threat==3 then
                aggro:Show()
                lowaggro:Hide()
            end
        else
            aggro:Hide()
            lowaggro:Hide()
        end
        if UnitGUID(u)then
            if UnitGUID("target")==UnitGUID(u)then
                selection:Show()
            else
                selection:Hide()
            end
        end
        if UnitIsConnected(u)then
            offline:Hide()
        elseif tContains(enabledElements,"offline")then
            offline:Show()
        else
            offline:Hide()
        end
        t2:SetText(UnitName(u))
        local _hpmax=unithp.hpmax(u)
        local _hp=unithp.hp(u)
        local _absorb=0
        if isClassic then
            _absorb=HealComm:GetHealAmount(UnitGUID(obj.unit),HealComm.ABSORB_SHIELDS)or 0
        else
            _absorb=unithp.absorb(u)
        end
        local _healabsorb=0
        if not isClassic then
            _healabsorb=unithp.healabsorb(u)
        end
        obj.health.current=_hp
        obj.health.max=_hpmax
        obj.health.absorb=_absorb
        obj.health.healing_absorb=_healabsorb
        _absorb=_absorb/_hpmax
        _healabsorb=_healabsorb/_hpmax
        _hp=_hp/_hpmax
        if _hp>1 then return self end -- Bad render frame (_hp is most likely infinity, divide by 0)
        obj.dead=UnitIsDeadOrGhost(u)
        if tContains(enabledElements,"percent")then
            if _hp==0 then
                t1:SetText("Dead")
            elseif obj.dead then
                t1:SetText("Ghost")
            else
                t1:SetText(math.floor(_hp*100).."%")
            end
        else
            t1:SetText("")
        end
        if obj.dead then
            health:Hide()
            health2:Hide()
        else
            health:Show()
            health2:Show()
        end
        if _hp>0 and _hp<=1 then
            health:SetTexCoord(0,_hp,0,1)
            health2:SetTexCoord(0,_hp,0,1)
            health:SetSize(_hp*200,100)
            health2:SetSize(_hp*200,100)
        end
        if not ticker then
            health:SetColorTexture(unpack(self.colors.health))
        end
        if tContains(enabledElements,"background")then
            back:SetColorTexture(unpack(self.colors.background))
        else
            back:SetColorTexture(0.05,0.05,0.05,0.9)
        end
        if _absorb+_hp>1 then
            absorb:SetTexCoord(0,1-_hp,0,1)
            absorb:SetSize(200*(1-_hp),100)
            absorb2:SetTexCoord(0,1-_hp,0,1)
            absorb2:SetSize(200*(1-_hp),100)
            overshield:Show()
        else
            absorb:SetTexCoord(0,_absorb,0,1)
            absorb:SetSize(200*_absorb,100)
            absorb2:SetTexCoord(0,_absorb,0,1)
            absorb2:SetSize(200*_absorb,100)
            overshield:Hide()
        end
        if _absorb>0 and _hp<=1 then
            absorb:Show()
            absorb2:Show()
        else
            absorb:Hide()
            absorb2:Hide()
        end
        if _hp==1 and _absorb>0 then
            absorb:Hide()
            absorb2:Hide()
            overshield:Show()
        end
        if _healabsorb>_hp then
            healabsorb:SetTexCoord(0,_hp,0,1)
            healabsorb:SetSize(200*_hp,100)
            overhealingabsorb:Show()
        else
            healabsorb:SetTexCoord(0,_healabsorb,0,1)
            healabsorb:SetSize(200*_healabsorb,100)
            overhealingabsorb:Hide()
        end
        if not tContains(enabledElements,"overabsorbs")then
            overshield:Hide()
            overhealingabsorb:Hide()
        end
        if _healabsorb>0 then
            healabsorb:Show()
        else
            healabsorb:Hide()
        end
        getIncoming(obj.health.max,obj.health.current)
        if b:IsShown()then
            f:Show()
            overlay:Show()
        else
            f:Hide()
            overlay:Hide()
        end
        local name=""
        local i=1
        local auras={

        }
        self.auras={
            buffs={

            },
            debuffs={

            }
        }
        while name do
            name=UnitAura(u,i,"PLAYER|HELPFUL")
            if name and not isBuffBlacklisted(name)then
                local _,icon,count,debuffType,duration,expirationTime,source,isStealable,_,spellId=UnitAura(u,i,"PLAYER|HELPFUL")
                if duration<60 and duration>0 then
                    if not isBuffBlacklisted(spellId)then
                        tinsert(auras,{name,count,icon,expirationTime,duration})
                    end
                end
                tinsert(self.auras.buffs,{name,spellId,duration,expirationTime})
            end
            i=i+1
        end
        i=1
        while i<=getn(auras)and i<=LOADED_VARS.max_buffs do
            local name,count,icon,expirationTime,duration=unpack(auras[i])
            if buffs[i]then
                buffs[i]:Show()
                buffs[i]:SetTexture(icon)
                buffs[i]:SetCooldown(expirationTime-duration,duration)
                buffs[i]:SetStacks(count)
            else
                newBuffIcon(icon,expirationTime-duration,duration,count)
            end
            i=i+1
        end
        while i<=getn(buffs)do
            if buffs[i]then
                buffs[i]:Hide()
            end
            i=i+1
        end
        name=""
        i=1
        auras={

        }
        local debuffsApplied={

        }
        local priority_={

        }
        while name do
            name=UnitAura(u,i,"HARMFUL")
            if name and not isDebuffBlacklisted(name)then
                local _,icon,count,debuffType,duration,expirationTime,source,isStealable,_,spellId=UnitAura(u,i,"HARMFUL")
                if not isDebuffBlacklisted(spellId)then
                    if priorityDebuffs[spellId]then
                        tinsert(priority_,{name,count,icon,expirationTime,duration,priorityDebuffs[spellId]})
                    elseif priorityDebuffs[name]then
                        tinsert(priority_,{name,count,icon,expirationTime,duration,priorityDebuffs[name]})
                    else
                        tinsert(auras,{name,count,icon,expirationTime,duration})
                    end
                end
                tinsert(self.auras.debuffs,{name,spellId,duration,expirationTime,debuffType})
                if debuffType and debuffType~=""then
                    debuffType=strlower(debuffType)
                    if debuffType=="curse"then
                        if not tContains(debuffsApplied,"CURSE")then
                            tinsert(debuffsApplied,"CURSE")
                        end
                    elseif debuffType=="disease"then
                        if not tContains(debuffsApplied,"DISEASE")then
                            tinsert(debuffsApplied,"DISEASE")
                        end
                    elseif debuffType=="magic"then
                        if not tContains(debuffsApplied,"MAGIC")then
                            tinsert(debuffsApplied,"MAGIC")
                        end
                    elseif debuffType=="poison"then
                        if not tContains(debuffsApplied,"POISON")then
                            tinsert(debuffsApplied,"POISON")
                        end
                    end
                end
            end
            i=i+1
        end
        if tContains(enabledElements,"dispeltypes")then
            registerDebuffs(debuffsApplied)
        else
            registerDebuffs({})
        end
        self.dispellable=dispellable
        i=1
        while i<=getn(priority_)and i<=LOADED_VARS.max_debuffs do
            local name,count,icon,expirationTime,duration,color=unpack(priority_[i])
            if debuffs[i]then
                debuffs[i]:Show()
                debuffs[i]:SetTexture(icon)
                debuffs[i]:SetCooldown(expirationTime-duration,duration)
                debuffs[i]:SetStacks(count)
                debuffs[i]:SetPriority(true,color)
            else
                newDebuffIcon(icon,expirationTime-duration,duration,count):SetPriority(true,color)
            end
            i=i+1
        end
        while i-getn(priority_)<=getn(auras)and i<=LOADED_VARS.max_debuffs do
            local name,count,icon,expirationTime,duration=unpack(auras[i-getn(priority_)])
            if debuffs[i]then
                debuffs[i]:Show()
                debuffs[i]:SetTexture(icon)
                debuffs[i]:SetCooldown(expirationTime-duration,duration)
                debuffs[i]:SetStacks(count)
                debuffs[i]:SetPriority(false)
            else
                newDebuffIcon(icon,expirationTime-duration,duration,count)
            end
            i=i+1
        end
        while i<=getn(debuffs)do
            if debuffs[i]then
                debuffs[i]:Hide()
            end
            i=i+1
        end
        if isOver then
            ClassHelper:ShowDispelTooltip(self.auras.debuffs)
        else
            ClassHelper:HideDispelTooltip()
        end
        return self
    end
    function obj:FirstUpdate()
        if LOADED_VARS.framerate>0 then
            C_Timer.NewTicker(1/LOADED_VARS.framerate,function()obj:Update()end)
        else -- If less than (shouldn't happen) or equal to 0 (maximum option), run maximum.
            C_Timer.NewTicker(0.001,function()obj:Update()end)
        end
    end
    function obj:SetHealthColor(...)
        self.colors.health={...}
        if not ticker then
            health:SetColorTexture(...)
        end
        return self
    end
    local glowing=false
    function obj:Glow()
        if b:IsShown()then
            ActionButton_ShowOverlayGlow(overlay)
            glowing=true
        else
            self:UnGlow()
        end
        return self
    end
    function obj:UnGlow()
        ActionButton_HideOverlayGlow(overlay)
        glowing=false
        return self
    end
    function obj:SetBackgroundColor(...)
        self.colors.background={...}
        back:SetColorTexture(...)
        return self
    end
    function obj:Flash(...)
        flashing={...}
        return self
    end
    C_Timer.NewTicker(0.25,function()
        if ticker then
            health:SetColorTexture(unpack(obj.colors.health))
        elseif getn(flashing)>0 then
            health:SetColorTexture(unpack(flashing))
        end
        ticker=not ticker
    end)
    function obj:IsGlowing()
        return glowing
    end
    function obj:IsFlashing()
        return(getn(flashing)>0)
    end
    tinsert(unitFrames,obj)
end
local onupdate=function()end
function ClassHelper:SetCustomRaidFramesUpdateFunction(func)
    onupdate=func
end
function ClassHelper:GetCustomRaidFramesUpdateFunction()
    return onupdate
end
local f=CreateFrame("FRAME")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
local has_entered_world=false
local function handle()
    if not has_entered_world then
        has_entered_world=true
        if _G.OmniCD and _G.OmniCD[1]and _G.OmniCD[1].unitFrameData then -- Set up OmniCD. (If loaded)
            tinsert(_G.OmniCD[1].unitFrameData,{
                [1]="ClassHelper",
                [2]="ClassHelper_SecureUnitFrame_raid",
                [3]="raidid",
                [4]=1
            })
            _G.OmniCD[1]:LoadAddOns() -- Load the AddOn into OmniCD.
        end
        function ClassHelper:SetupDispellableAttribute()
            local c=UnitClass("player") -- Setup .dispellable attribute
            if c=="Druid"then
                ClassHelper.CLASS_DISPELS={
                    "CURSE",
                    "POISON"
                }
                ClassHelper.DISPEL_ABILITY={["Remove Corruption"]={"CURSE","POISON"}}
                if GetSpecialization and GetSpecialization()==4 then
                    tinsert(ClassHelper.CLASS_DISPELS,"MAGIC")
                    ClassHelper.DISPEL_ABILITY={["Nature's Cure"]={"CURSE","POISON","MAGIC"}}
                end
            elseif c=="Paladin"then
                ClassHelper.CLASS_DISPELS={
                    "DISEASE",
                    "POISON"
                }
                ClassHelper.DISPEL_ABILITY={["Cleanse Toxins"]={"DISEASE","POISON"}}
                if GetSpecialization and GetSpecialization()==1 then
                    tinsert(ClassHelper.CLASS_DISPELS,"MAGIC")
                    ClassHelper.DISPEL_ABILITY={["Cleanse"]={"DISEASE","POISON","MAGIC"}}
                end
            elseif c=="Priest"then
                ClassHelper.CLASS_DISPELS={
                    "MAGIC",
                    "DISEASE"
                }
                ClassHelper.DISPEL_ABILITY={["Purify"]={"DISEASE","MAGIC"},["Mass Dispel"]={"MAGIC"}}
                if GetSpecialization and GetSpecialization()==3 then
                    ClassHelper.DISPEL_ABILITY={["Purify Disease"]={"DISEASE"},["Mass Dispel"]={"MAGIC"}}
                end
            elseif c=="Monk"then
                ClassHelper.CLASS_DISPELS={
                    "DISEASE",
                    "POISON"
                }
                ClassHelper.DISPEL_ABILITY={["Detox"]={"DISEASE","POISON"}}
                if GetSpecialization and GetSpecialization()==2 then
                    tinsert(ClassHelper.CLASS_DISPELS,"MAGIC")
                    ClassHelper.DISPEL_ABILITY={["Detox"]={"DISEASE","POISON","MAGIC"}}
                end
            elseif c=="Shaman"then
                ClassHelper.CLASS_DISPELS={
                    "CURSE"
                }
                ClassHelper.DISPEL_ABILITY={["Cleanse Spirit"]={"CURSE"}}
                if GetSpecialization and GetSpecialization()==3 then
                    tinsert(ClassHelper.CLASS_DISPELS,"MAGIC")
                    ClassHelper.DISPEL_ABILITY={["Purify Spirit"]={"MAGIC","CURSE"}}
                end
            elseif c=="Mage"then
                ClassHelper.CLASS_DISPELS={
                    "CURSE"
                }
                ClassHelper.DISPEL_ABILITY={["Remove Curse"]={"CURSE"}}
            end
        end
        ClassHelper:SetupDispellableAttribute()
        ClassHelper:DefaultSavedVariable("CustomUnitFrames","Framerate","60")
        ClassHelper:DefaultSavedVariable("CustomUnitFrames","DebuffPoint","BOTTOMLEFT")
        ClassHelper:DefaultSavedVariable("CustomUnitFrames","BuffPoint","BOTTOMRIGHT")
        ClassHelper:DefaultSavedVariable("CustomUnitFrames","Showing","true")
        ClassHelper:DefaultSavedVariable("CustomUnitFrames","HideOldFrames","false")
        ClassHelper:DefaultSavedVariable("CustomUnitFrames","Attributes",{
            ["type1"]="target",
            ["shift-type1"]="target",
            ["alt-type1"]="target",
            ["ctrl-type1"]="target",
            ["ctrl-shift-type1"]="target",
            ["alt-shift-type1"]="target",
            ["alt-ctrl-type1"]="target",
            ["alt-ctrl-shift-type1"]="target",
            ["type2"]="togglemenu",
            ["shift-type2"]="target",
            ["alt-type2"]="target",
            ["ctrl-type2"]="target",
            ["ctrl-shift-type2"]="target",
            ["alt-shift-type2"]="target",
            ["alt-ctrl-type2"]="target",
            ["alt-ctrl-shift-type2"]="target",
            ["click"]="AnyUp",
            ["framerate"]="60",
            ["priority"]="#disabled",
            ["elements"]="aggro,brez,incomingSummon,background,overabsorbs,phased,offline,dispelTypes,instanceGroup,leader,assist,role,percent,ready,inRange",
            ["dispel_tooltip"]="#disabled",
            ["tooltip_conditions"]="#disabled",
            ["tooltip_blacklist"]="#disabled\nPut anything you don't want to detect as a dispel (EX: Mass Dispel) here..."
        })
        ClassHelper:DefaultSavedVariable("CustomUnitFrames","Scale",1)
        LOADED_VARS.framerate=tonumber(ClassHelper:Load("CustomUnitFrames","Framerate"))
        LOADED_VARS.debuffPoint=ClassHelper:Load("CustomUnitFrames","DebuffPoint")
        LOADED_VARS.buffPoint=ClassHelper:Load("CustomUnitFrames","BuffPoint")
        local updating=false
        local function updateFunc(isFirst)
            if updating and isFirst then
                ClassHelper:Print("\124cffff0000You can't do that while in combat!")
                return
            end
            if InCombatLockdown()then
                updating=true
                if isFirst then
                    ClassHelper:Print("\124cffff0000You can't do that while in combat!")
                end
                C_Timer.NewTimer(1,function()updateFunc(false)end)
            else
                local t=ClassHelper:Load("CustomUnitFrames","Attributes")
                local special={
                    "priority",
                    "framerate",
                    "elements",
                    "dispel_tooltip",
                    "tooltip_conditions",
                    "tooltip_blacklist"
                }
                for i,v in pairs(t)do
                    if i=="click"then
                        for n=1,getn(secure_buttons)do
                            secure_buttons[n]:RegisterForClicks(v)
                        end
                    elseif not tContains(special,i)then
                        for n=1,getn(secure_buttons)do
                            secure_buttons[n]:SetAttribute(i,v)
                        end
                    end
                end
                if t["framerate"]then
                    ClassHelper:Save("CustomUnitFrames","Framerate",t["framerate"])
                end
                if t["elements"]then
                    enabledElements={strsplit(",",strlower(t["elements"]))}
                else
                    enabledElements={
                        "aggro",
                        "brez",
                        "incomingsummon",
                        "background",
                        "overabsorbs",
                        "phased",
                        "offline",
                        "dispeltypes",
                        "instancegroup",
                        "leader",
                        "assist",
                        "role",
                        "percent",
                        "ready",
                        "inrange"
                    }
                end
                if ClassHelper.dispelTooltipLoaded then -- Be careful when using functions from other files. Make sure they are loaded first...
                    if t["dispel_tooltip"]then
                        ClassHelper:SetDispelTooltipData(t["dispel_tooltip"])
                    else
                        ClassHelper:SetDispelTooltipData("#disabled")
                    end
                    if t["tooltip_conditions"]then
                        ClassHelper:SetDispelTooltipConditions(t["tooltip_conditions"])
                    else
                        ClassHelper:SetDispelTooltipConditions("#disabled")
                    end
                end
                if t["tooltip_blacklist"]and strsplit("\n",t["tooltip_blacklist"])~="#disabled"then
                    ClassHelper.dispelBlacklist=strsplit("\n",t["tooltip_blacklist"])
                else
                    ClassHelper.dispelBlacklist={}
                end
                local priority_=t["priority"]
                if priority_ and strsub(priority_,1,9)~="#disabled"then
                    local p={
                        ""
                    }
                    for i=1,strlen(priority_)do
                        local s=strsub(priority_,i,i)
                        if s=="\n"then
                            if tonumber(p[getn(p)])then
                                p[getn(p)]=tonumber(p[getn(p)])
                            end
                            tinsert(p,"")
                        else
                            p[getn(p)]=p[getn(p)]..s
                        end
                    end
                    local d={

                    }
                    for i=1,getn(p)do
                        local a1,a2=strsplit(";",p[i])
                        if a2 then
                            d[a1]={strsplit(",",a2)} -- Removed this for security reasons, you can no longer edit the RGBA values with custom functions.
                        elseif a1 then
                            d[a1]={}
                        end
                    end
                    priorityDebuffs=d
                end
                updating=false
                ClassHelper_UnitFrameContainer:SetScale(ClassHelper:Load("CustomUnitFrames","Scale")/2)
                ClassHelper:Print("Updated all RaidFrame attributes successfully!")
            end
        end
        function ClassHelper:UpdateUnitFrameScale(s)
            if s then
                self:Save("CustomUnitFrames","Scale",s)
            end
            updateFunc(true)
        end
        ClassHelper:CreateSlashCommand("unitframe-scale","ClassHelper:UpdateUnitFrameScale(tonumber(arguments))","Changes the CustomUnitFrames scale. Default is 1. Note thatthis will also update any attributes to update the scale.")
        ClassHelper:CreateSlashCommand("unitframe-attribute","ClassHelper:UpdateUnitFrameAttribute(arguments)","Updates a RaidFrame attribute. Type '/ch help unitframe-attribute' for more info. To update, type '/ch unitframe-attribute update'.",{"You can use these as automated ways of casting spells.","To make an automatic spellcast, simply type '/ch unitframe-attribute <clicking_method> macro'. Then type ","/ch unitframe-attribute macrotext <macro_data>","The clicking method can be any of these examples: type1 (left-click = button1); type2 (right-click = button2); shift-type1 (shift+leftclick); alt-ctrl-shift-type2 (ctrl+alt+shift+rightclick); <you can remove any modifiers, add any modifiers, or even use things like type3 for the 3rd mouse button. (middle button)","For more information, please see \124cffff6600https://wowwiki.fandom.com/wiki/SecureActionButtonTemplate \124cffffff00on the SetAttribute() method. What you type in these commands is being put into SetAttribute().","Use '~' for newlines to split lines of text in macros in command lines only. In the UI, you can use newlines."})
        ClassHelper:CreateSlashCommand("unitframe-attributes","ClassHelper:UpdateUnitFrameAttribute(arguments)","Updates a RaidFrame attribute. Type '/ch help unitframe-attribute' for more info. To update, type '/ch unitframe-attribute update'.",{"You can use these as automated ways of casting spells.","To make an automatic spellcast, simply type '/ch unitframe-attribute <clicking_method> macro'. Then type ","/ch unitframe-attribute macrotext <macro_data>","The clicking method can be any of these examples: type1 (left-click = button1); type2 (right-click = button2); shift-type1 (shift+leftclick); alt-ctrl-shift-type2 (ctrl+alt+shift+rightclick); <you can remove any modifiers, add any modifiers, or even use things like type3 for the 3rd mouse button. (middle button)","For more information, please see \124cffff6600https://wowwiki.fandom.com/wiki/SecureActionButtonTemplate \124cffffff00on the SetAttribute() method. What you type in these commands is being put into SetAttribute().","Use '~' for newlines to split lines of text in macros in command lines only. In the UI, you can use newlines."})
        function ClassHelper:UpdateUnitFrameAttribute(t)
            if t==""or not t then
                self:Print("Current unitframe attributes:")
                self:Print("-----------------------------")
                local t=self:Load("CustomUnitFrames","Attributes")
                for i,v in pairs(t)do
                    self:Print(i.."\124cffff6600: \124cffffff00"..v)
                end
                return
            end
            if t=="update"then
                updateFunc(true)
                return
            end
            if t=="reset"then
                self:Save("CustomUnitFrames","Attributes",{
                    ["type1"]="target",
                    ["shift-type1"]="target",
                    ["alt-type1"]="target",
                    ["ctrl-type1"]="target",
                    ["ctrl-shift-type1"]="target",
                    ["alt-shift-type1"]="target",
                    ["alt-ctrl-type1"]="target",
                    ["alt-ctrl-shift-type1"]="target",
                    ["type2"]="togglemenu",
                    ["shift-type2"]="target",
                    ["alt-type2"]="target",
                    ["ctrl-type2"]="target",
                    ["ctrl-shift-type2"]="target",
                    ["alt-shift-type2"]="target",
                    ["alt-ctrl-type2"]="target",
                    ["alt-ctrl-shift-type2"]="target",
                    ["click"]="AnyUp",
                    ["framerate"]="60",
                    ["priority"]="#disabled",
                    ["elements"]="aggro,brez,incomingSummon,background,overabsorbs,phased,offline,dispelTypes,instanceGroup,leader,assist,role,percent,ready,inRange",
                    ["dispel_tooltip"]="#disabled",
                    ["tooltip_conditions"]="#disabled",
                    ["tooltip_blacklist"]="#disabled\nPut anything you don't want to detect as a dispel (EX: Mass Dispel) here..."
                })
                self:Print("Resetting to the default attributes.")
                updateFunc(true)
                return
            end
            local t2=""
            for i=1,strlen(t)do
                if strsub(t,i,i)=="~"then
                    t2=t2.."\n"
                else
                    t2=t2..strsub(t,i,i)
                end
            end
            t=t2
            local x=strsplit(" ",t)
            local y=strsub(t,strlen(x)+2,strlen(t))
            if x and y then
                local v=self:Load("CustomUnitFrames","Attributes")
                if not v[x]then
                    v[x]="?(nil)"
                end
                self:Print("Changing attribute: \124cffff6600"..x.."\124cffffff00: (OLD) \124cffff6600"..v[x].."\124cffffff00 -> (NEW) \124cffff6600"..y)
                v[x]=y
                self:Save("CustomUnitFrames","Attributes",v)
                self:Print("Type '/ch unitframe-attributes update' or '/reload' to load the new attributes.")
            else
                self:Print("Invalid number of arguments.")
            end
        end
        function ClassHelper:SetUnitFrameAttributes(t)
            self:Save("CustomUnitFrames","Attributes",t)
            updateFunc(true)
        end
        function ClassHelper:UpdateAllUnitFrameAttributes()
            updateFunc(true)
        end
        if LOADED_VARS.framerate>0 then
            C_Timer.NewTicker(1/LOADED_VARS.framerate,function()
                local t={

                }
                for i=1,getn(unitFrames)do
                    if UnitName(unitFrames[i].unit)then
                        tinsert(t,unitFrames[i])
                    end
                end
                if onupdate then
                    onupdate(unitFrames)
                end
            end)
        else -- If less than (shouldn't happen) or equal to 0 (maximum option), run maximum.
            C_Timer.NewTicker(0.001,function()
                local t={

                }
                for i=1,getn(unitFrames)do
                    if UnitName(unitFrames[i].unit)then
                        tinsert(t,unitFrames[i])
                    end
                end
                if onupdate then
                    onupdate(unitFrames)
                end
            end)
        end
        for i=1,getn(unitFrames)do
            unitFrames[i]:FirstUpdate()
        end
        local f=CreateFrame("FRAME")
        local pos=ClassHelper:LoadFrame("CustomUnitFrames","UnitFrameContainer")
        if pos then
            if pos[2]then
                pos[2]=_G[pos[2]]
            else
                pos[2]=anchor_background
            end
            anchor:SetPoint(pos[1],anchor_background,pos[3],pos[4],pos[5]) -- DEBUG (Frame won't anchor to UIParent, try a different way.)
        end
        updateFunc(true)
        if ClassHelper:Load("CustomUnitFrames","Showing")=="true"then
            ClassHelper_UnitFrameContainer:Show()
        else
            ClassHelper_UnitFrameContainer:Hide()
        end
        if ClassHelper:Load("CustomUnitFrames","HideOldFrames")=="true"and ClassHelper:Load("CustomUnitFrames","Showing")=="true"then
            RegisterStateDriver(PartyMemberFrame1,"visibility","hide")
            RegisterStateDriver(PartyMemberFrame2,"visibility","hide")
            RegisterStateDriver(PartyMemberFrame3,"visibility","hide")
            RegisterStateDriver(PartyMemberFrame4,"visibility","hide")
            RegisterStateDriver(CompactRaidFrameContainer,"visibility","hide")
        end
    end
end
f:SetScript("OnEvent",handle)
local readyCheckFrame=CreateFrame("FRAME")
readyCheckFrame:RegisterEvent("READY_CHECK")
readyCheckFrame:RegisterEvent("READY_CHECK_FINISHED")
readyCheckFrame:RegisterEvent("READY_CHECK_CONFIRM")
local rc=false
local function handle(self,event,unit,status)
    if event=="READY_CHECK"or event=="READY_CHECK_CONFIRM"then
        setReady(2)
        rc=true
        local function func()
            if rc then
                setReady(1)
                C_Timer.NewTimer(0.05,func)
            else
                setReady(-1)
            end
        end
        C_Timer.NewTimer(0.05,func)
        setReady(1)
        C_Timer.NewTimer(30,function()rc=false end) -- Left the group?? (Fix the RaidFrames)
    elseif event=="READY_CHECK_FINISHED"then
        rc=false
        setReady(-1)
    end
end
readyCheckFrame:SetScript("OnEvent",handle)
newUnitFrame("player")
newUnitFrame("party1")
newUnitFrame("party2")
newUnitFrame("party3")
newUnitFrame("party4")
rowCounter=0 -- Reset the row and column, raid frames will overlay over the party frames.
columnCounter=0
for i=1,40 do
    newUnitFrame("raid"..i) -- Create 40 raid frames
end
function ClassHelper:ResetCustomRaidFrames()
    for i=1,getn(unitFrames)do
        local obj=unitFrames[i]
        obj:SetBackgroundColor(0.05,0.05,0.05,0.9)
        obj:SetHealthColor(0,1,0,1)
        obj:UnGlow()
        obj:Flash()
    end
end