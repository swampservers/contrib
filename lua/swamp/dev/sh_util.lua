-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--- For hacking/debugging. FindSinglePlayer but just returns nil if matches multiple.
function Ply(name)
    local found = FindSinglePlayer(name)

    if isnumber(found) then
        return nil
    else
        return found
    end
end
