-- This file is subject to copyright - contact swampservers@gmail.com for more information.

SWEP.PrintName = "Squee"

SWEP.Slot = 2

SWEP.ViewModel = ""
SWEP.WorldModel = ""

function SWEP:PrimaryAttack()
	self:ExtEmitSound("squee.wav", {shared=true})
end

function SWEP:SecondaryAttack()
	self:ExtEmitSound("boop.wav", {shared=true})
end
