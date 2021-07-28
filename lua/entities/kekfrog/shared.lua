-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
ENT.Type = "anim"
DEFINE_BASECLASS("base_gmodentity")
ENT.Model = Model("models/swamponions/kekfrog.mdl")

function ENT:Initialize()
    -- if SERVER then 
    --     local tr = util.TraceLine( {
    --         start=self:GetPos(),
    --         endpos = self:GetPos()-self:GetAngles():Up()*100,
    --         mask = MASK_NPCWORLDSTATIC
    --     })
    --     if tr.Hit then self:SetPos(tr.HitPos + self:GetAngles():Up()*4 ) end
    -- end

    self:SetModel(self.Model)
    self:SetModelScale(0.15)
    self:PhysicsInitBox(Vector(-1,-1,-1)*10,Vector(1,1,1)*10)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    -- self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:DrawShadow(false)
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        -- phys:EnableMotion(false)
    end

    if SERVER then
        self:SetTrigger(true)
        self:SetUseType(SIMPLE_USE)
        self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
    end
end
