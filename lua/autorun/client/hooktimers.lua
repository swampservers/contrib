-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

--move this to a diff file lol
--[[
timer.Simple(2, function()
	local function DiscordTry(port, callback)
		if port > 6473 then  return end

		http.Fetch(("http://127.0.0.1:%s"):format(port), function(body)
			if body:match("Authorization Required") then
				DiscordPort = port

				function DiscordSetActivity(activity)
					local callback = function(d,e) --if LocalPlayer():Nick()=="Swamp" then if d then PrintTable(d) end print(e) end 
					end

					HTTP{
						method = "POST",
						url = ("http://127.0.0.1:%s/rpc?v=1&client_id=439324484361650186"):format(DiscordPort),
						type = "application/json",
						body = util.TableToJSON{
							cmd = "SET_ACTIVITY",
							args = {
								pid = 1337,
								activity = activity
							},
							nonce = tostring(SysTime())
						},
						success = function(status, body)
							local data = util.JSONToTable(body)
							if not data or data.evt == "ERROR" then
								callback(false, "Discord error: " .. tostring(data.data and data.data.message or "nil"))
							else
								callback(data)
							end
						end,
						failed = function(err)
							callback(false, "HTTP error: " .. err)
						end,
					}
				end

				timer.Create("discordrpc_state", 18, 0, function()
					local GAMEMODE = GM or GAMEMODE
					local ip = game.GetIPAddress()

					local state = ""

					if IsValid(LocalPlayer()) and LocalPlayer().GetLocationName then
						state = "In "..LocalPlayer():GetLocationName()
						if LocalPlayer():IsAFK() then
							state = "AFK "..state
						end
						local th = LocalPlayer().GetTheater and LocalPlayer():GetTheater()
						if th then
						local name = th:IsPlaying() and th:VideoTitle()
							if name then
								state = "🎥 "..name.." "..state
							end
						end

					end

					local activity = {
						details = ip,
						state = state,
						assets = {
							large_image = "default",
							large_text = "HAHA",
							small_image = "default",
							small_text = "haha"
						},
					}
					DiscordSetActivity(activity)
				end)

				hook.Add("ShutDown", "discordrpc_clear", function() DiscordSetActivity() end)
			end
		end, function()
			DiscordTry(port + 1, callback)
		end)
	end
	DiscordTry(6463, callback)
end) ]]



timer.Simple(1, function()
	net.Start("setcntry")
	net.WriteString(string.lower(system.GetCountry()))
	net.SendToServer()
end)
		


hook.Add("DrawTranslucentAccessories", "DrawSpacehat", function(ply)
	if ply:GetNWBool("spacehat", false) and ply:Alive() then
		if not IsValid(SpaceHatCSModel) then
			local prod = PS_Products['spacehat']
			SpaceHatCSModel = ClientsideModel(prod.model, RENDERGROUP_OPAQUE)
			SpaceHatCSModel:SetMaterial(prod.material)
			SpaceHatCSModel:SetNoDraw(true)
		end
		
		local attach_id = ply:LookupAttachment('eyes')
		if attach_id then
			local attacht = ply:GetAttachment(attach_id)
			if attacht then
				pos = attacht.Pos
				ang = attacht.Ang
				SpaceHatCSModel:SetAngles(ang)
				if ply:IsPony() then
					SpaceHatCSModel:SetPos(pos + ang:Up()*4 + ang:Forward()*-4)
					SpaceHatCSModel:SetModelScale(1.0)
				else
					SpaceHatCSModel:SetPos(pos)	
					SpaceHatCSModel:SetModelScale(0.7)
				end
				
				SpaceHatCSModel:SetupBones()
				SpaceHatCSModel:DrawModel()
			end
		end
	end
end)

v_1=0
v_2=0
hook.Add("HUDPaint", "DebugUI", function()
	if not DebugOutput then return end
	surface.SetFont( "Trebuchet24" )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( 128, 128 )

	surface.DrawText(tostring(v_1).."/"..tostring(v_2))
	v_1=0
	v_2=0
end)

