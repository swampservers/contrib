-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- Encyclopedia SWEP by swamponions - STEAM_0:0:38422842
AddCSLuaFile()
SWEP.PrintName = "Nintendo Switch"
SWEP.Author = "swamponions"
--They actually do. That's the joke.
SWEP.Purpose = "Try to contain your excitement!"
SWEP.Slot = 1
SWEP.SlotPos = 99
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModelFOV = 85
SWEP.ViewModel = Model("models/swamponions/switchbox.mdl")
SWEP.WorldModel = Model("models/swamponions/switchbox.mdl")
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Damage = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.AutoIconAngle = Angle(90, 0, 0)

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if (IsValid(ply)) then
        local bn = "ValveBiped.Bip01_R_Hand"
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

        oang:RotateAroundAxis(oang:Forward(), 20)
        oang:RotateAroundAxis(oang:Up(), 90)
        oang:RotateAroundAxis(oang:Right(), 90)
        opos = opos + oang:Right() * 2
        opos = opos + oang:Forward() * -3
        opos = opos + oang:Up() * 10.5
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

function SWEP:Deploy()
    if IsValid(self.Owner) then
        self.Owner:SetFlexScale(1.9)
    end
end

function SWEP:Holster()
    if IsValid(self.Owner) then
        self.Owner:SetFlexScale(1)
    end

    return true
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 6
    pos = pos + ang:Up() * -12
    pos = pos + ang:Forward() * 20
    ang:RotateAroundAxis(ang:Forward(), -3)
    ang:RotateAroundAxis(ang:Up(), -105)
    ang:RotateAroundAxis(ang:Right(), -90)
    pos = pos + ang:Forward() * 0.2

    return pos, ang
end

function SWEP:Initialize()
    self:SetHoldType("slam")
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end
