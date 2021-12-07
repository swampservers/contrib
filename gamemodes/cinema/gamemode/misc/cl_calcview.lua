-- This file is subject to copyright - contact swampservers@gmail.com for more information.

GM.TauntCam = TauntCamera()

function UseThirdperson()
    local wc = IsValid(Me) and IsValid(Me:GetActiveWeapon()) and Me:GetActiveWeapon():GetClass()

    return THIRDPERSON or Me:GetActiveWeapon().AlwaysThirdPerson or wc == "weapon_fists" or Me:HasWeapon("weapon_goohulk") or (wc == "weapon_garfield" and IsValid(Me) and not Me:InVehicle())
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

    if UseThirdperson() then
        local trace = {
            start = origin,
            endpos = origin - (angles:Forward() * 100),
            mask = MASK_SOLID_BRUSHONLY
        }

        trace = util.TraceLine(trace)
        local view = {}

        if trace.Hit then
            view.origin = origin - (angles:Forward() * ((100 * trace.Fraction) - 5))
        else
            view.origin = origin - (angles:Forward() * 100)
        end

        view.angles = angles
        view.fov = fov

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

function GM:ShouldDrawLocalPlayer(ply)
    return UseThirdperson() or self.TauntCam:ShouldDrawLocalPlayer(ply, ply:IsPlayingTaunt())
end

