-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

if SERVER then
    util.AddNetworkString("SetMusicVis")
    net.Receive("SetMusicVis", function(len,ply)
        local st = net.ReadString()
        if st:len() > 30 then return end



end)
end



CreateClientConVar("vapor_flashing", "0")
CreateClientConVar("vapor_debug", "0")



local ColorSquareMaterial = CreateMaterial("ScreenSpaceSquare", "UnlitGeneric", {
    ["$basetexture"] = "color/white",
    ["$detail"] = "color/white",
    ["$detailblendmode"] = 8,
    ["$detailblendfactor"] = 1,
    ["$detailscale"] = 1,
    ["$alpha"] = 0.5, -- Note: DO NOT use translucent, it makes the z buffer the alpha
    ["$color"] = "[1 1 1]"
})
ColorSquareMaterial:SetTexture("$basetexture", render.GetScreenEffectTexture())
ColorSquareMaterial:SetTexture("$detail", render.GetScreenEffectTexture())
function DrawSquareColor(blend,color2,skipcopy)
    if blend > 0 then
        if not skipcopy then 
            render.CopyRenderTargetToTexture( render.GetScreenEffectTexture() )
        end
        ColorSquareMaterial:SetTexture("$basetexture", render.GetScreenEffectTexture())
        ColorSquareMaterial:SetTexture("$detail", render.GetScreenEffectTexture())
        ColorSquareMaterial:SetFloat("$alpha", math.min(blend,1))
        ColorSquareMaterial:SetVector("$color", color2)
        render.SetMaterial( ColorSquareMaterial )
        render.DrawScreenQuad()
    end
end



hook.Add("RenderScreenspaceEffects", "MusicVis", function()

    if (IsValid(LocalPlayer()) and LocalPlayer():GetLocationName() == "Vapor Lounge" and LocalPlayer():GetTheater() and LocalPlayer():GetTheater():IsPlaying()) then --and LocalPlayer():SteamID()=="STEAM_0:0:38422842" then

        local flicker_avg = 0.08

        if not GetConVar("vapor_flashing"):GetBool() then
            if not VAPORASKEDFLASHING then VAPORASKEDFLASHING=true
            Derma_Query("Enable flashing lights? Do not accept if you are prone to epilepsy.", "Epilepsy warning", "No", function() end, "Enable", function() GetConVar("vapor_flashing"):SetBool(true) end)
            end
            flicker_avg = 2
        end
        
        local s = VAPOR_SAMPLES_SHORT[#VAPOR_SAMPLES_SHORT]
        if not s then return end
        local mean = s.mean

        -- the frame mean is running avg to make it a little less flickery
        local mc = 1
        for i=#VAPOR_SAMPLES_SHORT-1,1,-1 do
            if VAPOR_SAMPLES_SHORT[i].t < SysTime()-flicker_avg then break end
            mean = mean + VAPOR_SAMPLES_SHORT[i].mean
            mc = mc + 1
        end
        mean = mean/mc
        
        local function vecavg(v)
            return (v.x+v.y+v.z)/3
        end

        -- Use the max of med and long mean, so it stays dark longer, but not bright as long
        -- local relativemean = Vector(math.max(VAPOR_RUNNINGMEAN_MED.x,VAPOR_RUNNINGMEAN_LONG.x),math.max(VAPOR_RUNNINGMEAN_MED.y,VAPOR_RUNNINGMEAN_LONG.y),math.max(VAPOR_RUNNINGMEAN_MED.z,VAPOR_RUNNINGMEAN_LONG.z))
        local relativemean = Vector(math.max(VAPOR_RUNNINGMEAN_SHORT.x,VAPOR_RUNNINGMEAN_LONG.x),math.max(VAPOR_RUNNINGMEAN_SHORT.y,VAPOR_RUNNINGMEAN_LONG.y),math.max(VAPOR_RUNNINGMEAN_SHORT.z,VAPOR_RUNNINGMEAN_LONG.z))
        local normalized = mean - relativemean --VAPOR_RUNNINGMEAN_LONG
        normalized.x = normalized.x/VAPOR_RUNNINGSTD_SHORT.x
        normalized.y = normalized.y/VAPOR_RUNNINGSTD_SHORT.y
        normalized.z = normalized.z/VAPOR_RUNNINGSTD_SHORT.z
        local norm_avg = vecavg(normalized)
        local mean_avg = vecavg(mean) --VAPOR_RUNNINGMEAN)
        -- local transition_avg = vecavg(VAPOR_RUNNINGMEAN - VAPOR_RUNNINGMEAN_LONG)



        local finalpower = 0.85-(norm_avg*1.1 + mean_avg*0.8) --math.sin(SysTime()*10)*0.5+0.5

        -- makes it less bright when the video gets bright
        if finalpower < 0.5 then
            finalpower = 0.5 - (0.5 - finalpower)*0.6
        end

        -- finalpower = -1

        


        -- finalpower = -5

        local function HSVFOR(timepoint)
            math.randomseed(timepoint)
            local hsv = VectorRand(0,1)
            math.randomseed(SysTime())
            if timepoint%2==0 then
                local h,s,v = ColorToHSV(VAPOR_RUNNINGMEAN_SHORT:ToColor())
                hsv.x = ((h/360) + hsv.x*0.1- 0.05) % 1
            end
            return hsv
        end

        local wanderingcolorbase = CurTime()*1
        local hsv = LerpVector(wanderingcolorbase-math.floor(wanderingcolorbase), HSVFOR(math.floor(wanderingcolorbase)), HSVFOR(math.ceil(wanderingcolorbase)))
        math.randomseed(SysTime())

        local extradarkness = math.min(0.2+mean_avg*5,1)
        if finalpower > 0.75 then
            extradarkness = extradarkness - (math.min(finalpower,1.0)-0.75)/5 --floor at 1 so its not always flashing
        end
        extradarkness = math.max(extradarkness, 0.7) --floor
        local c = HSVToColor(hsv.x*360, math.sqrt(hsv.y), extradarkness) --math.max((finalpower-1)*0.1, 0))
        c = Vector(c.r/255,c.g/255,c.b/255)

        -- finalpower = -10


        -- finalpower=-1

        local extraflash = 0
        if finalpower < 0 then
            extraflash = math.min(-(finalpower*0.6),1)
            DrawColorModify({
                ["$pp_colour_addr"] = 0, --ADD TO ONE
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = extraflash*0.1, --ADD TO ALL
                ["$pp_colour_colour"] = 1, --SATURATION
                ["$pp_colour_mulr"] = 0, -- MULTIPLY ONE...?
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0,
                ["$pp_colour_contrast"] = 1 +extraflash, --MULTIPLY ALL
            })
        else
            DrawSquareColor(finalpower, c, false)
        end

        --tab)  -- I want to not have to copy the texture twice, but cant get it to work, some really weird depth buffer issue

        if GetConVar("vapor_debug"):GetBool() then
            VaporChart("mean", mean)
            VaporChart("running_mean", VAPOR_RUNNINGMEAN_SHORT)
            VaporChart("running_mean_long", VAPOR_RUNNINGMEAN_LONG)
            -- VaporChart("mean-running_mean", mean-VAPOR_RUNNINGMEAN + Vector(0.5,0.5,0.5))
            VaporChart("running_std", VAPOR_RUNNINGSTD_SHORT)
            VaporChart("normalized5", (normalized*0.2) + Vector(0.5,0.5,0.5))
            VaporChart("final", 1-finalpower)
                        -- for i,col in ipairs(VAPORLASTPIXELS) do
            --     surface.SetDrawColor(col.x*255,col.y*255,col.z*255,255)
            --     surface.DrawRect(math.floor(i/16)*2,(i%16)*2,2,2)
            -- end
            local h,s,v = ColorToHSV(VAPOR_RUNNINGMEAN_SHORT:ToColor())
            VaporChart("hue", h/360)
 
            VaporChart("extradarkness",extradarkness)
            VaporChart("extraflash",extraflash)
        end
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


