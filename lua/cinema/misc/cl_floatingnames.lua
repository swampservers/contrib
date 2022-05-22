-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local HideNamesConVar = CreateClientConVar("cinema_hidenames", 0, true, false, "", 0, 1)
local ShowEyeAng = false

concommand.Add("showeyeang", function(ply, cmd, args)
    ShowEyeAng = not ShowEyeAng
    print(ShowEyeAng)
end)

local dotsperline = nil

local function DrawName(ply, opacityScale)
    if not IsValid(ply) or not ply:Alive() then return end
    if ply:IsDormant() or ply:GetNoDraw() then return end
    local pos = ply:EyePos() - Vector(0, 0, 4)
    local offset = pos - EyePos()
    local opacity = math.Clamp(320 - 0.4 * offset:Length(), 0, 150) * opacityScale
    if opacity <= 0 then return end
    local ang = LerpAngle(0.5, Angle(0, EyeAngles().y + 270, 90), Angle(0, math.deg(math.atan2(-offset.y, -offset.x)) + 90, 90))
    local anon = not (Me:IsStaff() and ShowEyeAng) and ply:UsingWeapon("weapon_anonymous")
    -- render.DepthRange( 0,0.998)
    cam.Start3D2D(pos + ang:Forward() * 10, ang, 0.08)
    local maxw = 500
    local y = 0
    local name = anon and "Anonymous" or ply:GetName()
    local namefont = FitFont("sansbold116", name, maxw) -- "Bebas Neue80_600"
    draw.ShadowedText(name, namefont, 0, y, Color(255, 255, 255, opacity))
    local nw, nh = GetTextSize(namefont, name)
    y = y + math.floor(nh * 0.92)
    local health = ply:Health() / ply:GetMaxHealth()

    if health < 1 then
        local barw, barh = math.max(nw, 200), 9
        local bary = math.floor(nh * 0.08) - barh

        draw.Rect(1, bary + 2, barw, barh, {0, 0, 0, 255 * math.pow(opacity / 255, 0.5)})

        local part = math.floor(barw * health)

        draw.Rect(0, bary, part, barh, {255, 255 * health, 255 * health, opacity})

        draw.Rect(part, bary, barw - part, barh, {0, 0, 0, opacity})
    end

    local chars = ply:TypingChars()

    if chars == 0 then
        y = y + 9
    else
        dotsperline = dotsperline or math.floor(100 * maxw / GetTextWidth(Font.sans28, string.rep("•", 100, "")))

        while chars > 0 do
            draw.ShadowedText(string.rep("•", math.min(chars, dotsperline), ""), Font.sans28, 0, y - 4, {255, 255, 255, opacity})

            chars = chars - dotsperline
            y = y + 9
        end
    end

    local x = 8

    local title, titlec = anon and "We are legion" or ply:GetTitle(), {255, 255, 255, opacity}

    if SHOWNPSET then
        local inset = InGroupSet(Me.NWP[SHOWNPSET] or "", ply)
        title = inset and SHOWNPSETVERB[1]:upper() .. SHOWNPSETVERB:sub(2) or "Not " .. SHOWNPSETVERB

        titlec = inset and {128, 255, 128, opacity} or {255, 128, 128, opacity}
    end

    if title ~= "" then
        draw.ShadowedText(title, Font.sansmedium60, x, y, titlec)
        x = x + GetTextWidth(Font.sansmedium60, title)
    end

    for i, icon in ipairs({
        {ply:IsAFK(), "swamp/icon48/clock-outline.png"},
        {ply.ClickMuted, "swamp/icon48/volume-off.png"},
        {ply.IsChatMuted, "swamp/icon48/chat-remove.png"},
    }) do
        if icon[1] then
            draw.ShadowedIcon(icon[2], 48, x + 8, y + 7, {255, 255, 255, opacity})

            x = x + 56
        end
    end

    if Me:IsStaff() and ShowEyeAng then
        draw.ShadowedText("Eyes " .. tostring(math.Round(ply:EyeAngles().p, 1)) .. " " .. tostring(math.Round(ply:EyeAngles().y, 1)) .. ", Mouse " .. tostring(ply.GuiMousePosX) .. " " .. tostring(ply.GuiMousePosY), Font.sans40, 0, y + 70, Color(255, 255, 255, opacity))

        if CurTime() - (ply.lastrequestedmousepos or 0) > 0.5 then
            ply.lastrequestedmousepos = CurTime()
            net.Start("GetGUIMousePos")
            net.WriteEntity(ply)
            net.SendToServer()
        end
    end

    cam.End3D2D()
    render.DepthRange(0, 1)
end

local HUDTargets = {}
local fadeTime = 2

hook.Add("PrePlayerDraw", "RecordDrawPlayerNames", function(ply)
    if ply ~= Me then
        HUDTargets[ply] = true
    end
end)

hook.Add("PostDrawTranslucentRenderables", "DrawPlayerNames", function(depth, sky, sky3d)
    local drawme = HUDTargets
    HUDTargets = {}
    if depth or sky3d then return end
    if not render.DrawingScreen() then return end
    if HideNamesConVar:GetBool() then return end
    if not IsValid(Me) or not Me.InTheater then return end
    if Me:UsingWeapon("weapon_camera") then return end
    if Me:InTheater() and (theater.Fullscreen or GetConVar("cinema_hideplayers"):GetBool()) then return end
    local tv = Me:InTheater() or Me:InVehicle()
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
            DrawName(ply, 0.5 * math.min(1, (dot - 0.85) * 6.66 + math.max(-0.5, (1 - dist) * 0.01)))
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
-- if not Me.InTheater then return end
-- --if IsValid( Me:GetVehicle() ) then return end
-- -- Draw lower opacity and recently targetted players in theater
-- if Me:InTheater() then
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
--     local tr = util.GetPlayerTrace(Me)
--     local trace = util.TraceLine(tr)
--     if not trace.Hit then return end
--     if not trace.HitNonWorld then return end
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
--     local lp = Me
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
