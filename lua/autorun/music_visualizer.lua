-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA


-- override this if you want to make new visualizations and look at them locally
function UsingMusicVis(name)
    return GetG("musicvis") == name
end





if SERVER then
    LOUNGE_DOORS = {}
    util.AddNetworkString("SetMusicVis")

    net.Receive("SetMusicVis", function(len, ply)
        local st = net.ReadString()
        if st:len() > 30 then return end    
        if ply:GetTheater() and ply:GetTheater():Name()=="Vapor Lounge" and (ply:GetTheater():GetOwner()==ply or ply:IsAdmin()) then
            if st=="ignite" then
                if (MUSIC_LAST_SFX or 0) < CurTime()-30 then
                    for _,v in ipairs(ents.FindByClass("prop_physics")) do
                        if v:GetModel()=="models/sunabouzu/speaker.mdl" then -- or v:GetModel()=="models/props_combine/breenconsole.mdl" then
                            v:Ignite(8)
                        end
                    end 
                    MUSIC_LAST_SFX=CurTime()
                end
                return
            end
            SetG("musicvis", st:lower())
        else
            ply:Notify("You must own the theater to do this.")
        end
    end)

    timer.Create("musicvis_resetter",0.8,0,function()
        local th =theater.GetByLocation(Location.GetLocationIndexByName("Vapor Lounge"))
        if not th then return end
        local o = th:GetOwner()
        if o~=MUSICVISLASTOWNER then
            MUSICVISLASTOWNER=o
            SetG("musicvis", "rave")
        end

        if #LOUNGE_DOORS==0 then
            for _,v in ipairs(ents.GetAll()) do if v.LOUNGEDOOR then v:Remove() end end
            for _,side in ipairs({-1,1}) do
            e = ents.Create("prop_door_rotating")
            e.LOUNGEDOOR=true
            table.insert(LOUNGE_DOORS, e)
            e:SetModel("models/props_c17/door01_left.mdl")
            e:SetSkin(2)
            e:SetPos(Vector(2050, 768+side*46, 54))
            e:SetAngles(Angle(0,90+90*side,0))
            e.INNER_OPEN = side==1 and 2 or 1
            e.OUTER_OPEN = side==1 and 1 or 2
            e:SetKeyValue("opendir",e.INNER_OPEN)
            e:SetKeyValue("returndelay",4)
            e:SetKeyValue("forceclosed",1)
            -- e:SetKeyValue( "spawnflags", 8192 ) --use closes
            e:SetColor(Color(128,128,128))
            e:Spawn()
            e:Activate()
            e.WASCLOSED = true
            e.IsOpen = function(ent) return math.abs(ent:GetAngles():Forward().y) > 0.5 end
            end
        end
 
        for _,v in ipairs(LOUNGE_DOORS) do
            if (v.UseTime or 0) < CurTime() - 4 then
                local op = v:IsOpen()
                if th:IsPlaying() == op then
                    v:Fire(op and "Close" or "Open")
                end
            end
        end
    end)

    hook.Add("PlayerUse", "LoungeDoorOpener", function(ply, ent)
        if ent.LOUNGEDOOR then
            local tofire = ent:IsOpen() and "Close" or "Open"
            for _,v in ipairs(LOUNGE_DOORS) do
                v:SetKeyValue("opendir", ply:GetPos().x<v:GetPos().x and v.OUTER_OPEN or v.INNER_OPEN)
                v:Fire(tofire)
                v.UseTime = CurTime()
            end
            return false
        end
    end)

    return
end

CreateClientConVar("musicvis_flashing", "0")
CreateClientConVar("musicvis_debug", "0")

concommand.Add("musicvis", function( ply, cmd, args )
    net.Start("SetMusicVis") net.WriteString(args[1]:lower()) net.SendToServer()
end)

--todo make this interface better
VISUALIZER_SETTINGS = {
     "Rave", "Colorful", "Flash", "Red",  "Dynamic", "Dark", "None", "Ignite",
}

