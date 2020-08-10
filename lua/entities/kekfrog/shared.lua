ENT.Type = "anim"
DEFINE_BASECLASS("base_gmodentity")
ENT.Model = Model("models/swamponions/kekfrog.mdl")
ENT.Material = Material("models/swamponions/kekfrog_gold")

function ENT:Initialize()  
    self:SetModel(self.Model)
    self:SetModelScale(0.1)

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
