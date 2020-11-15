-- The mod sharing script.
local sending=false
local pings={
    
}
local denyTimestamp=0
local denyMod=""
local ch=""
local rec=""
local bytes=0
local updateFunc=function()end
local function s(msg)
    tinsert(pings,strsub(msg,1,255))
    bytes=bytes+strlen(strsub(msg,1,255))
    sending=true
    if strlen(msg)>256 then
        s(strsub(msg,256,strlen(msg)))
    end
end
C_Timer.NewTicker(0.25,function()
    if bytes>0 then
        C_ChatInfo.SendAddonMessage("ClassHelper","8"..bytes,ch,rec)
        bytes=0
    elseif pings[1]then
        C_ChatInfo.SendAddonMessage("ClassHelper",pings[1],ch,rec)
        tremove(pings,1)
    else
        if sending then
            ClassHelper:Print("Your mod was sent, and the reciever was notified.")
        end
        sending=false
    end
end)
local recieve={

}
local function notifyMod(sender,timestamp)
    ClassHelper:DefaultSavedVariable("Share","NotificationsEnabled","true")
    if ClassHelper:Load("Share","NotificationsEnabled")=="true"then
        ClassHelper:Print("On "..timestamp..", "..sender.." shared a mod with you! Open the sharing section of the UI to download the mod.")
    end
    updateFunc()
end
C_ChatInfo.RegisterAddonMessagePrefix("ClassHelper")
local f=CreateFrame("FRAME")
f:RegisterEvent("CHAT_MSG_ADDON")
local function handle(self,event,...)
    if event=="CHAT_MSG_ADDON"then
        local prefix,text,channel,sender=...
        if prefix=="ClassHelper"and(channel=="RAID"or channel=="PARTY"or channel=="WHISPER")then
            local t=""
            if strlen(text)>1 then
                t=strsub(text,2,strlen(text))
            end
            local p=strsub(text,1,1)
            if tonumber(p)and tonumber(p)<8 and denyMod==sender then return end -- Ignore mods that have been denied transmission.
            if p=="0"then
                local bytes2=0
                if recieve[sender]and recieve[sender].bytes then
                    bytes2=recieve[sender].bytes
                end
                recieve[sender]={
                    title=t,
                    data="",
                    init="",
                    unload="",
                    reinit="",
                    load="",
                    loadable=nil,
                    transmitting=true,
                    sender=sender,
                    timestamp=date(),
                    bytes=bytes2
                }
                updateFunc()
            elseif p=="1"then
                recieve[sender].title=recieve[sender].title..t
            elseif p=="2"then
                recieve[sender].data=recieve[sender].data..t
            elseif p=="3"then
                recieve[sender].init=recieve[sender].init..t
            elseif p=="4"then
                recieve[sender].unload=recieve[sender].unload..t
            elseif p=="5"then
                recieve[sender].reinit=recieve[sender].reinit..t
            elseif p=="6"then
                recieve[sender].load=recieve[sender].load..t
            elseif p=="7"then
                if t=="1"then
                    recieve[sender].loadable=true
                else
                    recieve[sender].loadable=false
                end
                recieve[sender].transmitting=nil
                notifyMod(sender,recieve[sender].timestamp)
            elseif p=="8"then
                ClassHelper:DefaultSavedVariable("Share","MaxBytes",65536) -- 64 KB seems about right for most mods.
                if tonumber(t)then
                    t=tonumber(t)
                else
                    return
                end
                if (not(ClassHelper:Load("Share","MaxBytes")==-1))and channel=="WHISPER"and not(t<ClassHelper:Load("Share","MaxBytes"))then -- If more than the max bytes, then deny request.
                    if GetTime()-denyTimestamp<5 then
                        C_ChatInfo.SendAddonMessage("ClassHelper","9","WHISPER",sender)
                        denyTimestamp=GetTime()
                    end
                    denyMod=sender
                elseif (not(ClassHelper:Load("Share","MaxBytes")==-1))and denyMod==sender and t<ClassHelper:Load("Share","MaxBytes")then
                    denyMod=""
                end
                if (not(ClassHelper:Load("Share","MaxBytes")==-1))and t<ClassHelper:Load("Share","MaxBytes")then
                    recieve[sender]={
                        title="",
                        data="",
                        init="",
                        unload="",
                        reinit="",
                        load="",
                        loadable=nil,
                        transmitting=true,
                        sender=sender,
                        timestamp=date(),
                        bytes=t
                    }
                    updateFunc()
                end
            elseif p=="9"then
                if ch=="WHISPER"and rec==sender then -- If denied, then simply delete all the pings.
                    pings={

                    }
                end
            end
        end
    end
