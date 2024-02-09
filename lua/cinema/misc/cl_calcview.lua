-- This file is subject to copyright - contact swampservers@gmail.com for more information.
GM.TauntCam = TauntCamera()
local thirdperson_lerp = 0
local thirdperson_view_yaw = 0
local thirdperson_view_pitch = 0

function UseThirdperson()
    local localply = IsValid(Me) and Me
    if localply and localply:IsPlayingTaunt() then return true end
    local vehicle = localply:GetVehicle()
    if IsValid(vehicle) and vehicle:GetThirdPersonMode() then return true end
    local wep = localply and localply:GetActiveWeapon()
    local wc = localply and IsValid(wep) and wep:GetClass()

    if wep.IsScoped and wep:IsScoped() then
        thirdperson_lerp = 0

        return false
    end

    return THIRDPERSON or localply and (wep.AlwaysThirdPerson or wc == "weapon_fists" or localply:HasWeapon("weapon_goohulk") or wc == "weapon_garfield" and not localply:InVehicle())
end

concommand.Add("swamp_thirdperson", function()
    THIRDPERSON = not THIRDPERSON
end)

local was_f4_down = false

hook.Add("Think", "ThirdPersonToggler", function()
    local isf4down = input.IsKeyDown(KEY_F4)

    if isf4down and not was_f4_down then
        THIRDPERSON = not THIRDPERSON
    end

    was_f4_down = isf4down
end)

concommand.Add("swamp_freecam", function() end)

hook.Add("HUDShouldDraw", "HUDShouldDraw_HideCrosshair", function(name)
    if name == "CHudCrosshair" and (math.abs(thirdperson_view_yaw) > 1 or math.abs(thirdperson_view_pitch) > 1) then return false end
end)

local thirdperson_free_rotating = false
local thirdperson_binding_hint_shown = false

hook.Add("InputMouseApply", "InputMouseApply_ThirdPersonFreeze", function(cmd, x, y, ang)
    if thirdperson_lerp > 0 then
        local freecam_bind = input.LookupBinding("swamp_freecam")
        thirdperson_free_rotating = (freecam_bind and input.IsButtonDown(input.GetKeyCode(freecam_bind))) or (not input.LookupKeyBinding(MOUSE_MIDDLE) and input.IsButtonDown(MOUSE_MIDDLE))

        if freecam_bind == nil and thirdperson_free_rotating and not thirdperson_binding_hint_shown then
            LocalPlayerNotify("Freely rotate your camera in third person with middle mouse, or by binding swamp_freecam to the key of your choice.")
            thirdperson_binding_hint_shown = true
        end

        if thirdperson_free_rotating then
            thirdperson_view_yaw = (thirdperson_view_yaw or 0) - x / 44
            thirdperson_view_pitch = (thirdperson_view_pitch or 0) - y / 44
            thirdperson_view_yaw = math.NormalizeAngle(thirdperson_view_yaw)
            thirdperson_view_pitch = math.NormalizeAngle(thirdperson_view_pitch)
            cmd:SetMouseX(0)
            cmd:SetMouseY(0)

            return true
        end

        for i = 0, FrameTime() * 20 do
            thirdperson_view_yaw = thirdperson_view_yaw / 1.1
            thirdperson_view_pitch = thirdperson_view_pitch / 1.1
        end

        thirdperson_view_yaw = math.Round(thirdperson_view_yaw, 3)
    else
        thirdperson_free_rotating = false
        thirdperson_view_yaw = 0
        thirdperson_view_pitch = 0
    end
end)

hook.Add("ShouldDrawLocalPlayer", "ShouldDrawLocalPlayer_ThirdPerson", function(ply)
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep.GetSelfie and wep:GetSelfie() then return true end

    return thirdperson_lerp > 0 or ply:IsPlayingTaunt()
end)

function GM:CalcView(ply, origin, angles, fov, znear, zfar)
    local view = {
        origin = origin,
        angles = angles,
        fov = fov,
        znear = znear,
        zfar = zfar,
        drawviewer = false
    }

    if self.TauntCam:CalcView(view, ply, ply:IsPlayingTaunt()) then return view end
    local use_third_person = UseThirdperson()
    thirdperson_lerp = math.Approach(thirdperson_lerp or 0, use_third_person and 1 or 0, FrameTime() * 128)

    if thirdperson_lerp > 0 then
        local distance = thirdperson_lerp * 100
        angles:RotateAroundAxis(Vector(0, 0, 1), (thirdperson_view_yaw or 0) * thirdperson_lerp)
        angles:RotateAroundAxis(angles:Right(), (thirdperson_view_pitch or 0) * thirdperson_lerp)
        local offset = angles:Forward() * distance

        local trace = {
            start = origin,
            endpos = origin - offset,
            mins = Vector(1, 1, 1) * -8,
            maxs = Vector(1, 1, 1) * 8,
            mask = MASK_SOLID_BRUSHONLY
        }

        trace = util.TraceHull(trace)

        if trace.Hit then
            view.origin = origin - (offset * trace.Fraction)
        else
            view.origin = origin - offset
        end

        return view
    end

    local vehicle = ply:GetVehicle()
    local weapon = ply:GetActiveWeapon()
    if IsValid(vehicle) then return GAMEMODE:CalcVehicleView(vehicle, ply, view) end
    if drive.CalcView(ply, view) then return view end

    -- Give the active weapon a go at changing the viewmodel position
    if IsValid(weapon) then
        local func = weapon.GetViewModelPosition

        if func then
            view.vm_origin, view.vm_angles = func(weapon, origin * 1, angles * 1) -- Note: *1 to copy the object so the child function can't edit it.
        end

        local func = weapon.CalcView

        if func then
            view.origin, view.angles, view.fov = func(weapon, ply, origin * 1, angles * 1, fov) -- Note: *1 to copy the object so the child function can't edit it.
        end
    end

    return view
end
