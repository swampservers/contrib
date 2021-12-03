-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

-- TODO: Can we remove this? the volume control function can be handled by the thing that handles all game sounds, all it will really do is lip animation

net.Receive("ExtSound", function(len)
    local ply = net.ReadEntity()
    local sound = net.ReadString()
    local pitch = net.ReadFloat()
    local options = net.ReadTable()

    if IsValid(ply) and (not options.shared) or (ply ~= LocalPlayer()) then
        ExtSoundEmitSound(ply, sound, pitch, options)
    end
end)

function ExtSoundEmitSound(ply, sound, pitch, options)
    if IsValid(LocalPlayer()) and LocalPlayer():InTheater() and GetConVar("cinema_mutegame"):GetBool() then return end

    if IsValid(options.ent) then
        ply = options.ent
    end

    if IsValid(ply) then
        ply:EmitSound(sound, options.level or 75, pitch, options.volume or 1, options.channel or CHAN_AUTO)
    end
end

net.Receive("SetSpeech", function()
    local ply = net.ReadEntity()

    if IsValid(ply) then
        ply.MouthCloseTime = RealTime() + net.ReadFloat() + 0.3
    end
end)

net.Receive("playerGesture", function()
    local ply = net.ReadEntity()

    if IsValid(ply) then
        ply:AnimRestartGesture(net.ReadInt(8), net.ReadInt(16), net.ReadBool())
    end
end)
