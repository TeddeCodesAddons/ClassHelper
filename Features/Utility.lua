local util=ClassHelper.util
if not util then -- Making ClassHelper.util just ClassHelper to make this easier to use for players.
    ClassHelper.util=ClassHelper--[[{

    }]]
    util=ClassHelper.util
end
function util:ConvertNumberToTime(num)
    if num<0 then
        return "0.0"
    end
    num=math.floor(num*10)/10
    local s=num%60
    num=(num-s)/60
    local m=num%60
    local h=(num-m)/60
    local r=""
    if h>0 then
        r=h..":"
        if m<10 then
            m="0"..m
        end
    end
    if m*1>0 or h>0 then
        r=r..m..":"
    end
    if math.floor(s)==s and num==0 then
        r=r..s..".0"
    elseif num==0 then
        r=r..s
    else
        if s<10 then
            r=r.."0"..(math.floor(s))
        else
            r=r..(math.floor(s))
        end
    end
    return r
end
function util:ConvertTimeToNumber(num)
    local r=0
    local n=""
    for i=1,strlen(num)do
        if strsub(num,i,i)==":"then
            r=(r*60)+n
            n=""
        else
            n=n..strsub(num,i,i)
        end
    end
    return (r*60)+n
end
function util:GetNPCID(guid)
    local type,_,server,instance,zone,npc,spawn=strsplit("-",guid)
    local r={
        type=type,
        server_id=server,
        instance_id=instance,
        zone_uid=zone,
        npc_id=npc,
        spawn_id=spawn
    }
    return r
end
function util:GetGUID(unit)
    if strsub(unit,1,9)=="nameplate"then
        return ClassHelper:GetNameplateGUID(unit)
    else
        return UnitGUID(unit)
    end
end
function util:GetCooldown(spell,forceItem)
    local _time,CD=GetSpellCooldown(spell)
    local gcd_time,GCD=GetSpellCooldown(61304) -- Global cooldown
    if forceItem or not(_time and CD)then
        if not tonumber(spell)then
            spell=self:GetSpellInfo(spell).id
        end
        local _time,CD=GetItemCooldown(spell)
        if not(_time and CD)then
            return nil,"Invalid"
        end
        if _time==0 then
            return 0,0
        end
        return CD-(GetTime()-_time),CD
    end
    if _time==0 then
        return 0,0
    end
    if GCD-(GetTime()-gcd_time)~=CD-(GetTime()-_time)then
        return CD-(GetTime()-_time),CD
    else
        return 0,CD
    end
end
function util:GetSpellInfo(spell,forceItem)
    if not spell then return {}end
    local t={
        
    }
    local spellInfo={

    }
    local id=0
    local icon=0
    if GetSpellInfo(spell)and not forceItem then
        spellInfo={GetSpellInfo(spell)}
        id=spellInfo[7]
        icon=spellInfo[3]
        t.isSpell=true
        t.isItem=false
        t.name=spellInfo[1]
    elseif GetItemInfo(spell)then
        spellInfo={GetItemInfo(spell)}
        local _
        _,id=strsplit(":",spellInfo[2])
        icon=spellInfo[10]
        t.isItem=true
        t.isSpell=false
        t.name=spellInfo[1]
        t.equipped=IsEquippedItem(id)
    else
        spellInfo={nil,"Invalid"}
    end
    if id==0 or not id then return {}end
    local timeRemaining,CD=self:GetCooldown(id,forceItem)
    t.info=spellInfo
    t.cooldown={
        remaining=timeRemaining,
        max=CD,
        lastCastTime=((not forceItem)and GetSpellCooldown(id))or GetItemCooldown(id)or false
    }
    t.id=tonumber(id)
    t.learned=((not forceItem)and IsSpellKnown(id))or GetItemCount(id)>0
    t.isLearnedByPet=IsSpellKnown(id,true)or nil
    t.icon=icon
    t.actionButtons=self:SearchActionBar(id)
    return t
end
function util:SearchActionBar(id)
    if not id then return {}end
    if GetSpellInfo(id)then
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
                            tinsert(r,_G[p..i])
                        elseif t=="macro"then
                            s=GetMacroSpell(s)
                            if s then
                                s=select(7,GetSpellInfo(s))
                                if s and s==id then
                                    tinsert(r,_G[p..i])
                                end
                            else
                                s=GetMacroItem(s)
                                if s then
                                    if GetItemInfo(id)and not tonumber(id)then
                                        local itemInfo={GetItemInfo(id)}
                                        local _
                                        _,id=strsplit(":",itemInfo[2])
                                    end
                                    if tonumber(s)and tonumber(s)==id then
                                        tinsert(r,_G[p..i])
                                    end
                                end
                            end
                        elseif t=="item"then
                            if s then
                                if GetItemInfo(id)and not tonumber(id)then
                                    local itemInfo={GetItemInfo(id)}
                                    local _
                                    _,id=strsplit(":",itemInfo[2])
                                end
                                if tonumber(id)and tonumber(s)and tonumber(s)==tonumber(id)then
                                    tinsert(r,_G[p..i])
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
local LibRangeCheck=LibStub("LibRangeCheck-2.0")
function util:GetUnitRange(u,v)
    return LibRangeCheck:GetRange(u,v)
