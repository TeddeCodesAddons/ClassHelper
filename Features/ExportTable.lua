-- This script should export a table into a string, and import a string into a table.
local strlen=string.len -- !DEBUG
local strsub=string.sub -- !DEBUG
local function formatString(s)
    local s2=""
    for i=1,strlen(s)do
        local x=strsub(s,i,i)
        if x=="~"then
            s2=s2.."~~"
        elseif x=="\n"then
            s2=s2.."~n"
        else
            s2=s2..x
        end
    end
    return s2
end
local function unformatString(s)
    local s2=""
    local i=1
    while i<=strlen(s)do
        local x=strsub(s,i,i)
        if x=="~"then
            i=i+1
            local y=strsub(s,i,i)
            if y=="~"then
                s2=s2.."~"
            elseif y=="n"then
                s2=s2.."\n"
            elseif y=="$"then
                return s2,i
            elseif y==")"then
                return s2,i
            end
        else
            s2=s2..x
        end
        i=i+1
    end
    ClassHelper:Print("WARNING: No string terminator was detected.")
    return s2,strlen(s)
end
local function export(t)
    local returnString=""
    for i,v in pairs(t)do
        if type(i)=="number"then
            returnString=returnString.."("..i..")"
        elseif type(i)=="string"then
            returnString=returnString.."(~"..i.."~)"
        elseif type(i)=="boolean"then
            if i then
                returnString=returnString.."(@1)"
            else
                returnString=returnString.."(@0)"
            end
        end
        if type(v)=="table"then
            if v==t then
                geterrorhandler()("ClassHelper:ExportTable() doesn't work on tables that contain a pointer to themselves.")
                return
            end
            returnString=returnString.."#"..(export(v))
        elseif type(v)=="number"then
            returnString=returnString.."!"..v
        elseif type(v)=="boolean"then
            if v then
                returnString=returnString.."@1"
            else
                returnString=returnString.."@0"
            end
        elseif type(v)=="string"then
            v=formatString(v)
            returnString=returnString.."$"..v.."~$"
        end
    end
    returnString=returnString.."%"
    return returnString
end
function ClassHelper:ExportTable(t)
    return "!CH9.0:"..export(t)
end
local function import(s)
    local t={
        
    }
    local i=1
    local idx=nil
    while i<=strlen(s)do
        local x=strsub(s,i,i)
        if x=="("then
            i=i+1
            local y=strsub(s,i,i)
            if y=="~"then
                local s,n=unformatString(strsub(s,i+1,strlen(s)))
                i=i+n
                idx=s
            elseif y=="@"then
                if strsub(s,i+1,i+1)=="1"then
                    idx=true
                elseif strsub(s,i+1,i+1)=="0"then
                    idx=false
                else
                    ClassHelper:Print("WARNING: Invalid boolean value (Should be true or false)")
                end
                i=i+1
            elseif tonumber(y)then
                local n=tonumber(y)
                i=i+1
                y=strsub(s,i,i)
                while tonumber(y)do
                    n=n*10
                    n=n+tonumber(y)
                    i=i+1
                    y=strsub(s,i,i)
                end
                idx=n
                i=i-1
            else
                ClassHelper:Print("WARNING: Invalid table index type.")
            end
        elseif x=="!"then
            i=i+1
            local y=strsub(s,i,i)
            local n=0
            while tonumber(y)do
                n=n*10
                n=n+tonumber(y)
                i=i+1
                y=strsub(s,i,i)
            end
            i=i-1
            t[idx]=n
        elseif x=="@"then
            if strsub(s,i+1,i+1)=="1"then
                t[idx]=true
            elseif strsub(s,i+1,i+1)=="0"then
                t[idx]=false
            else
                ClassHelper:Print("WARNING: Invalid boolean value (Should be true or false)")
            end
            i=i+1
        elseif x=="#"then
            local t2,start=import(strsub(s,i+1,strlen(s)))
            t[idx]=t2
            i=i+start
        elseif x=="$"then
            local s2,a=unformatString(strsub(s,i+1,strlen(s)))
            t[idx]=s2
            i=i+a
        elseif x=="%"then
            return t,i
        else
            ClassHelper:Print("WARNING: Invalid table index header.")
        end
        i=i+1
    end
    ClassHelper:Print("WARNING: No table terminator was detected.")
    return t,strlen(s)
end
function ClassHelper:ImportTable(s)
    if not strsub(s,1,7)=="!CH9.0:"then
        ClassHelper:Print("ERROR: This string is not recognized as a valid ClassHelper export, and therefore cannot be imported.")
        return nil
    end
    local t=import(strsub(s,8,strlen(s)),1)
    return t