end
f:SetScript("OnEvent",handle)
function ClassHelper:DownloadModFromSender(sender)
    if recieve[sender].transmitting then
        self:Print("You couldn't download the mod because it was still in transmission. Please wait for it to complete before attempting to download the mod.")
        return
    end
    local title=recieve[sender].title
    local data=recieve[sender].data
    local init=recieve[sender].init
    local unload=recieve[sender].unload
    local reinit=recieve[sender].reinit
    local load=recieve[sender].load
    local loadable=recieve[sender].loadable
    local m={
        title=title,
        data=data,
        init=init,
        unload=unload,
        reinit=reinit,
        load=load,
        loadable=loadable
    }
    local x=ClassHelper:NewMod(m)
    if x then
        self:Print("Mod downloaded successfully! (Saved as "..title..")")
    else
        self:Print("You couldn't download the mod because you already have a mod with the same name. Please delete that mod before attempting to download the new mod.")
    end
end
function ClassHelper:ShareMod(modObject,channel,recipient)
    ch=channel
    rec=recipient
    bytes=0
    if sending then
        self:Print("\124cffff0000Please wait to send another mod! If you send mods too quickly, they can be mixed up by the reciever.")
        return
    end
    sending=true
    self:Print("Your mod is being sent. Please wait...")
    local data="0"..strsub(modObject.title,1,254)
    local i=255
    while i<strlen(modObject.title)do
        local d="1"..strsub(modObject.title,i,i+253)
        data=data..d
        i=i+254
    end
    s(data)
    i=1
    data=""
    while i<strlen(modObject.data)do
        local d="2"..strsub(modObject.data,i,i+253)
        data=data..d
        i=i+254
    end
    s(data)
    i=1
    data=""
    while i<strlen(modObject.init)do
        local d="3"..strsub(modObject.init,i,i+253)
        data=data..d
        i=i+254
    end
    s(data)
    i=1
    data=""
    while i<strlen(modObject.unload)do
        local d="4"..strsub(modObject.unload,i,i+253)
        data=data..d
        i=i+254
    end
    s(data)
    i=1
    data=""
    while i<strlen(modObject.reinit)do
        local d="5"..strsub(modObject.reinit,i,i+253)
        data=data..d
        i=i+254
    end
    s(data)
    i=1
    data=""
    while i<strlen(modObject.load)do
        local d="6"..strsub(modObject.load,i,i+253)
        data=data..d
        i=i+254
    end
    s(data)
    if modObject.loadable then
        s("71",channel,recipient)
    else
        s("72",channel,recipient)
    end
    bytes=bytes+2
end
function ClassHelper:Share(modName,channel,recipient)
    local m=self:LoadModByName(modName)
    if not m then self:Print("You don't have a mod called \124cffffffff"..modName.."\124r!")return end
    self:ShareMod(m,channel,recipient)
