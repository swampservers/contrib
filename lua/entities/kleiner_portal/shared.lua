-- This file is subject to copyright - contact swampservers@gmail.com for more information.

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

KLEINERPORTALPOS = Vector(5980,2880,-200)

-- todo: some sort of color lerp, maybe portal particles when the player teleports

function ENT:Initialize()
    --self:SetModel(self.Model)
    self:PhysicsInitBox(Vector(-8, -20, -42), Vector(8, 20, 42))
    self:SetMoveType(MOVETYPE_NONE)

    self:DrawShadow(false)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end
    
    if CLIENT then self:SetRenderBounds(-Vector(100,100,100),Vector(100,100,100)) end
    if SERVER then self:SV_Initialize() end
end
