local profile="Default"
local firstrun_mods={

}
function ClassHelper:SaveFrame(frame,prefix,frameName)
    if frame and prefix and frameName then
        local pt,rel,relPt,x,y=frame:GetPoint(1)
        if rel then
            rel=rel:GetName()
        end
        if not ClassHelper_Data["profiles"][profile]["frames"][prefix]then
            ClassHelper_Data["profiles"][profile]["frames"][prefix]={

            }
        end
        ClassHelper_Data["profiles"][profile]["frames"][prefix][frameName]={pt,rel,relPt,x,y}
    end
end
function ClassHelper:LoadFrame(prefix,frameName)
    if prefix and frameName and ClassHelper_Data["profiles"][profile]["frames"][prefix]then
        return ClassHelper_Data["profiles"][profile]["frames"][prefix][frameName]
    end
    return nil
end
function ClassHelper:GetCurrentProfile()
    return ClassHelper_Data["profiles"][profile]
end
function ClassHelper:Save(prefix,variable,value)
    if prefix and variable then
        if not ClassHelper_Data["profiles"][profile]["variables"][prefix]then
            ClassHelper_Data["profiles"][profile]["variables"][prefix]={

            }
        end
        ClassHelper_Data["profiles"][profile]["variables"][prefix][variable]=value
    else
        self:Error("SavedVariables","Save","Prefix and/or variable cannot be","nil")
    end
end
function ClassHelper:CreateModFromFile(m)
    firstrun_mods[m.title]=m
end
function ClassHelper:DeleteMod(modName)
    if ClassHelper_Data["profiles"][profile]["mods"][modName]then
        ClassHelper_Data["profiles"][profile]["mods"][modName]=nil
        self:Print("Permanently deleted "..modName.." mods. To unload these, type '/reload'. This only needs to be done to unload or update mods.")
    end
end
function ClassHelper:LoadModByName(modName)
    return ClassHelper_Data["profiles"][profile]["mods"][modName]
end
function ClassHelper:LoadModsByCondition(condition)
    local t={

    }
    for title,m in pairs(ClassHelper_Data["profiles"][profile]["mods"])do
        if m.loadable and m.load and strlower(m.load)==strlower(condition)then
            tinsert(t,m)
        end
    end
    return t
end
function ClassHelper:Search(t)
    local rt={

    }
    local idx={
        
    }
    local sortTable={

    }
    for title,m in pairs(ClassHelper_Data["profiles"][profile]["mods"])do
        if strfind(strlower(title),strlower(t))then
            local resultLength=strlen(title)-strlen(t) -- Find the number of letters missed.
            while idx[resultLength]do -- If index already exists, increase result id.
                resultLength=resultLength+1
            end
            idx[resultLength]=title
        end
    end
    for length,title in pairs(idx)do -- Make an index
        tinsert(sortTable,length)
    end
    sort(sortTable) -- Sort the table
    for i=1,getn(sortTable)do
        tinsert(rt,idx[sortTable[i]]) -- Return the values in search order.
    end
    return rt -- The results
end
function ClassHelper:SearchProfiles(t)
    local rt={

    }
    local idx={
        
    }
    local sortTable={

    }
    for title,p in pairs(ClassHelper_Data["profiles"])do
        if strfind(strlower(title),strlower(t))then
            local resultLength=strlen(title)-strlen(t) -- Find the number of letters missed.
            while idx[resultLength]do -- If index already exists, increase result id.
                resultLength=resultLength+1
            end
            idx[resultLength]=title
        end
    end
    for length,title in pairs(idx)do -- Make an index
        tinsert(sortTable,length)
    end
    sort(sortTable) -- Sort the table
    for i=1,getn(sortTable)do
        tinsert(rt,idx[sortTable[i]]) -- Return the values in search order.
    end
    return rt -- The results
end
function ClassHelper:NewMod(modObject)
    if ClassHelper_Data["profiles"][profile]["mods"][modObject.title]then
        return false
    end
    ClassHelper_Data["profiles"][profile]["mods"][modObject.title]=modObject
    return true
end
function ClassHelper:UpdateMod(modObject)
    if ClassHelper_Data["profiles"][profile]["mods"][modObject.title]then
        ClassHelper_Data["profiles"][profile]["mods"][modObject.title]=modObject
        return true
    end
    return false