function CurrentFrustrum()
	local v1 = gui.ScreenToVector(0,0)
	local v2 = gui.ScreenToVector(ScrW(),0)
	local v3 = gui.ScreenToVector(ScrW(),ScrH())
	local v4 = gui.ScreenToVector(0,ScrH())

	local frustrum = {
		{v1:Cross(v2),0},
		{v2:Cross(v3),0},
		{v3:Cross(v4),0},
		{v4:Cross(v1),0}
	}

	for n=1,4 do
		frustrum[n][2] = frustrum[n][1]:Dot(EyePos())
	end

	return frustrum
end

function FrustrumCull(frustrum, p, r)
	for n=1,4 do
		if frustrum[n][1]:Dot(p) < frustrum[n][2]-r then
			return true
		end
	end
	return false
end

function PlyOBBMin(ply)
	return Vector(ply:IsPony() and -24 or -16,-16,(ply:GetPos().z-(ply:InVehicle() and 24 or 0))-ply:EyePos().z)
end

function PlyOBBMax(ply)
	return Vector(20,16,12 + (ply:Crouching() and 16 or 0))

end

function PlyScreenArea(ply,n,x)

	local ep = ply:EyePos()
	local ang = Angle(0,ply:EyeAngles().y,0)
	local angz = Angle(0,0,0)
	n=n-Vector(16,16,16)
	x=x+Vector(16,16,16)

	local bs = ({LocalToWorld(Vector(n.x,n.y,n.z), angz, ep, ang)})[1]:ToScreen()
	local samps = {
		({LocalToWorld(Vector(n.x,n.y,x.z), angz, ep, ang)})[1]:ToScreen(),
		({LocalToWorld(Vector(n.x,x.y,n.z), angz, ep, ang)})[1]:ToScreen(),
		({LocalToWorld(Vector(n.x,x.y,x.z), angz, ep, ang)})[1]:ToScreen(),
		({LocalToWorld(Vector(x.x,n.y,n.z), angz, ep, ang)})[1]:ToScreen(),
		({LocalToWorld(Vector(x.x,n.y,x.z), angz, ep, ang)})[1]:ToScreen(),
		({LocalToWorld(Vector(x.x,x.y,n.z), angz, ep, ang)})[1]:ToScreen(),
		({LocalToWorld(Vector(x.x,x.y,x.z), angz, ep, ang)})[1]:ToScreen()
	}

	local xm = bs.x
	local xx = bs.x
	local ym = bs.y
	local yx = bs.y
	local vis = bs.visible

	for k,v in ipairs(samps) do
		xm = math.min(xm, v.x)
		xx = math.max(xx, v.x)
		ym = math.min(ym, v.y)
		yx = math.max(yx, v.y)
		vis = vis or v.visible
	end


	if (not vis) or xm > ScrW() or ym > ScrH() or xx < 0 or yx < 0 then
		return 0
	end

	return (xx-xm)*(yx-ym)
end

function PlyOBBRand(ply, n,x)
	local r1 = math.Rand(0,1)
	local r2 = math.Rand(0,1)
	local r3 = math.Rand(0,1)

	local ang = Angle(0,ply:EyeAngles().y,0)

	local wp,wa = LocalToWorld(Vector(Lerp(r1,n.x,x.x),Lerp(r2,n.y,x.y),Lerp(r3,n.z,x.z)), Angle(0,0,0), ply:EyePos(), ang)
	local wp2,wa2 = LocalToWorld(Vector(Lerp(1.0-r1,n.x,x.x),Lerp(1.0-r2,n.y,x.y),Lerp(1.0-r3,n.z,x.z)), Angle(0,0,0), ply:EyePos(), ang)

	return wp,wp2
end

function EnableNoDraw(ply)
	if not ply:GetNoDraw() then
		ply:SetNoDraw(true)
	end
