-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Anonymous Mask"
SWEP.Slot = 2
SWEP.WorldModel = Model("models/v/maskhq.mdl")

function SWEP:PrimaryAttack()
    self:ExtEmitSound("anonymous/memeheads.wav", {
        speech = 1.8,
        shared = true
    })
end

function SWEP:SecondaryAttack()
    self:ExtEmitSound("anonymous/maymays.wav", {
        speech = 2.2,
        shared = true
    })
end
