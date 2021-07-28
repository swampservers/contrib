-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include('shared.lua')

function SWEP:Initialize()
end

-- if self.Owner == LocalPlayer() then
--     self.Owner:ChatPrint(string.format('[red]You have %s seconds to reach the surface before this ancient artifact disappears. Good luck.', self.IdolTimer))
-- end
function SWEP:PreDrawViewModel(vm)
    vm:SetModelScale(0.1)
    render.MaterialOverride(self.Material)
end

function SWEP:PostDrawViewModel(vm)
    render.MaterialOverride()
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 17
    pos = pos + ang:Up() * -11
    pos = pos + ang:Forward() * 30
    ang:RotateAroundAxis(ang:Up(), -45)
    ang:RotateAroundAxis(ang:Forward(), 20)
    ang:RotateAroundAxis(ang:Right(), 0)

    return pos, ang
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if IsValid(ply) then
        local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
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
            opos = opos + oang:Forward() * 7
            opos = opos + oang:Up() * 2
            opos = opos + oang:Right() * -4
        else
            opos = opos + oang:Right() * 2
            opos = opos + oang:Forward() * 3
            opos = opos + oang:Up() * -1
        end

        oang:RotateAroundAxis(oang:Forward(), 180)
        oang:RotateAroundAxis(oang:Up(), -30)
        self:SetupBones()
        self:SetModelScale(0.1)
        self:DrawShadow(false)
        local mrt = self:GetBoneMatrix(0)

        if mrt then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            self:SetBoneMatrix(0, mrt)
        end
    end

    render.MaterialOverride(self.Material)
    self:DrawModel()
    render.MaterialOverride()
end
