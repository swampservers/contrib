-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

SWEP.PrintName = "ASS WE CAN"

SWEP.Slot = 2

SWEP.ViewModel	= ""
SWEP.WorldModel = ""
SWEP.HoldType = "normal"

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
	self:ExtEmitSound("billyh/asswecan.ogg", {speech=1.25, shared=true})
end

function SWEP:SecondaryAttack()
	self:ExtEmitSound("billyh/endurethelash.ogg", {speech=2.1, shared=true})
end

function SWEP:OnRemove()
	if self.Owner and self.Owner:IsValid() then self:ExtEmitSound("billyh/spank.ogg", {shared=true, channel=CHAN_AUTO}) end
end
