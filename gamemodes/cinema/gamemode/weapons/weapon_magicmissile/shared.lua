-- This file is subject to copyright - contact swampservers@gmail.com for more information.
if SERVER then
    function SWEP:Deploy()
        self.Owner:DrawViewModel(false)
    end

    SWEP.HoldType = "magic"
end

SWEP.PrintName = "Magic Missile"
SWEP.Slot = 1
SWEP.WorldModel = ""

function SWEP:PrimaryAttack()
    if SERVER then
        self:DoPrimaryAttack()
    end
end

function SWEP:SecondaryAttack()
    self:ExtEmitSound("magicmissile.wav", {
        speech = 0.9,
        shared = true
    })
end
