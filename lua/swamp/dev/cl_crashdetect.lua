-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local lastcrash = file.Read("swampcrash.txt", "DATA")

if lastcrash then
    timer.Simple(0, function()
        net.Start("ReportCrash")
        -- if lastcrash then
        net.WriteBool(true)
        net.WriteString(lastcrash)
        -- else
        --     net.WriteBool(false)
        -- end
        net.SendToServer()
    end)
end

local crashdata = {}

function SetCrashData(k, v, fortime)
    if crashdata[k] ~= v then
        crashdata[k] = v
        file.Write("swampcrash.txt", util.TableToJSON(crashdata))
    end

    if fortime then
        timer.Simple(fortime, function()
            if crashdata[k] == v then
                SetCrashData(k, nil)
            end
        end)
    end
end

SetCrashData("os", system.IsWindows() and "win" or (system.IsOSX() and "osx" or "linux"))

hook.Add("ShutDown", "CrashClear", function()
    file.Delete("swampcrash.txt")
end)
