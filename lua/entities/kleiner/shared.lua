-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Based" )
	self:NetworkVar( "Float", 0, "Talking" )
	self:NetworkVar( "Entity", 0, "Target" )
end

function ENT:GetName() return "Kleiner" end
function ENT:Alive() return true end
function ENT:InVehicle()
return false
end

list.Set( "NPC", "Kleiner", { 
	Name = "Kleiner",
	Class = "kleiner",
	Category = "Nextbot"
})