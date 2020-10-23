<<<<<<< HEAD
local panel=ClassHelper:NewUIPanel("FAQ")
local desc=panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
desc:SetText("Select an option for more info.")
desc:SetPoint("TOPLEFT",280,-15)
desc:SetJustifyH("LEFT")
desc:SetWidth(500)
local lastPos=0
local lastButton
local function newFAQ(questionName,description,width,header)
    local button=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
    button:SetText(questionName)
    if width then
        button:SetWidth(width)
    else
        button:SetWidth(100)
    end
    lastPos=lastPos-30
    if header then
        local head=panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
        head:SetText(header)
        head:SetPoint("TOPLEFT",20,lastPos)
        lastPos=lastPos-30
        button:SetPoint("TOPLEFT",40,lastPos)
    else
        button:SetPoint("TOPLEFT",40,lastPos)
    end
    button:SetScript("OnClick",function(self)desc:SetText(description)self:Disable()if lastButton then lastButton:Enable()end lastButton=self end)
end
newFAQ("Raidframes errors",[[If your raidframes won't show, you likely didn't set the |cffff6600ClassHelper.is_healer|r variable in the mod settings.
Another thing you could have forgotten is to set the raidframe's color when the aura is applied. In order to set the colors, use |cffff6600ClassHelper:ColorPartyRaidFrame(destName,true)|r to say they have an aura (EX: Glimmer of Light/Rejuvenation), or false if they don't.
If you want your raidframes to stay normal-colored even when someone is low and has your aura, type this: '|cffff6600/ch raidframes threshold low 0|r'.
If you want your raidframes to stay normal-colored above the high threshold, type this: '|cffff6600/ch raidframes threshold high 100|r'.]],200)
newFAQ("Dynamic power bars",[[If you want spells' power costs to show on your bar when you cast them, you have come to the right place.
Dynamic power bars allow you to show the final power you will have on the bar when you are done casting the current spell.
This requires a lot of setup however, and is not recommended for beginner programmers. The following code below shows how to create a dynamic update for the Regrowth cast.
|cffff6600if spellName=="Regrowth"then
    local function update()
        local cost=GetSpellPowerCost("Regrowth")[1].cost
        local a=UnitCastingInfo("player")
        if a and a=="Regrowth"then
            CH_MANA_BAR:ToggleDynamicDisplay(true)
            CH_MANA_BAR:DynamicUpdate(0-cost)
            C_Timer.NewTimer(0.05,update)
        else
            CH_MANA_BAR:ToggleDynamicDisplay(false)
        end
    end
    update()
end]],200)
newFAQ("Lighting up spells",[[Certain classes may have spells you want to light up when their cooldown finishes, or they are ready to use. EX: If you have 'Heating Up' on a fire mage, you may want to light up all spells that guarantee a critical strike (Like Fire Blast) to show that you can use that to instantly gain Hot Streak!
To do this, register the SPELL_AURA_APPLIED event where the spell name is "Fire Blast", and use the function |cffff6600ClassHelper:LightUpSpell("Fire Blast")|r to light up your spell. Make sure that when this aura is removed, that you |cffff6600ClassHelper:UnLightUpSpell("Fire Blast")|r or you will end up with it being permanently lit!]],200)
newFAQ("What is AlertSystem?",[[AlertSystem was actually an old addon, but I deprecated several commands and turned it into a module to make it usable for ClassHelper. The commands it comes with are listed below.
|cffff6600AlertSystem:ShowText("text",hideChat)
Airhorn()
|r'/alert <code here>': Will run the code every 0.1 sec. (Sort-of like '/run' except repeated.)]],200)
newFAQ("SendChatMessage() not working",[[If you are tying to use a callout while outside of an instance, you will just get the message "Interface action failed because of an AddOn", and the sending will fail.
This is because addons can only send chat messages to global chat while inside an instance, for obvious reasons. (Spamming bots, etc)]],200)
newFAQ("What are reserved bars?",[[Reserved timer bars can be used if you don't want the bar to override another bar when the pointer is being used.
In the most basic situations, you won't need to do this, but in some situations, you may want a bar that restarts when a tracked aura reappears.
In this case, you could just create a new bar if it doesn't exist anymore, or you could set it to reserved when you create it the first time.
Reserved bars never get deleted, so watch out how many you create! (Normal bars show below reserved bars)]],200)
newFAQ("What can ClassHelper do?",[[If this AddOn is seemingly useless, try using it on a healer, as the raidframes feature is very useful. If your class uses power of any type, try adding power bars on your screen. (Warlocks, Druids, Paladins, ... all use power of some type)
Also, this addon can do just about anything you tell it to do! The code you put in the editor is run with RunScript(), so you can even make your own addons in there, and this addon will automatically load them on demand! (No .toc file required)]],200)
newFAQ("I don't know how to code",[[In case you don't know how to code, I am working on mods for all classes. If you want a mod for specifically your class, simply ask me on
=======
local panel=ClassHelper:NewUIPanel("FAQ")
local desc=panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
desc:SetText("Select an option for more info.")
desc:SetPoint("TOPLEFT",280,-15)
desc:SetJustifyH("LEFT")
desc:SetWidth(500)
local lastPos=0
local lastButton
local function newFAQ(questionName,description,width,header)
    local button=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
    button:SetText(questionName)
    if width then
        button:SetWidth(width)
    else
        button:SetWidth(100)
    end
    lastPos=lastPos-30
    if header then
        local head=panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
        head:SetText(header)
        head:SetPoint("TOPLEFT",20,lastPos)
        lastPos=lastPos-30
        button:SetPoint("TOPLEFT",40,lastPos)
    else
        button:SetPoint("TOPLEFT",40,lastPos)
    end
    button:SetScript("OnClick",function(self)desc:SetText(description)self:Disable()if lastButton then lastButton:Enable()end lastButton=self end)
end
newFAQ("Raidframes errors",[[If your raidframes won't show, you likely didn't set the |cffff6600ClassHelper.is_healer|r variable in the mod settings.
Another thing you could have forgotten is to set the raidframe's color when the aura is applied. In order to set the colors, use |cffff6600ClassHelper:ColorPartyRaidFrame(destName,true)|r to say they have an aura (EX: Glimmer of Light/Rejuvenation), or false if they don't.
If you want your raidframes to stay normal-colored even when someone is low and has your aura, type this: '|cffff6600/ch raidframes threshold low 0|r'.
If you want your raidframes to stay normal-colored above the high threshold, type this: '|cffff6600/ch raidframes threshold high 100|r'.]],200)
newFAQ("Dynamic power bars",[[If you want spells' power costs to show on your bar when you cast them, you have come to the right place.
Dynamic power bars allow you to show the final power you will have on the bar when you are done casting the current spell.
This requires a lot of setup however, and is not recommended for beginner programmers. The following code below shows how to create a dynamic update for the Regrowth cast.
|cffff6600if spellName=="Regrowth"then
    local function update()
        local cost=GetSpellPowerCost("Regrowth")[1].cost
        local a=UnitCastingInfo("player")
        if a and a=="Regrowth"then
            CH_MANA_BAR:ToggleDynamicDisplay(true)
            CH_MANA_BAR:DynamicUpdate(0-cost)
            C_Timer.NewTimer(0.05,update)
        else
            CH_MANA_BAR:ToggleDynamicDisplay(false)
        end
    end
    update()
end]],200)
newFAQ("Lighting up spells",[[Certain classes may have spells you want to light up when their cooldown finishes, or they are ready to use. EX: If you have 'Heating Up' on a fire mage, you may want to light up all spells that guarantee a critical strike (Like Fire Blast) to show that you can use that to instantly gain Hot Streak!
To do this, register the SPELL_AURA_APPLIED event where the spell name is "Fire Blast", and use the function |cffff6600ClassHelper:LightUpSpell("Fire Blast")|r to light up your spell. Make sure that when this aura is removed, that you |cffff6600ClassHelper:UnLightUpSpell("Fire Blast")|r or you will end up with it being permanently lit!]],200)
newFAQ("What is AlertSystem?",[[AlertSystem was actually an old addon, but I deprecated several commands and turned it into a module to make it usable for ClassHelper. The commands it comes with are listed below.
|cffff6600AlertSystem:ShowText("text",hideChat)
Airhorn()
|r'/alert <code here>': Will run the code every 0.1 sec. (Sort-of like '/run' except repeated.)]],200)
newFAQ("SendChatMessage() not working",[[If you are tying to use a callout while outside of an instance, you will just get the message "Interface action failed because of an AddOn", and the sending will fail.
This is because addons can only send chat messages to global chat while inside an instance, for obvious reasons. (Spamming bots, etc)]],200)
newFAQ("What can ClassHelper do?",[[If this AddOn is seemingly useless, try using it on a healer, as the raidframes feature is very useful. If your class uses power of any type, try adding power bars on your screen. (Warlocks, Druids, Paladins, ... all use power of some type)
Also, this addon can do just about anything you tell it to do! The code you put in the editor is run with RunScript(), so you can even make your own addons in there, and this addon will automatically load them on demand! (No .toc file required)]],200)
newFAQ("I don't know how to code",[[In case you don't know how to code, I am working on mods for all classes. If you want a mod for specifically your class, simply ask me on
>>>>>>> origin/main
|cffff6600https://github.com/TeddeCodesAddons/ClassHelper]],200)