function VaporLightData(pixels)

    local mean = Vector(0,0,0)
    -- local meansqr = Vector(0,0,0)
    local totalw = 0

    if GetConVar("vapor_debug"):GetBool() then
        VAPORLASTPIXELS = {}
        for _,pix in ipairs(pixels) do
            table.insert(VAPORLASTPIXELS,Vector(pix.x,pix.y,pix.z))
        end
    end

    --todo: compute something with variance of the image itself? take min/max pixels?
    for _,pix in ipairs(pixels) do
        local weight = pix:Length2DSqr() + 0.01 --videos with a lot of black will focus on bright parts. note:index corresponds loosely to x pos
        mean = mean + pix*weight
        -- pix:Mul(pix)
        -- meansqr = meansqr + pix*weight
        totalw = totalw+weight
    end

    mean = mean/totalw
    -- meansqr = meansqr/totalw
    local meansqr = Vector(mean.x*mean.x,mean.y*mean.y,mean.z*mean.z)

    -- TODO track the mean for 3s, var for 1 or 2 s
    local cutoff = SysTime() - 1
    while #VAPOR_SAMPLES_SHORT > 0 and VAPOR_SAMPLES_SHORT[1].t < cutoff do
        local r = table.remove(VAPOR_SAMPLES_SHORT,1)
        VAPOR_SUMMEAN_SHORT = VAPOR_SUMMEAN_SHORT - r.mean
        VAPOR_SUMMEANSQR_SHORT = VAPOR_SUMMEANSQR_SHORT - r.meansqr
        VAPOR_SUMCOUNT_SHORT = VAPOR_SUMCOUNT_SHORT - 1
    end
    cutoff = SysTime() - 2
    while #VAPOR_SAMPLES_MED > 0 and VAPOR_SAMPLES_MED[1].t < cutoff do
        local r = table.remove(VAPOR_SAMPLES_MED,1)
        VAPOR_SUMMEAN_MED = VAPOR_SUMMEAN_MED - r.mean
        VAPOR_SUMCOUNT_MED = VAPOR_SUMCOUNT_MED - 1
    end
    cutoff = SysTime() - 4 --unused
    while #VAPOR_SAMPLES_LONG > 0 and VAPOR_SAMPLES_LONG[1].t < cutoff do
        local r = table.remove(VAPOR_SAMPLES_LONG,1)
        VAPOR_SUMMEAN_LONG = VAPOR_SUMMEAN_LONG - r.mean
        VAPOR_SUMCOUNT_LONG = VAPOR_SUMCOUNT_LONG - 1
    end
    -- make sure these are zero because of floating error over time
    if VAPOR_SUMCOUNT_SHORT==0 then 
        VAPOR_SUMMEAN_SHORT = Vector()
        VAPOR_SUMMEANSQR_SHORT = Vector()
    end
    if VAPOR_SUMCOUNT_MED==0 then 
        VAPOR_SUMMEAN_MED = Vector()
    end
    if VAPOR_SUMCOUNT_LONG==0 then 
        VAPOR_SUMMEAN_LONG = Vector()
    end

    local t = {
        t=SysTime(),
        mean=mean,
        meansqr=meansqr,
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

    VAPOR_RUNNINGMEAN_SHORT = VAPOR_SUMMEAN_SHORT/VAPOR_SUMCOUNT_SHORT
    VAPOR_RUNNINGMEAN_MED = VAPOR_SUMMEAN_MED/VAPOR_SUMCOUNT_MED
    VAPOR_RUNNINGMEAN_LONG = VAPOR_SUMMEAN_LONG/VAPOR_SUMCOUNT_LONG

    VAPOR_RUNNINGSTD_SHORT = VAPOR_SUMMEANSQR_SHORT/VAPOR_SUMCOUNT_SHORT - Vector(
        VAPOR_RUNNINGMEAN_SHORT.x*VAPOR_RUNNINGMEAN_SHORT.x,
        VAPOR_RUNNINGMEAN_SHORT.y*VAPOR_RUNNINGMEAN_SHORT.y,
        VAPOR_RUNNINGMEAN_SHORT.z*VAPOR_RUNNINGMEAN_SHORT.z
    )

    --Add an epsilon which also makes it less flickery when std gets low 
    local eps = 0.006
    VAPOR_RUNNINGSTD_SHORT = Vector(math.sqrt(math.max(VAPOR_RUNNINGSTD_SHORT.x,0))+ eps,math.sqrt(math.max(VAPOR_RUNNINGSTD_SHORT.y,0))+ eps,math.sqrt(math.max(VAPOR_RUNNINGSTD_SHORT.z,0)) + eps) 

end


--add value to chart, then draw it
VAPOR_CHARTS = {}
function VaporChart(name, val)
    VAPOR_CHARTS[name] = VAPOR_CHARTS[name] or {}
    local chart = VAPOR_CHARTS[name]

    local lookback = 4

    local cutoff = SysTime() - lookback
    while #chart > 0 and chart[1].t < cutoff do
        table.remove(chart, 1)
    end
    table.insert(chart, {v=val,t=SysTime()})

    local keys = table.GetKeys(VAPOR_CHARTS)
    table.sort( keys, function(a, b) return tonumber(util.CRC(a))> tonumber(util.CRC(b)) end )

    local i = table.KeyFromValue(keys, name) - 1

    local y1 = i*80 + 10
    local y2 = y1 + 70

    local x1 = 10
    local x2 = 300

    draw.DrawText(name, "DermaDefault", x1+5, y1+5)

    surface.SetDrawColor(200,200,200)
    surface.DrawLine(x1,y1,x2,y1)
    surface.DrawLine(x1,(y1+y2)/2,x2,(y1+y2)/2)
    surface.DrawLine(x1,y2,x2,y2)

    local it = 0
    for i=2,#chart do
        local a,b = chart[i-1],chart[i]
        local ax = Lerp( (SysTime()-a.t)/lookback, x2, x1)
        local bx = Lerp( (SysTime()-b.t)/lookback, x2, x1)

        local f,g = a.v,b.v
        if isvector(a.v) then
            surface.SetDrawColor(255,0,0) surface.DrawLine(ax,Lerp(a.v.x,y2,y1),bx,Lerp(b.v.x,y2,y1))
            surface.SetDrawColor(0,255,0) surface.DrawLine(ax,Lerp(a.v.y,y2,y1),bx,Lerp(b.v.y,y2,y1))
            surface.SetDrawColor(0,0,255) surface.DrawLine(ax,Lerp(a.v.z,y2,y1),bx,Lerp(b.v.z,y2,y1))
            f = (a.v.x + a.v.y+ a.v.z)/3
            g = (b.v.x + b.v.y+ b.v.z)/3
        end
        surface.SetDrawColor(255,255,255) surface.DrawLine(ax,Lerp(f,y2,y1),bx,Lerp(g,y2,y1))
        it = g
    end
    draw.DrawText(tostring(it), "DermaDefault", x2-100, y1+5)
end


function VaporUI()


end
