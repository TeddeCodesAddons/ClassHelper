ClassHelper.SLASH={

}
ClassHelper.SLASH_DESC={

}
ClassHelper.SLASH_DESC_ADVANCED={

}
ClassHelper.SLASH_CMD_ARGS={
        
}
ClassHelper.SLASH_INDEX={
    
}
SLASH_CLASSHELPER1="/classhelper"
SLASH_CLASSHELPER2="/ch"
function ClassHelper:RunSlashCommand(callback,arguments)
    ClassHelper.SLASH_CMD_ARGS=arguments
    RunScript("local arguments=ClassHelper.SLASH_CMD_ARGS;"..callback)
end
SlashCmdList["CLASSHELPER"]=function(msg)
    if msg==""then
        msg="interface"
    end
    local spaceSplit=strfind(msg," ")
    if spaceSplit then
        local cmd=strsub(msg,1,spaceSplit-1)
        local args
        if spaceSplit<strlen(msg)then
            args=strsub(msg,spaceSplit+1,strlen(msg))
        end
        if ClassHelper.SLASH[strlower(cmd)]then
            ClassHelper:RunSlashCommand(ClassHelper.SLASH[strlower(cmd)],args)
        else
            ClassHelper:Error("Core","Slash command","Unknown command",cmd)
        end
    else
        if ClassHelper.SLASH[strlower(msg)]then
            ClassHelper:RunSlashCommand(ClassHelper.SLASH[strlower(msg)],"")
        else
            ClassHelper:Error("Core","Slash command","Unknown command",msg)
        end
    end
end
function ClassHelper:CreateSlashCommand(slashCommand,callback,description,advanced_description)
    self.SLASH[strlower(slashCommand)]=callback
    tinsert(self.SLASH_INDEX,slashCommand)
    if description then
        self.SLASH_DESC[strlower(slashCommand)]=description
    else
        self.SLASH_DESC[strlower(slashCommand)]="<No description>"
    end
    if advanced_description then
        self.SLASH_DESC_ADVANCED[strlower(slashCommand)]=advanced_description
    else
        self.SLASH_DESC_ADVANCED[strlower(slashCommand)]={"<No advanced description>"}
    end
end
ClassHelper:CreateSlashCommand("help","ClassHelper:ShowCommandHelp(ClassHelper.SLASH_CMD_ARGS)")
function ClassHelper:ShowCommandHelp(cmd)
    self:Print("\124cff00ff00--------ClassHelper Commands--------")
    if cmd==""or tonumber(cmd)then
        local s=1
        if tonumber(cmd)then
            s=s+((tonumber(cmd)-1)*5)
        end
        if s<1 then
            self:Print("\124cffff0000Invalid help page index.")
            return
        end
        self:Print("/ch help (<page> or <cmd>)\124cffffffff: Display the syntax of a command, or show a listing of a few commmands.")
        local i=s
        while i<s+5 do
            if self.SLASH_INDEX[i]then
                local cmdName=self.SLASH_INDEX[i]
                if cmdName and self.SLASH_DESC[cmdName]then
                    self:Print("/ch "..cmdName.."\124r: "..(self.SLASH_DESC[cmdName]))
                end
            end
            i=i+1
        end
        if cmd==""then
            self:Print("\124cffff0000End of help page 1")
        else
            self:Print("\124cffff0000End of help page "..cmd)
        end
    else
        cmd=strlower(cmd)
        if self.SLASH[cmd]then
            if self.SLASH_DESC[cmd]and self.SLASH_DESC_ADVANCED[cmd]then
                self:Print("/ch "..cmd.."\124r: \124cff6666ff"..(self.SLASH_DESC[cmd]))
                self:Print("\124cff00ff00------------------------------------")
                for i=1,getn(self.SLASH_DESC_ADVANCED[cmd])do
                    self:Print(self.SLASH_DESC_ADVANCED[cmd][i])
                end
            else
                self:Print("There was an error reading the help data for \124r"..cmd)
            end
        else
            self:Print("There is no such command as \124r"..cmd)
        end
    end
end