-- This file is subject to copyright - contact swampservers@gmail.com for more information.

if not CRASH_DATA then
    local lastcrash = file.Read("swamp_crashdata.txt", "DATA")
    local crashtime = file.Time("swamp_crashdata.txt", "DATA")

    if lastcrash then
        timer.Simple(0, function()
            net.Start("ReportCrash")
            net.WriteDouble(crashtime)
            net.WriteString(lastcrash)
            net.SendToServer()
        end)
    end

    CRASH_DATA = {
        osx=system.IsOSX() or nil,
        linux = system.IsLinux() or nil,
        initializing=true
    }

    file.Write("swamp_crashdata.txt", util.TableToJSON(CRASH_DATA))
end

function SetCrashData(k, v, fortime)
    if CRASH_DATA[k] ~= v then
        CRASH_DATA[k] = v
        file.Write("swamp_crashdata.txt", util.TableToJSON(CRASH_DATA))
    end

    if fortime then
        timer.Simple(fortime, function()
            if CRASH_DATA[k]==v then
                SetCrashData(k, nil)
            end
        end)
    end
end

hook.Add("InitPostEntity", "CrashInit", function()
    timer.Simple(2, function() SetCrashData("initializing", nil) end)
end)


hook.Add("ShutDown", "CrashClear", function()
    file.Delete("swamp_crashdata.txt")
end)
