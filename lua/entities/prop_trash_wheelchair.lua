
AddCSLuaFile()
DEFINE_BASECLASS( "prop_trash" )

function ENT:Initialize()
	self:SetModel("models/props_wasteland/controlroom_chair001a.mdl")
	BaseClass.Initialize( self, true )

	if SERVER then
		SetupWheelchairProp(self)
	end
end

function ENT:OnRemove()
	if SERVER then
		self.BackWheel:Remove()
		self.FrontWheel:Remove()
	end
end

function ENT:CanTape(userid)
	return false
end