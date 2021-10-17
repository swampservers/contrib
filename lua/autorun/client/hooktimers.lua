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

hook.Add("RenderScreenspaceEffects", "FishEyeEffect", function()
    if IsValid(LocalPlayer()) and LocalPlayer():WaterLevel() == 3 then
        DrawMaterialOverlay("effects/water_warp01", -0.1)
    end
end)

-- translucent error here but whatever
-- it might be cool to make this piggyback off the shop accessories (ply:GetExtraAccessories...?)
hook.Add("PrePlayerDraw", "DrawSpacehat", function(ply)
    if ply:GetNWBool("spacehat", false) and ply:Alive() then
        if not IsValid(SpaceHatCSModel) then
            local prod = SS_Products['spacehat']
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
                    SpaceHatCSModel:SetPos(pos + ang:Up() * 4 + ang:Forward() * -4)
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

v_1 = 0
v_2 = 0

hook.Add("HUDPaint", "DebugUI", function()
    if not DebugOutput then return end
    surface.SetFont("Trebuchet24")
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(128, 128)
    surface.DrawText(tostring(v_1) .. "/" .. tostring(v_2))
    v_1 = 0
    v_2 = 0
end)

function CurrentFrustrum()
    local v1 = gui.ScreenToVector(0, 0)
    local v2 = gui.ScreenToVector(ScrW(), 0)
    local v3 = gui.ScreenToVector(ScrW(), ScrH())
    local v4 = gui.ScreenToVector(0, ScrH())

    local frustrum = {
        {v1:Cross(v2), 0},
        {v2:Cross(v3), 0},
        {v3:Cross(v4), 0},
        {v4:Cross(v1), 0}
    }

    for n = 1, 4 do
        frustrum[n][2] = frustrum[n][1]:Dot(EyePos())
    end

    return frustrum
end

function FrustrumCull(frustrum, p, r)
    for n = 1, 4 do
        if frustrum[n][1]:Dot(p) < frustrum[n][2] - r then return true end
    end

    return false
end

function PlyOBBMin(ply)
    return Vector(ply:IsPony() and -24 or -16, -16, (ply:GetPos().z - (ply:InVehicle() and 24 or 0)) - ply:EyePos().z)
end

function PlyOBBMax(ply)
    return Vector(20, 16, 12 + (ply:Crouching() and 16 or 0))
end

function PlyScreenArea(ply, n, x)
    local ep = ply:EyePos()
    local ang = Angle(0, ply:EyeAngles().y, 0)
    local angz = Angle(0, 0, 0)
    n = n - Vector(16, 16, 16)
    x = x + Vector(16, 16, 16)

    local bs = ({LocalToWorld(Vector(n.x, n.y, n.z), angz, ep, ang)})[1]:ToScreen()

    local samps = {
        ({LocalToWorld(Vector(n.x, n.y, x.z), angz, ep, ang)})[1]:ToScreen(),
        ({LocalToWorld(Vector(n.x, x.y, n.z), angz, ep, ang)})[1]:ToScreen(),
        ({LocalToWorld(Vector(n.x, x.y, x.z), angz, ep, ang)})[1]:ToScreen(),
        ({LocalToWorld(Vector(x.x, n.y, n.z), angz, ep, ang)})[1]:ToScreen(),
        ({LocalToWorld(Vector(x.x, n.y, x.z), angz, ep, ang)})[1]:ToScreen(),
        ({LocalToWorld(Vector(x.x, x.y, n.z), angz, ep, ang)})[1]:ToScreen(),
        ({LocalToWorld(Vector(x.x, x.y, x.z), angz, ep, ang)})[1]:ToScreen()
    }

    local xm = bs.x
    local xx = bs.x
    local ym = bs.y
    local yx = bs.y
    local vis = bs.visible

    for k, v in ipairs(samps) do
        xm = math.min(xm, v.x)
        xx = math.max(xx, v.x)
        ym = math.min(ym, v.y)
        yx = math.max(yx, v.y)
        vis = vis or v.visible
    end

    if (not vis) or xm > ScrW() or ym > ScrH() or xx < 0 or yx < 0 then return 0 end

    return (xx - xm) * (yx - ym)
end

function PlyOBBRand(ply, n, x)
    local r1 = math.Rand(0, 1)
    local r2 = math.Rand(0, 1)
    local r3 = math.Rand(0, 1)
    local ang = Angle(0, ply:EyeAngles().y, 0)
    local wp, wa = LocalToWorld(Vector(Lerp(r1, n.x, x.x), Lerp(r2, n.y, x.y), Lerp(r3, n.z, x.z)), Angle(0, 0, 0), ply:EyePos(), ang)
    local wp2, wa2 = LocalToWorld(Vector(Lerp(1.0 - r1, n.x, x.x), Lerp(1.0 - r2, n.y, x.y), Lerp(1.0 - r3, n.z, x.z)), Angle(0, 0, 0), ply:EyePos(), ang)

    return wp, wp2
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
    ["Locker Room"] = true,
    ["SportZone"] = true,
    ["Golf"] = true,
    ["The Pit"] = true,
    ["Maintenance Room"] = true,
    ["The Underworld"] = true,
    ["Sewer Tunnels"] = true
}

