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
local ClockArms = Material( "vgui/white" ) --Material("lights/white")
local ClockCenter = Vector(0, 1039.4 + 155, 192 - 4)

-- PostTranslucent so there is no z-fighting
hook.Add("PostDrawTranslucentRenderables", "lobbyclock", function(depth, sky)
    if sky or depth then return end
    if EyePos().y > ClockCenter.y then return end
    

    local seconds = Vector(0, -21, 0)
    local minutes = Vector(0, -25, 0)
    local hours = Vector(0, -18, 0)

    local h,m,s = unpack(os.date("%H:%M:%S"):Split(":"))
    seconds:Rotate(Angle(0, tonumber(s) * 6, 0))
    minutes:Rotate(Angle(0, tonumber(m) * 6, 0))
    hours:Rotate(Angle(0, tonumber(h) * 30, 0))

    local function DrawClockLine(endX, endY, thickness)
        local v2 = Vector(endX, 0, -endY)
        local v1 = v2:GetNormalized()*1.5 -- start point is offset from center
        local v3 = v2 - v1
        v3:Normalize()
        v3:Mul(thickness / 2)
        v3:Rotate(Angle(90, 0, 0))
        render.DrawQuad(ClockCenter + v1  + v3,  ClockCenter +v1  - v3,ClockCenter +v2  - v3,ClockCenter +v2  + v3, Color(36,36,36))
    end

    render.SetMaterial(ClockArms)
    DrawClockLine( seconds.x, seconds.y, 0.4) 
    DrawClockLine( minutes.x, minutes.y, 0.8)
    DrawClockLine( hours.x, hours.y, 1.2)
end)



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
end)

local flagmaterial = Material("models/props_fairgrounds/fairgrounds_flagpole01")
local vapermaterial = Material("swamponions/swampcinema/vapers")
local vapesignmaterial = Material("models/vapor/sign/sign_green")
local computerscreenmaterial = Material("models/unconid/pc_models/c64/screen_c64_ll")

timer.Simple(0, function()
    flagmaterial:SetTexture("$basetexture", "models/props_fairgrounds/fairgrounds_flagpole01_alternate")

    vapermaterial:SetMatrix("$basetexturetransform", Matrix({
        {1, 0, 0, 0},
        {0, 1.05, 0, 0},
        {0, 0, 1, 0},
        {0, 0, 0, 1}
    }))
end)

local last_thing = 0

hook.Add("Think", "VapeSignColor", function()
    if vapesignmaterial then
        local c = HSVToColor(SysTime() * 15, 0.5, 1)
        vapesignmaterial:SetVector("$color2", Vector(c.r, c.g, c.b) / 255)
    end

    --fix the screen
    local next_thing = math.floor(CurTime() * 7)

    if next_thing ~= last_thing then
        computerscreenmaterial:SetFloat("$sqrt2", (math.random() - 0.5) * 20 / CurTime())
        last_thing = next_thing
    end
end)
-- vapesignmaterial:SetVector("$color2",Vector(1,0.4,0.6))
concommand.Add("dashing", function( ply, cmd, args )
    local m = Material("models/fedora_rainbowdash/fedora_rainbowdash_texture")
    m:SetFloat("$cloakpassenabled",1)
    m:SetFloat("$cloakfactor",0.95)
    m:SetVector("$cloakcolortint",Vector(0.5,0.8,1))
    m:SetFloat("$refractamount",0)
end)
