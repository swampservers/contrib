-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
CreateClientConVar("musicvis_flashing", "0")
CreateClientConVar("musicvis_debug", "0")

concommand.Add("musicvis", function(ply, cmd, args)
    net.Start("SetMusicVis")
    net.WriteString(args[1]:lower())
    net.SendToServer()
end)

--todo make this interface better
VISUALIZER_SETTINGS = {"Rave", "Colorful", "Flash", "Red", "Dark", "None", "Ignite", "ClearStage"}

--"Dynamic",
hook.Add("PostDrawOpaqueRenderables", "MusicVisUI", function(depth, sky)
    if depth or sky then return end
    VISUALIZER_TYPE_TARGET = nil
    if not (IsValid(LocalPlayer()) and LocalPlayer():GetLocationName() == "Vapor Lounge" and LocalPlayer():GetTheater()) then return end
    local c, a = Vector(2302, 530, 69), Angle(0, 0, 40)
    local scl = 0.06
    local lh = 24
    local hit = util.IntersectRayWithPlane(EyePos(), EyeAngles():Forward(), c, a:Up())

    if hit and EyePos():Distance(hit) > 60 then
        hit = nil
    end

    if hit then
        hit, _ = WorldToLocal(hit, Angle(), c, a)
        hit = hit / scl
        hit.y = -hit.y

        if hit.x < -200 or hit.x > 200 or hit.y < -100 or hit.y > 200 then
            hit = nil
        end
    end

    -- local own = LocalPlayer():GetTheater():GetOwner()==LocalPlayer()
    cam.Start3D2D(c, a, scl)

    -- costs fps?? EyePos():Distance(c)<100 and
    --and HtmlLightsMatFixx then
    if theater.HtmlLightsMat then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(theater.HtmlLightsMat)
        -- surface.DrawTexturedRect(-30, 0, THLIGHT_CANVAS_XS * HtmlLightsMatFixx, THLIGHT_CANVAS_YS * HtmlLightsMatFixy)
        surface.DrawTexturedRect(-280, -60, 160 * 4, 90 * 4)
    end

    for i, v in ipairs(VISUALIZER_SETTINGS) do
        draw.SimpleText(v, "Trebuchet24", 16, lh * (i - 1), WHITE)

        if hit and hit.y > lh * (i - 1) and hit.y < lh * i then
            VISUALIZER_TYPE_TARGET = v
        end

        if UsingMusicVis(v:lower()) or VISUALIZER_TYPE_TARGET == v then
            surface.SetDrawColor(255, 255, 255, 255)
            local sz = UsingMusicVis(v:lower()) and 5 or 4
            surface.DrawRect(8 - sz, lh * (i - 0.5) - sz - 1, sz * 2, sz * 2)
        end
    end

    if VAPOR_LAST_DRIVE then
        local p = VAPOR_LAST_DRIVE

        if p < 0 then
            p = p * 0.2
        end

        if p > 1 then
            p = 1 - (1 - p) * 0.2
        end

        local h = p * 100
        surface.SetDrawColor(255, 128, 0, 255)

        if h >= 0 then
            h = math.max(h, 2)
        end

        surface.DrawRect(240, 160 - h, 20, h)

        -- surface.DrawRect(-260,40,14,2)
        for i, v in ipairs(VAPOR_LAST_FFT or {}) do
            surface.SetDrawColor(255, 255, i % 2 == 0 and 128 or 255, 255)
            h = math.max(v * 150, 2)
            surface.DrawRect(-260 + 20 * i, 160 - h, 14, h)
        end
    end

    if hit then
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(hit.x - 4, hit.y - 4, 8, 8)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(hit.x - 2, hit.y - 2, 4, 4)
    end

    cam.End3D2D()
end)

hook.Add("KeyPress", "MusicVisClick", function(ply, key)
    if (key == IN_USE or key == IN_ATTACK) and VISUALIZER_TYPE_TARGET and IsFirstTimePredicted() then
        RunConsoleCommand("musicvis", VISUALIZER_TYPE_TARGET)
        print("Use the console command: musicvis " .. VISUALIZER_TYPE_TARGET:lower() .. " for faster switching.")
    end
end)

local ColorSquareMaterial = CreateMaterial("ScreenSpaceSquare", "UnlitGeneric", {
    ["$basetexture"] = "color/white",
    ["$detail"] = "color/white",
    ["$detailblendmode"] = 8,
    ["$detailblendfactor"] = 1,
    ["$detailscale"] = 1,
    ["$alpha"] = 0.5,
    ["$color"] = "[1 1 1]"
})

function math.power2(n)
    return math.pow(2, math.ceil(math.log(n) / math.log(2)))
end

function DrawSquareColor(blend, color2, skipcopy)
    --WE NEED A RT WITHOUT ALPHA OR IT BUGS OUT
    if not DRAWSQUARECOLORRT or DRAWSQUARECOLORRT:Width() < ScrW() or DRAWSQUARECOLORRT:Height() < ScrH() then
        local w, h = math.power2(ScrW()), math.power2(ScrH())
        DRAWSQUARECOLORRT = GetRenderTargetEx("DRAWSQUARECOLORRT" .. tostring(w) .. "x" .. tostring(h), w, h, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, 1, 0, IMAGE_FORMAT_RGB888)
    end

    if blend > 0 then
        if not skipcopy then
            render.CopyRenderTargetToTexture(DRAWSQUARECOLORRT)
        end

        ColorSquareMaterial:SetTexture("$basetexture", DRAWSQUARECOLORRT)
        ColorSquareMaterial:SetTexture("$detail", DRAWSQUARECOLORRT)
        ColorSquareMaterial:SetFloat("$alpha", math.min(math.max(blend, 0), 1))
        ColorSquareMaterial:SetVector("$color", color2)
        render.SetMaterial(ColorSquareMaterial)
        render.DrawScreenQuad()
    end
end

CreateMaterial("VaporLoungeBoxes", "VertexLitGeneric", {
    ["$basetexture"] = "sunabouzu/theater_tile01",
    ["$basetexturetransform"] = "center 0 0 scale .5 .5 rotate 0 translate 0 0",
    ["$color2"] = "[0.7 0.7 0.65]",
})