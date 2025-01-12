-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- The rest of this file is in includes/util
-- possibly would it be useful to save the current hook name?
function CrashDataScope(callback, data)
    if not CRASH_DATA then return end
    local lastscope, lastdata = CRASH_DATA.scope, CRASH_DATA.scope_data
    data = data or {}

    for k, v in pairs(lastdata or {}) do
        if data[k] == nil then
            data[k] = v
        end
    end

    CRASH_DATA.scope, CRASH_DATA.scope_data = debug.traceback(), data
    SaveCrashData()
    local ok, a, b, c, d, e, f = pcall(callback)
    CRASH_DATA.scope, CRASH_DATA.scope_data = lastscope, lastdata
    SaveCrashData()

    if not ok then
        error(a)
    end

    return a, b, c, d, e, f
end

if not RealGetModelMeshes then
    RealGetModelMeshes = util.GetModelMeshes

    function util.GetModelMeshes(model, lod, mask)
        return CrashDataScope(function() return RealGetModelMeshes(model, lod, mask) end, {
            GetModelMeshes = model,
            lod = lod,
            mask = mask
        })
    end
end

if not RealCapturePixels then
    RealCapturePixels = render.CapturePixels

    function render.CapturePixels()
        return CrashDataScope(function() return RealCapturePixels() end, {
            CapturePixels = true
        })
    end
end

hook.Add("InitPostEntity", "CrashInit", function()
    timer.Simple(3, function()
        SetCrashData("initializing", nil)
    end)
end)

hook.Add("ShutDown", "CrashClear", function()
    file.Delete("swamp_crashdata.txt")
end)
-- hook.Add("MOTDClose", "ShowCrashDialog", function()
-- local delta = os.time() - crashtime
-- local function plural(x, st)
--     if x == 1 then
--         return x .. st
--     else
--         return x .. st .. "s"
--     end
-- end
-- if delta > 60 then
--     delta = math.floor(delta / 60)
--     if delta > 60 then
--         delta = math.floor(delta / 60)
--         if delta > 24 then
--             delta = plural(math.floor(delta / 24), " day")
--         else
--             delta = plural(delta, " hour")
--         end
--     else
--         delta = plural(delta, " minute")
--     end
-- else
--     delta = plural(delta, " second")
-- end
-- -- crashwindow(delta)
-- function crashwindow(delta)
-- ui.DFrame(function(p)
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
--             comments = ui.DTextEntry(function(p)
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
--             ui.DPanel(function(p)
--                 p:Dock(TOP)
--                 p:DockMargin(0, 0, 0, 8)
--                 p:SetTall(24)
--                 p.Paint = noop
--                 ui.DButton(function(p)
--                     p:DockMargin(70, 0, 0, 0)
--                     p:SetWide(125)
--                     p:Dock(LEFT)
--                     p:SetText("Send crash report")
--                     p.DoClick = comments.OnEnter
--                 end)
--                 ui.DButton(function(p)
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
--             ui.DLabel(function(p)
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
