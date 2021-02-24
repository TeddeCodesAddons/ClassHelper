-- This script should export a table into a string, and import a string into a table.
local function formatString(s)
    local s2=""
    for i=1,strlen(s)do
        local x=strsub(s,i,i)
        if x=="~"then
            s2=s2.."~~"
        elseif x=="\n"then
            s2=s2.."~n"
        else
            s2=s2..x
        end
    end
    return s2
end
local function unformatString(s)
    local s2=""
    local i=1
    while i<=strlen(s)do
        local x=strsub(s,i,i)
        if x=="~"then
            i=i+1
            local y=strsub(s,i,i)
            if y=="~"then
                s2=s2.."~"
            elseif y=="n"then
                s2=s2.."\n"
            elseif y=="$"then
                return s2,i
            elseif y==")"then
                return s2,i
            end
        else
            s2=s2..x
        end
        i=i+1
    end
    ClassHelper:Print("WARNING: No string terminator was detected.")
    return s2,strlen(s)
end
local function export(t)
    local returnString=""
    for i,v in pairs(t)do
        if type(i)=="number"then
            returnString=returnString.."("..i..")"
        elseif type(i)=="string"then
            returnString=returnString.."(~"..i.."~)"
        elseif type(i)=="boolean"then
            if i then
                returnString=returnString.."(@1)"
            else
                returnString=returnString.."(@0)"
            end
        end
        if type(v)=="table"then
            if v==t then
                geterrorhandler()("ClassHelper:ExportTable() doesn't work on tables that contain a pointer to themselves.")
                return
            end
            returnString=returnString.."#"..(export(v))
        elseif type(v)=="number"then
            returnString=returnString.."!"..v
        elseif type(v)=="boolean"then
            if v then
                returnString=returnString.."@1"
            else
                returnString=returnString.."@0"
            end
        elseif type(v)=="string"then
            v=formatString(v)
            returnString=returnString.."$"..v.."~$"
        end
    end
    returnString=returnString.."%"
    return returnString
end
function ClassHelper:ExportTable(t)
    return "!CH9.0:"..export(t)
end
local function import(s)
    local t={
        
    }
    local i=1
    local idx=nil
    while i<=strlen(s)do
        local x=strsub(s,i,i)
        if x=="("then
            i=i+1
            local y=strsub(s,i,i)
            if y=="~"then
                local s,n=unformatString(strsub(s,i+1,strlen(s)))
                i=i+n
                idx=s
            elseif y=="@"then
                if strsub(s,i+1,i+1)=="1"then
                    idx=true
                elseif strsub(s,i+1,i+1)=="0"then
                    idx=false
                else
                    ClassHelper:Print("WARNING: Invalid boolean value (Should be true or false)")
                end
                i=i+1
            elseif tonumber(y)then
                local n=tonumber(y)
                i=i+1
                y=strsub(s,i,i)
                while tonumber(y)do
                    n=n*10
                    n=n+tonumber(y)
                    i=i+1
                    y=strsub(s,i,i)
                end
                idx=n
                i=i-1
            else
                ClassHelper:Print("WARNING: Invalid table index type.")
            end
        elseif x=="!"then
            i=i+1
            local y=strsub(s,i,i)
            local n=0
            while tonumber(y)do
                n=n*10
                n=n+tonumber(y)
                i=i+1
                y=strsub(s,i,i)
            end
            i=i-1
            t[idx]=n
        elseif x=="@"then
            if strsub(s,i+1,i+1)=="1"then
                t[idx]=true
            elseif strsub(s,i+1,i+1)=="0"then
                t[idx]=false
            else
                ClassHelper:Print("WARNING: Invalid boolean value (Should be true or false)")
            end
            i=i+1
        elseif x=="#"then
            local t2,start=import(strsub(s,i+1,strlen(s)))
            t[idx]=t2
            i=i+start
        elseif x=="$"then
            local s2,a=unformatString(strsub(s,i+1,strlen(s)))
            t[idx]=s2
            i=i+a
        elseif x=="%"then
            return t,i
        else
            ClassHelper:Print("WARNING: Invalid table index header.")
        end
        i=i+1
    end
    ClassHelper:Print("WARNING: No table terminator was detected.")
    return t,strlen(s)
end
function ClassHelper:ImportTable(s)
    if not strsub(s,1,7)=="!CH9.0:"then
        ClassHelper:Print("ERROR: This string is not recognized as a valid ClassHelper export, and therefore cannot be imported.")
        return nil
    end
    local t=import(strsub(s,8,strlen(s)),1)
    return t
end