end

function DisableNoDraw(ply)
	if ply:GetNoDraw() then
		ply:SetNoDraw(false)
	end
end

-- LatestReflectionDraw = 0

FullRefractLocation = {
["Locker Room"]=true,
["SportZone"]=true,
["Golf"]=true,
["The Pit"]=true,
["Maintenance Room"]=true,
["The Underworld"]=true,
["Sewer Tunnels"]=true
}

SKYBOXLOC = -1



PLAYERVISDISABLED = false

concommand.Add("playervis", function( ply, cmd, args )
	for k,ply in ipairs(player.GetAll()) do DisableNoDraw(ply) end
	PLAYERVISDISABLED = not PLAYERVISDISABLED
	chat.AddText(PLAYERVISDISABLED and "disabled" or "enabled")
end)

hook.Add("PreDrawOpaqueRenderables","PlayerVisPreDraw",function(depth, sky)	
	if PLAYERVISDISABLED then return end

	if IsValid(LocalPlayer()) and LocalPlayer():GetNWInt("MONZ", 0)>0 then 
		for k,ply in ipairs(player.GetAll()) do DisableNoDraw(ply) end
		return
	end

	if depth or sky then return end
	if not Location then return end

	SKYBOXLOC = Location.GetLocationIndexByName("Way Outside")

	if not render.DrawingScreen() then
		local nam=render.GetRenderTarget():GetName()
		if nam=="_rt_waterreflection" then
			LatestReflectionDraw = FrameNumber()
		end
		-- if nam=="_rt_waterrefraction" then
		-- 	local nom = LocalPlayer():GetLocationName()
		-- 	local th = LocalPlayer():GetTheater()
		-- 	if FullRefractLocation[nom] or ((th and th._PermanentOwnerID)~=nil) or (nom=="Outside" and EyePos().x>2160 and EyePos().y<-1040) then
		-- 		return
		-- 	else
		-- 		return true
		-- 	end
		-- end
		return
	end

	if LocalPlayer().InTheater and LocalPlayer():InTheater() then
		if theater.Fullscreen or GetConVar("cinema_hideplayers"):GetBool() then
			for k,ply in ipairs(player.GetAll()) do
				if not ply:IsDormant() then
					EnableNoDraw(ply)
				end
			end
			return
		end
	end

	-- if LatestReflectionDraw == FrameNumber() then
	-- 	for k,ply in ipairs(player.GetAll()) do
	-- 		if not ply:IsDormant() then
	-- 			ply.LastDrawFrame = FrameNumber()
	-- 			DisableNoDraw(ply)
	-- 		end
	-- 	end
	-- 	return
	-- end

	if DebugOutput then
		local test = util.TraceLine( {
					start = EyePos(),
					endpos = EyePos()+(EyeAngles():Forward()*1000),
					mask = MASK_NPCWORLDSTATIC --VISIBLE
				} )
		if test.Hit then
			--util.DecalEx(BloodModelMaterials[1], test.Entity, test.HitPos, test.HitNormal, Color(255,255,255,255),10,10)
			render.DrawWireframeBox(test.HitPos,Angle(0,0,0),Vector(-1,-1,-1),Vector(1,1,1),Color(0,255,255),true)
		end
	end

	local frustrum = CurrentFrustrum()

	for k,ply in ipairs(player.GetAll()) do
		if ply:IsDormant() then continue end

		if ply:GetLocation()==SKYBOXLOC then
			DisableNoDraw(ply) continue
		end
		
		if DebugOutput and LocalPlayer():IsSuperAdmin() and ply~=LocalPlayer() then
			render.DrawWireframeBox(ply:EyePos(),Angle(0,ply:EyeAngles().y,0),PlyOBBMin(ply),PlyOBBMax(ply),Color(255,0,0),false)
		end
		

		local draw = true

		local obbm = PlyOBBMin(ply)
		local obbx = PlyOBBMax(ply)
		local obbc = ply:EyePos() + Vector(0,0,(obbm.z + obbx.z)*0.5)

		if FrustrumCull(frustrum, obbc, 40) then
			EnableNoDraw(ply) continue
		end

		v_2=v_2+1

		local area = PlyScreenArea(ply,obbm,obbx)
		if area==0 then
			EnableNoDraw(ply) continue
		end

		local frames = area/200

		if frames<400 and ply~=LocalPlayer() then
			local pos1,pos2 = PlyOBBRand(ply,obbm,obbx)

			if util.TraceLine( {
					start = EyePos(),
					endpos = pos1,
					mask = MASK_VISIBLE
				} ).Hit then

				if util.TraceLine( {
				start = EyePos(),
				endpos = pos2,
				mask = MASK_VISIBLE
				} ).Hit then
					draw = false
				end
				
				--[[if util.TraceLine( {
						start = EyePos(),
						endpos = ((2.0*ply:LocalToWorld(ply:OBBCenter())) - ply:EyePos()),
						mask = MASK_VISIBLE
					} ).Hit then
					draw = false
				end]]
			end
		end

		if draw then
				if DebugOutput and LocalPlayer():IsSuperAdmin() and ply~=LocalPlayer() then
					v_1=v_1+1
					render.DrawWireframeBox(ply:EyePos(),Angle(0,ply:EyeAngles().y,0),PlyOBBMin(ply),PlyOBBMax(ply),Color(0,255,0),false)
				end

			ply.LastDrawFrame = FrameNumber()
			DisableNoDraw(ply) continue

		else
			if FrameNumber()-(ply.LastDrawFrame or 0) > frames then
				EnableNoDraw(ply) continue
			else
				if DebugOutput and LocalPlayer():IsSuperAdmin() and ply~=LocalPlayer() then
					v_1=v_1+1
					render.DrawWireframeBox(ply:EyePos(),Angle(0,ply:EyeAngles().y,0),PlyOBBMin(ply),PlyOBBMax(ply),Color(0,255,0),false)
				end
				
				DisableNoDraw(ply) continue
			end
		end
		
	end
end)

