function ClassHelper:VoiceCountdown(countdown,channel)
    if not channel then channel="master"end
    if math.floor(countdown)==countdown then
        if countdown<11 then
            PlaySoundFile("Interface/AddOns/ClassHelper/Assets/countdown/"..countdown..".ogg",channel)
        end
        if countdown>1 then
            C_Timer.NewTimer(1,function()self:VoiceCountdown(countdown-1,channel)end)
        end
    end
end
function ClassHelper:PlayWarningSound(soundName,channel)
    if not channel then channel="master"end
    if soundName then
        soundName=strlower(soundName)
        if tonumber(soundName)then
            return PlaySound(soundName,channel)
        elseif soundName=="airhorn"then
            Airhorn()
            return true
        elseif soundName=="warning"then
            return PlaySound(8332,channel)
        elseif soundName=="important"then
            return PlaySound(37666,channel)
        elseif soundName=="runaway"then
            return PlaySound(9278,channel)
        elseif soundName=="reminder"then
            return PlaySound(11742,channel)
        elseif strsub(soundName,1,10)=="countdown:"then
            local c=strsub(soundName,11,strlen(soundName))
            if c and tonumber(c)and tonumber(c)<10 and math.floor(tonumber(c))==tonumber(c)then
                return PlaySoundFile("Interface/AddOns/ClassHelper/Assets/countdown/"..c..".ogg",channel)
            else
                return false
            end
        else
            return PlaySoundFile(soundName,channel)
        end
    else
        return PlaySound(8332,channel)
    end
end