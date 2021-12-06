-- This file is subject to copyright - contact swampservers@gmail.com for more information.

local HideNamesConVar = CreateClientConVar("cinema_hidenames", 0, true, false, "", 0, 1)

local ShowEyeAng = false

concommand.Add("showeyeang", function(ply, cmd, args)
    ShowEyeAng = not ShowEyeAng
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
    if HideNamesConVar:GetBool() then return end
    if not IsValid(LocalPlayer()) or not LocalPlayer().InTheater then return end
    if LocalPlayer():UsingWeapon("weapon_camera") then return end
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


-- TODO: make targeted players' names light up at long distance like in code below
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
