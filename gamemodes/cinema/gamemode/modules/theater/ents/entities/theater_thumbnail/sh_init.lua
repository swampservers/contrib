-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Model = Model( "models/sunabouzu/thumbnail_case.mdl" )

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "TheaterName" )
	self:NetworkVar( "String", 1, "Title" )
	self:NetworkVar( "String", 2, "Thumbnail" )
	self:NetworkVar( "String", 3, "Service" )

	if SERVER then
		self:SetTitle('NoVideoPlaying')
		self:SetTheaterName('Invalid')
		self:SetThumbnail('')
		self:SetService('')
	end
end

function ENT:OnRemove()

	if CLIENT and ValidPanel(self.HTML) then
		self.HTML:Remove()
	end

end

function ENT:UpdateTransmitState()
    return TRANSMIT_PVS
end
