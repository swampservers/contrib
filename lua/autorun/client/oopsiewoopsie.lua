-- This file is subject to copyright - contact swampservers@gmail.com for more information.
LASTERRORTIME = -100
REALERRORFUNCTION = REALERRORFUNCTION or debug.getregistry()[1]

debug.getregistry()[1] = function(...)
    LASTERRORTIME = SysTime()

    return REALERRORFUNCTION(...)
end

local matAlert = Material("icon16/error.png")

--draws on top of the default error
hook.Add("PostRenderVGUI", "OOPSIE WOOPSIE", function()
    local EndTime = SysTime() - 10
    if LASTERRORTIME < EndTime then return end
    local Recent = SysTime() - 0.5
    local text = "OOPSIE WOOPSIE!! Uwu We made a fucky wucky!! A wittle fucko boingo! The code monkeys at our headquarters are working VEWY HAWD to fix this!"
    surface.SetFont("DermaDefaultBold")
    local w = surface.GetTextSize(text) + 48
    draw.RoundedBox(2, 34, 34, w, 30, Color(40, 40, 40, 255))
    draw.RoundedBox(2, 32, 32, w, 30, Color(240, 240, 240, 255))

    if (LASTERRORTIME > Recent) then
        draw.RoundedBox(2, 32, 32, w, 30, Color(255, 200, 0, (LASTERRORTIME - Recent) * 510))
    end

    surface.SetTextColor(90, 90, 90, 255)
    surface.SetTextPos(32 + 34, 32 + 8)
    surface.DrawText(text)
    surface.SetDrawColor(255, 255, 255, 150 + math.sin(32 + SysTime() * 30) * 100)
    surface.SetMaterial(matAlert)
    surface.DrawTexturedRect(32 + 6, 32 + 6, 16, 16)
end)
