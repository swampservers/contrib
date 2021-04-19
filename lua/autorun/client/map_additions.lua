-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
--[[
SLITPOINTS=nil
SLITPOINTSMAT = Material( "effects/tool_tracer" )
hook.Add("PostDrawTranslucentRenderables", "DrawArenaBorder", function(dep,sky)
	if dep or sky then return end
	local alpha = 1.0- math.Clamp( (Vector(0,-1152,0):Distance(EyePos())-1500)/200, 0,1)
	if alpha==0 then return end
	if SLITPOINTS==nil then
		SLITPOINTS = {}
		for d=0,72 do
			local deg = math.rad(d*5)
			local pt = Vector(math.sin(deg)*650,(math.cos(deg)*650)-1152, 1)
			table.insert(SLITPOINTS, pt) ]]
--[[local tr = util.TraceLine( {
				start = pt,
				endpos = pt + Vector(0,0,-128),
				collisiongroup = COLLISION_GROUP_WORLD
			} )
			table.insert(SLITPOINTS, tr.HitPos+Vector(0,0,1)) ]]
--[[	end
	end

	render.SetMaterial(SLITPOINTSMAT)
	local texcoord = math.Rand( 0, 1 )
	local function DrawBeam( startpos, endpos )
		render.DrawBeam( startpos, endpos, 8, texcoord-1, texcoord, Color( 255, 255, 255, 255*alpha ) )
	end
	
	for q=1,72 do
		DrawBeam(SLITPOINTS[q],SLITPOINTS[q+1])	
	end

end) ]]
--
clockARMS = Material("tools/toolsblack")
clockCenter = Vector(0, 1038.8 + 155, 192 - 4) --Vector(0,1038.8-40,192-8)
clockScale = 0.1

hook.Add("PostDrawTranslucentRenderables", "lobbyclock", function(depth, sky)
    if sky then return end
    if not render.DrawingScreen() then return end
    if EyePos().y > clockCenter.y + 20 then return end
    render.SetMaterial(clockARMS)
    local time = os.time() + 3600
    local seconds = Vector(0, -200, 0)
    seconds:Rotate(Angle(0, (time % 60) * 6, 0))
    DrawClockLine(0, 0, seconds.x, seconds.y, 4)
    local minutes = Vector(0, -240, 0)
    minutes:Rotate(Angle(0, ((time / 60) % 60) * 6, 0))
    DrawClockLine(0, 0, minutes.x, minutes.y, 8)
    local hours = Vector(0, -170, 0)
    hours:Rotate(Angle(0, (((time / 3600) % 12) - 8) * 30, 0))
    DrawClockLine(0, 0, hours.x, hours.y, 12)
    render.DrawSphere(clockCenter + Vector(0, 1.5, 0), 2, 16, 16, Color(0, 0, 0))
end)

function DrawClockLine(startX, startY, endX, endY, thickness)
    local v1 = Vector(startX, startY, 0)
    local v2 = Vector(endX, endY, 0)
    local v3 = v2 - v1
    v3:Normalize()
    v3:Mul(thickness / 2)
    local v4 = Vector()
    v4:Set(v3)
    v4:Rotate(Angle(0, 90, 0))
    local p1 = XYToClock(v1 - v3 + v4)
    local p2 = XYToClock(v1 - v3 - v4)
    local p3 = XYToClock(v2 + v3 - v4)
    local p4 = XYToClock(v2 + v3 + v4)
    render.DrawQuad(p1, p2, p3, p4, Color(0, 0, 0))
end

function XYToClock(v)
    return clockCenter + Vector(v.x * clockScale, 0, -v.y * clockScale)
end

local hevmaterial = Material("models/hevsuit/hevsuit_sheet")

timer.Simple(0, function()
    hevmaterial:SetInt("$flags", 8192 + 65536)
end)

local resetmaterial = Material("swamponions/reset")

timer.Simple(0, function()
    resetmaterial:SetInt("$flags", 0)
end)

local lanternmaterial = Material("models/dojo/lantern/lantern")

timer.Create("lanternswitcher", 100, 0, function()
    if GetGlobalBool("DAY", true) then
        lanternmaterial:SetTexture("$basetexture", "models/dojo/lantern/lantern")
        lanternmaterial:SetInt("$flags", 0)
    else
        lanternmaterial:SetTexture("$basetexture", "models/dojo/lantern/lantern_night")
        lanternmaterial:SetInt("$flags", 64)
    end
end)

BARBRIGHTFADE = BARBRIGHTFADE or 0



