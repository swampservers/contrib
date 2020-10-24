-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

surface.CreateFont( "VideoInfoLarge", {
	font      = "Open Sans Condensed",
	size      = 148,
	weight    = 700,
	antialias = true
})

surface.CreateFont( "VideoInfoMedium", {
	font      = "Open Sans Condensed",
	size      = 72,
	weight    = 700,
	antialias = true
})

surface.CreateFont( "VideoInfoALittleSmaller", {
	font      = "Open Sans Condensed",
	size      = 60,
	weight    = 700,
	antialias = true
})

surface.CreateFont( "VideoInfoSmall", {
	font      = "Open Sans Condensed",
	size      = 32,
	weight    = 700,
	antialias = true
})

surface.CreateFont( "VideoInfoBrand", {
	font      = "Righteous",
	size      = 72,
	antialias = true
})

surface.CreateFont( "VideoInfoNV1", {
	font      = "Open Sans Condensed",
	size      = 56,
	weight    = 700,
	antialias = true
})

surface.CreateFont( "VideoInfoNV2", {
	font      = "Open Sans Condensed",
	size      = 40,
	weight    = 700,
	antialias = true
})

local gradientDown = surface.GetTextureID("VGUI/gradient_down")
local refreshTexture = surface.GetTextureID("gui/html/refresh")

local NoVideoScreen = Material( "theater/static.vmt" )

module("theater", package.seeall)

LastInfoDraw = 0
InfoDrawDelay = 3

Pos = Vector(0,0,0)
Ang = Angle(0,0,0)
InfoScale = 1
w = 0
h = 0

local LoadingStr = 'Loading'

HtmlLightsMat = nil

TheaterCustomRT = GetRenderTarget("ThLights",16,16,true)

local LastLocation = -1
local LocationChangeTime = 0
local LoadingStartTime = 0

function DrawActiveTheater( bDrawingDepth, bDrawingSkybox )

	if LastLocation ~= LocalPlayer():GetLocation() then
		LocationChangeTime = RealTime()
		LastLocation = LocalPlayer():GetLocation()
	end

	if (not IsValid(ActivePanel)) or (not ActivePanel:IsLoading()) then
		LoadingStartTime = RealTime()
	end

	if input.IsKeyDown(KEY_Q) then
		LastInfoDraw = CurTime()
	end

	if Fullscreen then return end -- Don't render twice

	local Theater = LocalPlayer():GetTheater()
	if !Theater then
		return
	end

	local ang = Theater:GetAngles()
	Ang = Angle( ang.p, ang.y, ang.r ) -- don't modify actual theater angle
	Ang:RotateAroundAxis( Ang:Forward(), 90 )

	Pos = Theater:GetPos()

	w, h = Theater:GetSize()
	w=w
	h=h
	--if (LocalPlayer():EyePos()-Pos):Dot(Ang:Up())<0 then return end

	--Don't draw a panel that is loading unless it has been loading for a long time
	local drawpanel = IsValid(ActivePanel) and ((not ActivePanel:IsLoading()) or (RealTime()-LoadingStartTime)>1.0)
	if drawpanel then
		drawpanel = (ActivePanel:GetHTMLMaterial()~=nil)
		if not drawpanel then
			ActivePanel:UpdateHTMLTexture()
			drawpanel = (ActivePanel:GetHTMLMaterial()~=nil)
		end
	end
	local drawblackscreen = false

	render.OverrideDepthEnable(true,false)
	if drawpanel then 
		cam.Start3D2D( Pos, Ang, 1 )
		HtmlLightsMat = draw.HTMLTexture(ActivePanel, w, h)
		cam.End3D2D()
	else
		if IsValid(ActivePanel) then
			drawblackscreen = true
		else
			cam.Start3D()
			render.SetMaterial(NoVideoScreen)
			local fv = Ang:Forward()*w
			local uv = Ang:Right()*h
			render.DrawQuad(Pos, Pos+fv, Pos+uv+fv, Pos+uv)
			cam.End3D()
		end
	end
	render.OverrideDepthEnable(false,true)

	local infoscale = 1100/w
	local iw = 1100
	local ih = infoscale*h

	local ev = ExplicitVideoWarning()
	local drawinfo = (LastInfoDraw + InfoDrawDelay > CurTime()) or ev
	local blackness = 1.0-math.Clamp((RealTime() - (LocationChangeTime+0.3))*0.8,0,1)

	if (not IsValid(ActivePanel)) or drawblackscreen or drawinfo or blackness>0 then
		cam.Start3D2D( Pos, Ang, 1.0/infoscale )
		if not IsValid(ActivePanel) then
			DrawNoVideoPlaying(iw, ih)
		end
		if drawblackscreen then
			surface.SetDrawColor(0,0,0,255.0)
			surface.DrawRect(0, 0, iw, ih)
		end
		if drawinfo then
			DrawVideoInfo(iw, ih, ev)
		end
		if blackness>0 then
			surface.SetDrawColor(0,0,0,blackness*255.0)
			surface.DrawRect(0, -1, iw+1, ih+2)
		end
		cam.End3D2D()
	end

