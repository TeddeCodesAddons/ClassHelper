local f=CreateFrame("FRAME")
local entered_world=false
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent",function()
    if not entered_world then
        entered_world=true
        local libDB11=LibStub("LibDataBroker-1.1")
        local libIcon=LibStub("LibDBIcon-1.0")
        local icon=libDB11:NewDataObject("ClassHelper",{
            type="minimap icon",
            label="ClassHelper",
            icon="Interface/AddOns/"..(ClassHelper.ADDON_PATH_NAME).."/Assets/MinimapIcon.blp"
        })
        local locked=true
        function icon:OnClick(self,button)
            if IsShiftKeyDown()then
                if locked then
                    libIcon:Unlock("ClassHelper")
                    locked=false
                else
                    libIcon:Lock("ClassHelper")
                    locked=true
                end
            else
                ClassHelper:ToggleUI()
            end
        end
        function icon.OnTooltipShow(tooltip)
            tooltip:SetText("\124cffff6600ClassHelper\124r")
            if ClassHelper.VERSION.isOutOfDate then
                tooltip:AddLine("\124cffff0000v"..(ClassHelper.VERSION.str).." OUT-OF-DATE (Interface "..(ClassHelper.VERSION.interface)..")\124r")
                tooltip:AddLine("Version "..(table.concat(ClassHelper.VERSION.latest,".")).." is available. (Type '/ch reset-version-checks' to ignore.)")
            else
                tooltip:AddLine("\124cff00ff00v"..(ClassHelper.VERSION.str).." No updates detected! (Interface "..(ClassHelper.VERSION.interface)..")\124r")
            end
            tooltip:AddLine("")
            tooltip:AddLine("\124cff666666What's new?")
            for i=1,getn(ClassHelper.VERSION.whats_new)do
                tooltip:AddLine("\124cff666666"..ClassHelper.VERSION.whats_new[i].."\124r")
            end
            tooltip:AddLine("")
            tooltip:AddLine("Left-click to toggle UI.")
            if locked then
                tooltip:AddLine("\124cff00ff00Icon is locked. \124rShift-click to \124cffff0000unlock\124r this icon.")
            else
                tooltip:AddLine("\124cffff0000Icon is unlocked. \124rShift-click to \124cff00ff00lock\124r this icon.")
            end
            tooltip:AddLine("\124cff666666Type '/ch minimap' to hide this icon.")
        end
        if not ClassHelper_Minimap then
            ClassHelper_Minimap={

            }
        end
        libIcon:Register("ClassHelper",icon,ClassHelper_Minimap)
        function ClassHelper:ToggleMinimapIcon()
            if ClassHelper_Minimap.hide then
                libIcon:Show("ClassHelper")
                ClassHelper_Minimap.hide=false
                self:Print("Showing minimap icon.")
            else
                libIcon:Hide("ClassHelper")
                ClassHelper_Minimap.hide=true
                self:Print("Hiding minimap icon.")
            end
        end
        ClassHelper:CreateSlashCommand("minimap","ClassHelper:ToggleMinimapIcon()","Toggles the minimap icon.")
    end
end)