--local PlayerRenderClipDistSq = 600*600 --900*900
--local PlayerRenderShadowDistSq = 450*450
local undomodelblend = false
local matWhite = Material("models/debug/debugwhite")

local HIDEALLPLAYERS = false

hook.Add("Think","CinemaHidePlayersUpdate",function()
	HIDEALLPLAYERS = IsValid(LocalPlayer()) and LocalPlayer().InTheater and LocalPlayer():InTheater() and (theater.Fullscreen or GetConVar("cinema_hideplayers"):GetBool())
end)

hook.Add("PrePlayerDraw","PlayerVisControl",function(ply)
	if HIDEALLPLAYERS or ply:GetNoDraw() then return true end

	if !ply:InVehicle() then 
		local transhide = false
			
		if LocalPlayer():InVehicle() and LocalPlayer():GetVehicle():GetNWBool("IsChessSeat", false) then
			if ChessLocalHideSpectators then transhide = true end
		end	

		if transhide then
			render.SetBlend(0.2)
			render.ModelMaterialOverride(matWhite)
			render.SetColorModulation(0.5, 0.5, 0.5)

			undomodelblend = true
		end
	end
end)

hook.Add("PostPlayerDraw", "UndoPlayerBlend", function( ply )
	if undomodelblend then
		render.SetBlend(1.0)
		render.ModelMaterialOverride()
		render.SetColorModulation(1, 1, 1)
		undomodelblend = false
	end
end)


--todo: move to new file
surface.CreateFont( "3D2DName", { font = "Bebas Neue", size = 80, weight = 600 } )

