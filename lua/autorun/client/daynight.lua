--[[
if IsValid(LocalPlayer()) and LocalPlayer():Nick()=="Swamp" then
	
	local projectionCenter = Vector(1800,-4000,5000)
	local projectionAngle = Angle(50,125,0)

	if IsValid(SunProjection) then SunProjection:Remove() end
	if IsValid(SunProjectionO) then SunProjectionO:Remove() end

	SunProjection = ProjectedTexture()

	SunProjection:SetPos(projectionCenter)
	SunProjection:SetAngles(projectionAngle)
	SunProjection:SetEnableShadows(true)
	SunProjection:SetTexture("swamponions/lights/sm_inner")
	SunProjection:SetOrthographic(true,200,200,200,200)
	SunProjection:SetNearZ(100)
	SunProjection:SetFarZ(10000)
	SunProjection:SetBrightness(20)

	SunProjection:Update()

	SunProjectionO = ProjectedTexture()

	SunProjectionO:SetPos(projectionCenter)
	SunProjectionO:SetAngles(projectionAngle)
	SunProjectionO:SetEnableShadows(false)
	SunProjectionO:SetTexture("swamponions/lights/sm_inner")
	SunProjectionO:SetOrthographic(true,2000,2000,2000,2000)
	SunProjectionO:SetNearZ(100)
	SunProjectionO:SetFarZ(10000)
	SunProjectionO:SetBrightness(20)

	SunProjectionO:Update()
end
]]

RunConsoleCommand("pp_colormod","1")
RunConsoleCommand("pp_colormod_brightness","-0.05")
RunConsoleCommand("pp_colormod_addr","4")
--RunConsoleCommand("pp_colormod_mulr","-1")


matproxy.Add({
	name = "cm_dn",
	init = function( self, mat, values )
	end,
	bind = function( self, mat, ent )
		mat:SetTexture("$envmap", GetGlobalBool("DAY") and "swamponions/cm_d" or "swamponions/cm_n")
	end
})

matproxy.Add({
	name = "cm_d",
	init = function( self, mat, values )
	end,
	bind = function( self, mat, ent )
		mat:SetTexture("$envmap", "swamponions/cm_d")
	end
})

matproxy.Add({
	name = "cm_fm",
	init = function( self, mat, values )
		self.tex = values.tex
	end,
	bind = function( self, mat, ent )
		mat:SetTexture("$envmapmask", self.tex)
	end
})

local sky_day_bk = Material( "swamponions/sky/sky_day_bk" )
local sky_day_ft = Material( "swamponions/sky/sky_day_ft" )
local sky_day_lf = Material( "swamponions/sky/sky_day_lf" )
local sky_day_rt = Material( "swamponions/sky/sky_day_rt" )
local sky_day_up = Material( "swamponions/sky/sky_day_up" ) 

local sky_night_bk = Material( "swamponions/sky/sky_night_bk" )
local sky_night_ft = Material( "swamponions/sky/sky_night_ft" )
local sky_night_lf = Material( "swamponions/sky/sky_night_lf" )
local sky_night_rt = Material( "swamponions/sky/sky_night_rt" )
local sky_night_up = Material( "swamponions/sky/sky_night_up" ) 

sky_day_bk =   Material("hell/03_BK")
sky_day_ft =   Material("hell/03_FR") 
sky_day_lf =   Material("hell/03_LF") 
sky_day_rt =   Material("hell/03_RT") 
sky_day_up =  Material("hell/03_UP")


sky_night_bk =   Material("hell/03_BK")
sky_night_ft =   Material("hell/03_FR") 
sky_night_lf =   Material("hell/03_LF") 
sky_night_rt =   Material("hell/03_RT") 
sky_night_up =  Material("hell/03_UP")


