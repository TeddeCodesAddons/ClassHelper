local boxData={

}
local boxChanged={

}
local PREDEFINED=ClassHelper:GetAllInGameFunctionNames()
local COLORS={
    ["0066ff"]={
        "nil",
        "self",
        "true",
        "false",
        "_G",
        "_"
    },
    ["cc00cc"]={
        "local",
        "function",
        "while",
        "do",
        "return",
        "if",
        "then",
        "elseif",
        "else",
        "end",
        "for",
        "in",
        "repeat",
        "until",
        "break"
    },
    ["999999"]={
        "and",
        "or",
        "not",
        "(",
        ")",
        "[",
        "]",
        "#"
    },
    ["ff6600"]={
        "ClassHelper",
        "AlertSystem"
    }
}
local SYMBOLS={
    "~",
    "+",
    "-",
    "*",
    "/",
    "^",
    "%",
    "=",
    "(",
    ")",
    "[",
    "]",
    "{",
    "}",
    "*",
    "&",
    "$",
    "#",
    "@",
    "!",
    "`",
    ";",
    "'",
    "\"",
    "|",
    ",",
    "?",
    "<",
    ">",
    " ",
    "\\",
    "\n"
}
local function insertAt(text,pos,len,color)
    local t1=strsub(text,1,pos-1)
    local t2=strsub(text,pos,pos+len)
    local t3=strsub(text,pos+len+1,strlen(text))
    return t1.."\124cff"..color..t2.."\124r"..t3
end
local function addColorToText(text)
    if strsub(text,1,15)=="-- @syntax: off"then return text end -- Disable syntax when this is typed.
    local i=1
    local streak=""
    text=text.." "
    local prev=""
    while i<=strlen(text)do
        streak=streak..strsub(text,i,i)
        i=i+1
        if strsub(text,i,i)=="."or strsub(text,i,i)==":"then -- Objects
            prev=streak
            streak=""
            if tonumber(prev)then
                text=insertAt(text,i-strlen(prev),strlen(prev)-1,"33aa33")
                i=i+12
                streak=""
                prev=""
            elseif tContains(COLORS["ff6600"],strsub(prev,1,12))or tContains(COLORS["ff6600"],prev)then -- "ClassHelper" and "AlertSystem" are both 11 letters, so if calling a function from either, can turn them orange easily.
                text=insertAt(text,i-strlen(prev),strlen(prev)-1,"ff6600")
                i=i+12
                streak=""
                prev=""
            elseif tContains(COLORS["0066ff"],prev)then
                text=insertAt(text,i-strlen(prev),strlen(prev)-1,"0066ff")
                i=i+12
                streak=""
                prev=""
            elseif tContains(COLORS["cc00cc"],prev)then
                text=insertAt(text,i-strlen(prev),strlen(prev)-1,"cc00cc")
                i=i+12
                streak=""
                prev=""
            elseif tContains(COLORS["999999"],prev)then
                text=insertAt(text,i-strlen(prev),strlen(prev)-1,"999999")
                i=i+12
                streak=""
                prev=""
            elseif tContains(PREDEFINED,prev)then
                text=insertAt(text,i-strlen(prev),strlen(prev)-1,"cccc00")
                i=i+12
                streak=""
                prev=""
            end
        end
        local newStreak=prev..streak
        if strsub(text,i,i)=="\""or strsub(text,i,i)=="'"then -- Strings
            if tonumber(newStreak)then -- The "string-bug"
                text=insertAt(text,i-strlen(newStreak),strlen(newStreak)-1,"33aa33")
                i=i+12
            elseif tContains(COLORS["ff6600"],strsub(newStreak,1,12))or tContains(COLORS["ff6600"],newStreak)then -- "ClassHelper" and "AlertSystem" are both 11 letters, so if calling a function from either, can turn them orange easily.
                text=insertAt(text,i-strlen(newStreak),strlen(newStreak)-1,"ff6600")
                i=i+12
            elseif tContains(COLORS["0066ff"],newStreak)then
                text=insertAt(text,i-strlen(newStreak),strlen(newStreak)-1,"0066ff")
                i=i+12
            elseif tContains(COLORS["cc00cc"],newStreak)then
                text=insertAt(text,i-strlen(newStreak),strlen(newStreak)-1,"cc00cc")
                i=i+12
            elseif tContains(COLORS["999999"],newStreak)then
                text=insertAt(text,i-strlen(newStreak),strlen(newStreak)-1,"999999")
                i=i+12
            elseif tContains(PREDEFINED,newStreak)then
                text=insertAt(text,i-strlen(newStreak),strlen(newStreak)-1,"cccc00")
                i=i+12
            end
            streak=""
            prev=""
            local startString=i
            local n=strsub(text,i,i)
            i=i+1
            while strsub(text,i,i)~=n and i<=strlen(text)do
                if strsub(text,i,i)=="\\"then
                    i=i+1
                end
                i=i+1
            end
            if i<=strlen(text)then
                text=insertAt(text,startString,i-startString,"aa4433")
            end
            i=i+13
        elseif tContains(SYMBOLS,strsub(text,i,i))then
            if tonumber(newStreak)then
                text=insertAt(text,i-strlen(newStreak),strlen(newStreak)-1,"33aa33")
                i=i+12
            elseif tContains(COLORS["ff6600"],strsub(newStreak,1,12))or tContains(COLORS["ff6600"],newStreak)then -- "ClassHelper" and "AlertSystem" are both 11 letters, so if calling a function from either, can turn them orange easily.
                text=insertAt(text,i-strlen(newStreak),strlen(newStreak)-1,"ff6600")
                i=i+12
            elseif tContains(COLORS["0066ff"],newStreak)then
                text=insertAt(text,i-strlen(newStreak),strlen(newStreak)-1,"0066ff")
                i=i+12
            elseif tContains(COLORS["cc00cc"],newStreak)then
                text=insertAt(text,i-strlen(newStreak),strlen(newStreak)-1,"cc00cc")
                i=i+12
            elseif tContains(COLORS["999999"],newStreak)then
                text=insertAt(text,i-strlen(newStreak),strlen(newStreak)-1,"999999")
                i=i+12
            elseif tContains(PREDEFINED,newStreak)then
                text=insertAt(text,i-strlen(newStreak),strlen(newStreak)-1,"cccc00")
                i=i+12
            end
            streak=""
            prev=""
        elseif tContains(SYMBOLS,newStreak)then
            if tContains(COLORS["999999"],newStreak)then
                text=insertAt(text,i-strlen(newStreak),strlen(newStreak)-1,"999999")
                i=i+12
            end
            streak=""
            prev=""
        end
    end
    return strsub(text,1,strlen(text)-1) -- Spacebar at end is removed.