hook.Add("PostDrawOpaqueRenderables", "MusicVisUI", function(depth,sky)

    if depth or sky then return end
    VISUALIZER_TYPE_TARGET = nil
    
    if not (IsValid(LocalPlayer()) and LocalPlayer():GetLocationName() == "Vapor Lounge" and LocalPlayer():GetTheater()) then
        return end

    
    local c,a = Vector(2302, 530, 69), Angle(0,0,40)
    local scl = 0.06
    local lh = 24


    local hit = util.IntersectRayWithPlane(EyePos(),EyeAngles():Forward(), c, a:Up() )
    if hit and EyePos():Distance(hit)>60 then hit=nil end
    if hit then
        hit,_ = WorldToLocal(hit,Angle(),c,a)
        hit = hit/scl
        hit.y=-hit.y
        if hit.x<-200 or hit.x>200 or hit.y<-100 or hit.y>200 then hit=nil end
    end
    -- local own = LocalPlayer():GetTheater():GetOwner()==LocalPlayer()

    cam.Start3D2D(c,a, scl )

        -- costs fps?? EyePos():Distance(c)<100 and
        if theater.HtmlLightsMat then --and HtmlLightsMatFixx then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(theater.HtmlLightsMat)
            -- surface.DrawTexturedRect(-30, 0, THLIGHT_CANVAS_XS * HtmlLightsMatFixx, THLIGHT_CANVAS_YS * HtmlLightsMatFixy)
            surface.DrawTexturedRect(-190,20,240,135)
        end

        for i,v in ipairs(VISUALIZER_SETTINGS) do
            draw.SimpleText(v, "Trebuchet24", 16, lh*(i-1), WHITE )

            if hit and hit.y > lh*(i-1) and hit.y < lh*i then
                VISUALIZER_TYPE_TARGET = v
            end
            if UsingMusicVis(v:lower()) or VISUALIZER_TYPE_TARGET==v then
                surface.SetDrawColor( 255,255,255, 255 )
                local sz = UsingMusicVis(v:lower()) and 5 or 4 
                surface.DrawRect(8-sz, lh*(i-0.5)-sz-1, sz*2, sz*2 )
            end
        end


        if VAPOR_LAST_FINALPOWER then
            local p = 1-VAPOR_LAST_FINALPOWER
            if p<0 then p=p*0.2 end
            if p>1 then p=1-(1-p)*0.2 end
            local h = p*60
            surface.SetDrawColor( 255,255,255, 255 )
            if h>=0 then h=math.max(h,2) end
            surface.DrawRect(-20,100-h,12,h)
            surface.DrawRect(-20,40,12,2)
        end


        if hit then 
            surface.SetDrawColor(0,0,0, 255 )
            surface.DrawRect(hit.x-4,hit.y-4,8,8)
            surface.SetDrawColor( 255,255,255, 255 )
            surface.DrawRect(hit.x-2,hit.y-2,4,4 )
        end

	cam.End3D2D()
end )

hook.Add("KeyPress","MusicVisClick",function(ply,key)
    if (key==IN_USE or key==IN_ATTACK) and VISUALIZER_TYPE_TARGET and IsFirstTimePredicted() then
        RunConsoleCommand("musicvis",VISUALIZER_TYPE_TARGET)
        print("Use the console command: musicvis "..VISUALIZER_TYPE_TARGET:lower().." for faster switching.")
    end
end)

local ColorSquareMaterial = CreateMaterial("ScreenSpaceSquare", "UnlitGeneric", {
    ["$basetexture"] = "color/white",
    ["$detail"] = "color/white",
    ["$detailblendmode"] = 8,
    ["$detailblendfactor"] = 1,
    ["$detailscale"] = 1,
    ["$alpha"] = 0.5,
    ["$translucent"] = 0,-- Note: DO NOT use translucent, it makes the z buffer the alpha
    ["$color"] = "[1 1 1]"
})

ColorSquareMaterial:SetTexture("$basetexture", render.GetScreenEffectTexture())
ColorSquareMaterial:SetTexture("$detail", render.GetScreenEffectTexture())

function DrawSquareColor(blend, color2, skipcopy)
    if blend > 0 then
        if not skipcopy then
            render.CopyRenderTargetToTexture(render.GetScreenEffectTexture())
        end

        ColorSquareMaterial:SetTexture("$basetexture", render.GetScreenEffectTexture())
        ColorSquareMaterial:SetTexture("$detail", render.GetScreenEffectTexture())
        ColorSquareMaterial:SetFloat("$alpha", math.min(blend, 1))
        ColorSquareMaterial:SetVector("$color", color2)
        render.SetMaterial(ColorSquareMaterial)
        render.DrawScreenQuad()
    end
