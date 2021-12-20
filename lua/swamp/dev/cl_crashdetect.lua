-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local lastcrash = file.Read("swampcrash.txt", "DATA")

timer.Simple(0, function()
    net.Start("ReportCrash")

    if lastcrash then
        net.WriteBool(true)
        net.WriteString(lastcrash)
    else
        net.WriteBool(false)
    end

    net.SendToServer()
end)

local crashdata = nil

function SetCrashData(str, fortime)
    if crashdata ~= str then
        crashdata = str
        file.Write("swampcrash.txt", str)

        if fortime then
            timer.Simple(fortime, function()
                if crashdata == str then
                    SetCrashData("")
                end
            end)
        end
    end
end

SetCrashData("")

hook.Add("ShutDown", "CrashClear", function()
    file.Delete("swampcrash.txt")
end)
