-- This file is subject to copyright - contact swampservers@gmail.com for more information.
if CLIENT then
    local notifications = {}

    net.Receive('Notify', function(length)
        Notify(net.ReadString())
    end)

    function Notify(str)
        print(str)

        table.insert(notifications, 1, {
            txt = str,
            pos = 1
        })
    end

    LocalPlayerNotify = Notify

    hook.Add("HUDDrawScoreBoard", "HUDPaint_PSNotification", function()
        local t = SysTime()
        local i = 1

        while i <= #notifications do
            local v = notifications[i]
            v.time = v.time or t
            local dt = SysTime() - v.time
            -- pos converges to i (todo make fps independent)
            v.pos = math.min(i, v.pos + FrameTime() + (i - v.pos) * 0.05)
            local a = math.Clamp(math.min(dt * 4, 5 - dt), 0, 1) - v.pos ^ 2 * 0.01

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
        ShowAnnouncement(net.ReadString(), net.ReadUInt(8))
    end)

    function ShowAnnouncement(txt, time)
        system.FlashWindow()
        surface.PlaySound("npc/attack_helicopter/aheli_damaged_alarm1.wav")
        GlobAnnce = txt
        AnnouncementOpenness = AnnouncementOpenness or Anim(0, 10)
        AnnouncementOpenness:SetTarget(1)

        timer.Create("AnnouncementRemover", time or 5, 1, function()
            AnnouncementOpenness:SetTarget(0)
        end)
    end

    hook.Add("HUDPaint", "Drawannocnr", function()
        if AnnouncementOpenness and AnnouncementOpenness() > 0 then
            local h = math.floor(AnnouncementOpenness() * 50) --ScrH()/8
            render.SetScissorRect(0, ScrH() / 2 - h, ScrW(), ScrH() / 2 + h, true)
            draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color.black)
            render.SetScissorRect(0, 0, 0, 0, false)
            h = math.max(h - 8, 0)
            local w = math.floor((math.min(AnnouncementOpenness() * 4, 1) * ScrW()) / 2)
            render.SetScissorRect(ScrW() / 2 - w, ScrH() / 2 - h, ScrW() / 2 + w, ScrH() / 2 + h, true)
            draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(200, 0, 0))
            draw.SimpleText(GlobAnnce, FitFont("sans64", GlobAnnce, ScrW()), ScrW() / 2, ScrH() / 2, Color.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            render.SetScissorRect(0, 0, 0, 0, false)
        end
    end)
else
    util.AddNetworkString('Notify')
end

--- Show a notification (bottow center screen popup). OK to call on invalid players (does nothing).
function Player:Notify(...)
    local st = table.concat({...}, ' ')

    if SERVER then
        if IsValid(self) then
            net.Start('Notify')
            net.WriteString(st)
            net.Send(self)
        end
    else
        assert(self == Me)
        LocalPlayerNotify(st)
    end
end