end

hook.Add("RenderScreenspaceEffects", "MusicVis", function()
    if (IsValid(LocalPlayer()) and LocalPlayer():GetLocationName() == "Vapor Lounge" and LocalPlayer():GetTheater() and LocalPlayer():GetTheater():IsPlaying()) then
        if UsingMusicVis("none") then return end

        local flicker_avg = 0.08

        if UsingMusicVis("dynamic") then flicker_avg=0.8 end

        if not GetConVar("musicvis_flashing"):GetBool() then
            if not MVIS_ASKEDFLASHING then
               MVIS_ASKEDFLASHING = true

                Derma_Query("Enable flashing lights? Do not accept if you are prone to epilepsy.", "Epilepsy warning", "No", function() end, "Enable", function()
                    GetConVar("musicvis_flashing"):SetBool(true)
                end)
            end

            flicker_avg = 2
        end

        local s = VAPOR_SAMPLES_SHORT[#VAPOR_SAMPLES_SHORT]
        if not s then return end
        local mean = s.mean
        -- the frame mean is running avg to make it a little less flickery
        local mc = 1

        for i = #VAPOR_SAMPLES_SHORT - 1, 1, -1 do
            if VAPOR_SAMPLES_SHORT[i].t < SysTime() - flicker_avg then break end
            mean = mean + VAPOR_SAMPLES_SHORT[i].mean
            mc = mc + 1
        end

        mean = mean / mc

        local function vecavg(v)
            return (v.x + v.y + v.z) / 3
        end

        -- Use the max of med and long mean, so it stays dark longer, but not bright as long
        -- local relativemean = Vector(math.max(VAPOR_RUNNINGMEAN_MED.x,VAPOR_RUNNINGMEAN_LONG.x),math.max(VAPOR_RUNNINGMEAN_MED.y,VAPOR_RUNNINGMEAN_LONG.y),math.max(VAPOR_RUNNINGMEAN_MED.z,VAPOR_RUNNINGMEAN_LONG.z))
        local relativemean = Vector(math.max(VAPOR_RUNNINGMEAN_SHORT.x, VAPOR_RUNNINGMEAN_LONG.x), math.max(VAPOR_RUNNINGMEAN_SHORT.y, VAPOR_RUNNINGMEAN_LONG.y), math.max(VAPOR_RUNNINGMEAN_SHORT.z, VAPOR_RUNNINGMEAN_LONG.z))
        local normalized = mean - relativemean --VAPOR_RUNNINGMEAN_LONG
        normalized.x = normalized.x / VAPOR_RUNNINGSTD_SHORT.x
        normalized.y = normalized.y / VAPOR_RUNNINGSTD_SHORT.y
        normalized.z = normalized.z / VAPOR_RUNNINGSTD_SHORT.z
        local norm_avg = normalized:Mean()
        local mean_avg = mean:Mean() --VAPOR_RUNNINGMEAN)
        -- local transition_avg = vecavg(VAPOR_RUNNINGMEAN - VAPOR_RUNNINGMEAN_LONG)
        local finalpower = 0.85 - (norm_avg * 1.1 + mean_avg * 0.8) --math.sin(SysTime()*10)*0.5+0.5

        -- makes it less bright when the video gets bright
        if not UsingMusicVis("flash") then
            if finalpower < 0.5 then
                finalpower = 0.5 - (0.5 - finalpower) * 0.6
            end
        end

        if UsingMusicVis("flash") then finalpower = finalpower-1 end

        if UsingMusicVis("dark") or UsingMusicVis("colorful") then finalpower=1 end

        -- finalpower = -1
        -- finalpower = -5
        local function HSVFOR(timepoint)
            math.randomseed(timepoint)
            local hsv = VectorRand(0, 1)
            math.randomseed(SysTime())

            local sc_h, sc_s, sc_v = ColorToHSV(VAPOR_RUNNINGMEAN_SHORT:ToColor())

            if timepoint % 2 == 0 then
                hsv.x = ((sc_h / 360) + hsv.x * 0.1 - 0.05) % 1
            end

            return hsv
        end

        local wanderingcolorbase = CurTime() * 1
        local hsv = LerpVector(wanderingcolorbase - math.floor(wanderingcolorbase), HSVFOR(math.floor(wanderingcolorbase)), HSVFOR(math.ceil(wanderingcolorbase)))
        math.randomseed(SysTime())
        local extradarkness = math.min(0.2 + mean_avg * 5, 1)

        if finalpower > 0.5 then
            extradarkness = extradarkness - (math.min(finalpower, 1.0) - 0.5) / 10 --floor at 1 so its not always flashing
        end

        extradarkness = math.max(extradarkness, 0.7) --floor
        local colormod = HSVToColor(hsv.x * 360, math.sqrt(hsv.y), extradarkness) --math.max((finalpower-1)*0.1, 0))
        colormod = Vector(colormod.r / 255, colormod.g / 255, colormod.b / 255)

        if UsingMusicVis("dark") then
            colormod = Vector(0.5,0.5,0.5)
        end

        if UsingMusicVis("red") then
            colormod = Vector(1,0.1,0.1)
            finalpower = math.max(finalpower, 0.1)
        end

        local extraflash = 0

        if finalpower < 0 then
            extraflash = math.min(-(finalpower * 0.6), 1)

            if UsingMusicVis("flash") then extraflash=extraflash*1.5 end

            DrawColorModify({
                ["$pp_colour_addr"] = 0, --ADD TO ONE
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = extraflash * 0.1, --ADD TO ALL
                ["$pp_colour_colour"] = 1, --SATURATION
                ["$pp_colour_mulr"] = 0, -- MULTIPLY ONE...?
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0,
                ["$pp_colour_contrast"] = 1 + extraflash, --MULTIPLY ALL
                
            })
        else
            -- TODO: maybe use a stencil to mask out the area outside the lounge so its not flashing? probalby not worth fps cost, just put doors on it that automatically close
            DrawSquareColor(finalpower, colormod, false)
        end

        --tab)  -- I want to not have to copy the texture twice, but cant get it to work, some really weird depth buffer issue
        if GetConVar("musicvis_debug"):GetBool() then
            draw.DrawText("Setting: "..tostring(GetG("musicvis")), "DermaDefault", 310,1)
            if GetConVar("musicvis_debug"):GetInt()>1 then
                for i,col in ipairs(VAPORLASTPIXELS) do
                    surface.SetDrawColor(col.x*255,col.y*255,col.z*255,255)
                    surface.DrawRect(math.floor(i/16)*3 + 310,(i%16)*3 + 20,3,3)
                end
            end
            VaporChart("final", 1 - finalpower)
            VaporChart("final_color", colormod)

            VaporChart("mean", mean)
            VaporChart("running_mean", VAPOR_RUNNINGMEAN_SHORT)
            VaporChart("running_mean_long", VAPOR_RUNNINGMEAN_LONG)
            -- VaporChart("mean-running_mean", mean-VAPOR_RUNNINGMEAN + Vector(0.5,0.5,0.5))
            VaporChart("running_std", VAPOR_RUNNINGSTD_SHORT)
            VaporChart("normalized5", (normalized * 0.2) + Vector(0.5, 0.5, 0.5))


            local h, s, v = ColorToHSV(VAPOR_RUNNINGMEAN_SHORT:ToColor())
            VaporChart("hue", h / 360)
            VaporChart("extradarkness", extradarkness)
            VaporChart("extraflash", extraflash)
        end

        VAPOR_LAST_FINALPOWER = finalpower
    end
