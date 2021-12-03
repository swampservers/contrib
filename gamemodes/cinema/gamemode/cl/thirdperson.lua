﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
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

function UseThirdperson()
    local wc = IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass()

    return THIRDPERSON or LocalPlayer():GetActiveWeapon().AlwaysThirdPerson or wc == "weapon_fists" or LocalPlayer():HasWeapon("weapon_goohulk") or (wc == "weapon_garfield" and IsValid(LocalPlayer()) and not LocalPlayer():InVehicle())
end

hook.Add("CalcView", "MyCalcViethridpersonw", function(ply, pos, angles, fov)
    if ply:IsPlayingTaunt() then return end

    if UseThirdperson() then
        local trace = {
            start = pos,
            endpos = pos - (angles:Forward() * 100),
            mask = MASK_SOLID_BRUSHONLY
        }

        trace = util.TraceLine(trace)
        local view = {}

        if trace.Hit then
            view.origin = pos - (angles:Forward() * ((100 * trace.Fraction) - 5))
        else
            view.origin = pos - (angles:Forward() * 100)
        end

        view.angles = angles
        view.fov = fov

        return view
    end
end)

hook.Add("ShouldDrawLocalPlayer", "MyShouldDrawLocalPlthridpersonayer", function(ply)
    if UseThirdperson() then return true end
end)
