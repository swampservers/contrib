-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include('shared.lua')

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()
    local canScale = self.canScale or 1.25
    self:SetModelScale(canScale, 0)
    self:SetSubMaterial()

    if IsValid(ply) then
        local modelStr = ply:GetModel():sub(1, 17)
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
            --pony position
            opos = opos + (oang:Forward() * 7.5) + (oang:Right() * -2.5) + (oang:Up() * -2.5)
            oang:RotateAroundAxis(oang:Right(), 0)
            oang:RotateAroundAxis(oang:Forward(), 5)
            oang:RotateAroundAxis(oang:Up(), -30)
            opos = opos + (oang:Up() * (2.3 + ((canScale - 1) * -10.25)))
        else
            if ply.monsterArmFullyUp then
                --head position
                opos = opos + (oang:Forward() * 2.5) + (oang:Right() * 5) + (oang:Up() * -.5)
                oang:RotateAroundAxis(oang:Forward(), 225)
                oang:RotateAroundAxis(oang:Right(), -30)
                oang:RotateAroundAxis(oang:Up(), 130)
                opos = opos + (oang:Up() * (canScale - 1) * -10.25)
            else
                --hand position
                oang:RotateAroundAxis(oang:Forward(), 110)
                oang:RotateAroundAxis(oang:Right(), 100)
                opos = opos + (oang:Forward() * 2) + (oang:Up() * -2.3) + (oang:Right() * -1)
                oang:RotateAroundAxis(oang:Forward(), 110)
                oang:RotateAroundAxis(oang:Up(), 20)
                opos = opos + (oang:Up() * (canScale - 1) * -10.25)
            end
        end

        self:SetupBones()
        local mrt = self:GetBoneMatrix(0)

        if mrt then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            self:SetBoneMatrix(0, mrt)
        end
    end

    self:DrawModel()
end

function SWEP:GetViewModelPosition(pos, ang)
    local vmpos1 = Vector(11, -.5, -3)
    local vmpos2 = Vector(14, -4.5, -8.5)
    local vmang1 = Vector(215, -95, 92)
    local vmang2 = Vector(200, -175, 175)

    if not LocalPlayer().monsterArmTime then
        LocalPlayer().monsterArmTime = 0
    end

    local lerp = math.Clamp((os.clock() - LocalPlayer().monsterArmTime) * 3, 0, 1)

    if LocalPlayer().monsterArm then
        lerp = 1 - lerp
    end

    local newpos = LerpVector(lerp, vmpos1, vmpos2)
    local newang = LerpVector(lerp, vmang1, vmang2)
    --I have a good reason for doing it like this
    newang = Angle(newang.x, newang.y, newang.z)
    pos, ang = LocalToWorld(newpos, newang, pos, ang)

    return pos, ang
end
