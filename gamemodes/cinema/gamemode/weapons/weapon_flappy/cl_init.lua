-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include("shared.lua")
SWEP.SwayScale = 0

function SWEP:GetViewModelPosition(pos, ang)
    local tipdelay = SysTime() - (self.TipTime or 0)
    local tipness = 1 - math.min(tipdelay * 6, 1)
    pos = pos + ang:Up() * 5.5
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), tipness * -10)

    return pos, ang
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if not self.UseFirstPersonTrail then
        self.CalcAbsolutePosition = nil
    end

    if IsValid(ply) then
        local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_Head1"
        local bon = ply:LookupBone(bn) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = ply:GetBonePosition(bon)

        if bp then
            opos = bp
        end

        if ba then
            oang = ba
        end

        if ply:IsPony() then
            oang:RotateAroundAxis(oang:Forward(), 90)
            oang:RotateAroundAxis(oang:Up(), -90)
            opos = opos + (oang:Up() * 13)
        else
            oang:RotateAroundAxis(oang:Right(), -90)
            oang:RotateAroundAxis(oang:Up(), 180)
            opos = opos + (oang:Right() * -0.5) + (oang:Up() * 6.5)
        end

        self:SetupBones()
        local mrt = self:GetBoneMatrix(0)

        if mrt then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            self:SetBoneMatrix(0, mrt)
        end

        -- This makes the trail appear where we want it
        if not self.UseFirstPersonTrail then
            self.CalcAbsolutePosition = function(ent, pos, ang) return opos + oang:Right() * 3, ang end
        end
    end

    self:DrawModel()
end

function SWEP:Think()
    self.UseFirstPersonTrail = self.Owner == Me and not hook.Run("ShouldDrawLocalPlayer", Me)

    if self.UseFirstPersonTrail then
        local ep = Me:EyePos() + Vector(0, 0, 3 + math.sin(SysTime() * 20)) - Me:EyeAngles():Forward() * 10
        self.CalcAbsolutePosition = function(ent, pos, ang) return ep, oang end
    end
end
