-- This file is subject to copyright - contact swampservers@gmail.com for more information.
timer.Create("AreaMusicController", 0.5, 0, function()
    if not IsValid(Me) or Me.GetLocationName == nil then return end
    local target = ""
    local loc = Me:GetLocationName()

    if loc == "Vapor Lounge" and not (Me:GetTheater() and Me:GetTheater():IsPlaying()) then
        target = "vapor"
    end

    -- if loc=="Mines" then
    -- 	if GetGlobalBool("DAY", true) then
    -- 		target = table.Random({"cavern", "cavernalt"}) --alt. theme - https://youtu.be/-erU20cQO_Y
    -- 	else
    -- 		target = "cavernnight" --night theme - https://youtu.be/QT8vuiS0cpQ
    -- 	end
    -- end
    if loc == "Treatment Room" then
        target = "treatment"
    end

    if loc == "Gym" then
        target = "gym"
    end

    if IsValid(HELLTAKERFRAME) then
        target = "helltaker"
    end

    if MusicPagePanel then
        if target == MusicPagePanel.target then
        else -- MusicPagePanel:RunJavascript("setAttenuation(" .. (Me:GetTheater() and Me:GetTheater():IsPlaying() and "0" or "1") .. ")")
            if (target == "cavern" or target == "cavernalt") and (MusicPagePanel.target == "cavern" or MusicPagePanel.target == "cavernalt") then return end
            --don't remove panel for caverns themes
            MusicPagePanel:Remove()
            MusicPagePanel = nil
        end
    else
        if target ~= "" then
            if MusicPagePanel == nil then
                MusicPagePanel = vgui.Create("TheaterHTML")

                if MusicPagePanel == nil then
                    print('dhtml error')

                    return true
                end

                MusicPagePanel:SetSize(100, 100)
                MusicPagePanel:SetAlpha(0)
                MusicPagePanel:SetMouseInputEnabled(false)

                function MusicPagePanel:ConsoleMessage(msg)
                end

                MusicPagePanel.target = target
                MusicPagePanel:OpenURL("https://swamp.sv/bgmusic.php?t=" .. target .. "&v=" .. GetConVar("cinema_volume"):GetString() .. "&r" .. tostring(math.random()))
            end
        end
    end
end)

timer.Create("RandomCaveAmbientSound", 20, 0, function()
    if math.random(0, 250) >= 5 then return end --rare chance to trigger

    --any sewer location that isn't a theater
    if string.find(Me:GetLocationName(), "Sewer") and not Me:InTheater() then
        sound.PlayFile("sound/sewers/cave0" .. tostring(math.random(1, 6)) .. ".ogg", "3d noplay", function(snd, errid, errnm)
            if not IsValid(snd) then return end
            snd:SetPos(Me:GetPos() + VectorRand(-500, 500)) --set in a random location near the player
            snd:Play()
            snd:Set3DFadeDistance(600, 100000)
        end)
    end
end)
