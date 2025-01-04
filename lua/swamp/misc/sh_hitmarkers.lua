-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- damage indicator shit
local hitmarkers = {}
local timeoffset = nil

API_Command("HitMarker", {API_COMP_VECTOR, API_FLOAT, API_UINT16, API_BOOL}, function(pos, time, dmg, kill)
    local offset = SysTime() - time
    timeoffset = timeoffset and math.min(timeoffset, offset) or offset

    table.insert(hitmarkers, {
        dmg = dmg,
        kill = kill,
        t = time + timeoffset,
        pos = pos
    })
end)

local badskull = Material("swamp/icon48/skull.png")

--NOMINIFY
hook.Add("PostDrawTranslucentRenderables", "DrawHitMarkers", function(d, s, s3)
    if d or s or s3 then return end
    local i, t = #hitmarkers, SysTime()

    while i > 0 do
        local mark = hitmarkers[i]
        i = i - 1
        local epicness = 1 + (mark.kill and math.sqrt(mark.dmg) / 20 or 0)
        local life = (t - mark.t) / epicness

        if life > 1 then
            table.remove(hitmarkers, i + 1)
            continue
        end

        -- if not mark.sx1 then mark.sx1 = (mark.pos:ToScreen().x or ScrW()/2)/ScrW() - 0.5 end
        local scale = (EyePos():Distance(mark.pos) + 150) / 150

        if not mark.motion1 then
            local function trianglewave(x)
                return 4 * (math.abs(x - math.floor(x + 0.5)) - 0.25)
            end

            local x = math.Clamp(((mark.pos:ToScreen().x or ScrW() / 2) / ScrW() - 0.5) * 10 + trianglewave(mark.t) * 1.5, -1, 1)
            mark.motion1 = (EyeAngles():Up() - EyeAngles():Forward()) * scale * 5
            mark.motion2 = EyeAngles():Right() * scale * x * 5 -- math.Rand(-2,2)
        end

        render.DepthRange(0, 0)
        local a = EyeAngles()
        a:RotateAroundAxis(a:Right(), 90)
        a:RotateAroundAxis(a:Up(), -90)
        cam.Start3D2D(mark.pos + life * mark.motion1 + life ^ 2 * mark.motion2, a, epicness * (life + 1) * scale * 60 / (ScrH() + 1000))

        local function drawtxt(txt, font, color)
            draw.SimpleText(txt, font, 2, 2, Color(0, 0, 0, color.a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            return draw.SimpleText(txt, font, 0, 0, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local alpha = 255 * math.sqrt(1 - life)
        local redfade = 255 * (1 - math.sqrt(life))
        -- Font.Roboto24
        local w = drawtxt(tostring(mark.dmg), Font["Lucida Console48"], Color(255, redfade, redfade, alpha))

        if mark.kill and not badskull:IsError() then
            local sz = 60
            surface.SetMaterial(badskull)
            surface.SetDrawColor(0, 0, 0, alpha)
            surface.DrawTexturedRect(w / 2 + 6 + 2, -sz / 2, sz, sz)
            surface.SetDrawColor(255, redfade, redfade, alpha)
            surface.DrawTexturedRect(w / 2 + 6, -sz / 2 - 2, sz, sz)
        end

        cam.End3D2D()
        render.DepthRange(0, 1)
    end
end)
-- hook.Add("HUDDrawScoreBoard", "DrawHitMarkers", function() end) -- local duration = 1 -- local t = SysTime() -- local i = 1 -- while i <= #hitmarkers do --     local marker = hitmarkers[i] --     if marker.t + duration < t then --         table.remove(hitmarkers, i) --     else --         i = i + 1 --         local drift = (t - marker.t) / duration --         local alpha = 1 - drift --         drift = drift + 0.1 --         -- ..marker.dmg.."" --         draw.SimpleText(marker.kill and "KILL " .. marker.dmg or tostring(marker.dmg), Font.Trebuchet24_1000, ScrW() / 2 + drift * 100 * marker.x, ScrH() / 2 + drift * 125, Color(255, 0, 0, 255 * alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) --     end -- end
