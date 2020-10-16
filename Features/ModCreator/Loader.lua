local loaded_mods={

}
local already_loaded={

}
local modvars={ -- New feature, allows mods to have their own environment, rather than making global variables.

}
function ClassHelper:LoadAllCurrentMods()
    local class=UnitClass("player")
    local specId=""
    local spec=""
    if GetSpecialization then -- Classic WoW does not have this feature.
        specId=GetSpecialization()
        spec=self.all_specs[class][specId]
    end
    local zone=GetZoneText()
    local zoneid=select(8,GetInstanceInfo())
    local all={
        "class:"..class,
        "spec:"..class.." "..spec,
        "specid:"..class..specId,
        "zone:"..zone,
        "zoneid:"..zoneid,
        "all",
        "custom"
    }
    for i=1,getn(all)do
        local mods=self:LoadModsByCondition(all[i])
        for i=1,getn(mods)do
            local m=mods[i]
            if not tContains(already_loaded,m.title)then
                tinsert(already_loaded,m.title)
                if not m.reinit then
                    m.reinit=m.init
                end
                if not m.unload then
                    m.unload=""
                end
                local modObject={
                    data=m.data,
                    init=m.init,
                    unload=m.unload,
                    reinit=m.reinit,
                    firstrun=true,
                    loaded=false,
                    load=m.load,
                    loadable=m.loadable,
                    title=m.title
                }
                function modObject:Load()
                    if self.loadable and not self.loaded then
                        if modvars[self.title]then
                            ClassHelper.vars=modvars[self.title]
                        else
                            modvars[self.title]={

                            }
                            ClassHelper.vars={

                            }
                        end
                        if strlower(self.load)=="custom"then
                            if self.firstrun then
                                RunScript("ClassHelper.system_loadMod=false local function LOAD()ClassHelper.system_loadMod=true end;"..self.init)
                            else
                                RunScript("ClassHelper.system_loadMod=false local function LOAD()ClassHelper.system_loadMod=true end;"..self.reinit)
                            end
                            if ClassHelper.system_loadMod then
                                self.loaded=true
                                if self.firstrun then
                                    ClassHelper:Print("Loaded \124cff00ffff"..(self.title).."\124cffffff00 mods.")
                                end
                                self.firstrun=false
                            end
                            ClassHelper.system_loadMod=nil -- Never store this value.
                        else
                            if self.firstrun then
                                self.firstrun=false
                                RunScript(self.init)
                            else
                                RunScript(self.reinit)
                            end
                            self.loaded=true
                        end
                        modvars[self.title]=ClassHelper.vars
                    end
                end
                function modObject:Run()
                    ClassHelper.vars=modvars[self.title]
                    if self.loaded and self.loadable then
                        RunScript(self.data)
                    end
                    modvars[self.title]=ClassHelper.vars
                end
                function modObject:Unload()
                    ClassHelper.vars=modvars[self.title]
                    if self.loaded and self.unload~=""then
                        RunScript("ClassHelper.system_unloadMod=false local function UNLOAD()ClassHelper.system_unloadMod=true end;"..self.unload)
                        if ClassHelper.system_unloadMod then
                            self.loaded=false
                        end
                        ClassHelper.system_unloadMod=nil -- Never store this value.
                    end
                    modvars[self.title]=ClassHelper.vars
                end
                tinsert(loaded_mods,modObject)
                if strlower(m.load)~="custom"then
                    self:Print("Loaded \124cff00ffff"..(m.title).."\124cffffff00 mods.")
                end
            end
        end
    end
    for i=1,getn(loaded_mods)do -- Unload mods
        local m=loaded_mods[i]
        if not tContains(all,m.load)or strlower(m.load)=="custom"then
            m:Unload()
        end
    end
    for i=1,getn(loaded_mods)do -- Load mods
        local m=loaded_mods[i]
        if tContains(all,m.load)then
            m:Load()
        end
    end
end
local TaskManager={
    textlist={

    },
    buttons={

    },
    taskId=0,
    selected={

    }
}
function ClassHelper:UnloadMod(modName)
    for i=1,getn(loaded_mods)do
        if loaded_mods[i].title==modName then
            loaded_mods[i]:Unload()
            loaded_mods[i].loaded=false
        end
    end
end
function ClassHelper:TempDisableMod(modName)
    for i=1,getn(loaded_mods)do
        if loaded_mods[i].title==modName then
            loaded_mods[i]:Unload()
            loaded_mods[i].loaded=false
            loaded_mods[i].loadable=false -- Temporarily disables mod
        end
    end
end
function ClassHelper:InitMod(modName)
    for i=1,getn(loaded_mods)do
        if loaded_mods[i].title==modName then
            loaded_mods[i].loaded=true
            loaded_mods[i].loadable=true -- Temporarily disabled? Restart.
            loaded_mods[i]:Load()
        end
    end
