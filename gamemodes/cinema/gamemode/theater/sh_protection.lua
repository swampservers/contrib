-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA


--- If we are "protected" from this attacker by theater protection. `att` doesn't need to be passed, it's only used to let theater owners override protection and prevent killing out of a protected area.
function Entity:IsProtected(att)
    if HumanTeamName ~= nil then return false end
    local loc, name = self:GetLocation(), self:GetLocationName()
    if name == "Movie Theater" and (self:GetPos().y > 1400 or self:GetPos().z > 150) then return true end

    if name == "Golf" then
        if self:IsPlayer() then
            local w = self:GetActiveWeapon()

            if IsValid(w) and w:GetClass() == "weapon_golfclub" then
                if IsValid(w:GetBall()) then return true end
            end
        end
    end

    local pt = protectedTheaterTable and protectedTheaterTable[loc]

    if pt ~= nil and pt["time"] > 1 then
        --if theater is protected and the attacker is the theater owner, then this player is not safe from them.
        local owner = self:GetTheater() and self:GetTheater():GetOwner()
        if IsValid(att) and att:IsPlayer() and self:IsPlayer() and self:InTheater() and owner == att then return false end

        return true
    end

    if self:IsPlayer() then
        if IsValid(self:GetVehicle()) then
            if self:GetVehicle():GetNWBool("IsChessSeat", false) then
                local e = self:GetVehicle():GetNWEntity("ChessBoard", nil)
                if IsValid(e) and e:GetPlaying() then return true end
            end

            local v = self:GetVehicle()
            if (v.SeatData ~= nil) and (v.SeatData.Ent ~= nil) and IsValid(v.SeatData.Ent) and v.SeatData.Ent:GetName() == "rocketseat" then return true end
        end
    end

    if IsValid(att) and att:IsProtected() and att:GetLocation() ~= self:GetLocation() then return true end

    return false
end
