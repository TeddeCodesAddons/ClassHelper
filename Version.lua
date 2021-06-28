local outOfDate=false
if select(4,GetBuildInfo())>tonumber(ClassHelper.VERSION.interface)then
    ClassHelper.VERSION.isOutOfDate=true
    outOfDate=true
end
function ClassHelper:ShowIsOutOfDate(v)
    ClassHelper:DefaultSavedVariable("Version","Ignore",nil)
    if not(v==ClassHelper:Load("Version","Ignore"))then
        self:Print("Your version of ClassHelper needs an update. Go to CurseForge and update your AddOn for newer features. (Version "..v.." is available.)")
        self:Save("Version","Latest",v)
        self.VERSION.isOutOfDate=true
    end
end
function ClassHelper:SendVersion(channel)
    C_ChatInfo.SendAddonMessage("ClassHelper","V"..(self.VERSION.str),channel)
end
local has_entered_world=false
local f=CreateFrame("FRAME")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
local function handle()
    if not has_entered_world then
        ClassHelper:DefaultSavedVariable("Version","Ignore",nil)
        ClassHelper:DefaultSavedVariable("Version","Latest",nil)
        has_entered_world=true
        if outOfDate then
            ClassHelper:Print("Your version of ClassHelper has not been updated to the current interface. Please download the latest version from CurseForge. (If available)")
        end
        local latest=ClassHelper:Load("Version","Latest")
        if latest and latest~=ClassHelper.VERSION.str then
            ClassHelper:ShowIsOutOfDate(latest)
            ClassHelper.VERSION.latest={strsplit(".",latest)}
            ClassHelper.VERSION.isOutOfDate=true
        end
        ClassHelper:SendVersion("GUILD")
        ClassHelper:CreateSlashCommand("reset-version-checks","ClassHelper:RemoveLatestVersion()","Removes the latest version from the version check cache. Useful if you don't want to update your AddOn.")
    end
end
f:SetScript("OnEvent",handle)
function ClassHelper:RemoveLatestVersion()
    ClassHelper:Save("Version","Ignore",ClassHelper:Load("Version","Latest"))
    ClassHelper:Save("Version","Latest",nil)
    ClassHelper.VERSION.latest={strsplit(".",ClassHelper.VERSION.str)}
    ClassHelper.VERSION.isOutOfDate=false
    ClassHelper:Print("Will now ignore the latest version until another one comes out.")
end