end
function TaskManager:Init()
    local panel=ClassHelper:NewUIPanel("Task Manager")
    local scroll=CreateFrame("ScrollFrame",nil,panel,"UIPanelScrollFrameTemplate")
    scroll:SetSize(775,670)
    scroll:SetPoint("RIGHT",-25,0)
    local panel2=CreateFrame("FRAME",nil,panel)
    panel2:SetSize(775,670)
    panel2:SetPoint("RIGHT",panel,"RIGHT",0,0)
    function TaskManager:NewTask(taskName,isLoaded,isEnabled)
        self.taskId=self.taskId+1
        local t=self.textlist[self.taskId]
        if not t then
            t=panel2:CreateFontString(nil,"ARTWORK","GameFontNormal")
            t:SetPoint("TOPLEFT",60,(self.taskId*-30)-50)
            tinsert(self.textlist,t)
        end
        if isEnabled then
            if isLoaded then
                t:SetText(taskName.." \124cff00ff00(Running)")
            else
                t:SetText(taskName.." \124cff999999(Unloaded)")
            end
        else
            t:SetText(taskName.." \124cffff0000(Temporarily Disabled)")
        end
        local b=self.buttons[self.taskId]
        if not b then
            b=CreateFrame("CheckButton",nil,panel2,"ChatConfigCheckButtonTemplate")
            b:SetPoint("TOPLEFT",30,(self.taskId*-30)-45)
            tinsert(self.buttons,b)
        end
        b.tooltip="Select \124cffffffff"..taskName.."\124r. This task can be \124cff999999ended\124r, \124cffff0000disabled\124r, or \124cff00ff00restarted\124r."
        if tContains(self.selected,taskName)then
            b:SetChecked(true)
        else
            b:SetChecked(false)
        end
        b:SetScript("OnClick",function(self)
            if self:GetChecked()then
                if not tContains(TaskManager.selected,taskName)then
                    tinsert(TaskManager.selected,taskName)
                end
            else
                local idx=tIndexOf(TaskManager.selected,taskName)
                if idx then
                    tremove(TaskManager.selected,idx)
                end
            end
        end)
    end
    function TaskManager:Update()
        self.taskId=0
        for i=1,getn(loaded_mods)do
            self:NewTask(loaded_mods[i].title,loaded_mods[i].loaded,loaded_mods[i].loadable)
        end
    end
    function TaskManager:End(tasks)
        for i=1,getn(tasks)do
            ClassHelper:UnloadMod(tasks[i])
            ClassHelper:Print("\124cffff0000Ending task: \124cffffff00"..tasks[i])
        end
        self:Update()
    end
    function TaskManager:Disable(tasks)
        for i=1,getn(tasks)do
            ClassHelper:TempDisableMod(tasks[i])
            ClassHelper:Print("\124cffff0000Disabling task: \124cffffff00"..tasks[i])
        end
        self:Update()
    end
    function TaskManager:StartTasks(tasks)
        for i=1,getn(tasks)do
            ClassHelper:InitMod(tasks[i])
            ClassHelper:Print("\124cff00ff00Starting: \124cffffff00"..tasks[i])
        end
        self:Update()
    end
    scroll:SetScrollChild(panel2)
    local endButton=CreateFrame("Button",nil,panel2,"UIPanelButtonTemplate")
    endButton:SetText("End task(s)")
    endButton:SetWidth(100)
    endButton:SetPoint("TOPLEFT",10,-10)
    endButton:SetScript("OnClick",function()TaskManager:End(TaskManager.selected)end)
    local disableButton=CreateFrame("Button",nil,panel2,"UIPanelButtonTemplate")
    disableButton:SetText("\124cffff0000Disable")
    disableButton:SetWidth(100)
    disableButton:SetPoint("TOPLEFT",130,-10)
    disableButton:SetScript("OnClick",function()TaskManager:Disable(TaskManager.selected)end)
    local initButton=CreateFrame("Button",nil,panel2,"UIPanelButtonTemplate")
    initButton:SetText("\124cff00ff00(Re)start")
    initButton:SetWidth(100)
    initButton:SetPoint("TOPLEFT",250,-10)
    initButton:SetScript("OnClick",function()TaskManager:StartTasks(TaskManager.selected)end)
    local t=panel2:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
    t:SetPoint("TOPLEFT",260,-30)
    t:SetText("\124cffff6600Some mods may not unload completely.\nYou may need to type '/reload' to reload your UI.\nThe mod may also load again when you do that.\nIf you want to disable a mod from loading again, uncheck the 'Enabled' box in the mod editor.")
end
local entered_world=false
local f=CreateFrame("FRAME")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
if GetSpecialization then
    f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED") -- Classic WoW does not have this feature.
end
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
local function handle(self,event,...)
    if event=="COMBAT_LOG_EVENT_UNFILTERED"then
        for i=1,getn(loaded_mods)do
            loaded_mods[i]:Run()
        end
    else
        if event=="PLAYER_ENTERING_WORLD"and not entered_world then
            entered_world=true
            TaskManager:Init()
        end
        ClassHelper:LoadAllCurrentMods()
        TaskManager:Update()
    end
end
f:SetScript("OnEvent",handle)