end
local function init()
    local panel=ClassHelper:NewUIPanel("Sharing mods")
    local scroll=CreateFrame("ScrollFrame",nil,panel,"UIPanelScrollFrameTemplate")
    scroll:SetSize(775,670)
    scroll:SetPoint("RIGHT",-25,0)
    local panel2=CreateFrame("FRAME",nil,panel)
    panel2:SetSize(775,670)
    panel2:SetPoint("RIGHT",panel,"RIGHT",0,0)
    local id=0
    local buttons={

    }
    local textlist={

    }
    local function newEntry(entry)
        entry=recieve[entry]
        if not entry then return end
        id=id+1
        local t=textlist[id]
        if not t then
            t=panel2:CreateFontString(nil,"ARTWORK","GameFontNormal")
            t:SetPoint("TOPLEFT",60,(id*-30)-50)
            tinsert(textlist,t)
        end
        if entry.transmitting then
            t:SetText("\124cffffffff("..(entry.timestamp)..") \124cffff6600"..(entry.sender).."\124r: \124r"..(entry.title).." \124cffffffff("..(entry.bytes).." bytes) \124cffff0000IN TRANSMISSION")
        else
            t:SetText("\124cffffffff("..(entry.timestamp)..") \124cffff6600"..(entry.sender).."\124r: \124r"..(entry.title).." \124cffffffff("..(entry.bytes).." bytes) \124cff00ff00READY FOR DOWNLOAD")
        end
        local b=buttons[id]
        if not b then
            b=CreateFrame("CheckButton",nil,panel2,"ChatConfigCheckButtonTemplate")
            b:SetPoint("TOPLEFT",30,(id*-30)-45)
            tinsert(buttons,b)
        end
        b.tooltip="Click here to download the mod."
        b:SetScript("OnClick",function(self)
            self:SetChecked(false)
            ClassHelper:DownloadModFromSender(entry.sender)
        end)
    end
    local function update()
        id=0
        for i,v in pairs(recieve)do
            newEntry(i)
        end
    end
    updateFunc=update
    scroll:SetScrollChild(panel2)
    local refreshButton=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
    refreshButton:SetText("Refresh")
    refreshButton:SetWidth(100)
    refreshButton:SetPoint("TOPLEFT",10,-10)
    refreshButton:SetScript("OnClick",function()update()ClassHelper:Print("Updating...")end)
    local modNameBox=CreateFrame("EditBox",nil,panel)
    modNameBox:SetSize(500,20)
    modNameBox:SetAutoFocus(false)
    modNameBox:SetPoint("TOPRIGHT",-40,-20)
    modNameBox:SetFont("Interface\\AddOns\\ClassHelper\\Assets\\monaco.ttf",9)
    modNameBox:SetCursorPosition(0)
    modNameBox:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
    local modNameTexture=panel:CreateTexture(nil,"ARTWORK")
    modNameTexture:SetColorTexture(0.05,0.05,0.05,0.8)
    modNameTexture:SetSize(500,20)
    modNameTexture:SetPoint("TOPRIGHT",-40,-20)
    local sendToBox=CreateFrame("EditBox",nil,panel)
    sendToBox:SetSize(500,20)
    sendToBox:SetAutoFocus(false)
    sendToBox:SetPoint("TOPRIGHT",-40,-50)
    sendToBox:SetFont("Interface\\AddOns\\ClassHelper\\Assets\\monaco.ttf",9)
    sendToBox:SetCursorPosition(0)
    sendToBox:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
    local sendToTexture=panel:CreateTexture(nil,"ARTWORK")
    sendToTexture:SetColorTexture(0.05,0.05,0.05,0.8)
    sendToTexture:SetSize(500,20)
    sendToTexture:SetPoint("TOPRIGHT",-40,-50)
    local t=panel2:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
    t:SetPoint("BOTTOMLEFT",260,10)
    t:SetText("To download a mod, simply click the checkbox.\nYou might need to refresh to see the mod.\nTo share a mod, type the mod name in the first box, and the recipient in the second box.\n(Or leave it empty for group transmission)")
    local sendButton=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
    sendButton:SetText("Send mod")
    sendButton:SetWidth(100)
    sendButton:SetPoint("TOPLEFT",150,-10)
    sendButton:SetScript("OnClick",function()
        if sendToBox:GetText()==""then
            if IsInRaid()then
                ClassHelper:Share(modNameBox:GetText(),"RAID")
            elseif IsInGroup()then
                ClassHelper:Share(modNameBox:GetText(),"PARTY")
            else
                ClassHelper:Print("\124cffff0000You aren't in a group, please fill out the recipient box.")
            end
        elseif strfind(sendToBox:GetText(),"-",1,true)then
            ClassHelper:Print("\124cffff0000You aren't on the same realm as who you are attempting to send this mod to! \124rAddons cannot send private invisible messages to players unless they are on the same realm. To work around this, invite that player to a group.")
        else
            ClassHelper:Share(modNameBox:GetText(),"WHISPER",sendToBox:GetText())
        end
    end)
    modNameBox:SetText("<Mod name>")
    sendToBox:SetText("<Send to>")
    modNameBox:SetScript("OnTabPressed",function()sendToBox:SetFocus()end)
    sendToBox:SetScript("OnTabPressed",function()modNameBox:SetFocus()end)
end
local f=CreateFrame("FRAME")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
local in_world=false
f:SetScript("OnEvent",function()if in_world then return end in_world=true init()end)