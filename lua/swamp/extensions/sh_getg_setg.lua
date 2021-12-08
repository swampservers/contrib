-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- WORKING SETGLOBAL* BECAUSE GARRYS VERSION UNSETS ITSELF RANDOMLY THANKS A LOT GARRY
glbls = glbls or {}

-- TODO use just a table called Global similar to NWPrivate

--- Get a globally shared value (similar to GetGlobal* but actually works)
function GetG(k)
    return glbls[k]
end

if SERVER then
    util.AddNetworkString("Glbl")

    hook.Add("PlayerInitialSpawn", "globalsync", function(ply)
        net.Start("Glbl")
        net.WriteTable(glbls)
        net.Send(ply)
    end)

    timer.Create("FixGlobalEnts", 2, 0, function()
        local glblents = {}

        for k, v in pairs(glbls) do
            if isentity(v) then
                glblents[k] = v
            end
        end

        if not table.IsEmpty(glblents) then
            net.Start("Glbl", true)
            net.WriteTable(glblents)
            net.Broadcast()
        end
    end)

    --- Set a globally shared value (server)
    function SetG(k, v)
        if not istable(v) and glbls[k] == v then return end
        net.Start("Glbl")

        net.WriteTable({
            [k] = v
        })

        net.Broadcast()
        glbls[k] = v
    end
else
    net.Receive("Glbl", function()
        local t = net.ReadTable()

        for k, v in pairs(t) do
            glbls[k] = v
        end
    end)
end
