-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
util.AddNetworkString("ExtSound")

function ExtSoundEmitSound(ply, sound, pitch, options)
    if options.speech then
        local duration = options.speech
        options.speech = nil

        if duration < 0 then
            duration = SoundDuration(sound)
        end

        duration = duration * 100.0 / pitch
        SetPlayerSpeechDuration(ply, math.max(duration - 0.3, 0))
    end

    net.Start("ExtSound")
    net.WriteEntity(ply)
    net.WriteString(sound)
    net.WriteFloat(pitch)
    net.WriteTable(options)
    net.Send(whoHearsCache(ply))

    if not options.shared then
        net.Start("ExtSound")
        net.WriteEntity(ply)
        net.WriteString(sound)
        net.WriteFloat(pitch)
        net.WriteTable(options)
        net.Send(ply)
    end
end

function whoHearsCache(ply)
    if not IsValid(ply) then return {} end

    if (CurTime() - (ply.whohearscachetime or 0)) > 1 then
        ply.whohearscache = whoHears(ply)
        ply.whohearscachetime = CurTime()
    end

    return ply.whohearscache
end

--todo: change to use playercanhearplayersvoice
function whoHears(ply)
    local recievers = {}

    --[[	
	if IsValid(ply) and ply:InTheater() then
		for k, v in pairs(player.GetAll()) do
			if ply:GetLocation() == v:GetLocation() then
				table.insert(recievers,v)
			end
		end
	else
		for k, v in pairs(player.GetAll()) do
			if not v:InTheater() then
				table.insert(recievers,v)
			end
		end
	end
	]]
    for k, v in pairs(player.GetAll()) do
        local a, b = hook.Run("PlayerCanHearPlayersVoice", v, ply)

        if a then
            table.insert(recievers, v)
        end
    end

    return recievers
end

util.AddNetworkString("SetSpeech")
util.AddNetworkString("playerGesture")

function SetPlayerSpeechDuration(ply, amt)
    if ply and IsValid(ply) then
        net.Start("SetSpeech")
        net.WriteEntity(ply)
        net.WriteFloat(amt)
        net.Broadcast()
    end
end

function setPlayerGesture(ply, slot, gesture, loop)
    if gesture > 0 then
        net.Start("playerGesture")
        net.WriteEntity(ply)
        net.WriteInt(slot, 8)
        net.WriteInt(gesture, 16)
        net.WriteBool(loop)
        net.Broadcast()
    end
end
