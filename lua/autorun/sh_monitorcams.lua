
if CLIENT then
    SituationMonitorRT = nil

    hook.Add("PreRender", "MonitorTheSituation", function()
        if IsValid(LocalPlayer()) and LocalPlayer():GetNWInt("MONZ", 0)>0 then
            if SituationMonitorRT==nil then
                SituationMonitorRT = GetRenderTarget( cvx_anonymous_name(),1024,1024,false)
                SituationMonitorMaterial = CreateMaterial(cvx_anonymous_name(), "UnlitTwoTexture", {
                    ["$basetexture"] = SituationMonitorRT:GetName(),
                    ["$texture2"]=	"swamponions/plastic/noise",
                    ["$basetexturetransform"] = "center 0 1 scale -1 -0.625 rotate 0 translate 0 0"
                })
            end

--            print(CurTime())

            render.PushRenderTarget(SituationMonitorRT)
            -- MONITORINGTHESITUATION = true
            if LocalPlayer():GetNWInt("MONZ", 0) == 1 then
                render.RenderView( {
                    origin = GetGlobalVector("MON1P", Vector(0,0,0)),
                    angles = GetGlobalAngle("MON1A", Angle(0,0,0)),
                    x = 0, y = 0,
                    w = 1024, h = 640,
                    fov=90,
                    drawmonitors=false,
                    drawhud=false,
                })
            else
                render.RenderView( {
                    origin = GetGlobalVector("MON2P", Vector(0,0,0)),
                    angles = GetGlobalAngle("MON2A", Angle(0,0,0)),
                    x = 0, y = 0,
                    w = 1024, h = 1024,
                    fov=80,
                    drawmonitors=false,
                    drawhud=false,
                })
            end
            -- MONITORINGTHESITUATION = false
            render.PopRenderTarget()
        end
    end)

    
    -- hook.Add( "ShouldDrawLocalPlayer", "MonitorDraw3p", function( ply )
    --     if MONITORINGTHESITUATION then return true end
    -- end )
    

    local mat = Material( "sprites/sent_ball" )
local mat2 = Material( "models/wireframe" )

    hook.Add("PostDrawOpaqueRenderables", "MonitorDraw", function()
        if IsValid(LocalPlayer()) and LocalPlayer():GetNWBool("MON", false) then

            SituationMonitorMaterial:SetMatrix("$texture2transform", Matrix({{1.5, 0, 0, math.Rand(0,1)}, {0, 1, 0, math.Rand(0,1)}, {0, 0, 1, 0}, {0, 0, 0, 1}}))
            local v = 0.97
            v = Vector(math.Rand(v,1),math.Rand(v,1),math.Rand(v,1))*math.Rand(v,1)
            SituationMonitorMaterial:SetVector("$color",v)

            render.SetMaterial( SituationMonitorMaterial )
            render.DrawQuadEasy( Vector( -2748, 117, -249.6 ), Vector( 1, 0, 0 ), 104, 65, Color( 255, 255, 255))
            render.DrawQuadEasy( Vector( 10863, 10510, 12151 ), Vector( 0, -1, 0 ), 136, 85, Color( 255, 255, 255))
        
        end
    end)

end