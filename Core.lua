ClassHelper={
    all_specs={
        ["Death Knight"]={
            [1]="Blood",
            [2]="Frost",
            [3]="Unholy"
        },
        ["Demon Hunter"]={
            [1]="Havoc",
            [2]="Vengeance"
        },
        ["Druid"]={
            [1]="Balance",
            [2]="Feral",
            [3]="Guardian",
            [4]="Restoration"
        },
        ["Hunter"]={
            [1]="Beast Mastery",
            [2]="Marksmanship",
            [3]="Survival"
        },
        ["Mage"]={
            [1]="Arcane",
            [2]="Fire",
            [3]="Frost"
        },
        ["Monk"]={
            [1]="Brewmaster",
            [2]="Mistweaver",
            [3]="Windwalker"
        },
        ["Paladin"]={
            [1]="Holy",
            [2]="Protection",
            [3]="Retribution"
        },
        ["Priest"]={
            [1]="Discipline",
            [2]="Holy",
            [3]="Shadow"
        },
        ["Rogue"]={
            [1]="Assassination",
            [2]="Outlaw",
            [3]="Subtlety"
        },
        ["Shaman"]={
            [1]="Elemental",
            [2]="Enchancement",
            [3]="Restoration"
        },
        ["Warlock"]={
            [1]="Affliction",
            [2]="Demonology",
            [3]="Destruction"
        },
        ["Warrior"]={
            [1]="Arms",
            [2]="Fury",
            [3]="Protection"
        }
    },
    ADDON_PATH_NAME="ClassHelper"
}
function ClassHelper:TextToBool(toggle)
    toggle=strlower(toggle)
    if toggle=="on"or toggle=="1"or toggle=="true"or toggle=="t"then
        return 1
    elseif toggle=="off"or toggle=="0"or toggle=="false"or toggle=="f"then
        return 0
    elseif toggle=="toggle"or toggle=="2"or toggle=="-"or toggle=="/"then
        return 2
    else
        return -1
    end
end
function ClassHelper:Print(msg)
    print("\124cffff6600ClassHelper: \124cffffff00"..msg)
end
function ClassHelper:Error(origin,functionName,text,variable)
    self:Print("\124cff3366ff "..origin..": \124cffffff00"..functionName.." - Error ("..text.." \124cffffffff"..variable.."\124cffffff00)")
end
function ClassHelper:FormatTime(t)
    local h=math.floor(t/3600)
    local m=math.floor(t/60)-(h*60)
    local s=t-(m*60)-(h*3600)
    if m>0 or h>0 then
        s=math.floor(s)
        if s<10 then
            s="0"..s
        end
    end
    if h>0 then
        if h>0 and m<10 then
            m="0"..m
        end
        return h..":"..m..":"..s
    elseif m>0 then
        if h>0 and m<10 then
            m="0"..m
        end
        return m..":"..s
    else
        return s
    end
end
function ClassHelper:ConvertTime(t)
    local h,m,s=strsplit(":",t)
    if m then
        if s then
            return (h*3600)+(m*60)+s
        end
        return (h*60)+m
    end
    return h
end