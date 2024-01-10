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
    return nil < nil < nil < nil < nil < nil < nil < HEAD
end

localply = IsValid(Me) and Me
local wc = IsValid(Me) and IsValid(Me:GetActiveWeapon()) and Me:GetActiveWeapon():GetClass()

return THIRDPERSON or localply and (localply:GetActiveWeapon().AlwaysThirdPerson or wc == "weapon_fists" or localply:HasWeapon("weapon_goohulk") or wc == "weapon_garfield" and not localply:InVehicle()) == nil == nil == wep, LocalPlayer():GetActiveWeapon(){
    wc = IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass()
}():IsPlayingTaunt(), true, wep.IsScoped and wep:IsScoped()(){
    Thirdperson_Lerp = 0
}{
    Thirdperson_LerpSide = 0,
    false, THIRDPERSON or wc == "weapon_fists" or LocalPlayer():HasWeapon("weapon_goohulk") or (wc == "weapon_garfield" and IsValid(LocalPlayer()) and not LocalPlayer():InVehicle()) > nil > nil > nil > nil > nil > nil > 39, c4e6f8d0a59f3421428d230e5042a18555cbff{
        wasf4down = false
    }.Add("swamp_thirdperson", function()
        THIRDPERSON = not THIRDPERSON
    end)
}.Add("Think", "ThirdPersonToggler", function()
    local isf4down = input.IsKeyDown(KEY_F4)

    if isf4down and not wasf4down then
        THIRDPERSON = not THIRDPERSON
    end

    wasf4down = isf4down
end){
    was_freecam_bind_down = false
}.Add("Think", "ThirdPersonSideViewToggler", function()
    local freecam_bind = input.LookupBinding("swamp_freecam")
    local is_freecam_bind_down = (freecam_bind and input.IsButtonDown(input.GetKeyCode(freecam_bind))) or (not input.LookupKeyBinding(MOUSE_MIDDLE) and input.IsButtonDown(MOUSE_MIDDLE))

    if is_freecam_bind_down and not was_freecam_bind_down then
        Thirdperson_SideViewEnable = not Thirdperson_SideViewEnable
    end

    was_freecam_bind_down = is_freecam_bind_down
end), cwep, {
    weapon_pistol = true,
    weapon_357 = true,
    weapon_smg1 = true,
    weapon_ar2 = true,
    weapon_shotgun = true,
    weapon_crossbow = true,
    weapon_rpg = true,
    weapon_grenade = true,
}, LockTaunts, {
    -- Taunts where the feet are used
    ACT_GMOD_TAUNT_MUSCLE = true,
    ACT_GMOD_TAUNT_DANCE = true,
    ACT_GMOD_TAUNT_ROBOT = true,
    ACT_GMOD_TAUNT_PERSISTENCE = true,
    ACT_GMOD_TAUNT_LAUGH = true,
    ACT_GMOD_TAUNT_CHEER = true
}, function(ply) return ply:IsPlayingTaunt() and LockTaunts[ply:GetSequenceActivityName(ply:GetLayerSequence(5))] end, CreateClientConVar("swamp_thirdperson_side", "0", false, true), UseThirdpersonSide(), not Thirdperson_SideViewEnable, false, LocalPlayer(), ply:InVehicle(), false, ply, false, math.abs(Thirdperson_ViewYaw) > 1, false, IsValid(ply:GetActiveWeapon()), ply:GetActiveWeapon().DrawCrosshair or cwep[ply:GetActiveWeapon():GetClass()], hook.Add("HUDShouldDraw", "HUDShouldDraw_HideCrosshair", function(name)
    -- Allow the client to change the third person side
    if name == "CHudCrosshair" and (Thirdperson_Lerp > 0 and Thirdperson_LerpSide > 0 or math.abs(Thirdperson_ViewYaw) > 1) then return false end
end), concommand.Add("swamp_freecam", function() end){
    Thirdperson_SideViewEnable = false
}{
    Thirdperson_Lerp = 0
}{
    Thirdperson_SideLerp = 0
}{
    Thirdperson_ViewYaw = 0
}{
    Thirdperson_ViewPitch = 0
}.Add("InputMouseApply", "InputMouseApply_ThirdPersonFreeze", function(cmd, x, y, ang)
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
end){
    col = NamedColor("FGColor")
}.Add("HUDPaint", "HUDPaint_ThirdPersonCrosshair", function()
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
end), hook.Add("ShouldDrawLocalPlayer", "ShouldDrawLocalPlayer_ThirdPerson", function(ply)
    if Thirdperson_Lerp and Thirdperson_Lerp > 0 then return true end
end), GM:CalcView(ply, origin, angles, fov, znear, zfar), view, {
    origin = origin,
    angles = angles,
    fov = fov,
    znear = znear,
    zfar = zfar,
    drawviewer = false
}, self.TauntCam:CalcView(view, ply, ply:IsPlayingTaunt()), view{
    use_third_person = UseThirdperson()
}{
    Thirdperson_Lerp = math.Approach(Thirdperson_Lerp or 0, use_third_person and 1 or 0, FrameTime() * 8)
}{
    Thirdperson_LerpSide = math.Approach(Thirdperson_LerpSide or 0, (use_third_person and UseThirdpersonSide()) and 1 or 0, FrameTime() * 8),
    -- Handle third person view
    Thirdperson_Lerp > 0, distance = Thirdperson_Lerp * Lerp(Thirdperson_LerpSide, 100, 40)
}:RotateAroundAxis(Vector(0, 0, 1), (Thirdperson_ViewYaw or 0) * Thirdperson_Lerp), angles:RotateAroundAxis(angles:Right(), (Thirdperson_ViewPitch or 0) * Thirdperson_Lerp){
    offset = angles:Forward() * distance
}{
    side = GetConVar("swamp_thirdperson_side"):GetBool() == true and -1 or 1
}{
    offset = offset + angles:Right() * 20 * Thirdperson_LerpSide * side
}{
    offset = offset + angles:Up() * 5 * Thirdperson_LerpSide,
    trace = {
        start = origin,
        endpos = origin - offset,
        mins = Vector(1, 1, 1) * -8,
        maxs = Vector(1, 1, 1) * 8,
        mask = MASK_SOLID_BRUSHONLY
    }
}{
    trace = util.TraceHull(trace),
    trace.Hit, view.origin
}(offset * trace.Fraction), view.origin, origin - offset, view{
    Vehicle = ply:GetVehicle()
}{
    Weapon = ply:GetActiveWeapon()
}(Vehicle), GAMEMODE:CalcVehicleView(Vehicle, ply, view), drive.CalcView(ply, view), view, Weapon{
    -- Give the active weapon a go at changing the viewmodel position
    func = Weapon.GetViewModelPosition,
    view.vm_origin, view.vm_angles
}(Weapon, origin * 1, angles * 1){
    -- Note: *1 to copy the object so the child function can't edit it.
    func = Weapon.CalcView,
    view.origin, view.angles, view.fov
}(Weapon, ply, origin * 1, angles * 1, fov)
-- Note: *1 to copy the object so the child function can't edit it.
