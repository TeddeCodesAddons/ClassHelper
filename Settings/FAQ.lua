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
newFAQ("|cffff6600CustomUnitFrames attributes",[[There are many different attributes you can assign to the CustomUnitFrames, while out of combat, such as macros, debuff priority, or even clicking methods.
Here is a list of all attributes and what they do:


<modifiers>-type<mouse_button>|cffff6600: Binds a selected mouse button or modifiers to the specified attribute.
Typing ctrl-type1 will bind control-click to whatever you type. (Type "macro" to bind it to a macro, or "target", to target the unit)

|rmacrotext|cffff6600: Add your macro's text here. You can detect which method triggered the macro by using [button:X], [mod:alt/ctrl/shift]
If you want to use Lay on Hands when you shift-right-click, type the following into 'macrotext' (assuming you bound shift-type2 to macro)
/use [@mouseover,button:2,mod:shift]Lay on Hands

|rpriority|cffff6600: If you are having trouble seeing debuffs on these RaidFrames, you can add a priority list.
To use the list, simply type any number of spells, separated by newlines into the text box. (If you are running command lines, go to the settings page instead to type newlines easier.)
If you want the debuff to glow a certain color, type the debuff's name followed by a semicolon (;) and type the color in RGBA format.
EX: to make Polymorph glow blue, type "Polymorph;0.1,0.1,1". (0 is the minimum and 1 is the maximum for each channel)
The first number is the red, the second the green, and the third is the blue. If you don't want the debuff to glow, just type the buff name.
Typing "#disabled" into the beginning of priority will disable the priority list. (Doesn't matter if there are buffs listed after "#disabled")

|r|cffff0000*YOU MUST USE NUMBERS TO COLOR PRIORITY DEBUFFS BECAUSE IT IS A TEXTURE, NOT TEXT.

|rframerate|cffff6600: The maximum framerate for the RaidFrames. This will never exceed your game's current framerate. (Automatically goes slower when needed)

|rclick|cffff6600: The clicking method for the RaidFrames. Recommended methods are "AnyUp" and "AnyDown".
AnyUp will make the RaidFrames normal, they will activate their actions when you release the mouse.
AnyDown will make it so if you click on the frame, it will perform it's action when you click the mouse down.
*AnyDown is faster, but most people are used to AnyUp, and AnyDown is not really an optimization, because for some people it might make it more challenging to cast on their current target if they switch targets by accident.

|rHave a suggestion? Join the discord and type it in the suggestions channel!]],200)
newFAQ("|cffff6600Dispel tooltip attributes",[[dispel_tooltip|cffff6600: There is now a dispel tooltip in the CustomUnitFrames. By default, this is disabled, but when enabled, this attribute will control what debuffs are prioritized on the tooltip.
EX: Typing "Unstable Affliction;ff0000" in here will make Unstable Affliction appear closer to the cursor and red.

|r|cffff0000*ON THE TOOLTIP, YOU MUST USE HEXCODES TO COLOR DEBUFFS BECAUSE IT IS TEXT, NOT A TEXTURE.

|rtooltip_conditions|cffff6600: These are the conditions in which the tooltip will show. Typing "#disabled" here will disable the tooltip entirely.
To use, type either 'arena', 'warmode', 'battleground', 'pvp', 'pvporwarmode', 'instance', 'raid', 'party', 'group', 'always', or 'cooldown'.
You may use advanced conditionals too. EX: Here's how you would enable the tooltip in PvP while the spell is off cooldown...
!pvp: false (sets it so if you aren't in a battleground or arena to disable the tooltip), cooldown: true (sets it to display when off cooldown), always: false (sets it to hide the tooltip in none of these cases)
Make sure to separate each conditional with a newline!

|rtooltip_blacklist|cffff6600: Put buffs here you don't want to appear on the tooltip. These will never appear on the tooltip.

|rHave a suggestion? Join the discord and type it in the suggestions channel!]],200)
newFAQ("Raidframes errors",[[*THIS FEATURE WILL BE REMOVED IN LATER VERSIONS OF THIS ADDON* If your raidframes won't show, you likely didn't set the |cffff6600ClassHelper.is_healer|r variable in the mod settings.
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
newFAQ("What is a warning text?",[[Warning texts, unlike the AlertSystem:ShowText() function, are created permanently by mods, can be moved anywhere on the screen, and can shake, flash, change color and size.
This is more useful if you want to announce a proc without having it override what is currently being shown by AlertSystem.]],200)
newFAQ("My nameplates broke.",[[Nameplates are difficult to use. Since the NamePlates.lua script was tested many times, it is likely you made a mistake while creating your own script. You can copy straight from the example, and change it to match your class. That's the whole reason it was included!]],200)
newFAQ("What are templates?",[[Templates allow you to save code for later, even if you don't want to run it. You can also access this in between profiles, so it is extremely useful to transfer mods. Templates do get backed up too, and restored when a backup is restored.]],200)
newFAQ("|cffff6600What are CustomUnitFrames?",[[CustomUnitFrames are easier to code than blizzard raid frames, and can be used to automatically cast a spell on any mouse button (left click, right click, shift-left click, etc...)
|cffff6600This is no longer a BETA feature. Customization options are currently being added. Suggest one on our discord server today!
|cffff0000To disable this feature, go to settings, and turn off CustomUnitFrames. You may need to '/reload' to see the setting. It is directly below the CustomUnitFrames attributes, and is called CustomRaidFrames.]],200)
newFAQ("What can ClassHelper do?",[[If this AddOn is seemingly useless, try using it on a healer, as the raidframes feature is very useful. If your class uses power of any type, try adding power bars on your screen. (Warlocks, Druids, Paladins, ... all use power of some type)
Also, this addon can do just about anything you tell it to do! The code you put in the editor is run with RunScript(), so you can even make your own addons in there, and this addon will automatically load them on demand! (No .toc file required)]],200)
newFAQ("I don't know how to code",[[In case you don't know how to code, I am working on mods for all classes. If you want a mod for specifically your class, simply ask me on
|cffff6600https://github.com/TeddeCodesAddons/ClassHelper]],200)
newFAQ("Discord Server",[[Here is the link to my discord: https://discord.gg/6RzJPGjwtv
Unfortunately, I haven't added a way to easily copy the link, but I think we all have had enough experience copying in-game discord links.

|cffff6600From this discord server, you can...
|cffffff001. Send bug reports.
2. Make suggestions.
3. Get support!

Have fun, happy gaming!
- Tedde

|r|r
For confirmation, the discord link is:
6 (number), capital R, lowercase z, capital J, capital P, capital G, lowercase j (not an i), lowercase w, lowercase t, lowercase v.]],200)