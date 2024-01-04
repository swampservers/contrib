-- This file is subject to copyright - contact swampservers@gmail.com for more information.
GM.TauntCam = TauntCamera()

-- Disable standard vehicle third person
timer.Simple(0, function()
    local VEHICLE = FindMetaTable("Vehicle")
    function VEHICLE:GetThirdPersonMode()
        return false
    end
end)

function UseThirdperson()
    local wep = LocalPlayer():GetActiveWeapon()
    local wc = IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass()
    if LocalPlayer():IsPlayingTaunt() then return true end

    if (wep.IsScoped and wep:IsScoped()) then
        Thirdperson_Lerp = 0
        Thirdperson_LerpSide = 0

        return false
    end

    return THIRDPERSON or wc == "weapon_fists" or LocalPlayer():HasWeapon("weapon_goohulk") or (wc == "weapon_garfield" and IsValid(LocalPlayer()) and not LocalPlayer():InVehicle())
end

local wasf4down = false

concommand.Add("swamp_thirdperson", function()
    THIRDPERSON = not THIRDPERSON
end)

hook.Add("Think", "ThirdPersonToggler", function()
    local isf4down = input.IsKeyDown(KEY_F4)

    if isf4down and not wasf4down then
        THIRDPERSON = not THIRDPERSON
    end

    wasf4down = isf4down
end)

local was_freecam_bind_down = false

hook.Add("Think", "ThirdPersonSideViewToggler", function()
    local freecam_bind = input.LookupBinding("swamp_freecam")
    local is_freecam_bind_down = (freecam_bind and input.IsButtonDown(input.GetKeyCode(freecam_bind))) or (not input.LookupKeyBinding(MOUSE_MIDDLE) and input.IsButtonDown(MOUSE_MIDDLE))

    if is_freecam_bind_down and not was_freecam_bind_down then
        Thirdperson_SideViewEnable = not Thirdperson_SideViewEnable
    end

    was_freecam_bind_down = is_freecam_bind_down
end)

local cwep = {
    weapon_pistol = true,
    weapon_357 = true,
    weapon_smg1 = true,
    weapon_ar2 = true,
    weapon_shotgun = true,
    weapon_crossbow = true,
    weapon_rpg = true,
    weapon_grenade = true,
}

-- Taunts where the feet are used
local LockTaunts = {
    ACT_GMOD_TAUNT_MUSCLE = true,
    ACT_GMOD_TAUNT_DANCE = true,
    ACT_GMOD_TAUNT_ROBOT = true,
    ACT_GMOD_TAUNT_PERSISTENCE = true,
    ACT_GMOD_TAUNT_LAUGH = true,
    ACT_GMOD_TAUNT_CHEER = true
}

function IsLockedByTaunting(ply)
    return ply:IsPlayingTaunt() and LockTaunts[ply:GetSequenceActivityName(ply:GetLayerSequence(5))]
end

-- Allow the client to change the third person side
CreateClientConVar("swamp_thirdperson_side", "0", false, true)

function UseThirdpersonSide()
    if not Thirdperson_SideViewEnable then return false end
    local ply = LocalPlayer()
    if ply:InVehicle() then return false end
    if IsLockedByTaunting(ply) then return false end
    if math.abs(Thirdperson_ViewYaw) > 1 then return false end
    if IsValid(ply:GetActiveWeapon()) then return ply:GetActiveWeapon().DrawCrosshair or cwep[ply:GetActiveWeapon():GetClass()] end

    return false
end

hook.Add("HUDShouldDraw", "HUDShouldDraw_HideCrosshair", function(name)
    if name == "CHudCrosshair" and (Thirdperson_Lerp > 0 and Thirdperson_LerpSide > 0 or math.abs(Thirdperson_ViewYaw) > 1) then return false end
end)

concommand.Add("swamp_freecam", function() end)
Thirdperson_SideViewEnable = false
Thirdperson_Lerp = 0
Thirdperson_SideLerp = 0
Thirdperson_ViewYaw = 0
Thirdperson_ViewPitch = 0

