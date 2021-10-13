-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Type = "anim"
DEFINE_BASECLASS("base_gmodentity")
ENT.Model = Model("models/items/boxmrounds.mdl")
ENT.RenderGroup = RENDERGROUP_BOTH


function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "Patriots" )

end

-- models/items/boxmrounds.mdl
-- models/illusion/eftcontainers/magbox.mdl


