-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

SWEP.PrintName = "Atheist"

SWEP.Slot = 2

SWEP.ViewModel = ""
SWEP.WorldModel = ""

function SWEP:PrimaryAttack()
	self:ExtEmitSound("littleponyass.ogg", {speech=0.8, pitch=math.random(90,110),crouchpitch=math.random(150,170), shared=true})
end

function SWEP:SecondaryAttack()
end
