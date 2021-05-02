-- This file is subject to copyright - contact swampservers@gmail.com for more information.

-- WORKING SETGLOBAL* BECAUSE GARRYS VERSION UNSETS ITSELF RANDOMLY THANKS A LOT GARRY
glbls = glbls or {}

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

    timer.Create("KEEP IT REAL", 2, 0, function()
        local glblents = {}

        for k, v in pairs(glbls) do
            if isentity(v) then
                glblents[k] = v
            end
        end

        net.Start("Glbl", true)
        net.WriteTable(glblents)
        net.Broadcast()
    end)

    function SetG(k, v)
        if glbls[k] == v then return end
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
