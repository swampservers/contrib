-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "KEK Frog Idol"
SWEP.Purpose = "An ancient artifact of unknown origin. Very likely to fetch a reasonable sum of money."
SWEP.Spawnable = true
SWEP.Slot = 0
SWEP.ViewModel = "models/swamponions/kekfrog.mdl"
SWEP.WorldModel = "models/swamponions/kekfrog.mdl"
SWEP.HoldType = "slam"
SWEP.Material = Material("models/swamponions/kekfrog_gold")
SWEP.IdolPrize = 100000 --prize the player gets in points for reaching the surface in time
SWEP.IdolTimer = 100 --seconds the player should have to reach the surface
SWEP.DrawAmmo = false

function SWEP:PrimaryAttack()
    if SERVER then
        self:Remove()
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
    self:SetHoldType(self.HoldType)
end

function SWEP:Holster()
    return true
end
