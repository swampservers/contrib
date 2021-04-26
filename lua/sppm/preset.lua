-- This file is subject to copyright - contact swampservers@gmail.com for more information.
PPM.bannedVars = {"m_bodyt0"}

-- NOTABLE LIMITATION: WILL REMOVE SPACES FROM STRINGS TYPE ITEMS BEFORE SAVING AND WILL REFUSE TO LOAD THEM PROPERLY
-- (THIS IS A LIMITATION OF THE ORIGINAL FORMAT FROM A PRIOR AUTHOR AND MAY BE FIXED LATER WITH A WORKAROUND IF IT EVER BECOMES NEEDED)
function PPM.PonyDataToString(ponydata)
    local saveframe = {}

    for k, v in SortedPairs(ponydata) do
        if not table.HasValue(PPM.bannedVars, k) then
            if type(v) == "number" then
                table.insert(saveframe, "\n " .. k .. " " .. tostring(v))
            elseif type(v) == "Vector" then
                table.insert(saveframe, "\n " .. k .. " " .. tostring(v))
            elseif type(v) == "boolean" then
                table.insert(saveframe, "\n " .. k .. " b " .. tostring(v))
            elseif type(v) == "string" then
                table.insert(saveframe, "\n " .. k .. " s " .. string.Replace(v, " ", ""))
            end
        end
    end

    return table.concat(saveframe)
end

function PPM.StringToPonyData(str)
    local lines = string.Split(str, "\n")
    local ponydata = {}

    for k, v in pairs(lines) do
        local args = string.Split(string.Trim(v), " ")
        local name = string.Replace(args[1], "pny_", "")

        if not table.HasValue(PPM.bannedVars, name) then
            if (table.Count(args) == 2) then
                ponydata[name] = tonumber(args[2])
            elseif (table.Count(args) == 4) then
                ponydata[name] = Vector(tonumber(args[2]), tonumber(args[3]), tonumber(args[4]))
            elseif (table.Count(args) == 3) then
                if args[2] == "b" then
                    ponydata[name] = tobool(args[3])
                elseif args[2] == "s" then
                    ponydata[name] = args[3]
                end
            end
        end
    end

    return ponydata
end

if CLIENT then
    function PPM.Save(filename, ponydata)
        local saveframe = PPM.PonyDataToString(ponydata)

        if not string.EndsWith(filename, ".txt") then
            filename = filename .. ".txt"
        end

        if not file.Exists("ppm", "DATA") then
            file.CreateDir("ppm")
        end

        MsgN("saving .... " .. "ppm/" .. filename)
        file.Write("ppm/" .. filename, saveframe)
    end

    function PPM.Load(filename)
        local data = file.Read("data/ppm/" .. filename, "GAME")

        return PPM.StringToPonyData(data)
    end
end