end
local changed=false
function ClassHelper:DefineSyntaxBox(box,onkeydown)
    box.SetDisplayedText=box.SetText
    function box:SetText(t)
        t=addColorToText(t)
        self:SetDisplayedText(t)
        self.last_set_text=GetTime()
    end
    box.GetAllText=box.GetText
    function box:GetText()
        local t=self:GetAllText()
        local i=1
        local r=""
        while i<=strlen(t)do
            while strsub(t,i,i)=="\124"do
                if strsub(t,i,i+1)=="\124\124"then
                    r=r.."\124\124"
                    i=i+2
                else
                    if strsub(t,i+1,i+1)=="c"then
                        i=i+10
                    elseif strsub(t,i+1,i+1)=="r"then
                        i=i+2
                    end
                end
            end
            r=r..strsub(t,i,i)
            i=i+1
        end
        return r
    end
    box.GetActualCursorPosition=box.GetCursorPosition
    function box:GetCursorPosition()
        local pos=self:GetActualCursorPosition()
        local t=self:GetAllText()
        local i=1
        local rpos=pos
        while i<strlen(t)and i<pos do
            while strsub(t,i,i)=="\124"and i<pos do
                if strsub(t,i,i+1)=="\124\124"then
                    i=i+2
                else
                    if strsub(t,i+1,i+1)=="c"then
                        rpos=rpos-10
                        i=i+10
                    elseif strsub(t,i+1,i+1)=="r"then
                        rpos=rpos-2
                        i=i+2
                    end
                end
            end
            i=i+1
        end
        return rpos
    end
    box.SetActualCursorPosition=box.SetCursorPosition
    function box:SetCursorPosition(pos)
        local t=self:GetAllText()
        local i=1
        while i<=strlen(t)and i<=pos do
            while strsub(t,i,i)=="\124"and i<=pos do
                if strsub(t,i,i+1)=="\124\124"then
                    i=i+2
                else
                    if strsub(t,i+1,i+1)=="c"then
                        pos=pos+10
                        i=i+10
                    elseif strsub(t,i+1,i+1)=="r"then
                        pos=pos+2
                        i=i+2
                    end
                end
            end
            i=i+1
        end
        return self:SetActualCursorPosition(pos)
    end
    box.HighlightActualText=box.HighlightText
    function box:HighlightText(start,finish)
        box:SetCursorPosition(start)
        local c1=box:GetActualCursorPosition()
        box:SetCursorPosition(finish)
        local c2=box:GetActualCursorPosition()
        box:HighlightActualText(c1,c2)
    end
    local lastUpdate=GetTime()
    local updating=false
    local speed=0.5
    if ClassHelper:Load("ModEditor","SyntaxTypingDelay")=="long"then
        speed=1
    end
    box:SetScript("OnKeyDown",function(...)
        if onkeydown then
            onkeydown(...)
        end
        lastUpdate=GetTime()
        if updating then return end
        updating=true
        local function update()
            if GetTime()-lastUpdate>speed then
                updating=false
                local pos=box:GetCursorPosition()
                box:SetText(box:GetText()) -- Update the box after typing finishes.
                box:SetCursorPosition(pos)
            else
                C_Timer.NewTimer(0.5,update)
            end
        end
        C_Timer.NewTimer(0.5,update)
    end)
end