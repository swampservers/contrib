-- This file is subject to copyright - contact swampservers@gmail.com for more information.
CreateClientConVar("cinema_volume", 100, true, false, "", 0, 100)
GameVolumeConVar = CreateClientConVar("cinema_game_volume", 100, true, false, "", 0, 100)
VoiceVolumeConVar = CreateClientConVar("cinema_voice_volume", 100, true, false, "", 0, 100)

--NOMINIFY

--reset it
if GameVolumeConVar:GetInt() == 1 then
    RunConsoleCommand("cinema_game_volume", "100")
end

MuteGameConVar = CreateClientConVar("cinema_mutegame", 0, true, true, "", 0, 1)
MuteVoiceConVar = CreateClientConVar("cinema_mute_voice", 0, true, true, "", 0, 4)
CreateClientConVar("cinema_lightfx", 0, true, false, "", 0, 1)
CreateClientConVar("cinema_quality", 1, true, false, "", 0, 3)
local MuteNoFocus = CreateClientConVar("cinema_mute_nofocus", 1, true, false, "", 0, 1)

net.Receive("EntityEmitSound", function(len)
    local ent = net.ReadEntity()
    local soundname = net.ReadString()
    local soundlevel = net.ReadFloat()
    local pitch = net.ReadFloat()
    local volume = net.ReadFloat()
    local channel = net.ReadUInt(8) - 2
    local flags = net.ReadUInt(10)
    local dsp = net.ReadUInt(8)
    if not IsValid(ent) then return end --unloaded ent
    -- played in prediction, hopefully...?
    if ent == Me or ent:IsWeapon() and ent.Owner == Me then return end
    -- if net.ReadEntity() == Me then return end --predictedplayer
    ent:EmitSound(soundname, soundlevel, pitch, volume, channel ~= -2 and channel or nil, flags, dsp)
end)

net.Receive("EmitSound", function(len)
    local soundname = net.ReadString()
    local pos = net.ReadVector()
    local channel = net.ReadUInt(8) - 1
    local volume = net.ReadFloat()
    local soundlevel = net.ReadFloat()
    local flags = net.ReadUInt(10)
    local pitch = net.ReadFloat()
    local dsp = net.ReadUInt(8)
    if net.ReadEntity() == Me then return end --predictedplayer
    -- EmitSound(soundname,pos,-1,channel,volume,soundlevel,flags,pitch,dsp)
    sound.Play(soundname, pos, soundlevel, pitch, volume)
end)

function CinemaGameVolumeSetting()
    if IsValid(Me) and Me:InTheater() and MuteGameConVar:GetBool() then return 0 end

    return GameVolumeConVar:GetFloat() / 100
end

surface.PlaySoundOriginal = surface.PlaySoundOriginal or surface.PlaySound

surface.PlaySound = function(fl)
    if CinemaGameVolumeSetting() > 0 then
        surface.PlaySoundOriginal(fl)
    end
end

hook.Add("EntityEmitSound", "CinemaMuteGame", function(s)
    local f = CinemaGameVolumeSetting()
    if f == 0 then return false end

    if f < 1 then
        s.Volume = s.Volume * f

        return true
    end
end)

local lastmuted = false

timer.Create("SoundStopper", 0.2, 0, function()
    local f = CinemaGameVolumeSetting()
    local muted = f == 0

    if muted and not lastmuted then
        RunConsoleCommand('stopsound')
    end

    lastmuted = muted
end)

concommand.Add("cinema_requestlast", function()
    if LastURLRequested then
        RequestVideoURL(LastURLRequested)
    else
        local thelastrequest = nil
        local thevurl = nil

        for _, request in pairs(theater.GetRequestHistory()) do
            if not thelastrequest then
                thelastrequest = request.lastRequest
            end

            if thelastrequest < request.lastRequest then
                thevurl = request.url
            end

            thelastrequest = request.lastRequest
        end

        if thevurl then
            RequestVideoURL(thevurl)
        end
    end
end)

cvars.AddChangeCallback("cinema_quality", function(cmd, old, new)
    theater.ResizePanel()
end)

cvars.AddChangeCallback("cinema_volume", function(cmd, old, new)
    new = tonumber(new)

    if not new then
        return
    elseif new < 0 then
        RunConsoleCommand("cinema_volume", 0)
    elseif new > 100 then
        RunConsoleCommand("cinema_volume", 100)
    else
        theater.SetVolume(new)

        if MusicPagePanel then
            MusicPagePanel:RunJavascript("setVolume(" .. tostring(new) .. ");")
        end
    end
end)

cvars.AddChangeCallback("cinema_voice_volume", function(cmd, old, new)
    new = tonumber(new)

    if not new then
        return
    elseif new < 0 then
        RunConsoleCommand("cinema_voice_volume", 0)
    elseif new > 100 then
        RunConsoleCommand("cinema_voice_volume", 100)
    else
        for i, v in ipairs(player.GetAll()) do
            v:SetVoiceVolumeScale(new / 100)
        end
    end
end)

hook.Add("OnEntityCreated", "PlayerVoiceVolume", function(ent)
    if ent:IsPlayer() then
        ent:SetVoiceVolumeScale(VoiceVolumeConVar:GetFloat() / 100)
    end
end)

concommand.Add("cinema_refresh", function()
    theater.RefreshPanel(true)
end)

concommand.Add("cinema_fullscreen", function()
    theater.ToggleFullscreen()
end)

-- Mute theater on losing focus to Garry's Mod window
local FocusState, HasFocus, LastVolume = true, true, false

hook.Add("Think", "TheaterMuteOnFocusChange", function()
    if LastVolume == false then
        LastVolume = theater.GetVolume()
    end

    if not MuteNoFocus:GetBool() then return end
    HasFocus = system.HasFocus()

    if LastState and not HasFocus or not LastState and HasFocus then
        if HasFocus == true then
            theater.SetVolume(LastVolume)

            if MusicPagePanel then
                MusicPagePanel:RunJavascript("setVolume(" .. tostring(LastVolume) .. ");")
            end

            LastVolume = nil
        else
            LastVolume = theater.GetVolume()
            theater.SetVolume(0)

            if MusicPagePanel then
                MusicPagePanel:RunJavascript("setVolume(0);")
            end
        end

        LastState = HasFocus
    end
end)
