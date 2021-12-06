-- This file is subject to copyright - contact swampservers@gmail.com for more information.


function Ply(name)
    local humans = player.GetHumans()
    name = string.lower(name)

    for _, v in ipairs(humans) do
        if string.lower(v:Name()) == name then return v end
    end

    for _, v in ipairs(humans) do
        if (string.find(string.lower(v:Name()), name, 1, true) ~= nil) then return v end
    end
end

function PlyCount(name)
    name = string.lower(name)
    local rply = nil
    local c = 0

    for _, v in ipairs(player.GetHumans()) do
        if (string.find(string.lower(v:Name()), name, 1, true) ~= nil) then
            rply = v
            c = c + 1
        end
    end

    return rply, c
end
