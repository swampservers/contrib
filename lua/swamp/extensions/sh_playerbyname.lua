-- This file is subject to copyright - contact swampservers@gmail.com for more information.

function Ply(name)
    local ply,c = PlyCount(name)
    return ply
end

--- Find a player whose name contains some text. Returns any found player as well as the count of found players.
function PlyCount(name)
    name = name:lower()
    local rply = nil
    local c = 0

    for _, v in ipairs(player.GetHumans()) do
        if string.lower(v:Name()):find(name, 1, true) then
            rply = v
            c = c + 1
        end
    end

    return rply, c
end
