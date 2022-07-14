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

if CLIENT then
    function ServerPrint(...)
        local arg = {...}
        local st = ""
        for i,v in ipairs(arg) do
            if i>1 then
                st = st.." "
            end
            st=st..tostring(v)
        end
        net.Start("ServerPrint")
        net.WriteString(st)
        net.SendToServer()
    end
else
    util.AddNetworkString("ServerPrint")
    net.Receive("ServerPrint", function(len, ply)
        --print(ply, "ServerPrint", net.ReadString())
    end)
end

