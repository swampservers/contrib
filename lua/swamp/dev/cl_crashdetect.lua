-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- function crashwindow(delta)
    -- vgui("DFrame", function(p)
    --     local popup = p
    --     p:SetSize(440, 210)
    --     p:Center()
    --     p:SetBackgroundBlur(true)
    --     p:SetDrawOnTop(true)
    --     p:MakePopup()
    --     p:DoModal()
    --     -- timer.Simple(0.1, function()
    --     p:CloseOnEscape()
    --     -- end)
    --     p:SetTitle("Crashed?")

    --     for i, line in ipairs({"It looks like your game crashed last time you played (" .. delta .. " ago).", "If so, please send a crash report to help us fix it.", "If you send a crash report, you may optionally include comments below:", "BUTTONS", "Don't send a crash report if your game closed for another reason (eg. power outage).", "If you keep crashing, try disabling playermodel downloads and the\n  \"turbo button\" in the tab menu. If you still crash, ask for help."}) do
    --         if line == "BUTTONS" then
    --             local comments

    --             comments = vgui("DTextEntry", function(p)
    --                 p:Dock(TOP)
    --                 p:DockMargin(0, 0, 0, 8)
    --                 p:SetPlaceholderText(" what were you doing when it crashed? does anything seem to cause the crash?")

    --                 p.OnEnter = function()
    --                     net.Start("ReportCrash")
    --                     net.WriteDouble(crashtime)
    --                     net.WriteString(lastcrash)
    --                     net.WriteString(comments:GetValue())
    --                     net.SendToServer()
    --                     popup:Close()
    --                 end
    --             end)

    --             vgui("DPanel", function(p)
    --                 p:Dock(TOP)
    --                 p:DockMargin(0, 0, 0, 8)
    --                 p:SetTall(24)
    --                 p.Paint = noop

    --                 vgui("DButton", function(p)
    --                     p:DockMargin(70, 0, 0, 0)
    --                     p:SetWide(125)
    --                     p:Dock(LEFT)
    --                     p:SetText("Send crash report")
    --                     p.DoClick = comments.OnEnter
    --                 end)

    --                 vgui("DButton", function(p)
    --                     p:DockMargin(0, 0, 70, 0)
    --                     p:SetWide(125)
    --                     p:Dock(RIGHT)
    --                     p:SetText("Don't send")

    --                     p.DoClick = function()
    --                         popup:Close()
    --                     end
    --                 end)
    --             end)
    --         else
    --             vgui("DLabel", function(p)
    --                 p:Dock(TOP)
    --                 p:SetText(line)
    --                 p:SizeToContents()
    --                 p:DockMargin(0, 0, 0, 8)
    --                 p:SetContentAlignment(5)
    --             end)
    --         end
    --     end
    -- end)
-- end

if not CRASH_DATA then
    local lastcrash = file.Read("swamp_crashdata.txt", "DATA")
    local crashtime = file.Time("swamp_crashdata.txt", "DATA")

    if lastcrash then
        -- timer.Simple(0.1, function()
        --     timer.Simple(0.1, function()
        hook.Add("MOTDClose", "ShowCrashDialog", function()
            local delta = os.time() - crashtime

            local function plural(x, st)
                if x == 1 then
                    return x .. st
                else
                    return x .. st .. "s"
                end
            end

            if delta > 60 then
                delta = math.floor(delta / 60)

                if delta > 60 then
                    delta = math.floor(delta / 60)

                    if delta > 24 then
                        delta = plural(math.floor(delta / 24), " day")
                    else
                        delta = plural(delta, " hour")
                    end
                else
                    delta = plural(delta, " minute")
                end
            else
                delta = plural(delta, " second")
            end

            -- crashwindow(delta)
            net.Start("ReportCrash")
            net.WriteDouble(crashtime)
            net.WriteString(lastcrash)
            net.WriteString("")
            net.SendToServer()
        end)
        -- end)
    end

    CRASH_DATA = {
        osx = system.IsOSX() or nil,
        linux = system.IsLinux() or nil,
        initializing = true,
        uptime = 0
    }

    local uptime = 0

    timer.Create("CrashDataUptime", 10, 0, function()
        uptime = uptime + 10
        SetCrashData("uptime", uptime)
    end)

    file.Write("swamp_crashdata.txt", util.TableToJSON(CRASH_DATA))
end

function SetCrashData(k, v, fortime)
    if CRASH_DATA[k] ~= v then
        CRASH_DATA[k] = v
        file.Write("swamp_crashdata.txt", util.TableToJSON(CRASH_DATA))
    end

    if fortime then
        timer.Simple(fortime, function()
            if CRASH_DATA[k] == v then
                SetCrashData(k, nil)
            end
        end)
    end
end

hook.Add("InitPostEntity", "CrashInit", function()
    timer.Simple(2, function()
        SetCrashData("initializing", nil)
    end)
end)

hook.Add("ShutDown", "CrashClear", function()
    file.Delete("swamp_crashdata.txt")
end)
