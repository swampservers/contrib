-- This file is subject to copyright - contact swampservers@gmail.com for more information.
if CLIENT then
    local notifications = {}

    net.Receive('Notify', function(length)
        LocalPlayerNotify(net.ReadString())
    end)


    function LocalPlayerNotify(str)
        print(str)

        table.insert(notifications, 1, {
            txt = str,
            pos = 1
        })
    end

    hook.Add("HUDDrawScoreBoard", "HUDPaint_PSNotification", function()
        local t = SysTime()
        local i = 1

        while i <= #notifications do
            local v = notifications[i]
            v.time = v.time or t
            local dt = SysTime() - v.time
            local a = math.Clamp(math.min(dt * 4, 5 - dt), 0, 1)
            -- pos converges to i (todo make fps independent)
            v.pos = math.min(i, v.pos + FrameTime() + (i - v.pos) * 0.05)

            if a > 0 then
                surface.SetFont("ChatFont")
                local w, h = surface.GetTextSize(v.txt)
                draw.WordBox(6, ScrW() / 2, (ScrH() - 20) - (v.pos - 1) * (h + 16), v.txt, "ChatFont", Color(0, 0, 0, 150 * a), Color(255, 255, 255, 255 * a), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                i = i + 1
            elseif dt > 1 then
                table.remove(notifications, i)
            end
        end
    end)

    -- code for center screen announcements
    GlobAnnce = false

    net.Receive("Announcement", function()
        surface.PlaySound("npc/attack_helicopter/aheli_damaged_alarm1.wav")
        GlobAnnce = net.ReadString()
        local time = net.ReadUInt(8)

        timer.Create("AnnouncementRemover", time, 1, function()
            GlobAnnce = false
        end)
    end)

    hook.Add("HUDPaint", "Drawannocnr", function()
        if not GlobAnnce then return end
        local bs = 15
        surface.SetFont("DermaLarge")
        local w, h = surface.GetTextSize(GlobAnnce)
        draw.WordBox(bs, ((ScrW() - w) / 2) - bs, ((ScrH() - h) / 2) - bs, GlobAnnce, "DermaLarge", Color(255, 0, 0), Color(255, 255, 255))
        bs = bs - 5
        draw.WordBox(bs, ((ScrW() - w) / 2) - bs, ((ScrH() - h) / 2) - bs, GlobAnnce, "DermaLarge", Color(0, 0, 0), Color(255, 255, 255))
    end)
else
    util.AddNetworkString('Notify')
end

local Player = FindMetaTable('Player')

--- Show a notification (bottow center screen popup)
function Player:Notify(...)
    local st = table.concat({...}, '')
    if SERVER then
        net.Start('Notify')
        net.WriteString(st)
        net.Send(self)
    else
        assert(self == Me)
        LocalPlayerNotify(st)
    end
end
