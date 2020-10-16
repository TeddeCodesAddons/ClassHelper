ClassHelper.prevMana=0.15
ClassHelper.manaTimer=0
function ClassHelper:DoManaAlerts()
    if UnitPower("player",0)and UnitPowerMax("player",0)then
        if UnitPower("player",0)/UnitPowerMax("player",0)<0.15 and ClassHelper.prevMana>0.15 and GetTime()-ClassHelper.manaTimer>5 then
            ClassHelper.prevMana=0.15
            Airhorn()
            AlertSystem:ShowText("\124cffff0000MANA! (15%)")
            ClassHelper.manaTimer=GetTime()
        end
        if UnitPower("player",0)/UnitPowerMax("player",0)<0.35 and ClassHelper.prevMana>0.35 and GetTime()-ClassHelper.manaTimer>5 then
            ClassHelper.prevMana=0.35
            PlaySound(37666)
            AlertSystem:ShowText("Mana! (35%)")
            ClassHelper.manaTimer=GetTime()
        end
        if UnitPower("player",0)/UnitPowerMax("player",0)<0.5 and ClassHelper.prevMana>0.5 and GetTime()-ClassHelper.manaTimer>5 then
            ClassHelper.prevMana=0.5
            PlaySound(8332)
            AlertSystem:ShowText("\124cffffff00Mana! (50%)")
            ClassHelper.manaTimer=GetTime()
        end
        if UnitPower("player",0)/UnitPowerMax("player",0)>=0.15 then
            ClassHelper.prevMana=0.35
        end
        if UnitPower("player",0)/UnitPowerMax("player",0)>=0.35 then
            ClassHelper.prevMana=0.5
        end
        if UnitPower("player",0)/UnitPowerMax("player",0)>=0.5 then
            ClassHelper.prevMana=1
        end
    end
end
local powerDictionary={
    ["HEALTH_COST"]=-2,
    ["HEALTH COST"]=-2,
    ["HEALTHCOST"]=-2,
    ["NONE"]=-1,
    ["MANA"]=0,
    ["RAGE"]=1,
    ["FOCUS"]=2,
    ["ENERGY"]=3,
    ["COMBOPOINTS"]=4,
    ["COMBO_POINTS"]=4,
    ["COMBO POINTS"]=4,
    ["RUNES"]=5,
    ["RUNICPOWER"]=6,
    ["RUNIC_POWER"]=6,
    ["RUNIC POWER"]=6,
    ["SOULSHARDS"]=7,
    ["SOUL_SHARDS"]=7,
    ["SOUL SHARDS"]=7,
    ["SOUL_SHARD_FRAGMENTS"]="ACCURATE:7",
    ["SOUL SHARD FRAGMENTS"]="ACCURATE:7",
    ["SOULSHARDFRAGMENTS"]="ACCURATE:7",
    ["SOUL_SHARD_FRAGMENT"]="ACCURATE:7",
    ["SOUL SHARD FRAGMENT"]="ACCURATE:7",
    ["SOULSHARDFRAGMENT"]="ACCURATE:7",
    ["LUNAR_POWER"]=8,
    ["LUNAR POWER"]=8,
    ["LUNARPOWER"]=8,
    ["ASTRALPOWER"]=8,
    ["ASTRAL_POWER"]=8,
    ["ASTRAL POWER"]=8,
    ["HOLYPOWER"]=9,
    ["HOLY POWER"]=9,
    ["HOLY_POWER"]=9,
    ["ALTERNATE"]=10,
    ["MAELSTROM"]=11,
    ["CHI"]=12,
    ["INSANITY"]=13,
    ["OBSOLETE"]=14,
    ["OBSOLETE2"]=15,
    ["ARCANECHARGES"]=16,
    ["ARCANE CHARGES"]=16,
    ["ARCANE_CHARGES"]=16,
    ["FURY"]=17,
    ["PAIN"]=18,
    ["NUM_POWER_TYPES"]=19,
    ["HEALTH"]="HEALTH",
    ["DEFAULT"]="DEFAULT"
}
function ClassHelper:GetPowerType(power)
    if not power then return 0 end -- If nil, return mana
    if tonumber(power)==power then return power end -- If number, return itself
    power=strupper(power) -- If a string, make it caps
    if powerDictionary[power]then -- If in dictionary, then return it
        return powerDictionary[power]
    elseif tonumber(power)then
        return tonumber(power) -- Otherwise return as a number.
    elseif strsub(power,1,9)=="ACCURATE:"and tonumber(strsub(power,10,strlen(power)))then
        return power -- If an accurate power, return it as any type.
    else
        self:Print("\124cffff0000WARNING: An unknown power type was specified, so default was used instead.")
        return "DEFAULT" -- Return default power if unknown.
    end