end
--[[local t=importTable(exportTable({ -- !DEBUG
    ["Holy Paladin"] = {
        ["init"] = "ClassHelper.vars[\"Divine Purpose\"]=false\nClassHelper.vars[\"Infusion of Light\"]=false\nClassHelper.vars[\"loaded\"]=true\nClassHelper.is_healer=true\nHOLY_PALADIN_MANA_BAR=ClassHelper:NewPowerBar(0)\nHOLY_PALADIN_POWER_BAR=ClassHelper:NewPowerBar(\"HOLY_POWER\")\nHOLY_PALADIN_POWER_BAR:ClearFade()\nHOLY_PALADIN_POWER_BAR:DisplayNumber()\nHOLY_PALADIN_POWER_BAR:SetColor(1,1,0,0.2)\nHOLY_PALADIN_POWER_BAR:Fade(1,\"GREATERTHAN\",2,1,0.5,0,0.2)\nHOLY_PALADIN_POWER_BAR:SetSize(300,32)\nHOLY_PALADIN_POWER_BAR:SetPoint(\"CENTER\",0,-48,UIParent)\nlocal varsPointer=ClassHelper.vars\nlocal showBeacon=ClassHelper.vars[\"showBeacons\"]\nlocal showMindgames=ClassHelper.vars[\"showMindgames\"]\nlocal showShield=ClassHelper.vars[\"showShockBarrier\"]\nlocal showGlimmer=ClassHelper.vars[\"showGlimmer\"]\nClassHelper.vars[\"raidframesfunc\"]=function(t)\n    for i=1,getn(t)do\n        local f=t[i]\n        local b=f.auras.buffs\n        local glimmer=false\n        for x=1,getn(b)do\n            if b[x][1]==\"Glimmer of Light\"then\n                glimmer=true\n            end\n        end\n        local beacon=false\n        for x=1,getn(b)do\n            if b[x][1]==\"Beacon of Virtue\"then\n                beacon=true\n            end\n        end\n        local shield=false\n        for x=1,getn(b)do\n            if b[x][1]==\"Shock Barrier\"then\n                shield=true\n            end\n        end\n        local d=f.auras.debuffs\n        local mindgames=false\n        for x=1,getn(d)do\n            if d[x][2]==323673 then\n                mindgames=true\n            end\n        end\n        if not showMindgames then\n            mindgames=false\n        end\n        if mindgames then\n            if not f:IsGlowing()then\n                f:Glow()\n            end\n        else\n            if f:IsGlowing()then\n                f:UnGlow()\n            end\n        end\n        if not showBeacon then\n            beacon=false\n        end\n        if not showShield then\n            shield=false\n        end\n        if not showGlimmer then\n            glimmer=false\n        end\n        if glimmer then\n            f:SetBackgroundColor(0.05,0.05,0.05,0.9)\n        else\n            f:SetBackgroundColor(0.9,0,0,0.9)\n        end\n        if beacon then\n            f:SetHealthColor(1,0,1,1)\n        elseif shield then\n            f:SetHealthColor(1,0.5,0,1)\n        else\n            f:SetHealthColor(0,1,0,1)\n        end\n    end\nend\nClassHelper:SetCustomRaidFramesUpdateFunction(varsPointer[\"raidframesfunc\"])\nlocal lit=false\nlocal lightOfDawnFrame=ClassHelper:NewIconFrame()\n:SetPoint(\"CENTER\",100,100)\n:SetSize(30)\n:SetStacks(3)\n:SetIcon(461859)\n:Glow()\n:Hide()\nC_Timer.NewTicker(0.05,function()\n    if not varsPointer[\"loaded\"]then return end\n    if UnitPower(\"player\",9)==5 then\n        if not lit then\n            ClassHelper:LightUpSpell(\"Light of Dawn\")\n            ClassHelper:LightUpSpell(\"Word of Glory\")\n            lit=true\n        end\n    else\n        if lit then\n            ClassHelper:UnLightUpSpell(\"Light of Dawn\")\n            ClassHelper:UnLightUpSpell(\"Word of Glory\")\n            lit=false\n        end\n    end\n    local a=\"None\"\n    local i=0\n    local s\n    local x\n    local d\n    local _\n    while a and a~=\"Enkindled Spirit\"do\n        i=i+1\n        a,_,s,_,x,d=UnitAura(\"player\",i,\"PLAYER||HELPFUL\")\n    end\n    if varsPointer[\"showLightOfDawn\"]and a==\"Enkindled Spirit\"then\n        lightOfDawnFrame:SetDuration(d-x,x)\n        :SetStacks(s)\n        :Show()\n    else\n        lightOfDawnFrame:Hide()\n    end\nend)",
        ["data"] = "local scm=SendChatMessage\nlocal function SendChatMessage(...)\n    if ClassHelper.vars[\"callouts\"]then\n        return scm(...)\n    end\nend\nlocal timestamp,subevent,_,_,sourceName,_,_,guid,destName=CombatLogGetCurrentEventInfo()\nlocal spellId,spellName,spellSchool,amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing,isOffHand=select(12,CombatLogGetCurrentEventInfo())\nif sourceName==UnitName(\"player\")then\n    if subevent==\"SPELL_AURA_APPLIED\"then\n        if spellName==\"Glimmer of Light\"then\n            ClassHelper:ColorPartyRaidFrame(destName,true)\n        elseif spellName==\"Infusion of Light\"then\n            if ClassHelper.vars[\"Divine Purpose\"]then\n                ClassHelper.vars[\"Divine Purpose\"]=false\n                ClassHelper.vars[\"Infusion of Light\"]=true\n            else\n                AlertSystem:ShowText(\"\\124cff00ff00Powercast\")\n            end\n        elseif spellName==\"Hammer of Justice\"and IsInInstance()then\n            SendChatMessage(\"Hammer of Justice on \"..destName,\"YELL\")\n        elseif spellName==\"Divine Purpose\"then\n            PlaySound(8332)\n            AlertSystem:ShowText(\"\\124cffff66ffExtracast\")\n            ClassHelper.vars[\"Divine Purpose\"]=true\n            C_Timer.NewTimer(2,function()ClassHelper.vars[\"Divine Purpose\"]=false end)\n        elseif spellName==\"Divine Shield\"then\n            ClassHelper:NewBar(8,\"Divine Shield fades\"):SetColor(1,0,0,1)\n        elseif spellName==\"Forbearance\"then\n            ClassHelper:NewBar(30,\"Forbearance (\"..destName..\")\"):SetColor(1,0,0,1)\n        elseif spellName==\"Blessing of Freedom\"and destName~=UnitName(\"player\")and IsInInstance()and IsInRaid()then\n            SendChatMessage(\"Blessing of Freedom used on \"..destName..\"!\")\n        end\n    elseif subevent==\"SPELL_AURA_REMOVED\"then\n        if spellName==\"Glimmer of Light\"then\n            ClassHelper:ColorPartyRaidFrame(destName,false)\n        elseif spellName==\"Divine Purpose\"and ClassHelper.vars[\"Infusion of Light\"]then\n            AlertSystem:ShowText(\"\\124cff00ff00Powercast\")\n            ClassHelper.vars[\"Infusion of Light\"]=false\n        elseif spellName==\"Infusion of Light\"then\n            ClassHelper.vars[\"Infusion of Light\"]=false\n        end\n    elseif subevent==\"SPELL_CAST_SUCCESS\"then\n        if spellName==\"Beacon of Virtue\"then\n            ClassHelper:NewBar(15,\"Beacon CD\",200025):RegisterEvent(0,function()AlertSystem:ShowText(\"Beacon Ready\")end):SetColor(1,1,0,1)\n        elseif spellName==\"Avenging Wrath\"then\n            ClassHelper:NewBar(\"1:30\",\"Wings CD\",31884):SetColor(0,1,1,1)\n        elseif spellName==\"Avenging Crusader\"then\n            ClassHelper:NewBar(\"1:30\",\"Wings CD\",216331):SetColor(0,1,1,1)\n        elseif spellName==\"Aura Mastery\"and IsInInstance()then\n            SendChatMessage(\"Aura Mastery used!\")\n        elseif spellName==\"Holy Avenger\"then\n            ClassHelper:NewBar(\"3:00\",\"Holy Avenger CD\",spellId):SetColor(1,0,1,1)\n            ClassHelper:NewBar(20,\"COOLDLOWN: Holy Avenger\"):SetColor(1,0.5,0,1)\n        end\n    end\n    ClassHelper:DoManaAlerts()\nend",
        ["default_settings"] = "callouts: true",
        ["title"] = "Holy Paladin",
        ["unload"] = "ClassHelper.is_healer=false\nHOLY_PALADIN_MANA_BAR:Hide()\nHOLY_PALADIN_POWER_BAR:Hide()\nUNLOAD()\nClassHelper:SetCustomRaidFramesUpdateFunction(nil)\nClassHelper.vars[\"loaded\"]=false",
        ["reinit"] = "ClassHelper.vars[\"Divine Purpose\"]=false\nClassHelper.vars[\"Infusion of Light\"]=false\nClassHelper.is_healer=true\nHOLY_PALADIN_MANA_BAR:Show()\nHOLY_PALADIN_POWER_BAR:Show()\nClassHelper:SetCustomRaidFramesUpdateFunction(varsPointer[\"raidframesfunc\"])\nClassHelper.vars[\"loaded\"]=true",
        ["loadable"] = true,
        ["load"] = "spec:Paladin Holy",
        ["settings"] = "callouts: true\nshowGlimmer: true\nshowShockBarrier: false\nshowMindgames: true\nshowBeacons: true\nshowLightOfDawn: false"
    },
    ["0"]={
        ["X"]={
            ["1"]=5,
            ["A"]=1
        },
        ["9"]=9,
        ["G"]={
            ["^"]=6,
            ["&"]=7
        }
    }
}))]]