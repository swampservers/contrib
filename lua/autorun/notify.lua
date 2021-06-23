-- This file is subject to copyright - contact swampservers@gmail.com for more information.
if CLIENT then
    LatestNotification = ""
    LatestNotificationTime = -10
    ResetNotificationTime = false

    net.Receive('Notify', function(length)
        LocalPlayerNotify(net.ReadString())
    end)

    function LocalPlayerNotify(str)
        print(str)
        LatestNotification = str
        ResetNotificationTime = true
    end

    hook.Add("PostRenderVGUI", "HUDPaint_PSNotification", function()
        if ResetNotificationTime then
            LatestNotificationTime = CurTime()
            ResetNotificationTime = false
        end

        local dt = CurTime() - LatestNotificationTime
        local a = math.Clamp(math.min(dt * 4, 5 - dt), 0, 1)

        if a > 0 then
            surface.SetFont("ChatFont")
            local w, h = surface.GetTextSize(LatestNotification)
            draw.WordBox(8, (ScrW() - (16 + w)) * 0.5, ScrH() - 50, LatestNotification, "ChatFont", Color(0, 0, 0, 150 * a), Color(255, 255, 255, 255 * a))
        end
    end)
else
    util.AddNetworkString('Notify')
    local Player = FindMetaTable('Player')

    function Player:Notify(...)
        net.Start('Notify')

        net.WriteString(table.concat({...}, ''))

        net.Send(self)
    end
end