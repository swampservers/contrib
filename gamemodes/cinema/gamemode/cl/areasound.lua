﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
timer.Create("AreaMusicController", 0.5, 0, function()
    if not IsValid(LocalPlayer()) or LocalPlayer().GetLocationName == nil then return end
    local target = ""
    local loc = LocalPlayer():GetLocationName()

    if loc == "Vapor Lounge" and not (LocalPlayer():GetTheater() and LocalPlayer():GetTheater():IsPlaying()) then
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

    if ValidPanel(HELLTAKERFRAME) then
        target = "helltaker"
    end

    if MusicPagePanel then
        if target == MusicPagePanel.target then
        else -- MusicPagePanel:RunJavascript("setAttenuation(" .. (LocalPlayer():GetTheater() and LocalPlayer():GetTheater():IsPlaying() and "0" or "1") .. ")")
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
                MusicPagePanel:OpenURL("http://swamp.sv/bgmusic.php?t=" .. target .. "&v=" .. GetConVar("cinema_volume"):GetString() .. "&r" .. tostring(math.random()))
            end
        end
    end
end)

timer.Create("RandomCaveAmbientSound", 20, 0, function()
    if math.random(0, 250) >= 5 then return end --rare chance to trigger

    --any sewer location that isn't a theater
    if string.find(LocalPlayer():GetLocationName(), "Sewer") and not LocalPlayer():InTheater() then
        sound.PlayFile("sound/sewers/cave0" .. tostring(math.random(1, 6)) .. ".ogg", "3d noplay", function(snd, errid, errnm)
            if not IsValid(snd) then return end
            snd:SetPos(LocalPlayer():GetPos() + VectorRand(-500, 500)) --set in a random location near the player
            snd:Play()
            snd:Set3DFadeDistance(600, 100000)
        end)
    end
end)
