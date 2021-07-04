local soundpacks={
    [1]="corsica",
    [2]="koltrane",
    [3]="smooth"
}
ClassHelper:CreateSlashCommand("countdowns","ClassHelper:Print(\"Currently supported countdowns: Corsica, Koltrane, Smooth. Access these using ClassHelper:VoiceCountdown(countdown,channel,voice)\")","Currently supported countdowns: Corsica, Koltrane, Smooth.")
function ClassHelper:VoiceCountdown(countdown,channel,voice)
    if not voice then voice="corsica"end
    voice=strlower(voice)
    if not channel then channel="master"end
    if math.floor(countdown)==countdown then
        if countdown<11 then
            PlaySoundFile("Interface/AddOns/"..(ClassHelper.ADDON_PATH_NAME).."/Assets/countdown/"..voice.."/"..countdown..".ogg",channel)
        end
        if countdown>1 then
            C_Timer.NewTimer(1,function()self:VoiceCountdown(countdown-1,channel)end)
        end
    end
end
function ClassHelper:PlayWarningSound(soundName,channel,countdownVoice)
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
        elseif soundName=="beware"then
            return PlaySound(15391,channel)
        elseif strsub(soundName,1,10)=="countdown:"then
            if not countdownVoice then countdownVoice="corsica"end
            if tonumber(countdownVoice)then countdownVoice=soundpacks[tonumber(countdownVoice)]end
            if countdownVoice==""or not countdownVoice then
                countdownVoice="corsica" -- Default voice if not found
            end
            local c=strsub(soundName,11,strlen(soundName))
            if c and tonumber(c)and tonumber(c)<10 and math.floor(tonumber(c))==tonumber(c)then
                return PlaySoundFile("Interface/AddOns/"..(ClassHelper.ADDON_PATH_NAME).."/Assets/countdown/"..countdownVoice.."/"..c..".ogg",channel)
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
function ClassHelper:GetTTSVoice(voice)
    local voices=C_VoiceChat.GetTtsVoices()
    for i=1,getn(voices)do
        if voices[i].voiceID==voice or voices[i].name==voice then
            return voices[i]
        end
    end
    return voices[1]
end
function ClassHelper:PlayTTSWarning(text,voice,volume)
    local vol=0
    if volume then
        vol=TextToSpeechFrameAdjustVolumeSlider:GetValue()or 0
        TextToSpeech_SetVolume(volume)
    end
    local voice=self:GetTTSVoice(voice)
    TextToSpeech_Speak(text,voice)
    if volume then
        TextToSpeech_SetVolume(vol)
    end
end
ClassHelper:CreateSlashCommand("tts","ClassHelper:PlayTTSWarning(arguments)","Samples the text on the TTS interpreter. Volume will be at 100% and voice will be set to 0. Change these with ClassHelper:PlayTTSWarning(text,voice,volume)")