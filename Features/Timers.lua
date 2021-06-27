-- -- [Timer bars example 1]
-- local timer=ClassHelper:NewTimer(60,"My custom timer")
-- timer:RegisterEvent(15,function()print("15 seconds left on the timer!")end)
-- timer:RegisterEvent(0,function()print("Timer expired!")end)
-- -- [Timer bars example 2]
-- ClassHelper:NewTimer(5,"My custom timer"):RegisterEvent(0,function()print("Timer expired!")end)

local all_bars={

}
local function createBar()
    local barObject={
        start_time=0,
        end_time=0,
        current_time=0,
        last_update=0,
        events={

        },
        enabled=false,
        is_restricted=false,
        paused=false
    }
    function barObject:Start(totalTime,cooldown)
        if cooldown~=nil then
            self.cooldown=cooldown
        else
            self.cooldown=-1
        end
        totalTime=ClassHelper:ConvertTime(totalTime)
        local t=GetTime()
        if self.maxTime then
            self.start_time=t-(self.maxTime-totalTime)
        else
            self.start_time=t
        end
        self.end_time=totalTime+t
        self.current_time=t
        self.last_update=t
        self.paused=false
        self.events={

        }
        self.enabled=true
        return self
    end
    function barObject:RegisterEvent(_time,_function)
        tinsert(self.events,{_time,_function,false})
        return self
    end
    function barObject:Resume()
        self.paused=false
        return self
    end
    function barObject:Stop()
        self.events={

        }
        self.enabled=false
        return self
    end
    function barObject:ChangeTime(_time,setEqual)
        if setEqual and not(self.is_restricted and _time<self.current_time)then
            self.current_time=self.end_time-_time
        elseif not setEqual then
            self.current_time=self.current_time+_time
        end
        if self.current_time<self.start_time then
            self.start_time=self.current_time
            self.last_update=self.current_time
        end
        return self
    end
    function barObject:SetConstantMaxTime(maxTime)
        self.maxTime=maxTime
        return self
    end
    function barObject:RemoveConstantMaxTime()
        self.maxTime=nil
        return self
    end
    local function update()
        if barObject.paused then return end
        if barObject.enabled then
            if barObject.cooldown==-1 then
                barObject:ChangeTime(GetTime()-barObject.last_update,false)
            elseif barObject.last_update>barObject.start_time then
                local _time,CD=GetSpellCooldown(barObject.cooldown)
                local gcd_time,GCD=GetSpellCooldown(61304) -- Global cooldown
                if GCD-(GetTime()-gcd_time)~=CD-(GetTime()-_time)then
                    barObject:ChangeTime(CD-(GetTime()-_time),true)
                else -- If on global then tick down to 0 and expire.
                    barObject:ChangeTime(GetTime()-barObject.last_update,false)
                end
            end
            barObject.last_update=GetTime()
            local et=barObject.end_time-barObject.current_time
            local st=barObject.current_time-barObject.start_time
            local tt=et+st
            st=st*2
            et=et*2
            if getn(barObject.events)>0 then
                for i=1,getn(barObject.events)do
                    if barObject.end_time-barObject.current_time<=barObject.events[i][1]and not barObject.events[i][3]then
                        barObject.events[i][3]=true
                        barObject.events[i][2]()
                    end
                end
            end
            if barObject.current_time>=barObject.end_time then
                barObject:Stop()
            end
        end
    end
    function barObject:Pause()
        update()
        self.paused=true
        return self
    end
    C_Timer.NewTicker(0.05,update)
    update()
    tinsert(all_bars,barObject)
end
function ClassHelper:NewTimer(_time,cooldown)
    local barObject="none"
    for i=1,getn(all_bars)do
        if not all_bars[i].enabled then
            barObject=all_bars[i]
        end
    end
    if barObject=="none"then
        createBar()
        return all_bars[getn(all_bars)]:Start(_time,cooldown)
    end
    return barObject:Start(_time,cooldown)
end