end)

-- todo track these without code duplication
VAPOR_SUMMEAN_SHORT = Vector()
VAPOR_SUMMEANSQR_SHORT = Vector()
VAPOR_SUMCOUNT_SHORT = 0
VAPOR_SAMPLES_SHORT = {}
VAPOR_SUMMEAN_MED = Vector()
VAPOR_SUMCOUNT_MED = 0
VAPOR_SAMPLES_MED = {}
VAPOR_SUMMEAN_LONG = Vector()
VAPOR_SUMCOUNT_LONG = 0
VAPOR_SAMPLES_LONG = {}
VAPOR_RUNNINGMEAN_SHORT = Vector()
VAPOR_RUNNINGMEAN_MED = Vector()
VAPOR_RUNNINGMEAN_LONG = Vector()
VAPOR_RUNNINGSTD_SHORT = Vector()


VAPORLASTPIXELS = {}
function VaporLightData(pixels)
    local mean = Vector(0, 0, 0)
    -- local meansqr = Vector(0,0,0)
    local totalw = 0

    if GetConVar("musicvis_debug"):GetInt()>1 then
        VAPORLASTPIXELS = {}

        for _, pix in ipairs(pixels) do
            table.insert(VAPORLASTPIXELS, Vector(pix.x, pix.y, pix.z))
        end
    end

    --todo: compute something with variance of the image itself? take min/max pixels?
    for _, pix in ipairs(pixels) do
        local weight = pix:Length2DSqr() + 0.01 --videos with a lot of black will focus on bright parts. note:index corresponds loosely to x pos
        mean = mean + pix * weight
        -- pix:Mul(pix)
        -- meansqr = meansqr + pix*weight
        totalw = totalw + weight
    end

    mean = mean / totalw
    -- meansqr = meansqr/totalw
    local meansqr = Vector(mean.x * mean.x, mean.y * mean.y, mean.z * mean.z)
    -- TODO track the mean for 3s, var for 1 or 2 s
    local cutoff = SysTime() - 1

    while #VAPOR_SAMPLES_SHORT > 0 and VAPOR_SAMPLES_SHORT[1].t < cutoff do
        local r = table.remove(VAPOR_SAMPLES_SHORT, 1)
        VAPOR_SUMMEAN_SHORT = VAPOR_SUMMEAN_SHORT - r.mean
        VAPOR_SUMMEANSQR_SHORT = VAPOR_SUMMEANSQR_SHORT - r.meansqr
        VAPOR_SUMCOUNT_SHORT = VAPOR_SUMCOUNT_SHORT - 1
    end

    cutoff = SysTime() - 2

    while #VAPOR_SAMPLES_MED > 0 and VAPOR_SAMPLES_MED[1].t < cutoff do
        local r = table.remove(VAPOR_SAMPLES_MED, 1)
        VAPOR_SUMMEAN_MED = VAPOR_SUMMEAN_MED - r.mean
        VAPOR_SUMCOUNT_MED = VAPOR_SUMCOUNT_MED - 1
    end

    cutoff = SysTime() - 4 --unused

    while #VAPOR_SAMPLES_LONG > 0 and VAPOR_SAMPLES_LONG[1].t < cutoff do
        local r = table.remove(VAPOR_SAMPLES_LONG, 1)
        VAPOR_SUMMEAN_LONG = VAPOR_SUMMEAN_LONG - r.mean
        VAPOR_SUMCOUNT_LONG = VAPOR_SUMCOUNT_LONG - 1
    end

    -- make sure these are zero because of floating error over time
    if VAPOR_SUMCOUNT_SHORT == 0 then
        VAPOR_SUMMEAN_SHORT = Vector()
        VAPOR_SUMMEANSQR_SHORT = Vector()
    end

    if VAPOR_SUMCOUNT_MED == 0 then
        VAPOR_SUMMEAN_MED = Vector()
    end

    if VAPOR_SUMCOUNT_LONG == 0 then
        VAPOR_SUMMEAN_LONG = Vector()
    end

    local t = {
        t = SysTime(),
        mean = mean,
        meansqr = meansqr,
    }

    table.insert(VAPOR_SAMPLES_SHORT, t)
    table.insert(VAPOR_SAMPLES_MED, t)
    table.insert(VAPOR_SAMPLES_LONG, t)
    VAPOR_SUMMEAN_SHORT = VAPOR_SUMMEAN_SHORT + mean
    VAPOR_SUMMEANSQR_SHORT = VAPOR_SUMMEANSQR_SHORT + meansqr
    VAPOR_SUMCOUNT_SHORT = VAPOR_SUMCOUNT_SHORT + 1
    VAPOR_SUMMEAN_MED = VAPOR_SUMMEAN_MED + mean
    VAPOR_SUMCOUNT_MED = VAPOR_SUMCOUNT_MED + 1
    VAPOR_SUMMEAN_LONG = VAPOR_SUMMEAN_LONG + mean
    VAPOR_SUMCOUNT_LONG = VAPOR_SUMCOUNT_LONG + 1
    VAPOR_RUNNINGMEAN_SHORT = VAPOR_SUMMEAN_SHORT / VAPOR_SUMCOUNT_SHORT
    VAPOR_RUNNINGMEAN_MED = VAPOR_SUMMEAN_MED / VAPOR_SUMCOUNT_MED
    VAPOR_RUNNINGMEAN_LONG = VAPOR_SUMMEAN_LONG / VAPOR_SUMCOUNT_LONG
    VAPOR_RUNNINGSTD_SHORT = VAPOR_SUMMEANSQR_SHORT / VAPOR_SUMCOUNT_SHORT - Vector(VAPOR_RUNNINGMEAN_SHORT.x * VAPOR_RUNNINGMEAN_SHORT.x, VAPOR_RUNNINGMEAN_SHORT.y * VAPOR_RUNNINGMEAN_SHORT.y, VAPOR_RUNNINGMEAN_SHORT.z * VAPOR_RUNNINGMEAN_SHORT.z)
    --Add an epsilon which also makes it less flickery when std gets low 
    local eps = 0.006
    VAPOR_RUNNINGSTD_SHORT = Vector(math.sqrt(math.max(VAPOR_RUNNINGSTD_SHORT.x, 0)) + eps, math.sqrt(math.max(VAPOR_RUNNINGSTD_SHORT.y, 0)) + eps, math.sqrt(math.max(VAPOR_RUNNINGSTD_SHORT.z, 0)) + eps)