local function DrawName( ply, opacityScale )

	if !IsValid(ply) or !ply:Alive() then return end
	if ply:IsDormant() or ply:GetNoDraw() then return end

	if (not LocalPlayer():IsStaff()) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass()=="weapon_anonymous" then return end
	
	local pos = ply:EyePos() - Vector(0,0,4)
	local ang = LocalPlayer():EyeAngles()
	
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	if LocalPlayer():InVehicle() then
		ang:RotateAroundAxis( ang:Right(), -LocalPlayer():GetVehicle():GetAngles().y )		
	end
	
	--[[
	if ply:InVehicle() then
		pos = pos + Vector( 0, 0, 30 )
	else
		pos = pos + Vector( 0, 0, 60 )
	end
	
	]]--

	local dist = LocalPlayer():GetPos():Distance( ply:GetPos() )
	if ( dist >= 800 ) then return end

	
	local opacity = math.Clamp( 310.526 - ( 0.394737 * dist ), 0, 150 )
	
	opacityScale = opacityScale and opacityScale or 1
	opacity = opacity * opacityScale

	local name = string.upper( ply:GetName() )

	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.15 )

		-- render.OverrideDepthEnable(false, true)

		draw.TheaterText( name, "3D2DName", 65, 0, Color( 255, 255, 255, opacity ) )

		if LocalPlayer():IsStaff() then
			if ply:IsAFK() then
				draw.TheaterText( "[AFK]", "DermaLarge", 70, 70, Color( 255, 255, 255, opacity ) )
			end
			if ShowEyeAng then
				draw.TheaterText(tostring(math.Round(ply:EyeAngles().p,1)).." "..tostring(math.Round(ply:EyeAngles().y,1)), "DermaLarge", 70, 100, Color( 255, 255, 255, opacity ) )
				draw.TheaterText(tostring(ply.GuiMousePosX).." "..tostring(ply.GuiMousePosY), "DermaLarge", 70, 130, Color( 255, 255, 255, opacity ) )
				ply.lastrequestedmousepos = ply.lastrequestedmousepos or 0
				if CurTime()-ply.lastrequestedmousepos > 0.5 then
					ply.lastrequestedmousepos = CurTime()
					net.Start("GetGUIMousePos")
					net.WriteEntity(ply)
					net.SendToServer()
				end
			end
		end
		
		-- render.OverrideDepthEnable(false, false)

	cam.End3D2D()
end

local HUDTargets = {}
local fadeTime = 2
hook.Add( "PostDrawTranslucentRenderables", "DrawPlayerNames", function(depth, sky)

	if sky then
		return
	end

	if not render.DrawingScreen() then
		return
	end

	local t1 = os.clock()

	if GetConVar("cinema_drawnames") and !GetConVar("cinema_drawnames"):GetBool() then return end
	if !LocalPlayer().InTheater then return end
	--if IsValid( LocalPlayer():GetVehicle() ) then return end

	-- Draw lower opacity and recently targetted players in theater
	if LocalPlayer():InTheater() then

		if theater.Fullscreen then return end
		if GetConVar("cinema_hideplayers"):GetBool() then return end

		for ply, time in pairs(HUDTargets) do

			if time < RealTime() then
				HUDTargets[ply] = nil
				continue
			end

			-- Fade over time
			DrawName( ply, 0.11 * ((time - RealTime()) / fadeTime) )

		end

		local tr = util.GetPlayerTrace( LocalPlayer() )
		local trace = util.TraceLine( tr )
		if (!trace.Hit) then return end
		if (!trace.HitNonWorld) then return end
		
		-- Keep track of recently targetted players
		if trace.Entity:IsPlayer() then
			HUDTargets[trace.Entity] = RealTime() + fadeTime
		elseif trace.Entity:IsVehicle() and
			IsValid(trace.Entity:GetOwner()) and
			trace.Entity:GetOwner():IsPlayer() then
			HUDTargets[trace.Entity:GetOwner()] = RealTime() + fadeTime
		end

	else -- draw all players names

		local v1 = EyeVector():GetNormalized()

		for _, ply in pairs( player.GetAll() ) do

			if ply != LocalPlayer() then

				local v2 = (ply:EyePos()-EyePos())

				local dist = v2:Length()

				if math.acos(v1:Dot(v2/dist)) < Lerp(math.Clamp(dist/600,0,1),0.7,0.35) and dist<600 then
				
					HUDTargets[ply] = math.max(RealTime() + Lerp(math.Clamp((dist-550)/50,0,1),fadeTime,0), HUDTargets[ply] or 0)

				end

			end
		end

		for ply, time in pairs(HUDTargets) do

			if time < RealTime() then
				HUDTargets[ply] = nil
				continue
			end

			-- Fade over time
			DrawName( ply, 0.7 * ((time - RealTime()) / fadeTime) )
		end

	end

end )