end
function ClassHelper:NewBackup()
    local d=date()
    if not ClassHelper_Data["backups"]then
        ClassHelper_Data["backups"]={

        }
    end
    ClassHelper_Data["backups"][d]={
        ["profiles"]=ClassHelper_Data["profiles"],
        ["saved_profiles"]=ClassHelper_Data["saved_profiles"]
    }
    self:Print("Backup created: "..d)
end
function ClassHelper:RestoreBackup(backupName)
    self:Print("RESTORING BACKUP: \124cffffffff"..backupName)
    if ClassHelper_Data["backups"][backupName]then
        self:NewBackup()
        ClassHelper_Data["profiles"]=ClassHelper_Data["backups"][backupName]["profiles"]
        ClassHelper_Data["saved_profiles"]=ClassHelper_Data["backups"][backupName]["saved_profiles"]
        self:Print("Restored old backup: "..backupName)
        self:Print("Another backup was also created so you can restore it in case you need your old data back.")
    else
        self:Print("Could not find a backup with the specified name: "..backupName)
        self:Print("Please make sure this backup exists before attempting to load it.")
        self:Print("If you deleted your WTF folder or SavedVariables, all data is permanently lost.")
    end
end
function ClassHelper:GetBackups()
    local t={
        
    }
    for i,v in pairs(ClassHelper_Data["backups"])do
        tinsert(t,i)
    end
    return t
end
function ClassHelper:Backup(cmd)
    if(not cmd)or cmd==""then
        self:NewBackup()
        return
    end
    local c=strsub(cmd,1,2)
    if not c then
        self:NewBackup()
        return
    end
    if c=="-a"then
        local b=self:GetBackups()
        self:Print("\124cffffffffAll backups:")
        for i=1,getn(b)do
            self:Print(b[i])
        end
        self:Print("\124cffffffff------------")
    elseif c=="-n"then
        self:NewBackup()
    elseif c=="-r"then
        local n=strsub(cmd,4,strlen(cmd))
        if strsub(cmd,3,3)and strsub(cmd,3,3)==" "and n then
            self:RestoreBackup(n)
        elseif strsub(cmd,3,3)~=" "then
            self:Print("ERROR: Cannot read command line, expected space near '-r', found '"..strsub(cmd,3,3).."'.")
        else
            self:Print("ERROR: Cannot read command line, expected space near '-r', found EOF.")
        end
    elseif c=="-d"then
        local n=strsub(cmd,4,strlen(cmd))
        if strsub(cmd,3,3)and strsub(cmd,3,3)==" "and n then
            if n=="*"then
                self:Print("Recycling all backups. (NOT deleted)")
                self:Print("Are you sure you want to delete all backups? To recover, type '/run ClassHelper_Data.backups=ClassHelper_Data.RECOVERY'. (You may logout while changing your mind, and it will still work)")
                ClassHelper_Data["RECOVERY"]=ClassHelper_Data["backups"]
                ClassHelper_Data["backups"]={

                }
                self:Print("To confirm, type '/run ClassHelper_Data.RECOVERY=nil'. \124cffff0000WARNING: This permanently deletes ALL backups. Run at your own risk.")
            else
                self:DeleteBackup(n)
            end
        elseif strsub(cmd,3,3)~=" "then
            self:Print("ERROR: Cannot read command line, expected space near '-d', found '"..strsub(cmd,3,3).."'.")
        else
            self:Print("ERROR: Cannot read command line, expected space near '-d', found EOF.")
        end
    elseif c==""then
        self:NewBackup()
    else
        self:RestoreBackup(cmd)
    end
end
ClassHelper:CreateSlashCommand("backup","ClassHelper:Backup(arguments)","Creates a new backup, or restores an old one if a date is specified. (To get all backup's dates, type '/ch backup -a')",{"'/ch backup -n': New backup (automatic)","'/ch backup -r': Restore a backup (automatic)","'/ch backup -a': List all backups","'/ch backup -d': Deletes a backup.","All these backups can be found in the backup section of the AddOn. (Type '/ch' to open UI)"})
function ClassHelper:Load(prefix,variable)
    return ClassHelper_Data["profiles"][profile]["variables"][prefix][variable]
