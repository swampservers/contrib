-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
RecentErrors = RecentErrors or {}

function ServerDebug(e)
    RecentErrors[tostring(e)] = CurTime()
end

ERRORLOG_REALERRORFUNCTION = ERRORLOG_REALERRORFUNCTION or debug.getregistry()[1]

debug.getregistry()[1] = function(e)
    ServerDebug("Error: " .. tostring(e))

    return ERRORLOG_REALERRORFUNCTION(e)
end

util.AddNetworkString("PrintConsole")

concommand.Add("serverdebug", function(ply, cmd, args)
    if (ply.sv_errors_last or 0) + 1 > CurTime() then return end
    ply.sv_errors_last = CurTime()
    ply:SendLua([[net.Receive("PrintConsole", function() print(net.ReadString()) end)]])
    local errors_ordered = {}

    for k, v in pairs(RecentErrors) do
        table.insert(errors_ordered, {k, v})
    end

    table.sort(errors_ordered, function(a, b) return a[2] < b[2] end)
    error_str = "\n\n"

    for i = math.max(1, #errors_ordered - 10), #errors_ordered do
        error_str = error_str .. tostring(math.floor(CurTime() - errors_ordered[i][2])) .. " seconds ago: " .. errors_ordered[i][1] .. "\n\n"
    end

    net.Start("PrintConsole")
    net.WriteString(error_str)
    net.Send(ply)
end)
