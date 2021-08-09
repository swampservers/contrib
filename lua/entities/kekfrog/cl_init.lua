-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")
local mat = Material("models/swamponions/kekfrog_gold")

function ENT:Draw()
    render.MaterialOverride(mat)
    self:DrawModel()
    render.MaterialOverride()
end

net.Receive("KekOffer", function(len)
    local e = net.ReadEntity()

    Derma_StringRequest("Kek offering", "Enter the number of points to sacrifice.\nMay increase the income of this idol.", "1000", function(text)
        local n = tonumber(text)

        if n then
            net.Start("KekOffer")
            net.WriteEntity(e)
            net.WriteUInt(n, 32)
            net.SendToServer()
        end
    end, function(text) end)
end)

USEMENUENT = nil
RELEASING_USEMENU = false

net.Receive("EntUseMenu", function(len)
    if len == 0 then
        RELEASING_USEMENU = true
    else
        USEMENUENT = net.ReadEntity()
    end
end)

--NOMINIFY
local keksaytime = -100
local saykekdata = {}

net.Receive("saykek", function(len)
    local t = net.ReadTable()
    saykekdata = t
    print(#saykekdata, "keks")
    keksaytime = CurTime()
end)

-- hook.Add( "PreDrawHalos", "AddPropHalos", function()
--     -- local alpha = math.sin(CurTime()*10)*0.25 + 0.75
--     -- local td = CurTime() - keksaytime
--     -- if td < 10 then 
--     --     alpha  = alpha * math.Clamp(td,0,1) * math.Clamp(10-td,0,1)
-- 	--     halo.Add(Ents.kekfrog, Color(255,255,255,255*alpha), 5, 5, 16,true,true )
--     -- end
-- end )
hook.Add("HUDPaint", "saykek2", function()
    local alpha = math.sin(CurTime() * 10) * 0.25 + 0.75
    local td = CurTime() - keksaytime

    if td < 10 then
        alpha = alpha * math.Clamp(td, 0, 1) * math.Clamp(10 - td, 0, 1)

        -- halo.Add(Ents.kekfrog, Color(255,255,255,255*alpha), 5, 5, 16,true,true )
        for i, v in ipairs(saykekdata) do
            local p = v[2]

            if IsValid(v[1]) and not v[1]:IsDormant() then
                p = v[1]:GetPos()
            end

            local sc = p:ToScreen()

            if sc.visible then
                draw.SimpleText("kek", "Trebuchet18", sc.x, sc.y, Color(255, 220, 40, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end
end)

hook.Add("PostDrawTranslucentRenderables", "EntityUseMenu", function(d, sky, sky3d)
    if sky3d then return end
    if not render.DrawingScreen() then return end

    if IsValid(USEMENUENT) then
        local to = USEMENUENT:GetPos() - EyePos()
        local c, a, scl = USEMENUENT:GetPos(), to:Angle(), 0.07
        a:RotateAroundAxis(a:Right(), 90)
        a:RotateAroundAxis(a:Up(), -90)
        render.DepthRange(0, 0)
        cam.Start3D2D(c, a, scl)
        local hit = util.IntersectRayWithPlane(EyePos(), EyeAngles():Forward(), c, a:Up())

        if hit and EyePos():Distance(hit) > 100 then
            hit = nil
        end

        if hit then
            hit, _ = WorldToLocal(hit, Angle(), c, a)
            hit = hit / scl
            hit.y = -hit.y
            -- if hit.x < -200 or hit.x > 200 or hit.y < -100 or hit.y > 200 then
            --     hit = nil
            -- end
        end

        draw.SimpleText("Idol of Kek", "DermaLarge", 0, -80, color_white, TEXT_ALIGN_CENTER)
        local inc = USEMENUENT:Income()
        local sup =  math.ceil( USEMENUENT:IncomeSuppression()*100)
        draw.SimpleText(
            inc > 0 and 
                (
                    sup == 100 and
                    ("Generating " .. inc .. " points/minute") 
                    or
                    (inc .. " PPM - suppressed to "..sup.."% by higher level idols nearby") 
                )
                
                or "Bring to an unsafe area aboveground to generate income"
                
                , "Trebuchet18", 0, -40, color_white, TEXT_ALIGN_CENTER)

        local buttons = {
            {"pickup", "Pick up"},
            {"collect", "Collect " .. USEMENUENT:GetCollectPoints() .. " points"},
            {"offer", "Make an offering"}
        }

        for i, button in ipairs(buttons) do
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(-110, -50 + 50 * i, 220, 40)
            draw.SimpleText(button[2], "DermaLarge", 0, -50 + 50 * i + 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            if RELEASING_USEMENU then
                if hit and hit.x > -110 and hit.x < 110 and hit.y > -50 + 50 * i and hit.y < -50 + 50 * i + 40 then
                    net.Start("EntUseMenu")
                    net.WriteEntity(USEMENUENT)
                    net.WriteString(button[1])
                    net.SendToServer()
                end
            end
        end

        if hit then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawRect(hit.x - 4, hit.y - 4, 8, 8)
        end

        cam.End3D2D()
        render.DepthRange(0, 1)

        if RELEASING_USEMENU then
            USEMENUENT = nil
            RELEASING_USEMENU = false
        end
    end
end)
