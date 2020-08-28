-- This file is subject to copyright - contact swampservers@gmail.com for more information.

ENT.Type = "anim"
DEFINE_BASECLASS("base_gmodentity")
ENT.Model = Model("models/swamponions/neko.mdl")
ENT.Meow = Sound("mow.ogg")
ENT.AutomaticFrameAdvance = true

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_NONE)

    self:DrawShadow(false)

    self:PhysicsInitStatic(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end

    if SERVER then self:SetUseType(SIMPLE_USE) end
end

function ENT:Think() --for animations
    self:NextThink(CurTime())
    return true
end
