local f=CreateFrame("FRAME")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
local loaded=false
local function handle()
    if not loaded then
        loaded=true
        ClassHelper:DefaultSavedVariable("Raidframes","Enabled","true")
        ClassHelper:DefaultSavedVariable("Raidframes","ThresholdLow",50)
        ClassHelper:DefaultSavedVariable("Raidframes","ThresholdHigh",95)
        ClassHelper.class_auras={

        }
        ClassHelper.is_healer=false
        ClassHelper.raid_frames_message_displayed=false
        function ClassHelper:UpdateRaidframes()
            local high=self:Load("Raidframes","ThresholdHigh")
            local low=self:Load("Raidframes","ThresholdLow")
            if IsInRaid()and self.is_healer and self:Load("Raidframes","Enabled")=="true"then
                if not self.raid_frames_message_displayed then
                    self.raid_frames_message_displayed=true
                    self:Print("Raidframes plugin is enabled. Type '/ch help raidframes' for more info.")
                end
                for i=1,40 do
                    local name
                    if _G["CompactRaidFrame"..i]and _G["CompactRaidFrame"..i].unit then
                        local realm
                        name,realm=UnitName(_G["CompactRaidFrame"..i].unit)
                        if realm then
                            name=name.."-"..realm
                        end
                    end
                    if name then
                        local h=UnitHealth(name)/UnitHealthMax(name)
                        if h<high/100 then -- If target is above 95%, they don't really need healing.
                            if h==0 or UnitIsDeadOrGhost(name)or(tContains(self.class_auras,name)and h>low/100)then -- If below 50%, don't care about auras, they could die. If they are dead, ignore them.
                                _G["CompactRaidFrame"..i.."HealthBarBackground"]:SetColorTexture(0,0,0,0) -- Normal texture, hides missing health
                            else
                                _G["CompactRaidFrame"..i.."HealthBarBackground"]:SetColorTexture(1,0,0,1) -- Red, needs an aura, <95%, heal this one!
                            end
                        else
                            _G["CompactRaidFrame"..i.."HealthBarBackground"]:SetColorTexture(0,1,0,1) -- Green, has aura and above 95%. Don't heal this one or it will overheal.
                        end
                    end
                end
            end
        end
        C_Timer.NewTicker(0.05,function()ClassHelper:UpdateRaidframes()end)
        function ClassHelper:EditFrameColor(frameId,red,green,blue,alpha)
            if not IsInRaid()then
                if frameId=="party0"then
                    PlayerName:SetTextColor(red,green,blue,alpha)
                elseif frameId=="party1"then
                    PartyMemberFrame1Name:SetTextColor(red,green,blue,alpha)
                elseif frameId=="party2"then
                    PartyMemberFrame2Name:SetTextColor(red,green,blue,alpha)
                elseif frameId=="party3"then
                    PartyMemberFrame3Name:SetTextColor(red,green,blue,alpha)
                elseif frameId=="party4"then
                    PartyMemberFrame4Name:SetTextColor(red,green,blue,alpha)
                else
                    self:Error("Core","EditFrameColor","Unknown frame",frameId)
                end
            end
        end
        if ClassHelper.is_healer then
            ClassHelper:EditFrameColor("party0",1,0,0,1) -- Pre-initialize tracker
            ClassHelper:EditFrameColor("party1",1,0,0,1)
            ClassHelper:EditFrameColor("party2",1,0,0,1)
            ClassHelper:EditFrameColor("party3",1,0,0,1)
            ClassHelper:EditFrameColor("party4",1,0,0,1)
        end
        function ClassHelper:GetAccurateUnit(name)
            if GetNumGroupMembers()>1 then
                for i=1,GetNumGroupMembers()-1 do
                    local n,r=UnitName(_G["PartyMemberFrame"..i].unit)
                    if r then
                        n=n.."-"..r
                    end
                    if n==name then
                        return i
                    end
                end
            end
            local p=UnitName("player")
            if p==name then
                return 0
            end
            return nil
        end
        function ClassHelper:ColorPartyRaidFrame(name,hasAura)
            if IsInRaid()and not IsActiveBattlefieldArena()then
                if hasAura then
                    if not tContains(self.class_auras,name)then
                        tinsert(self.class_auras,name)
                    end
                else
                    local idx=tIndexOf(self.class_auras,name)
                    if idx then
                        tremove(self.class_auras,idx)
                    end
                end
            else
                local idx=self:GetAccurateUnit(name)
                if idx then
                    if hasAura then r,g,b=0,1,0 else r,g,b=1,0,0 end
                    self:EditFrameColor("party"..idx,r,g,b,1)
                end
            end
        end
        ClassHelper:CreateSlashCommand("raidframes","ClassHelper:SetupHealerRaids(arguments)","Toggles on and off modded healer raid frames. (Type '/ch help raidframes' for more info)",{"This includes red damage bars (for incoming damage when they don't have your 'class aura')","Green filling when healing someone above 95% will cause an overheal if they have your 'class aura'.","If none are true, bar remains normal.","Another usage is '/ch raidframes threshold <high/low> <percent>'. This allows you to change the minimal percentage of damage to turn someone's raidframe red. EX: '/ch raidframes threshold high 95'.","\124cffff0000WARNING: ElvUI, Healbot, and many other addons that alter your raidframes are not supported!"})
        function ClassHelper:SetupHealerRaids(toggle)
            local a1,a2,a3=strsplit(" ",toggle)
            if strlower(a1)=="threshold"then
                if a2 then
                    a2=strlower(a2)
                end
                if a2 and(a2=="high"or a2=="low")then
                    if a3 and tonumber(a3)then
                        self:Print("Raid frames "..a2.." threshold set to \124cffff6600"..a3)
                        if a2=="high"then
                            a2="High"
                        elseif a2=="low"then
                            a2="Low"
                        end
                        self:Load("Raidframes","Threshold"..a2,a3)
                    elseif a3 then
                        self:Error("Slash command","raidframes","Number is not a number",a3)
                    else
                        if a2=="high"then
                            a2="High"
                        elseif a2=="low"then
                            a2="Low"
                        end
                        self:Print("Raid frames "..strupper(a2).." threshold is \124cffff6600"..(self:Load("Raidframes","Threshold"..a2)))
                    end
                else
                    self:Print("Raidframes threshold: ")
                    self:Print("\124cff00ff00HIGH: "..(self:Load("Raidframes","ThresholdHigh")))
                    self:Print("\124cffff0000LOW: "..(self:Load("Raidframes","ThresholdLow")))
                end
                return
            end
            local b=self:TextToBool(toggle)
            if b==1 then
                self:Save("Raidframes","Enabled","true")
                self:Print("Raid frames are now \124cff00ff00ENABLED")
            elseif b==0 then
                self:Save("Raidframes","Enabled","false")
                self:Print("Raid frames are now \124cffff0000DISABLED")
            elseif b==2 then
                if self:Load("Raidframes","Enabled")=="true"then
                    self:Save("Raidframes","Enabled","false")
                    self:Print("Raid frames are now \124cffff0000DISABLED")
                else
                    self:Save("Raidframes","Enabled","true")
                    self:Print("Raid frames are now \124cff00ff00ENABLED")
                end
            elseif b==-1 then
                if toggle=="show"or toggle=="print"or toggle==""then
                    if self:Load("Raidframes","Enabled")=="true"then
                        self:Print("Raid frames are currently \124cff00ff00ENABLED")
                    else
                        self:Print("Raid frames are currently \124cffff0000DISABLED")
                    end
                else
                    self:Error("Slash command","raidframes","Could not turn the following variable to true, false, or toggle:",toggle)
                end
            end
        end
    end
end
f:SetScript("OnEvent",handle)