end
function ClassHelper:DefaultSavedVariable(prefix,variable,value)
    if ClassHelper_Data["profiles"][profile]["variables"][prefix]then
        if not ClassHelper_Data["profiles"][profile]["variables"][prefix][variable]then
            ClassHelper_Data["profiles"][profile]["variables"][prefix][variable]=value
        end
    else
        ClassHelper_Data["profiles"][profile]["variables"][prefix]={
            [variable]=value
        }
    end
end
function ClassHelper:GetProfile()
    return profile
end
function ClassHelper:NewProfile(profileName)
    if ClassHelper_Data["profiles"][profileName]then
        self:Print("Cannot create a profile that already exists!")
        return
    end
    ClassHelper_Data["profiles"][profileName]={
        ["frames"]={

        },
        ["variables"]={

        }
    }
    self:ChangeProfile(profileName)
    self:Print("A new profile was created. A reload is required to load the profile. Please type '/reload'.")
    message("A new profile was created. A reload is required to load the profile.\nPlease type '/reload'.")
end
function ClassHelper:DeleteProfile(profileName)
    if profileName=="Default"then
        self:Print("\124cffff0000Cannot delete the Default profile.")
        return
    end
    if profileName==profile then
        self:Print("\124cffff0000Cannot delete a profile in-use!")
        return
    end
    ClassHelper_Data["profiles"][profileName]=nil
    self:Print("Deleted the "..profileName.." profile. If any characters attempt to load this, the default profile will be loaded instead.")
end
function ClassHelper:ChangeProfile(profileName)
    if ClassHelper_Data["profiles"][profileName]then
        local n,r=UnitFullName("player")
        n=n.."-"..r
        ClassHelper_Data["saved_profiles"][n]=profileName
        self:Print("Profile was changed. A reload is now required to load the new profile. To do this, type '/reload'.")
        message("Profile was changed. A reload is now required to load the new profile. To do this, type '/reload'.")
    else
        self:Print("\124cffff0000Invalid profile name!")
    end
end
local f=CreateFrame("FRAME")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
local function handle(self,event,...)
    local n,r=UnitFullName("player")
    n=n.."-"..r
    if not ClassHelper_Data then
        ClassHelper_Data={
            ["profiles"]={
                ["Default"]={
                    ["frames"]={

                    },
                    ["variables"]={

                    }
                }
            },
            ["saved_profiles"]={
                [n]="Default"
            },
            ["backups"]={

            }
        }
        ClassHelper:Print("Welcome to ClassHelper!")
        ClassHelper:Print("Type '/ch help' for a list of commands.")
        ClassHelper:Print("Type '/ch' to toggle UI.")
        ClassHelper:Print("To code mods, refer to the API, and make sure to use proper syntax.")
        ClassHelper:Print("A mod template will be provided, but you will need to provide spell names/IDs, and what you want to happen when those spells are used.")
    end
    if not ClassHelper_Data["backups"]then
        ClassHelper_Data["backups"]={
            
        }
    end
    if ClassHelper_Data["saved_profiles"][n]then
        profile=ClassHelper_Data["saved_profiles"][n]
    else
        profile="Default" -- If this is first run, use the default profile.
        ClassHelper_Data["saved_profiles"][n]="Default"
    end
    if not ClassHelper_Data["profiles"][profile]then -- If profile was deleted, reset to defaults.
        profile="Default"
        ClassHelper:Print("\124cffff0000--- WARNING ---")
        ClassHelper:Print("The previous profile you used was deleted.")
        ClassHelper:Print("You are now using the Default profile.")
        ClassHelper:Print("\124cffff0000--- WARNING ---")
        ClassHelper_Data["saved_profiles"][n]="Default"
    end
    if not ClassHelper_Data["profiles"][profile]["mods"]then
        ClassHelper_Data["profiles"][profile]["mods"]=firstrun_mods
        ClassHelper:Print("Imported mods to your current profile: "..profile..". (If any mod packages were included)")
        ClassHelper:Print("\124cffff0000If you did not include any mods, you must refer to the API to code your own mods.")
    end
end
f:SetScript("OnEvent",handle)