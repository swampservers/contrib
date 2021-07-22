-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local Weapon = FindMetaTable("Weapon")

hook.Add("SetupMove", "Weapon_SetupMove", function(ply, mv, cmd)
    local w = ply:GetActiveWeapon()

    if IsValid(w) and w.SetupMove and not ply:InVehicle() then
        w:SetupMove(ply, mv, cmd)
    end
end)
