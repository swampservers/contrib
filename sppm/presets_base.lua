-- This file is subject to copyright - contact swampservers@gmail.com for more information.
if (CLIENT) then
    PPM.reservedPresetNames = {}

    function addPreset(name, code)
        Save(name, code)
        PPM.reservedPresetNames[name] = name
    end

    function Save(filename, code)
        if not file.Exists("ppm", "DATA") then
            file.CreateDir("ppm")
        end

        file.Write("ppm/" .. filename, code)
    end
end