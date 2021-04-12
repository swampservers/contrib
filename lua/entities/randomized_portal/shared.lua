-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
ENT.Type = "anim"
DEFINE_BASECLASS("base_gmodentity")
ENT.Model = Model("models/swamponions/teleportal.mdl")

-- todo: some sort of color lerp, maybe portal particles when the player teleports
function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInitBox(Vector(-8, -20, -42), Vector(8, 20, 42))
    self:SetMoveType(MOVETYPE_NONE)
    self:DrawShadow(false)
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:EnableMotion(false)
    end

    self:SetMaterial("tools/toolswhite")

    if SERVER then
        self:SV_Initialize()
    end
end