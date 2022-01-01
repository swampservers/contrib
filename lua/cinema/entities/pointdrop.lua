-- This file is subject to copyright - contact swampservers@gmail.com for more information.
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Dodgeball"

-- models/props_lab/harddrive02.mdl
-- models/props_lab/reciever01d.mdl
function ENT:Initialize()
    self:SetModel("models/props_lab/reciever01d.mdl")
    self:SetColor(Color(200, 255, 150, 255))
    -- self:PhysicsInit(SOLID_VPHYSICS)
    -- self:SetMoveType(MOVETYPE_VPHYSICS)
    -- self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInitSphere(10, "rubber")
    local phys = self:GetPhysicsObject()
    phys:SetMass(30)
    phys:Wake()
end

function ENT:Use(activator, caller)
end

function ENT:Draw()
    self:DrawModel()
end