hook.Add( "PostDraw2DSkyBox", "DrawDayNightSky", function()
	if not render.DrawingScreen() then
		return
	end

	render.OverrideDepthEnable(true, false)
	cam.Start3D(Vector(0, 0, 0))

	if GetGlobalBool("DAY") then
		render.SetMaterial(sky_day_rt)
		render.DrawQuadEasy(Vector(32, 0, 12), Vector(-1, 0, 0), 64, 40, Color(255, 255, 255), 0)
		render.SetMaterial(sky_day_bk)
		render.DrawQuadEasy(Vector(0, -32, 12), Vector(0, 1, 0), 64, 40, Color(255, 255, 255), 0)
		render.SetMaterial(sky_day_lf)
		render.DrawQuadEasy(Vector(-32, 0, 12), Vector(1, 0, 0), 64, 40, Color(255, 255, 255), 0)
		render.SetMaterial(sky_day_ft)
		render.DrawQuadEasy(Vector(0, 32, 12), Vector(0, -1, 0), 64, 40, Color(255, 255, 255), 0)
		render.SetMaterial(sky_day_up)
		render.DrawQuadEasy(Vector(0, 0, 32), Vector(0, 0, -1), 64, 64, Color(255, 255, 255), 0)
	else
		render.SetMaterial(sky_night_rt)
		render.DrawQuadEasy(Vector(32, 0, 12), Vector(-1, 0, 0), 64, 40, Color(255, 255, 255), 0)
		render.SetMaterial(sky_night_bk)
		render.DrawQuadEasy(Vector(0, -32, 12), Vector(0, 1, 0), 64, 40, Color(255, 255, 255), 0)
		render.SetMaterial(sky_night_lf)
		render.DrawQuadEasy(Vector(-32, 0, 12), Vector(1, 0, 0), 64, 40, Color(255, 255, 255), 0)
		render.SetMaterial(sky_night_ft)
		render.DrawQuadEasy(Vector(0, 32, 12), Vector(0, -1, 0), 64, 40, Color(255, 255, 255), 0)
		render.SetMaterial(sky_night_up)
		render.DrawQuadEasy(Vector(0, 0, 32), Vector(0, 0, -1), 64, 64, Color(255, 255, 255), 0)
	end
	
	cam.End3D()
	render.OverrideDepthEnable(false, false)
end )

local sky_space_lf = Material("swamponions/sky/sky_space_lf")
local sky_space_rt = Material("swamponions/sky/sky_space_rt")
local sky_space_up = Material("swamponions/sky/sky_space_up")
local sky_space_dn = Material("swamponions/sky/sky_space_dn")
local sky_space_ft = Material("swamponions/sky/sky_space_ft")
local sky_space_bk = Material("swamponions/sky/sky_space_bk")
local sky_space_sun = Material("effects/yellowflare_noz")

hook.Add( "PostDrawSkyBox", "DrawMoonStars", function()
	if not render.DrawingScreen() then
		return
	end

	local alpha = IsValid(LocalPlayer()) and math.Clamp((LocalPlayer():GetPos().z-7500)/3500,0,1) or 0
	if alpha<=0 then return end

	sky_space_rt:SetFloat("$alpha", alpha)
	sky_space_lf:SetFloat("$alpha", alpha)
	sky_space_up:SetFloat("$alpha", alpha)
	sky_space_dn:SetFloat("$alpha", alpha)
	sky_space_ft:SetFloat("$alpha", alpha)
	sky_space_bk:SetFloat("$alpha", alpha)

	render.OverrideDepthEnable(true, false)
	cam.Start3D(Vector(0, 0, 0))
		render.SetMaterial(sky_space_rt)
		render.DrawQuadEasy(Vector(32, 0, 0), Vector(-1, 0, 0), 64, 64, Color(255, 255, 255), 0)
		render.SetMaterial(sky_space_lf)
		render.DrawQuadEasy(Vector(-32, 0, 0), Vector(1, 0, 0), 64, 64, Color(255, 255, 255), 0)
		render.SetMaterial(sky_space_ft)
		render.DrawQuadEasy(Vector(0, 32, 0), Vector(0, -1, 0), 64, 64, Color(255, 255, 255), 0)
		render.SetMaterial(sky_space_bk)
		render.DrawQuadEasy(Vector(0, -32, 0), Vector(0, 1, 0), 64, 64, Color(255, 255, 255), 0)
		render.SetMaterial(sky_space_up)
		render.DrawQuadEasy(Vector(0, 0, 32), Vector(0, 0, -1), 64, 64, Color(255, 255, 255), 0)
		render.SetMaterial(sky_space_dn)
		render.DrawQuadEasy(Vector(0, 0, -32), Vector(0, 0, 1), 64, 64, Color(255, 255, 255), 0)

		render.SetMaterial(sky_space_sun)
		render.DrawQuadEasy(Vector(16, -11, -3), Vector(-1, 1, 0), 12, 12, Color(255, 255, 255), 0)
	cam.End3D()
	render.OverrideDepthEnable(false, false)
end )