hook.Add("InputMouseApply", "InputMouseApply_ThirdPersonFreeze", function(cmd, x, y, ang)
    if Thirdperson_Lerp > 0 then
        local freecam_bind = input.LookupBinding("swamp_freecam")
        Thirdperson_FreeRotate = (freecam_bind and input.IsButtonDown(input.GetKeyCode(freecam_bind))) or (not input.LookupKeyBinding(MOUSE_MIDDLE) and input.IsButtonDown(MOUSE_MIDDLE))

        if freecam_bind == nil and Thirdperson_FreeRotate and not ThirdPerson_BindingHint then
            LocalPlayerNotify("Freely rotate your camera in third person with middle mouse, or by binding swamp_freecam to the key of your choice.")
            ThirdPerson_BindingHint = true
        end

        if IsLockedByTaunting(LocalPlayer()) then
            Thirdperson_FreeRotate = true
        end

        if Thirdperson_FreeRotate then
            Thirdperson_ViewYaw = (Thirdperson_ViewYaw or 0) - x / 44
            Thirdperson_ViewPitch = (Thirdperson_ViewPitch or 0) - y / 44
            Thirdperson_ViewYaw = math.NormalizeAngle(Thirdperson_ViewYaw)
            Thirdperson_ViewPitch = math.NormalizeAngle(Thirdperson_ViewPitch)
            cmd:SetMouseX(0)
            cmd:SetMouseY(0)

            return true
        end

        for i = 0, FrameTime() * 20 do
            Thirdperson_ViewYaw = Thirdperson_ViewYaw / 1.1
            Thirdperson_ViewPitch = Thirdperson_ViewPitch / 1.1
        end

        Thirdperson_ViewYaw = math.Round(Thirdperson_ViewYaw, 3)
    else
        Thirdperson_FreeRotate = nil
        Thirdperson_ViewYaw = 0
        Thirdperson_ViewPitch = 0
    end
end)

local col = NamedColor("FGColor")

hook.Add("HUDPaint", "HUDPaint_ThirdPersonCrosshair", function()
    if Thirdperson_Lerp > 0 and Thirdperson_LerpSide > 0 then
        local ply = LocalPlayer()
        local trace = ply:GetEyeTrace()
        local data2D = trace.HitPos:ToScreen() -- Gets the position of the entity on your screen
        local data2Do = trace.StartPos:ToScreen() -- Gets the position of the entity on your screen
        -- The position is not visible from our screen, don't draw and continue onto the next prop
        local wep = ply:GetActiveWeapon()

        if IsValid(wep) and data2D.visible then
            local x, y = data2D.x, data2D.y
            local ox, oy = data2Do.x, data2Do.y
            x = math.floor(x)
            y = math.floor(y)
            local ovr

            if IsValid(wep) and wep.DoDrawCrosshair then
                ovr = wep:DoDrawCrosshair(x, y)
            end

            if not ovr then
                surface.SetDrawColor(col)
                surface.DrawRect(x, y, 1, 1)
                surface.DrawRect(x + 10, y, 1, 1)
                surface.DrawRect(x - 10, y, 1, 1)
                surface.DrawRect(x, y + 8, 1, 1)
                surface.DrawRect(x, y - 8, 1, 1)
                surface.SetDrawColor(ColorAlpha(col, 7 * Thirdperson_Lerp))
            end
        end
    end
end)

hook.Add("ShouldDrawLocalPlayer", "ShouldDrawLocalPlayer_ThirdPerson", function(ply)
    if Thirdperson_Lerp and Thirdperson_Lerp > 0 then return true end
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
    Thirdperson_Lerp = math.Approach(Thirdperson_Lerp or 0, use_third_person and 1 or 0, FrameTime() * 8)
    Thirdperson_LerpSide = math.Approach(Thirdperson_LerpSide or 0, (use_third_person and UseThirdpersonSide()) and 1 or 0, FrameTime() * 8)

    -- Handle third person view
    if Thirdperson_Lerp > 0 then
        local distance = Thirdperson_Lerp * Lerp(Thirdperson_LerpSide, 100, 40)
        angles:RotateAroundAxis(Vector(0, 0, 1), (Thirdperson_ViewYaw or 0) * Thirdperson_Lerp)
        angles:RotateAroundAxis(angles:Right(), (Thirdperson_ViewPitch or 0) * Thirdperson_Lerp)
        local offset = angles:Forward() * distance
        local side = GetConVar("swamp_thirdperson_side"):GetBool() == true and -1 or 1
        offset = offset + angles:Right() * 20 * Thirdperson_LerpSide * side
        offset = offset + angles:Up() * 5 * Thirdperson_LerpSide

        local trace = {
            start = origin,
            endpos = origin - offset,
            mins = Vector(1, 1, 1) * -8,
            maxs = Vector(1, 1, 1) * 8,
            mask = MASK_SOLID_BRUSHONLY
        }

        trace = util.TraceHull(trace)

        if trace.Hit then
            view.origin = origin - (offset * (trace.Fraction))
        else
            view.origin = origin - (offset)
        end

        return view
    end

    local Vehicle = ply:GetVehicle()
    local Weapon = ply:GetActiveWeapon()
    if IsValid(Vehicle) then return GAMEMODE:CalcVehicleView(Vehicle, ply, view) end
    if drive.CalcView(ply, view) then return view end

    -- Give the active weapon a go at changing the viewmodel position
    if IsValid(Weapon) then
        local func = Weapon.GetViewModelPosition

        if func then
            view.vm_origin, view.vm_angles = func(Weapon, origin * 1, angles * 1) -- Note: *1 to copy the object so the child function can't edit it.
        end

        local func = Weapon.CalcView

        if func then
            view.origin, view.angles, view.fov = func(Weapon, ply, origin * 1, angles * 1, fov) -- Note: *1 to copy the object so the child function can't edit it.
        end
    end

    return view
end
