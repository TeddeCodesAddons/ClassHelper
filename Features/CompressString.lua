local allowed="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 1234567890-=_+!@#$%^&*()`~[{]}\\|:'\",<.>/?"
local toCompress={ -- 36 default keywords
    "local",
    "function",
    "end~n    ", -- Common newline indent after 'end'.
    "end~n",
    "end",
    "for",
    "then",
    "elseif",
    "~n    ",
    "    ",
    "C_Timer.NewTimer",
    "AlertSystem:ShowText",
    "ClassHelper:NewBar",
    "ClassHelper:Print",
    "ClassHelper:CreateSlashCommand",
    "ClassHelper:PlayWarningSound",
    "ClassHelper:VoiceCountdown",
    "ClassHelper:NewWarningText",
    "ClassHelper:NewPowerBar",
    "ClassHelper:DoManaAlerts",
    "ClassHelper:ColorPartyRaidFrame",
    "ClassHelper:SetRaidFrameGlowFunction",
    "ClassHelper:LightUpSpell",
    "ClassHelper:UnLightUpSpell",
    "ClassHelper:FlashSpell",
    "ClassHelper.vars",
    "ClassHelper:NewFrameOnNameplate",
    "ClassHelper:SetCustomRaidFramesUpdateFunction",
    "GetTime",
    "SendChatMessage",
    "GetSpellCooldown",
    "UnitName",
    "ClassHelper",
    "true",
    "false",
    "nil",
    "self"
}
local function replace(s,f,r)
    local o=""
    local d=strlen(f)
    local i=strfind(s,f,i,true)
    if i then
        o=o..strsub(s,1,i-1)..r
    else
        return s
    end
    while i do
        p=i
        i=strfind(s,f,i,true)
        if i then
            o=o..strsub(s,p+d,i-1)..r
        else
            return o..strsub(s,p+d,strlen(s))
        end
    end
end
local function replace2(s,f,r)
    local o=""
    local d=strlen(f)
    local l=strlen(s)
    local i=strfind(s,f,i,true)
    if i then
        o=o..strsub(s,1,i-1)..r
    else
        return s
    end
    while i do
        p=i
        i=strfind(s,f,i+d,true)
        if i then
            if strsub(s,i-1,i-1)==";"then
                while strsub(s,i-1,i-1)and strsub(s,i-1,i-1)==";"do
                    i=i+2
                end
                if i>strlen(s)then
                    return o..strsub(s,p+d,l)
                end
                i=strfind(s,f,i+1,true) -- Find a new instance if there's a semicolon that is part of a compression key.
            end
        end
        if i then
            o=o..strsub(s,p+d,i-1)..r
        else
            return o..strsub(s,p+d,l)
        end
    end
    return o..strsub(s,p+d,l)
end
local function compress(s,ct)
    if not ct then
        ct={

        }
    end
    local o=""
    local cTable=toCompress
    for i=1,getn(ct)do
        o=o..ct[i]..";"
        if strfind(ct[i],";")or strfind(ct[i],"?")then
            geterrorhandler()("Cannot compress when the dictionary contains key characters. (? and ;)")
            return nil,"Cannot compress when the dictionary contains keyword characters. (? and ;)"
        elseif strlen(ct[i])<3 then
            geterrorhandler()("Compression key must be 3 letters or more.")
            return nil,"Compression key must be 3 letters or more."
        end
        tinsert(cTable,ct[i])
    end
    if getn(cTable)>strlen(allowed)then
        geterrorhandler()("Cannot compress when the compression table's size exceeds the dictionary's size. Try using less compression keys. (Dictionary is "..strlen(allowed).." characters, and compression table is "..getn(cTable).." items)")
        return nil,"Cannot compress when the compression table's size exceeds the dictionary's size. Try using less compression keys. (Dictionary is "..strlen(allowed).." characters, and compression table is "..getn(cTable).." items)"
    end
    local S=replace(s,"?","??")
    S=replace(S,";","?s")
    for i=1,getn(cTable)do
        S=replace2(S,cTable[i],";"..strsub(allowed,i,i))
    end
    return "$CH9.0:"..o.."?"..S,nil
end
local function decompress(s)
    if not strsub(s,1,7)=="$CH9.0:"then
        return nil,"Error: This is most likely not a compressed string. (Missing header)"
    end
    local cTable=toCompress
    local S=""
    local i=8
    local k=""
    while S and S~="?"do
        S=strsub(s,i,i)
        if s==";"then
            tinsert(cTable,k)
            k=""
        else
            k=k..S
        end
        i=i+1
    end
    local o=""
    local n=i
    while n<=strlen(s)do
        local v=strsub(s,n,n)
        if v==";"then
            n=n+1
            v=strsub(s,n,n)
            local x=strfind(allowed,v,1,true)
            if x and cTable[x]then
                o=o..cTable[x]
            else
                geterrorhandler()("Attempted to use an invalid decompression key. Decompression fails.")
                return nil,"Attempted to use an invalid decompression key. Decompression fails."
            end
        else
            o=o..v
        end
        n=n+1
    end
    return o,nil
end
function ClassHelper:CompressString(s,t)
    return compress(s,t)
end
function ClassHelper:DecompressString(s)
    return decompress(s)
end