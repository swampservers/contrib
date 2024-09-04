-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("weapon_swamp_base")
SWEP.HoldType = "magic"
SWEP.PrintName = "Magic Missile"
SWEP.Slot = 1
SWEP.WorldModel = ""

function SWEP:ShouldDrawViewModel()
    return false
end

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
