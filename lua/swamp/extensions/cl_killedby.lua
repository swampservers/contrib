local killdata
local killdatarecipt = 0

net.Receive("KilledByData", function(len)
    killdata = {net.ReadString(), net.ReadString()}

    killdatarecipt = CurTime()
end)

local skull = Material("HUD/killicons/default")
local skullwhitetime = SysTime()

hook.Add("HUDPaint", "DeathNotice", function()
    if not IsValid(Me) or Me:Alive() or not killdata then
        if CurTime() > killdatarecipt + 2 then
            killdata = nil
        end

        skullwhitetime = SysTime()

        return
    end

    local redness = math.Clamp((SysTime() - 0.5) - skullwhitetime, 0, 1)
    surface.SetMaterial(skull)
    surface.SetDrawColor(255, 255 * (1 - redness), 255 * (1 - redness), 255)
    local s = 128
    surface.DrawTexturedRect((ScrW() - s) / 2, ScrH() / 2 - s, s, s)
    draw.SimpleText(killdata[1], "DermaLarge", ScrW() / 2, ScrH() / 2, color_white, TEXT_ALIGN_CENTER)
    draw.SimpleText(killdata[2], "Trebuchet24", ScrW() / 2, ScrH() / 2 + 38, color_white, TEXT_ALIGN_CENTER)
end)