SKYBOXLOC = -1

concommand.Add("playervis", function(ply, cmd, args)
    for k, ply in ipairs(player.GetAll()) do
        DisableNoDraw(ply)
    end

    if (hook.GetTable()["PreDrawOpaqueRenderables"] or {})["PlayerVisPreDraw"] then
        hook.Remove("PreDrawOpaqueRenderables", "PlayerVisPreDraw")
        chat.AddText("Disabled")
    else
        hook.Add("PreDrawOpaqueRenderables", "PlayerVisPreDraw", PlayerVisUpdate)
        chat.AddText("Enabled")
    end
end)

function PlayerVisUpdate(depth, sky)
    if IsValid(LocalPlayer()) and LocalPlayer():GetNWInt("MONZ", 0) > 0 then
        for k, ply in ipairs(player.GetAll()) do
            DisableNoDraw(ply)
        end

        return
    end

    if depth or sky then return end
    if not Location then return end
    SKYBOXLOC = LocationByName["Way Outside"]

    if not render.DrawingScreen() then
        local nam = render.GetRenderTarget():GetName()

        if nam == "_rt_waterreflection" then
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
            for k, ply in ipairs(player.GetAll()) do
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
        local test = util.TraceLine({
            start = EyePos(),
            endpos = EyePos() + (EyeAngles():Forward() * 1000),
            mask = MASK_NPCWORLDSTATIC --VISIBLE
            
        })

        if test.Hit then
            --util.DecalEx(BloodModelMaterials[1], test.Entity, test.HitPos, test.HitNormal, Color(255,255,255,255),10,10)
            render.DrawWireframeBox(test.HitPos, Angle(0, 0, 0), Vector(-1, -1, -1), Vector(1, 1, 1), Color(0, 255, 255), true)
        end
    end

    local frustrum = CurrentFrustrum()

    for k, ply in ipairs(player.GetAll()) do
        if ply:IsDormant() then continue end

        if ply:GetLocation() == SKYBOXLOC then
            DisableNoDraw(ply)
            continue
        end

        if DebugOutput and LocalPlayer():IsSuperAdmin() and ply ~= LocalPlayer() then
            render.DrawWireframeBox(ply:EyePos(), Angle(0, ply:EyeAngles().y, 0), PlyOBBMin(ply), PlyOBBMax(ply), Color(255, 0, 0), false)
        end

        local draw = true
        local obbm = PlyOBBMin(ply)
        local obbx = PlyOBBMax(ply)
        local obbc = ply:EyePos() + Vector(0, 0, (obbm.z + obbx.z) * 0.5)

        if FrustrumCull(frustrum, obbc, 40) then
            EnableNoDraw(ply)
            continue
        end

        v_2 = v_2 + 1
        local area = PlyScreenArea(ply, obbm, obbx)

        if area == 0 then
            EnableNoDraw(ply)
            continue
        end

        local frames = area / 200

        if frames < 400 and ply ~= LocalPlayer() then
            local pos1, pos2 = PlyOBBRand(ply, obbm, obbx)

            if util.TraceLine({
                start = EyePos(),
                endpos = pos1,
                mask = MASK_VISIBLE
            }).Hit then
                if util.TraceLine({
                    start = EyePos(),
                    endpos = pos2,
                    mask = MASK_VISIBLE
                }).Hit then
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
            if DebugOutput and LocalPlayer():IsSuperAdmin() and ply ~= LocalPlayer() then
                v_1 = v_1 + 1
                render.DrawWireframeBox(ply:EyePos(), Angle(0, ply:EyeAngles().y, 0), PlyOBBMin(ply), PlyOBBMax(ply), Color(0, 255, 0), false)
            end

            ply.LastDrawFrame = FrameNumber()
            DisableNoDraw(ply)
            continue
        else
            if FrameNumber() - (ply.LastDrawFrame or 0) > frames then
                EnableNoDraw(ply)
                continue
            else
                if DebugOutput and LocalPlayer():IsSuperAdmin() and ply ~= LocalPlayer() then
                    v_1 = v_1 + 1
                    render.DrawWireframeBox(ply:EyePos(), Angle(0, ply:EyeAngles().y, 0), PlyOBBMin(ply), PlyOBBMax(ply), Color(0, 255, 0), false)
                end

                DisableNoDraw(ply)
                continue
            end
        end
    end