end
hook.Add( "PostDrawOpaqueRenderables", "DrawTheaterScreen", DrawActiveTheater )

function DrawNoVideoPlaying( w, h )
	draw.TheaterText( "SWAMP CINEMA", "VideoInfoBrand", w/2, (h/2)-44, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.TheaterText( "To request a video, hold Q", "VideoInfoNV1", w/2, (h/2)+30, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.TheaterText( "Need help? Say /help", "VideoInfoNV2", w/2, (h/2)+96, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

local LastTitle = ""
local WasFullscreen = false
local Title = ""
function DrawVideoInfo( w, h, explicit )

	local Video = CurrentVideo
	if !Video then return end

	if explicit then
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0, 0, w, h)
	end

	surface.SetDrawColor(0,0,0,255)
	surface.SetTexture(gradientDown)
	surface.DrawTexturedRect(0, -1, w+1, h+1)

	-- Title
	if LastTitle != Video:Title() or WasFullscreen != Fullscreen then
		LastTitle = Video:Title()
		WasFullscreen = Fullscreen
		Title = string.reduce( LastTitle, "VideoInfoMedium", w )
	end
	draw.TheaterText( Title, "VideoInfoMedium", 10, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

	-- Volume
	draw.TheaterText( "VOLUME", "VideoInfoSmall", w - 72, 120, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	draw.TheaterText( GetVolume() .. "%", "VideoInfoMedium", w - 72, 136, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

	-- Vote Skips
	if NumVoteSkips > 0 then
		draw.TheaterText( T('Voteskips'):upper(), "VideoInfoSmall", w - 72, 230, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		draw.TheaterText( NumVoteSkips .. "/" .. ReqVoteSkips, "VideoInfoMedium", w - 72, 246, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end

	if Safe(LocalPlayer()) then
		draw.TheaterText( "PROTECTED", "VideoInfoSmall", w - 72, 90, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end

	-- Timed video info
	if Video:IsTimed() then
		local current = (CurTime() - Video:StartTime())
		local percent = math.Clamp( (current / Video:Duration() ) * 100, 0, 100 )

		-- Bar
		local bh = h * 1/32
		draw.RoundedBox( 0, 0, h - bh, w, bh+1, Color(0,0,0,200) )
		draw.RoundedBox( 0, 0, h - bh, w * (percent/100), bh+1, Color( 255, 255, 255, 255 ) )

		-- Current Time
		local strSeconds = string.FormatSeconds(math.Clamp(math.Round(current), 0, Video:Duration()))
		draw.TheaterText( strSeconds, "VideoInfoMedium", 16, h - bh, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

		-- Duration
		local strDuration = string.FormatSeconds(Video:Duration())
		draw.TheaterText( strDuration, "VideoInfoMedium", w - 16, h - bh, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
	end

	-- Loading indicater
	if IsValid(ActivePanel) and ActivePanel:IsLoading() then
		surface.SetDrawColor(255,255,255,255)
		surface.SetTexture(refreshTexture)
		surface.DrawTexturedRectRotated( 32, 128, 64, 64, RealTime() * -256 )
	end

	if explicit then
		surface.SetDrawColor(0,0,0,220)
		surface.DrawRect(0, 0, w, h)
		draw.TheaterText( "This video may contain explicit content.", "VideoInfoMedium", w/2, h*0.44, Color(255,50,50,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.TheaterText( "Press F6 if you're okay with seeing adult material.", "VideoInfoALittleSmaller", w/2, h*0.56, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

end

KKKLightColor = Vector(0,0,0)
KKKLightColor2 = Vector(0,0,0)

matproxy.Add({
	name = "klub0",
	init = function( self, mat, values )
	end,
	bind = function( self, mat, ent )
		mat:SetVector("$color2", KKKLightColor)
	end
})
matproxy.Add({
	name = "klub1",
	init = function( self, mat, values )
	end,
	bind = function( self, mat, ent )
		mat:SetVector("$color2", LerpVector(0.1,KKKLightColor,KKKLightColor2))
	end
})
matproxy.Add({
	name = "klub2",
	init = function( self, mat, values )
	end,
	bind = function( self, mat, ent )
		mat:SetVector("$color2", LerpVector(0.3,KKKLightColor,KKKLightColor2))
	end
})
matproxy.Add({
	name = "klub3",
	init = function( self, mat, values )
	end,
	bind = function( self, mat, ent )
		mat:SetVector("$color2", LerpVector(0.5,KKKLightColor,KKKLightColor2))
	end
})
matproxy.Add({
	name = "klub4",
	init = function( self, mat, values )
	end,
	bind = function( self, mat, ent )
		mat:SetVector("$color2", LerpVector(0.7,KKKLightColor,KKKLightColor2))
	end
})
matproxy.Add({
	name = "klub5",
	init = function( self, mat, values )
	end,
	bind = function( self, mat, ent )
		mat:SetVector("$color2", LerpVector(0.9,KKKLightColor,KKKLightColor2))
	end
})
matproxy.Add({
	name = "klub6",
	init = function( self, mat, values )
	end,
	bind = function( self, mat, ent )
		mat:SetVector("$color2", KKKLightColor2)
	end
})

function DrawFullscreenOrLighting()
	if Fullscreen and IsValid(ActivePanel) then

		if ActivePanel:GetHTMLMaterial()~=nil then
			draw.HTMLTexture( ActivePanel, ScrW(), ScrH() )
		end

		local ev = ExplicitVideoWarning()
		if ev or LastInfoDraw + InfoDrawDelay > CurTime() then
			DrawVideoInfo( ScrW(), ScrH(), ev )
		end

	else

		local settin = GetConVarNumber("cinema_lightfx")
		local inkkk = LocalPlayer():GetLocationName()=="Kool Kids Klub"

		if settin<1 and !inkkk then return end

		--dont activate the developer stuff
		settin=1

		if HtmlLightsMat == nil then return end

		local firsttime=nil
		if settin>1 then firsttime=SysTime() end

		--Cool lighting fx by Swamp Onions

		local Theater = LocalPlayer().GetTheater and LocalPlayer():GetTheater() or nil
		if !Theater then
			return
		end

		local ang = Theater:GetAngles()
		Ang = Angle( ang.p, ang.y, ang.r ) -- don't modify actual theater angle
		Ang:RotateAroundAxis( Ang:Forward(), 90 )

		Pos = Theater:GetPos() + Ang:Right() * 0.01

		--used below to place lights
		w, h = Theater:GetSize()

		local OldRT = render.GetRenderTarget()
		local ow, oh = ScrW(), ScrH()
		if settin<3 then render.SetRenderTarget( TheaterCustomRT ) end
		if settin>3 then render.SetRenderTarget(HtmlLightsMat:GetTexture("$basetexture")) end
		render.SetViewPort( 0, 0, 16, 16 )	
	 
		if settin < 4 then
			render.Clear( 0, 0, 0, 255, true )
			
			cam.Start2D()
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(HtmlLightsMat)
			surface.DrawTexturedRect( 0, 0, 16, 16 )
		end

		render.CapturePixels()
		local avgr1 =0
		local avgg1 =0
		local avgb1 =0
		local avgr2 =0
		local avgg2 =0
		local avgb2 =0
		local avgc =0

		for x=0, 16-1 do
		for y=0, 16-1 do
	    local r, g, b = render.ReadPixel( x, y )
	 	
	 	if x>=(16/2) then
	 		avgr2=avgr2+r
			avgg2=avgg2+g
			avgb2=avgb2+b
	 	else
	 		avgr1=avgr1+r
			avgg1=avgg1+g
			avgb1=avgb1+b
			avgc=avgc+1
	 	end

		 
		end
		end

		if settin < 4 then
			cam.End2D()
		end
		 
		render.SetViewPort( 0, 0, ow, oh )
	 
		render.SetRenderTarget( OldRT )

		avgc1 = Color(avgr1/avgc,avgg1/avgc,avgb1/avgc)
		avgc2 = Color(avgr2/avgc,avgg2/avgc,avgb2/avgc)

		if inkkk then
			local h1,s1,v1 = ColorToHSV(avgc1)
			local h2,s2,v2 = ColorToHSV(avgc2)
			s1 = math.pow(s1,0.3)
			s2 = math.pow(s2,0.3)

			v1=math.pow(v1,0.5)
			v2=math.pow(v2,0.5)

			avgc1=HSVToColor(h1,s1,v1)
			avgc2=HSVToColor(h2,s2,v2)

			KKKLightColor = Vector(avgc1.r/255.0,avgc1.g/255.0,avgc1.b/255.0)
			KKKLightColor2 = Vector(avgc2.r/255.0,avgc2.g/255.0,avgc2.b/255.0)
		end

		local dlight = DynamicLight( 1439 )
		if ( dlight ) then
			dlight.pos = Pos + (Ang:Forward()*(w/4)) + (Ang:Right()*(h/2)) + (Ang:Up()*((w+h)/4))
			dlight.r = avgc1.r
			dlight.g = avgc1.g
			dlight.b = avgc1.b
			dlight.brightness = 2
			dlight.Decay = 100
			dlight.Size = (w+h)*1.25
			dlight.DieTime = CurTime() + 1

			if inkkk then
				dlight.pos = Vector(2228,568,72)
				dlight.Size = 900
			end
		end

		dlight = DynamicLight( 1441 )
		if ( dlight ) then
			dlight.pos = Pos + (Ang:Forward()*(w*3/4)) + (Ang:Right()*(h/2)) + (Ang:Up()*((w+h)/4))
			dlight.r = avgc2.r
			dlight.g = avgc2.g
			dlight.b = avgc2.b
			dlight.brightness = 2
			dlight.Decay = 100
			dlight.Size = (w+h)*1.25
			dlight.DieTime = CurTime() + 1

			if inkkk then
				dlight.pos = Vector(2380,568,72)
				dlight.Size = 900
			end
		end

		if firsttime then print(SysTime()-firsttime) end
	end
end
hook.Add( "HUDPaint", "DrawFullscreenInfo", DrawFullscreenOrLighting )

function ExplicitVideoWarning()
	if GetConVar("swamp_mature_content"):GetBool() then return false end

	local Theater = LocalPlayer().GetTheater and LocalPlayer():GetTheater()
	if Theater and Theater._Video and Theater._Video:IsMature() then
		if Theater._Name=="Movie Theater" and IsValid(Theater._Video:GetOwner()) and Theater._Video:GetOwner():IsStaff() then
			return false
		end
		return true
	end
	
	return false
end


hook.Add("HUDPaint", "DrawNoFlashWarning", function()
	local Theater = LocalPlayer().GetTheater and LocalPlayer():GetTheater()
	if Theater and Theater._Video then
		if (not EmbeddedIsReady()) then return end
		local needschromium = Theater._Video:Service().NeedsChromium and (not EmbeddedHasChromium())
		local needsflash = Theater._Video:Service().NeedsFlash and (not EmbeddedHasFlash())
		local needscodecs = ((Theater._Video:Duration()==0 and Theater._Video:Service().LivestreamNeedsCodecs) or Theater._Video:Service().NeedsCodecs) and (not EmbeddedHasCodecs())

		if needschromium or needsflash or needscodecs then
			local plural = (needschromium and 1 or 0) + (needsflash and 1 or 0) + (needscodecs and 1 or 0) > 1 and "them" or "it"
			draw.WordBox( 10, ScrW()/2 - 80, ScrH()/2 - 50, "You don't have"..(needschromium and " Chromium," or "")..(needsflash and " the Adobe Flash plugin," or "")..(needscodecs and " the video codec patch," or ""), "CloseCaption_Bold",Color(0,0,0,255), Color(255,255,255,255))
			draw.WordBox( 10, ScrW()/2 - 80, ScrH()/2, "Without "..plural..", you can't watch this video", "CloseCaption_Bold",Color(0,0,0,255), Color(255,255,255,255))
			draw.WordBox( 10, ScrW()/2 - 80, ScrH()/2 + 50, "Press F2 to install "..plural.."! Then fully reboot Garry's Mod.", "CloseCaption_Bold",Color(0,0,0,255), Color(255,255,255,255))

			if needschromium and (not needsflash) and Theater._Video:Service().NeedsFlash then
				 draw.WordBox( 10, ScrW()/2 - 80, ScrH()/2 + 100, "This video also requires flash", "CloseCaption_Bold",Color(0,0,0,255), Color(255,255,255,255))
			end
		end
	end
end)
