-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Dodgeball"

-- models/props_lab/harddrive02.mdl
-- models/props_lab/reciever01d.mdl
function ENT:Initialize()
    self:SetModel("models/pyroteknik/dodgeball.mdl") --"models/hunter/misc/sphere075x075.mdl")
    self:SetMaterial("hunter/myplastic")
    self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self:SetColor(Color(255, 0, 255, 80))
    -- self:PhysicsInit(SOLID_VPHYSICS)
    -- self:SetMoveType(MOVETYPE_VPHYSICS)
    -- self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInitSphere(30, "popcan")
    local phys = self:GetPhysicsObject()
    phys:SetMass(80)
    phys:Wake()
end

function ENT:Use(activator, caller)
end

function ENT:Draw()
    self:DrawModel()
end