end

--local PlayerRenderClipDistSq = 600*600 --900*900
--local PlayerRenderShadowDistSq = 450*450
local undomodelblend = false
local matWhite = Material("models/debug/debugwhite")
local HIDEALLPLAYERS = false

hook.Add("Think", "CinemaHidePlayersUpdate", function()
    HIDEALLPLAYERS = IsValid(LocalPlayer()) and LocalPlayer().InTheater and LocalPlayer():InTheater() and (theater.Fullscreen or GetConVar("cinema_hideplayers"):GetBool())
end)

hook.Add("PrePlayerDraw", "PlayerVisControl", function(ply)
    if HIDEALLPLAYERS or ply:GetNoDraw() then return true end

    if not ply:InVehicle() then
        local transhide = false

        if LocalPlayer():InVehicle() and LocalPlayer():GetVehicle():GetNWBool("IsChessSeat", false) then
            if ChessLocalHideSpectators then
                transhide = true
            end
        end

        if transhide then
            render.SetBlend(0.2)
            render.ModelMaterialOverride(matWhite)
            render.SetColorModulation(0.5, 0.5, 0.5)
            undomodelblend = true
        end
    end
end)

hook.Add("PostPlayerDraw", "UndoPlayerBlend", function(ply)
    if undomodelblend then
        render.SetBlend(1.0)
        render.ModelMaterialOverride()
        render.SetColorModulation(1, 1, 1)
        undomodelblend = false
    end
end)

local function DrawName(ply, opacityScale)
    if not IsValid(ply) or not ply:Alive() then return end
    if ply:IsDormant() or ply:GetNoDraw() then return end
    if (not LocalPlayer():IsStaff()) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_anonymous" then return end
    local dist = EyePos():Distance(ply:EyePos())
    if (dist >= 800) then return end
    local opacity = math.Clamp(310.526 - (0.394737 * dist), 0, 150)
    opacity = opacity * opacityScale
    if opacity <= 0 then return end
    local pos = ply:EyePos() - Vector(0, 0, 4)
    local ang = EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    -- if LocalPlayer():InVehicle() then
    --     ang:RotateAroundAxis(ang:Right(), -LocalPlayer():GetVehicle():GetAngles().y)
    -- end
    --[[
	if ply:InVehicle() then
		pos = pos + Vector( 0, 0, 30 )
	else
		pos = pos + Vector( 0, 0, 60 )
	end
	 
	]]
    --
    local name = string.upper(ply:GetName())
    cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.15)
    -- render.OverrideDepthEnable(false, true)
    DrawTheaterText(name, "3D2DName", 65, 0, Color(255, 255, 255, opacity))
    local ch = ply:TypingChars()
    local chy = 58
    local title = ply:GetTitle()

    if ply:IsAFK() then
        title = "[AFK] " .. title
    end

    if title ~= "" then
        DrawTheaterText(title, "TheaterDermaLarge", 70, 70, Color(255, 255, 255, opacity))
    end

    while ch > 0 do
        DrawTheaterText(string.rep("•", math.min(ch, 50), ""), "DebugFixed", 75, chy, Color(255, 255, 255, opacity))
        chy = chy + 6
        ch = ch - 50
    end

    if LocalPlayer():IsStaff() and ShowEyeAng then
        DrawTheaterText(tostring(math.Round(ply:EyeAngles().p, 1)) .. " " .. tostring(math.Round(ply:EyeAngles().y, 1)), "TheaterDermaLarge", 70, 100, Color(255, 255, 255, opacity))
        DrawTheaterText(tostring(ply.GuiMousePosX) .. " " .. tostring(ply.GuiMousePosY), "TheaterDermaLarge", 70, 130, Color(255, 255, 255, opacity))
        ply.lastrequestedmousepos = ply.lastrequestedmousepos or 0

        if CurTime() - ply.lastrequestedmousepos > 0.5 then
            ply.lastrequestedmousepos = CurTime()
            net.Start("GetGUIMousePos")
            net.WriteEntity(ply)
            net.SendToServer()
        end
    end

    -- render.OverrideDepthEnable(false, false)
    cam.End3D2D()
