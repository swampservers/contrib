-- This file is subject to copyright - contact swampservers@gmail.com for more information.
if CLIENT then
    SituationMonitorRT = nil

    hook.Add("PostRender", "MonitorTheSituation", function()
        if IsValid(Me) and Me:GetNWInt("MONZ", 0) > 0 then
            if SituationMonitorRT == nil then
                SituationMonitorRT = GetRenderTarget(cvx_anonymous_name(), 1024, 1024, false)

                SituationMonitorMaterial = CreateMaterial(cvx_anonymous_name(), "UnlitTwoTexture", {
                    ["$basetexture"] = SituationMonitorRT:GetName(),
                    ["$texture2"] = "swamponions/plastic/noise",
                    ["$basetexturetransform"] = "center 0 1 scale -1 -0.625 rotate 0 translate 0 0"
                })
            end

            --print(CurTime())
            render.PushRenderTarget(SituationMonitorRT)

            -- MONITORINGTHESITUATION = true
            if Me:GetNWInt("MONZ", 0) == 1 then
                render.RenderView({
                    origin = GetGlobalVector("MON1P", Vector(0, 0, 0)),
                    angles = GetGlobalAngle("MON1A", Angle(0, 0, 0)),
                    x = 0,
                    y = 0,
                    w = 1024,
                    h = 640,
                    fov = 90,
                    drawmonitors = false,
                    drawhud = false,
                })
            else
                local a = Me:EyePos() - KLEINERPORTALPOS
                a.z = -a.z
                local l = math.max(a:Length() * 0.02, 1)
                a:Rotate(GetGlobalAngle("MON2A", Angle(0, 0, 0)))
                a = a:Angle()
                --a = GetGlobalAngle("MON2A", Angle(0,0,0))
                local fov = 70 + 50 / l

                render.RenderView({
                    origin = GetGlobalVector("MON2P", Vector(0, 0, 0)),
                    angles = a,
                    x = 0,
                    y = 0,
                    w = 1024,
                    h = 1024,
                    fov = fov,
                    drawmonitors = false,
                    drawhud = false,
                })
            end

            -- MONITORINGTHESITUATION = false
            render.PopRenderTarget()
        end
    end)

    -- hook.Add( "ShouldDrawLocalPlayer", "MonitorDraw3p", function( ply )
    --     if MONITORINGTHESITUATION then return true end
    -- end )
    -- TODO(winter): This should probably just be a matproxy
    --local mat = Material("sprites/sent_ball")
    --local mat2 = Material("models/wireframe")
    local situationRoomMonitorPos = MapTargets["monitor_situationroom"][1]["origin"]
    local situationRoomMonitorNormal = Vector(1, 0, 0)
    situationRoomMonitorNormal:Rotate(MapTargets["monitor_situationroom"][1]["angles"])

    --local deepSpaceMonitorPos = MapTargets["monitor_deepspace"][1]["origin"]
    hook.Add("PostDrawOpaqueRenderables", "MonitorDraw", function(depth, sky)
        if sky or depth then return end
        if not SituationMonitorMaterial then return end

        if IsValid(Me) and Me:GetNWInt("MONZ", 0) == 1 then
            SituationMonitorMaterial:SetMatrix("$texture2transform", Matrix({
                {1.5, 0, 0, math.Rand(0, 1)},
                {0, 1, 0, math.Rand(0, 1)},
                {0, 0, 1, 0},
                {0, 0, 0, 1}
            }))

            local colorMod = 0.97
            colorMod = Vector(math.Rand(colorMod, 1), math.Rand(colorMod, 1), math.Rand(colorMod, 1)) * math.Rand(colorMod, 1)
            SituationMonitorMaterial:SetVector("$color", colorMod)
            render.SetMaterial(SituationMonitorMaterial)
            render.DrawQuadEasy(situationRoomMonitorPos, situationRoomMonitorNormal, 104, 66, Color(255, 255, 255))
            --render.DrawQuadEasy(deepSpaceMonitorPos, Vector(0, -1, 0), 136, 85, Color(255, 255, 255))
        end
    end)
end