end

--add value to chart, then draw it
VAPOR_CHARTS = {}

function VaporChart(name, val)
    local chart = nil
    local i = nil
    for ii,v in ipairs(VAPOR_CHARTS) do
        if v.name == name then chart = v.chart i=ii end
    end
    if not chart then
        table.insert(VAPOR_CHARTS,{name=name,chart={}})
        chart=VAPOR_CHARTS[#VAPOR_CHARTS].chart
        i=#VAPOR_CHARTS
    end
    i=i-1

    local lookback = 4
    local cutoff = SysTime() - lookback

    while #chart > 0 and chart[1].t < cutoff do
        table.remove(chart, 1)
    end

    table.insert(chart, {
        v = val,
        t = SysTime()
    })

    local y1 = i * 80 + 10
    local y2 = y1 + 70
    local x1 = 10
    local x2 = 300
    draw.DrawText(name, "DermaDefault", x1 + 5, y1 + 5)
    surface.SetDrawColor(200, 200, 200)
    surface.DrawLine(x1, y1, x2, y1)
    surface.DrawLine(x1, (y1 + y2) / 2, x2, (y1 + y2) / 2)
    surface.DrawLine(x1, y2, x2, y2)
    local it = 0

    for i = 2, #chart do
        local a, b = chart[i - 1], chart[i]
        local ax = Lerp((SysTime() - a.t) / lookback, x2, x1)
        local bx = Lerp((SysTime() - b.t) / lookback, x2, x1)
        local f, g = a.v, b.v

        if isvector(a.v) then
            surface.SetDrawColor(255, 0, 0)
            surface.DrawLine(ax, Lerp(a.v.x, y2, y1), bx, Lerp(b.v.x, y2, y1))
            surface.SetDrawColor(0, 255, 0)
            surface.DrawLine(ax, Lerp(a.v.y, y2, y1), bx, Lerp(b.v.y, y2, y1))
            surface.SetDrawColor(0, 0, 255)
            surface.DrawLine(ax, Lerp(a.v.z, y2, y1), bx, Lerp(b.v.z, y2, y1))
            f = (a.v.x + a.v.y + a.v.z) / 3
            g = (b.v.x + b.v.y + b.v.z) / 3
        end

        surface.SetDrawColor(255, 255, 255)
        surface.DrawLine(ax, Lerp(f, y2, y1), bx, Lerp(g, y2, y1))
        it = g
    end

    draw.DrawText(tostring(it), "DermaDefault", x2 - 100, y1 + 5)
end


CreateMaterial("VaporLoungeBoxes", "VertexLitGeneric", {
    ["$basetexture"] = "sunabouzu/theater_tile01",
    ["$basetexturetransform"] = "center 0 0 scale .5 .5 rotate 0 translate 0 0",
    ["$color2"] = "[0.7 0.7 0.65]",
})
