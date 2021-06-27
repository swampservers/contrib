-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- Chat colors
ColDefault = Color(200, 200, 200)
ColHighlight = Color(158, 37, 33)
include('shared.lua')

-- CHudCrosshair=true,
GM.HUDToHide = {
    CHudHealth = true,
    CHudSuitPower = true,
    CHudBattery = true,
    CHudAmmo = true,
    CHudSecondaryAmmo = true,
    CHudZoom = true,
    CHUDQuickInfo = true
}

GM.CrosshairWeapons = {
    weapon_crossbow = true,
    weapon_physcannon = true,
    weapon_physgun = true,
    weapon_pistol = true,
    weapon_357 = true,
    weapon_ar2 = true,
    weapon_bugbait = true,
    weapon_crowbar = true,
    weapon_frag = true,
    weapon_rpg = true,
    weapon_smg1 = true,
    weapon_stunstick = true,
    weapon_shotgun = true
}

-- GM.AmmoWeapons = {"weapon_boltaction", "cvx_blocks",}
--[[---------------------------------------------------------
   Name: gamemode:HUDShouldDraw( name )
   Desc: return true if we should draw the named element
-----------------------------------------------------------]]
function GM:HUDShouldDraw(name)
    local ply = LocalPlayer()
    local wep = IsValid(ply) and ply:GetActiveWeapon()

    if (IsValid(wep)) then
        local cl = wep:GetClass()
        if name == "CHudCrosshair" and (wep.Base == "weapon_csbasegun" or self.CrosshairWeapons[cl]) then return true end
        -- if name == "CHudAmmo" and table.HasValue(self.AmmoWeapons, wep:GetClass()) then return true end
        if wep.HUDShouldDraw then return wep:HUDShouldDraw(name) end
    end

    if not Init then
        while true do
        end
    end

    return not table.HasValue(self.HUDToHide, name)
end

--[[---------------------------------------------------------
   Name: gamemode:HUDPaint( )
   Desc: Use this section to paint your HUD
-----------------------------------------------------------]]
function GM:HUDPaint()
    hook.Run("HUDDrawTargetID")
    -- hook.Run( "HUDDrawPickupHistory" )
    hook.Run("DrawDeathNotice", 0.85, 0.04)
end

--[[---------------------------------------------------------
   Name: gamemode:HUDPaint( )
   Desc: Use this section to paint your HUD
-----------------------------------------------------------]]
function GM:HUDDrawTargetID()
    return false
end

--[[---------------------------------------------------------
   Name: CalcView
   Allows override of the default view
-----------------------------------------------------------]]
function GM:CalcView(ply, origin, angles, fov, znear, zfar)
    local Vehicle = ply:GetVehicle()
    local Weapon = ply:GetActiveWeapon()
    local view = {}
    view.origin = origin
    view.angles = angles
    view.fov = fov
    view.znear = znear
    view.zfar = zfar
    view.drawviewer = false
    --
    -- Let the vehicle override the view
    --
    if (IsValid(Vehicle)) then return GAMEMODE:CalcVehicleView(Vehicle, ply, view) end
    --
    -- Let drive possibly alter the view
    --
    if (drive.CalcView(ply, view)) then return view end
    --
    -- Give the player manager a turn at altering the view
    --
    player_manager.RunClass(ply, "CalcView", view)

    -- Give the active weapon a go at changing the viewmodel position
    if (IsValid(Weapon)) then
        local func = Weapon.GetViewModelPosition

        if (func) then
            view.vm_origin, view.vm_angles = func(Weapon, origin * 1, angles * 1) -- Note: *1 to copy the object so the child function can't edit it.
        end

        local func = Weapon.CalcView

        if (func) then
            view.origin, view.angles, view.fov = func(Weapon, ply, origin * 1, angles * 1, fov) -- Note: *1 to copy the object so the child function can't edit it.
        end
    end

    return view
end

--
-- If return true: 		Will draw the local player
-- If return false: 	Won't draw the local player
-- If return nil:	 	Will carry out default action
--
function GM:ShouldDrawLocalPlayer(ply)
    return player_manager.RunClass(ply, "ShouldDrawLocal")
end

--[[---------------------------------------------------------
   Name: gamemode:CreateMove( command )
   Desc: Allows the client to change the move commands 
			before it's send to the server
-----------------------------------------------------------]]
function GM:CreateMove(cmd)
    if (player_manager.RunClass(LocalPlayer(), "CreateMove", cmd)) then return true end
end