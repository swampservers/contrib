-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

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

function SWEP:Reload()
	if (self.SqueeReloadCooldown or 0) > CurTime() then return end
	self.SqueeReloadCooldown = CurTime() + 0.7
	self:ExtEmitSound("mowsquee.wav", {shared=true})
end
