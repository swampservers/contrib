-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local swamp_weaponvolume = CreateClientConVar("swamp_weaponvolume", "1", true, false, "", 0.0, 1.0)

local weapon_sound_patterns = {
    "weapon",
    "bullet",
    "garand",
    "throatneck",
    "isissong"
}

hook.Add("EntityEmitSound", "EntityEmitSound_WeaponVolume", function(data)
    for k, v in pairs(data) do
        if (k == "SoundName") then
            for i = 1, #weapon_sound_patterns do
                if string.find(v, weapon_sound_patterns[i]) then
                    data.Volume = swamp_weaponvolume:GetFloat()
                    return true
                end
            end
        end
    end
end)
