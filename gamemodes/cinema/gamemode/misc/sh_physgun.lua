-- This file is subject to copyright - contact swampservers@gmail.com for more information.

-- Allow physgun pickup of players ONLY ... maybe add trash and some other stuff?... dont forget PROTECTION for this
function GM:PhysgunPickup(ply, ent)
    if ent:IsPlayer() and ent:Alive() and not ent:IsProtected() and not ply:IsProtected() and not ent:IsFrozen() and ent:GetMoveType() ~= MOVETYPE_NOCLIP then
        if ent:IsJuggernaut() then return end

        return true
    end

    if ply:GetMoveType() == MOVETYPE_NOCLIP then return true end

    return false
end
