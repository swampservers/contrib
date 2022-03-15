-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include("shared.lua")
SWEP.Instructions = "Primary: Throw hard\nSecondary: Throw soft\nReload: Pass"
SWEP.DrawAmmo = false
SWEP.ViewModelFOV = 85

--NOMINIFY
function SWEP:ThrownBallExists()
    if self:GetThrowState() < 2 then return false end
    if IsValid(self:GetThrownBall()) then return true end
    if IsValid(self.fakethrownball) then return true end
    local ply = self:GetOwner()

    if IsValid(ply) then
        local lookent = ply:GetEyeTrace().Entity

        if IsValid(lookent) and lookent:GetClass() == "dodgeball" and lookent:GetPos():Distance(ply:EyePos()) < 128 then
            self.fakethrownball = lookent

            return true
        end
    end

    return false
end

function SWEP:DrawWorldModel()
    if self:ThrownBallExists() then return end
    render.SetColorModulation(1, 0, 0)
    self:DrawModel()
    render.SetColorModulation(1, 1, 1)
end

function SWEP:PreDrawViewModel(vm, wp, ply)
    render.SetColorModulation(1, 0, 0)
end

function SWEP:GetViewModelPosition(pos, ang)
    if self:ThrownBallExists() then return Vector(0, 0, -10000), ang end
    local targetpos = Vector(0, 25, -23)
    local state = self:GetThrowState()
    local power = self:GetThrowPower()

    if state == 1 then
        targetpos = power >= 600 and Vector(15, 30, 23) or Vector(0, 20, -23)
    end

    if state == 2 then
        targetpos = power >= 600 and Vector(0, 60, 23) or Vector(0, 60, -23)
    end

    self.PosLerp = LerpVector(FrameTime() * 2, self.PosLerp or targetpos, targetpos)
    local localpos = self.PosLerp
    pos = pos + ang:Right() * localpos.x
    pos = pos + ang:Forward() * localpos.y
    pos = pos + ang:Up() * localpos.z

    return pos, ang
end

function SWEP:PostDrawViewModel(vm, wp, ply)
    render.SetColorModulation(1, 1, 1)
end
