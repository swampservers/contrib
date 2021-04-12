-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Type = "anim"
DEFINE_BASECLASS("base_gmodentity")
ENT.Model = Model("models/golf rack/golf rack.mdl")

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_NONE)
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:DrawShadow(false)
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:EnableMotion(false)
    end

    if SERVER then
        self:SetTrigger(true)
        self:SetUseType(SIMPLE_USE)
    end
end