end

local HUDTargets = {}
local fadeTime = 2

hook.Add("PrePlayerDraw", "RecordDrawPlayerNames", function(ply)
    if ply ~= LocalPlayer() then
        HUDTargets[ply] = true
    end
end)

hook.Add("PostDrawTranslucentRenderables", "DrawPlayerNames", function(depth, sky, sky3d)
    local drawme = HUDTargets
    HUDTargets = {}
    if depth or sky3d then return end
    if not render.DrawingScreen() then return end
    if HideNamesConVar and HideNamesConVar:GetBool() then return end
    if not IsValid(LocalPlayer()) or not LocalPlayer().InTheater then return end
    if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera" then return end
    if LocalPlayer():InTheater() and (theater.Fullscreen or GetConVar("cinema_hideplayers"):GetBool()) then return end
    local tv = LocalPlayer():InTheater() or LocalPlayer():InVehicle()
    local fwd = EyeAngles():Forward()
    local ep = EyePos()
    local sorteddraw = {}

    for ply, _ in pairs(drawme) do
        local to = ply:EyePos() - ep
        local dist = to:Length()

        table.insert(sorteddraw, {ply, to, dist})
    end

    table.SortByMember(sorteddraw, 3)

    for _, stuff in ipairs(sorteddraw) do
        local ply = stuff[1]
        local to = stuff[2]
        local dist = stuff[3]
        to = to / dist
        local dot = fwd:Dot(to)

        if tv then
            DrawName(ply, 0.5 * math.min(1, ((dot - 0.85) * 6.66 + math.max(-0.5, (1 - dist) * 0.01))))
        else
            DrawName(ply, math.min(1, (dot - 0.8) * 5 + math.max(0, (200 - dist) * 0.01)))
        end
    end
end)

-- hook.Add("PostDrawTranslucentRenderables", "DrawPlayerNames", function(depth, sky)
-- if sky then return end
-- if not render.DrawingScreen() then return end
-- local t1 = os.clock()
-- if GetConVar("cinema_drawnames") and not GetConVar("cinema_drawnames"):GetBool() then return end
-- if not LocalPlayer().InTheater then return end
-- --if IsValid( LocalPlayer():GetVehicle() ) then return end
-- -- Draw lower opacity and recently targetted players in theater
-- if LocalPlayer():InTheater() then
--     if theater.Fullscreen then return end
--     if GetConVar("cinema_hideplayers"):GetBool() then return end
--     for ply, time in pairs(HUDTargets) do
--         if time < RealTime() then
--             HUDTargets[ply] = nil
--             continue
--         end
--         -- Fade over time
--         DrawName(ply, 0.11 * ((time - RealTime()) / fadeTime))
--     end
--     local tr = util.GetPlayerTrace(LocalPlayer())
--     local trace = util.TraceLine(tr)
--     if (not trace.Hit) then return end
--     if (not trace.HitNonWorld) then return end
--     -- Keep track of recently targetted players
--     if trace.Entity:IsPlayer() then
--         HUDTargets[trace.Entity] = RealTime() + fadeTime
--     elseif trace.Entity:IsVehicle() and IsValid(trace.Entity:GetOwner()) and trace.Entity:GetOwner():IsPlayer() then
--         HUDTargets[trace.Entity:GetOwner()] = RealTime() + fadeTime
--     end
-- else -- draw all players names
--     local t1 = SysTime()
--     -- local ap = player.GetAll()
--     local v1 = EyeVector():GetNormalized()
--     local lp = LocalPlayer()
--     local ep = EyePos()
--     -- for _, ply in ipairs(player.GetAll()) do
--     -- for k,ply in ipairs(ap) do
--     for k, ply in pairs(Ents.player) do
--         if ply ~= lp then
--             local v2 = (ply:EyePos() - ep)
--             local dist2 = v2:LengthSqr()
--             if dist2 < 360000 then
--                 local dist = math.sqrt(dist2)
--                 if math.acos(v1:Dot(v2 / dist)) < Lerp(math.Clamp(dist / 600, 0, 1), 0.7, 0.35) then
--                     HUDTargets[ply] = math.max(RealTime() + Lerp(math.Clamp((dist - 550) / 50, 0, 1), fadeTime, 0), HUDTargets[ply] or 0)
--                 end
--             end
--         end
--     end
--     for ply, time in pairs(HUDTargets) do
--         if time < RealTime() then
--             HUDTargets[ply] = nil
--             continue
--         end
--         -- Fade over time
--         DrawName(ply, 0.7 * ((time - RealTime()) / fadeTime))
--     end
--     -- print(3, SysTime()-t1)
-- end
-- end)
net.Receive("GetGUIMousePos", function(len)
    local e = net.ReadEntity()
    local x = net.ReadInt(16)
    local y = net.ReadInt(16)
    e.GuiMousePosX = x
    e.GuiMousePosY = y
end)