end
function util:GetAuraInfo(unit,auraName,type,mustBeOwn)
    local filter=type
    if type then
        if mustBeOwn then
            filter=filter.."|PLAYER"
        end
    elseif mustBeOwn then
        filter="PLAYER"
    else
        filter=nil
    end
    local auras={

    }
    local i=1
    local name=UnitAura(unit,i,filter)
    while name do
        local _,icon,count,debuffType,duration,expirationTime,source,isStealable,_,spellId=UnitAura(unit,i,filter)
        auras[name]={
            stacks=count,
            icon=icon,
            expirationTime=expirationTime,
            duration=duration,
            source=source,
            isStealable=isStealable,
            dispelType=debuffType,
            id=spellId,
            name=name
        }
        i=i+1
        name=UnitAura(unit,i,filter)
    end
    if auraName and auras[auraName]then
        return auras[auraName]
    end
    if auraName then
        return nil
    end
    return auras
end
function util:GetNearbyUnits(range)
    local t={
        OOR={
            units={

            },
            amount=0
        },
        aggroNeutral={
            units={

            },
            amount=0
        },
        aggroHostile={
            units={

            },
            amount=0
        },
        aggroFriendly={
            units={

            },
            amount=0
        },
        neutral={
            units={

            },
            amount=0
        },
        hostile={
            units={

            },
            amount=0
        },
        friendly={
            units={

            },
            amount=0
        },
        units={

        },
        amount=0
    }
    local i=1
    while UnitExists("nameplate"..i)or i<=40 do -- Make sure that all nameplates are scanned.
        if UnitExists("nameplate"..i)then
            if(not range)or(select(2,self:GetUnitRange("nameplate"..i))or 0)<=range then
                tinsert(t.units,UnitGUID("nameplate"..i))
                t.amount=t.amount+1
                if UnitIsEnemy("player","nameplate"..i)then
                    if UnitAffectingCombat("nameplate"..i)then
                        tinsert(t.aggroHostile.units,UnitGUID("nameplate"..i))
                        t.aggroHostile.amount=t.aggroHostile.amount+1
                    else
                        tinsert(t.hostile.units,UnitGUID("nameplate"..i))
                        t.hostile.amount=t.hostile.amount+1
                    end
                elseif UnitIsFriend("player","nameplate"..i)then
                    if UnitAffectingCombat("nameplate"..i)then
                        tinsert(t.aggroFriendly.units,UnitGUID("nameplate"..i))
                        t.aggroFriendly.amount=t.aggroFriendly.amount+1
                    else
                        tinsert(t.friendly.units,UnitGUID("nameplate"..i))
                        t.friendly.amount=t.hostile.amount+1
                    end
                elseif UnitAffectingCombat("nameplate"..i)then
                    tinsert(t.aggroNeutral.units,UnitGUID("nameplate"..i))
                    t.aggroNeutral.amount=t.aggroNeutral.amount+1
                else
                    tinsert(t.neutral.units,UnitGUID("nameplate"..i))
                    t.neutral.amount=t.neutral.amount+1
                end
            else
                tinsert(t.OOR.units,UnitGUID("nameplate"..i))
                t.OOR.amount=t.OOR.amount+1
            end
        end
        i=i+1
    end
    return t
end
function util:GetNearbyEnemies(range)
    local t={
        units={
            
        },
        amount=0
    }
    local i=1
    while UnitExists("nameplate"..i)or i<=40 do -- Make sure that all nameplates are scanned.
        if UnitExists("nameplate"..i)and(UnitIsEnemy("player","nameplate"..i)or(UnitAffectingCombat("nameplate"..i)and not UnitIsFriend("player","nameplate"..i)))then
            if(not range)or(select(2,self.util:GetUnitRange("nameplate"..i))or 0)<=range then
                tinsert(t.units,UnitGUID("nameplate"..i))
                t.amount=t.amount+1
            end
        end
        i=i+1
    end
    return t
end
function util:GetNearbyFriends(range)
    local t={
        units={
            
        },
        amount=0
    }
    local i=1
    while UnitExists("nameplate"..i)or i<=40 do -- Make sure that all nameplates are scanned.
        if UnitExists("nameplate"..i)and UnitIsFriend("player","nameplate"..i)then
            if(not range)or(select(2,self.util:GetUnitRange("nameplate"..i))or 0)<=range then
                tinsert(t.units,UnitGUID("nameplate"..i))
                t.amount=t.amount+1
            end
        end
        i=i+1
    end
    return t
end
function util:GetNearbyGroupMembers(range)
    local t={
        units={
            
        },
        amount=0
    }
    if IsInRaid()then
        local i=1
        while UnitExists("raid"..i)or i<=40 do
            if UnitExists("raid"..i)and UnitIsFriend("player","raid"..i)then -- Charmed??
                if(not range)or(select(2,self.util:GetUnitRange("raid"..i))or 0)<=range then
                    tinsert(t.units,"raid"..i)
                    t.amount=t.amount+1
                end
            end
            i=i+1
        end
    elseif IsInGroup()then
        local i=1
        while UnitExists("party"..i)or i<=40 do
            if UnitExists("party"..i)and UnitIsFriend("player","party"..i)then -- Charmed??
                if(not range)or(select(2,self.util:GetUnitRange("party"..i))or 0)<=range then
                    tinsert(t.units,"party"..i)
                    t.amount=t.amount+1
                end
            end
            i=i+1
        end
    end
    return t
end