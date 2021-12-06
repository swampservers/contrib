-- This file is subject to copyright - contact swampservers@gmail.com for more information.

if CLIENT then
    function GM:CreateMove(cmd)
        local p = LocalPlayer()
        -- in cl_calcview.lua
        if self.TauntCam:CreateMove(cmd, p, p:IsPlayingTaunt()) then return true end
    end
end

function GM:SetupMove(ply, mv, cmd)
    local w = ply:GetActiveWeapon()
    if IsValid(w) and w.SetupMove and not ply:InVehicle() then return w:SetupMove(ply, mv, cmd) end    
end

function GM:Move(ply, mv)
    local w = ply:GetActiveWeapon()
    if IsValid(w) and w.Move and not ply:InVehicle() then return w:Move(ply, mv) end
end

function GM:FinishMove(ply, mv)
    
end