end
function ClassHelper:NewPowerBar(powerType) -- Power bars NO LONGER SAVE. They MUST BE MADE by m.init.
    local powerbar=CreateFrame("Frame","Frame",UIParent)
    powerbar:SetSize(300,64)
    powerbar:SetPoint("CENTER",0,-100,UIParent)
    local powerbarBack=powerbar:CreateTexture(nil,"ARTWORK")
    powerbarBack:SetColorTexture(0,0,1,0.8)
    powerbarBack:SetPoint("LEFT")
    powerbarBack:SetSize(300,64)
    local powerbarBack2=powerbar:CreateTexture(nil,"BACKGROUND")
    powerbarBack2:SetColorTexture(0.1,0.1,0.1,0.4)
    powerbarBack2:SetPoint("CENTER")
    powerbarBack2:SetSize(300,64)
    local powerbarBack3=powerbar:CreateTexture(nil,"BACKGROUND")
    powerbarBack3:SetColorTexture(0,0,0,0)
    powerbarBack3:SetPoint("LEFT",powerbarBack,"RIGHT",0,0) -- Dynamic texture
    powerbarBack3:SetSize(300,64)
    local t1=powerbar:CreateFontString(nil,"OVERLAY")
    t1:SetFontObject(GameFontNormal)
    t1:SetPoint("CENTER",0,0,UIParent)
    t1:SetTextColor(1,1,1,1)
    t1:SetText("0")
    t1:SetScale(2)
    powerbar:RegisterForDrag("LeftButton")
    powerbar:SetMovable(true)
    powerbar:SetScript("OnDragStart",function(self)self:StartMoving()end)
    powerbar:SetScript("OnDragStop",function(self)self:StopMovingOrSizing()local _,_,_,x,y=self:GetPoint(1)self:SetPoint("CENTER",math.floor(x/10)*10,math.floor(y/10)*10,UIParent)end)
    powerbar:EnableMouse(false)
    powerbar:Hide()
    powerType=self:GetPowerType(powerType)
    local obj={
        color={
            0,
            0,
            1,
            0.2
        },
        fade={
            {
                1,
                "LESSTHANPERCENT",
                50,
                1,
                1,
                0,
                0.2
            },
            {
                1,
                "LESSTHANPERCENT",
                35,
                1,
                0.5,
                0,
                0.2
            },
            {
                1,
                "LESSTHANPERCENT",
                15,
                1,
                0,
                0,
                0.2
            }
        },
        display="PERCENT",
        dynamic=false,
        power=powerType,
        length=300,
        height=64
    }
    function obj:DisplayPercent()
        self.display="PERCENT"
        return self
    end
    function obj:DisplayNumber()
        self.display="NUMBER"
        return self
    end
    function obj:SetSize(length,height)
        if length then
            self.length=length
        end
        if height then
            self.height=height
        end
        powerbar:SetSize(self.length,self.height)
        powerbarBack2:SetSize(self.length,self.height)
        self:Update()
        return self
    end
    function obj:SetDisplayMode(mode)
        mode=strupper(mode)
        if mode=="PERCENT"or mode=="NUMBER"then
            self.display=mode
        else
            return "ERROR"
        end
        return self
    end
    function obj:ToggleDynamicDisplay(toggle)
        self.dynamic=toggle
        if toggle then
            powerbarBack3:Show()
        else
            powerbarBack3:Hide()
            self:Update()
        end
        return self
    end
    function obj:Fade(priority,condition,number,r,g,b,a)
        tinsert(self.fade,{priority,condition,number,r,g,b,a})
        return self
    end
    function obj:ClearFade()
        self.fade={

        }
        return self
    end
    function obj:SetColor(r,g,b,a)
        self.color={r,g,b,a}
        return self
    end
    function obj:Show()
        powerbar:Show()
        return self
    end
    function obj:Hide()
        powerbar:Hide()
        return self
    end
    function obj:SetPoint(point,x,y,relative)
        if not relative then
            relative=UIParent
        end
        powerbar:ClearAllPoints()
        powerbar:SetPoint(point,relative,point,x,y)
        return self
    end
    function obj:Unlock()
        powerbar:EnableMouse(true)
        return self
    end
    function obj:Lock()
        powerbar:EnableMouse(false)
        return self
    end
    function obj:GetPosition()
        return powerbar:GetPoint(1)
    end
    function obj:SetDynamicColor(r,g,b,a)
        self.dynamic_color={r,g,b,a}
        return self
    end
    function obj:DynamicUpdate(additionalPower) -- BETA TEST - Start casting a spell that uses power...
        local power=1 -- Then this new feature allows you to see the final outcome. (Run on event)
        local powerMax=1
        if strupper(self.power)=="HEALTH"then
            power=UnitHealth("player")
            powerMax=UnitHealthMax("player")
        elseif strupper(self.power)=="DEFAULT"then
            power=UnitPower("player")
            powerMax=UnitPowerMax("player")
        elseif strsub(strupper(self.power),1,9)=="ACCURATE:"then
            local p=strsub(self.power,10,strlen(self.power))
            power=UnitPower("player",p,true)
            powerMax=UnitPowerMax("player",p,true)
            local originalPowerMax=UnitPowerMax("player",p)
            local originalPower=UnitPower("player",p)
            powerMax=powerMax/originalPowerMax
            power=power-(originalPower*powerMax)
        else
            power=UnitPower("player",self.power)
            powerMax=UnitPowerMax("player",self.power)
        end
        if additionalPower+power>powerMax then
            additionalPower=powerMax-power
        end
        local color=self.color
        local priority=0
        if getn(self.fade)>0 then
            for i=1,getn(self.fade)do
                if self.fade[i]then
                    local a=self.fade[i]
                    if a[1]and a[1]>priority then
                        if a[2]=="GREATERTHAN"then
                            if power>a[3]then
                                color={
                                    a[4],
                                    a[5],
                                    a[6],
                                    a[7]
                                }
                            end
                        elseif a[2]=="LESSTHAN"then
                            if power<a[3]then
                                color={
                                    a[4],
                                    a[5],
                                    a[6],
                                    a[7]
                                }
                            end
                        elseif a[2]=="EQUALS"then
                            if power==a[3]then
                                color={
                                    a[4],
                                    a[5],
                                    a[6],
                                    a[7]
                                }
                            end
                        elseif a[2]=="LESSTHANPERCENT"then
                            if power/powerMax<a[3]/100 then
                                color={
                                    a[4],
                                    a[5],
                                    a[6],
                                    a[7]
                                }
                            end
                        elseif a[2]=="GREATERTHANPERCENT"then
                            if power/powerMax>a[3]/100 then
                                color={
                                    a[4],
                                    a[5],
                                    a[6],
                                    a[7]
                                }
                            end
                        elseif a[2]=="EQUALSPERCENT"then
                            if power/powerMax==a[3]/100 then
                                color={
                                    a[4],
                                    a[5],
                                    a[6],
                                    a[7]
                                }
                            end
                        end
                    end
                end
            end
        end
        powerbarBack:SetColorTexture(color[1],color[2],color[3],color[4])
        powerbarBack:SetSize(power*self.length/powerMax,self.height)
        if additionalPower>0 then
            if self.dynamic_color then
                powerbarBack3:SetColorTexture(self.dynamic_color[1],self.dynamic_color[2],self.dynamic_color[3],self.dynamic_color[4])
            else
                powerbarBack3:SetColorTexture(color[1],color[2],color[3],color[4]/2)
            end
        elseif additionalPower<0 then
            powerbarBack:SetSize((power+additionalPower)*self.length/powerMax,self.height)
            if self.dynamic_color then
                powerbarBack3:SetColorTexture(self.dynamic_color[1],self.dynamic_color[2],self.dynamic_color[3],self.dynamic_color[4])
            else
                powerbarBack3:SetColorTexture(color[1],color[2],color[3],color[4]/2)
            end
        else
            powerbarBack3:SetColorTexture(0,0,0,0)
        end
        powerbarBack3:SetSize((math.abs(additionalPower))*self.length/powerMax,self.height)
        if self.display=="PERCENT"then
            t1:SetText((math.floor(power*1000/powerMax)/10).."%")
        else
            t1:SetText(power+additionalPower)
        end
        return self
    end
    function obj:Update(auto)
        if auto and self.dynamic then return end
        local power=1
        local powerMax=1
        if strupper(self.power)=="HEALTH"then
            power=UnitHealth("player")
            powerMax=UnitHealthMax("player")
        elseif strupper(self.power)=="DEFAULT"then
            power=UnitPower("player")
            powerMax=UnitPowerMax("player")
        elseif strsub(strupper(self.power),1,9)=="ACCURATE:"then
            local p=strsub(self.power,10,strlen(self.power))
            power=UnitPower("player",p,true)
            powerMax=UnitPowerMax("player",p,true)
            local originalPowerMax=UnitPowerMax("player",p)
            local originalPower=UnitPower("player",p)
            powerMax=powerMax/originalPowerMax
            power=power-(originalPower*powerMax)
        else
            power=UnitPower("player",self.power)
            powerMax=UnitPowerMax("player",self.power)
        end
        local color=self.color
        local priority=0
        if getn(self.fade)>0 then
            for i=1,getn(self.fade)do
                if self.fade[i]then
                    local a=self.fade[i]
                    if a[1]and a[1]>priority then
                        if a[2]=="GREATERTHAN"then
                            if power>a[3]then
                                color={
                                    a[4],
                                    a[5],
                                    a[6],
                                    a[7]
                                }
                            end
                        elseif a[2]=="LESSTHAN"then
                            if power<a[3]then
                                color={
                                    a[4],
                                    a[5],
                                    a[6],
                                    a[7]
                                }
                            end
                        elseif a[2]=="EQUALS"then
                            if power==a[3]then
                                color={
                                    a[4],
                                    a[5],
                                    a[6],
                                    a[7]
                                }
                            end
                        elseif a[2]=="LESSTHANPERCENT"then
                            if power/powerMax<a[3]/100 then
                                color={
                                    a[4],
                                    a[5],
                                    a[6],
                                    a[7]
                                }
                            end
                        elseif a[2]=="GREATERTHANPERCENT"then
                            if power/powerMax>a[3]/100 then
                                color={
                                    a[4],
                                    a[5],
                                    a[6],
                                    a[7]
                                }
                            end
                        elseif a[2]=="EQUALSPERCENT"then
                            if power/powerMax==a[3]/100 then
                                color={
                                    a[4],
                                    a[5],
                                    a[6],
                                    a[7]
                                }
                            end
                        end
                    end
                end
            end
        end
        powerbarBack:SetColorTexture(color[1],color[2],color[3],color[4])
        powerbarBack:SetSize(power*self.length/powerMax,self.height)
        if self.display=="PERCENT"then
            t1:SetText((math.floor(power*1000/powerMax)/10).."%")
        else
            t1:SetText(power)
        end
        return self
    end
    C_Timer.NewTicker(0.1,function()obj:Update(true)end)
    return obj:Show()
end