net.Receive("GetGUIMousePos",function(len)
    local e = net.ReadEntity()
    local x = net.ReadInt(16)
    local y = net.ReadInt(16)
    e.GuiMousePosX = x
	e.GuiMousePosY = y
end)

net.Receive("ReportGUIMousePos",function(len)
	local x,y = gui.MousePos()
	net.Start("ReportGUIMousePos")
	net.WriteInt(x,16)
    net.WriteInt(y,16)
    net.SendToServer()
end)

ShowEyeAng = false
concommand.Add( "showeyeang", function( ply, cmd, args )
	ShowEyeAng = !ShowEyeAng
end )

timer.Create("AreaMusicController", 0.5, 0, function()
	if LocalPlayer().GetLocationName == nil then return end
	local target = ""
	local loc = LocalPlayer():GetLocationName()
	if loc=="Vapor Lounge" then
		target = "vapor"
	end
	-- if loc=="Mines" then
	-- 	if GetGlobalBool("DAY", true) then
	-- 		target = table.Random({"cavern", "cavernalt"}) --alt. theme - https://youtu.be/-erU20cQO_Y
	-- 	else
	-- 		target = "cavernnight" --night theme - https://youtu.be/QT8vuiS0cpQ
	-- 	end
	-- end
	if loc=="Treatment Room" then
		target = "treatment"
	end
	if loc=="Gym" then
		target = "gym"
	end
	if MusicPagePanel then
		if target~=MusicPagePanel.target then
			if (target == "cavern" or target == "cavernalt") and (MusicPagePanel.target == "cavern" or MusicPagePanel.target == "cavernalt") then return end
			--don't remove panel for caverns themes
			MusicPagePanel:Remove()
			MusicPagePanel = nil
		end 
	else
		if target~="" then
			if MusicPagePanel==nil then
				MusicPagePanel = vgui.Create("TheaterHTML")
				if MusicPagePanel == nil then print('dhtml error') return true end
				MusicPagePanel:SetSize(100,100)
				MusicPagePanel:SetAlpha(0)
				MusicPagePanel:SetMouseInputEnabled(false)
				function MusicPagePanel:ConsoleMessage(msg) end
				MusicPagePanel.target=target
				MusicPagePanel:OpenURL("http://swampservers.net/bgmusic.php?t="..target.."&v="..GetConVar("cinema_volume"):GetString())
			end
		end
	end
end)

timer.Create("RandomCaveAmbientSound", 60, 0, function()
	if math.random(0, 250) >= 5 then return end --rare chance to trigger
	if string.find(LocalPlayer():GetLocationName(), "Sewer") and !LocalPlayer():InTheater() then --any sewer location that isn't a theater
		sound.PlayFile("sound/sewers/cave0"..tostring(math.random(1, 6))..".ogg", "3d noplay", function(snd, errid, errnm)
			if !IsValid(snd) then return end
			snd:SetPos(LocalPlayer():GetPos() + VectorRand(-500, 500)) --set in a random location near the player
			snd:Play()
			snd:Set3DFadeDistance(600, 100000)
		end)
	end
end)
