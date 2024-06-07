-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--- Find a player whose name contains some text. If it finds exactly one matching player, returns that player. Otherwise, returns the number of found players (0 or >=2). To use this check isnumber() on the return.
function FindSinglePlayer(name, exact_overrides_multiple)
    name = name:lower()
    local count, ply = 0, nil

    for _, v in player.HumanIterator() do
        local plyname = v:Name():lower()
        -- exact match cancels any substring matches
        if exact_overrides_multiple and name == plyname then return v end

        if plyname:find(name, 1, true) then
            ply = v
            count = count + 1
        end
    end

    return count == 1 and ply or count
end