local ColorSquareMaterial = CreateMaterial("VaporScreenSpaceSquare"..tostring(os.time()), "UnlitGeneric", {
    ["$basetexture"] = "color/white",
    ["$detail"] = "color/white",
    ["$detailblendmode"] = 8,
    ["$detailblendfactor"] = 1,
    ["$detailscale"] = 1,
    ["$alpha"] = 0.5,
    -- ["$translucent"] = 1,
    ["$color"] = "[1 1 1]",
    -- ["$model"] = 1,
    -- ["$translucent"] = 0,
    -- ["$vertexalpha"] = 1,
    -- ["$vertexcolor"] = 1
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

hook.Add("RenderScreenspaceEffects", "BarBrightness", function()
    if IsValid(LocalPlayer()) and LocalPlayer():GetLocationName() == "Drunken Clam" or vape then
        BARBRIGHTFADE = math.min(BARBRIGHTFADE + FrameTime(), 1)
    else
        BARBRIGHTFADE = math.max(BARBRIGHTFADE - FrameTime() * 2, 0)
    end

    if BARBRIGHTFADE > 0 then
        local thing = -(BARBRIGHTFADE * 0.06)
        local tab = {}

        tab["$pp_colour_contrast"] = 1 / (1 + thing * 0.5)
        tab["$pp_colour_colour"] = 1 + thing
        tab["$pp_colour_brightness"] = thing
        tab["$pp_colour_mulr"] = 0
        tab["$pp_colour_mulg"] = 0
        tab["$pp_colour_mulb"] = 0
        DrawColorModify(tab)
    end

    if (IsValid(LocalPlayer()) and LocalPlayer():GetLocationName() == "Vapor Lounge" and LocalPlayer():GetTheater() and LocalPlayer():GetTheater():IsPlaying()) then --and LocalPlayer():SteamID()=="STEAM_0:0:38422842" then

        local tab = {
            ["$pp_colour_addr"] = 0, --ADD TO ONE
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0, --ADD TO ALL
            ["$pp_colour_colour"] = 1, --SATURATION
            ["$pp_colour_mulr"] = 0, -- MULTIPLY ONE...?
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0,
            ["$pp_colour_contrast"] = 1, --MULTIPLY ALL
        }

        local s = VAPOR_SAMPLES[#VAPOR_SAMPLES]
        if not s then return end
        local mean = s.mean

        -- the frame mean is running avg to make it a little less flickery
        local mc = 1
        for i=#VAPOR_SAMPLES-1,1,-1 do
            if VAPOR_SAMPLES[i].t < SysTime()-0.07 then break end
            mean = mean + VAPOR_SAMPLES[i].mean
            mc = mc + 1
        end
        mean = mean/mc
        



        local normalized = mean - VAPOR_RUNNINGMEAN
        normalized.x = normalized.x/VAPOR_RUNNINGSTD.x
        normalized.y = normalized.y/VAPOR_RUNNINGSTD.y
        normalized.z = normalized.z/VAPOR_RUNNINGSTD.z

        local norm_avg = (normalized.x+normalized.y+normalized.z)/3
        -- this won't vary as much
        local mean_avg = (VAPOR_RUNNINGMEAN.x+VAPOR_RUNNINGMEAN.y+VAPOR_RUNNINGMEAN.z)/3

        -- tab["$pp_colour_contrast"] = 1
        -- tab["$pp_colour_colour"] = 1
        -- tab["$pp_colour_brightness"] = 0
        -- tab["$pp_colour_mulr"] = VAPOR_RUNNINGMEAN.x*1
        -- tab["$pp_colour_mulg"] = VAPOR_RUNNINGMEAN.y*2
        -- tab["$pp_colour_mulb"] = VAPOR_RUNNINGMEAN.z*2

        local SquarePower = 0.75-(norm_avg*4 + mean_avg*0.8) --math.sin(SysTime()*10)*0.5+0.5

        -- makes it less bright when the video gets bright
        if SquarePower < 0.5 then
            SquarePower = 0.5 - (0.5 - SquarePower)*0.6
        end

        local function HSVFOR(timepoint)
            math.randomseed(timepoint)
            local hsv = VectorRand(0,1)
            math.randomseed(SysTime())
            if timepoint%2==0 then
                local h,s,v = ColorToHSV(VAPOR_RUNNINGMEAN:ToColor())
                hsv.x = ((h/360) + hsv.x*0.1- 0.05) % 1
            end
            return hsv
        end

        local wanderingcolorbase = CurTime()*1
        local hsv = LerpVector(wanderingcolorbase-math.floor(wanderingcolorbase), HSVFOR(math.floor(wanderingcolorbase)), HSVFOR(math.ceil(wanderingcolorbase)))
        math.randomseed(SysTime())

        
        local c = HSVToColor(hsv.x*360, hsv.y, 1) --math.max((SquarePower-1)*0.1, 0))
        -- print(c:ToVector())

        c = Vector(c.r/255,c.g/255,c.b/255)
        -- print(VAPOR_RUNNINGMEAN)




        if LocalPlayer():Nick()=="Joker Gaming" then
            -- SquarePower=1
            -- c = c*0.1
            -- chat.AddText(tostring(hsv))
            -- chat.AddText(tostring(SquarePower))
            -- chat.AddText(tostring(VAPOR_RUNNINGSTD))
            -- for i,col in ipairs(VAPORLASTPIXELS) do
            --     surface.SetDrawColor(col.x*255,col.y*255,col.z*255,255)
            --     surface.DrawRect(math.floor(i/16)*2,(i%16)*2,2,2)
            -- end
            -- render.OverrideBlend( true, BLEND_SRC_ALPHA, BLEND_ONE_MINUS_SRC_ALPHA, BLENDFUNC_ADD)

        end

        -- I want to not have to copy the texture twice, but cant get it to work, some really weird depth buffer issue
        DrawSquareColor(SquarePower, c, false)
        -- DrawColorModify(tab)
        -- render.OverrideBlend( false)
    end
end)

local flagmaterial = Material("models/props_fairgrounds/fairgrounds_flagpole01")

timer.Simple(0, function()
    flagmaterial:SetTexture("$basetexture", "models/props_fairgrounds/fairgrounds_flagpole01_alternate")
end)



 VAPOR_SUMMEAN = Vector()
 VAPOR_SUMMEANSQR = Vector()
 VAPOR_SUMCOUNT = 0

VAPOR_STD = Vector()
VAPOR_SAMPLES = {}

 VAPOR_RUNNINGMEAN = Vector()
 VAPOR_RUNNINGSTD = Vector()


function VaporLightData(pixels)

    local mean = Vector(0,0,0)
    local meansqr = Vector(0,0,0)
    local totalw = 0

    VAPORLASTPIXELS = {}

    for _,pix in ipairs(pixels) do
        table.insert(VAPORLASTPIXELS,Vector(pix.x,pix.y,pix.z))
        local weight = pix:Length2DSqr() + 0.01 --videos with a lot of black will focus on bright parts. note:index corresponds loosely to x pos
        mean = mean + pix*weight
        pix:Mul(pix)
        meansqr = meansqr + pix*weight
        totalw = totalw+weight
    end

    mean = mean/totalw
    meansqr = meansqr/totalw

    local cutoff = SysTime() - 2

    while #VAPOR_SAMPLES > 0 and VAPOR_SAMPLES[1].t < cutoff do
        local r = table.remove(VAPOR_SAMPLES,1)
        VAPOR_SUMMEAN = VAPOR_SUMMEAN - r.mean
        VAPOR_SUMMEANSQR = VAPOR_SUMMEANSQR - r.meansqr
        VAPOR_SUMCOUNT = VAPOR_SUMCOUNT - 1
    end

    -- make sure these are zero because of floating error over time
    if VAPOR_SUMCOUNT==0 then 
        VAPOR_SUMMEAN = Vector()
        VAPOR_SUMMEANSQR = Vector()
    end

    table.insert(VAPOR_SAMPLES, {
        t=SysTime(),
        mean=mean,
        meansqr=meansqr,
    })

    VAPOR_SUMMEAN = VAPOR_SUMMEAN + mean
    VAPOR_SUMMEANSQR = VAPOR_SUMMEANSQR + meansqr
    VAPOR_SUMCOUNT = VAPOR_SUMCOUNT + 1

    VAPOR_RUNNINGMEAN = VAPOR_SUMMEAN/VAPOR_SUMCOUNT

    VAPOR_RUNNINGSTD = VAPOR_SUMMEANSQR/VAPOR_SUMCOUNT - Vector(
        VAPOR_RUNNINGMEAN.x*VAPOR_RUNNINGMEAN.x,
        VAPOR_RUNNINGMEAN.y*VAPOR_RUNNINGMEAN.y,
        VAPOR_RUNNINGMEAN.z*VAPOR_RUNNINGMEAN.z
    )

    --Add an epsilon which also makes it less flickery when std gets low 
    local eps = 0.05
    VAPOR_RUNNINGSTD = Vector(math.sqrt(VAPOR_RUNNINGSTD.x)+ eps,math.sqrt(VAPOR_RUNNINGSTD.y)+ eps,math.sqrt(VAPOR_RUNNINGSTD.z) + eps) 

end

-- timer.Create("extravaporclean",1,0,VaporLightClean)