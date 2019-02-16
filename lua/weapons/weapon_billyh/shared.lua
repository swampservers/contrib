SWEP.PrintName = "ASS WE CAN"

SWEP.Slot = 2

SWEP.ViewModel	= ""
SWEP.WorldModel = ""

function SWEP:PrimaryAttack()
	self:ExtEmitSound("billyh/asswecan.ogg", {speech=1.25, {shared=true}})
end

function SWEP:SecondaryAttack()
	self:ExtEmitSound("billyh/endurethelash.ogg", {speech=2.1, {shared=true}})
end

function SWEP:OnRemove()
	if CLIENT then
		if self.Owner and self.Owner:IsValid() then sound.Play( "billyh/spank.ogg", self.Owner:GetPos(), 90, 100, 1) end
	end
end