net.Receive("ReportGUIMousePos", function(len)
    local x, y = gui.MousePos()
    net.Start("ReportGUIMousePos")
    net.WriteInt(x, 16)
    net.WriteInt(y, 16)
    net.SendToServer()
end)

ShowEyeAng = false

--NOMINIFY
concommand.Add("showeyeang", function(ply, cmd, args)
    ShowEyeAng = not ShowEyeAng
end)

timer.Create("AreaMusicController", 0.5, 0, function()
    if not IsValid(LocalPlayer()) or LocalPlayer().GetLocationName == nil then return end
    local target = ""
    local loc = LocalPlayer():GetLocationName()

    if loc == "Vapor Lounge" and not (LocalPlayer():GetTheater() and LocalPlayer():GetTheater():IsPlaying()) then
        target = "vapor"
    end

    -- if loc=="Mines" then
    -- 	if GetGlobalBool("DAY", true) then
    -- 		target = table.Random({"cavern", "cavernalt"}) --alt. theme - https://youtu.be/-erU20cQO_Y
    -- 	else
    -- 		target = "cavernnight" --night theme - https://youtu.be/QT8vuiS0cpQ
    -- 	end
    -- end
    if loc == "Treatment Room" then
        target = "treatment"
    end

    if loc == "Gym" then
        target = "gym"
    end

    if ValidPanel(HELLTAKERFRAME) then
        target = "helltaker"
    end

    if MusicPagePanel then
        if target == MusicPagePanel.target then
        else -- MusicPagePanel:RunJavascript("setAttenuation(" .. (LocalPlayer():GetTheater() and LocalPlayer():GetTheater():IsPlaying() and "0" or "1") .. ")")
            if (target == "cavern" or target == "cavernalt") and (MusicPagePanel.target == "cavern" or MusicPagePanel.target == "cavernalt") then return end
            --don't remove panel for caverns themes
            MusicPagePanel:Remove()
            MusicPagePanel = nil
        end
    else
        if target ~= "" then
            if MusicPagePanel == nil then
                MusicPagePanel = vgui.Create("TheaterHTML")

                if MusicPagePanel == nil then
                    print('dhtml error')

                    return true
                end

                MusicPagePanel:SetSize(100, 100)
                MusicPagePanel:SetAlpha(0)
                MusicPagePanel:SetMouseInputEnabled(false)

                function MusicPagePanel:ConsoleMessage(msg)
                end

                MusicPagePanel.target = target
                MusicPagePanel:OpenURL("http://swamp.sv/bgmusic.php?t=" .. target .. "&v=" .. GetConVar("cinema_volume"):GetString() .. "&r" .. tostring(math.random()))
            end
        end
    end
end)

timer.Create("RandomCaveAmbientSound", 60, 0, function()
    if math.random(0, 250) >= 5 then return end --rare chance to trigger

    --any sewer location that isn't a theater
    if string.find(LocalPlayer():GetLocationName(), "Sewer") and not LocalPlayer():InTheater() then
        sound.PlayFile("sound/sewers/cave0" .. tostring(math.random(1, 6)) .. ".ogg", "3d noplay", function(snd, errid, errnm)
            if not IsValid(snd) then return end
            snd:SetPos(LocalPlayer():GetPos() + VectorRand(-500, 500)) --set in a random location near the player
            snd:Play()
            snd:Set3DFadeDistance(600, 100000)
        end)
    end
end)
