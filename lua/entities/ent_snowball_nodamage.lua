-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Type = "anim"
DEFINE_BASECLASS("base_gmodentity")
ENT.Model = Model("models/weapons/w_snowball_thrown.mdl")
local hitsnd = Sound("weapons/weapon_snowball/snowhit.ogg")

function ENT:Initialize()
    local plycol = self:GetOwner():GetNWVector("SnowballColor", Vector(1, 1, 1)):ToColor()
    self.Entity:SetModel(self.Model)
    self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
    self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
    self.Entity:SetSolid(SOLID_VPHYSICS)
    self.Entity:PhysicsInit(SOLID_VPHYSICS)
    self:PhysicsInitSphere(3, "ice")
    if CLIENT then return end
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:Wake()
        phys:EnableGravity(true)
        phys:SetBuoyancyRatio(0) --make the snowball pass straight through water
    end

    self:SetColor(plycol)
    self.Trail = util.SpriteTrail(self.Entity, 0, plycol, false, 4, 0, 0.8, 1 / (15 + 0) * 0.5, "trails/smoke.vmt") --color trail
    SafeRemoveEntityDelayed(self, 10) --remove the entity automatically in a case where it gets stuck
end

function ENT:Think()
end

function ENT:Draw()
    self.Entity:DrawModel()
end

function ENT:PhysicsCollide(data)
    local pos = self.Entity:GetPos()
    local effectdata = EffectData()
    local fwd = self:GetOwner():GetAimVector()

    --push players around a small amount
    if data.HitEntity:IsPlayer() then
        data.HitEntity:SetVelocity(Vector(fwd * 100))
        local ply = data.HitEntity

        if (self.Hardness and self.Hardness > 0) then
            self:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random(1, 4) .. ".wav")
            local d = DamageInfo()
            d:SetDamage(self.Hardness * 10)
            d:SetAttacker(self:GetOwner())
            d:SetInflictor(self)
            d:SetDamageForce(self:GetVelocity())
            d:SetDamageType(DMG_CLUB)
            ply:TakeDamageInfo(d)
        end
    end

    local p1 = data.HitPos + (data.HitNormal * 2)
    local p2 = data.HitPos - (data.HitNormal * 2)
    util.Decal("Splash.Large", p1, p2)
    effectdata:SetOrigin(pos)
    effectdata:SetScale(1.5)
    self:EmitSound(self.Hardness > 5 and "physics/glass/glass_impact_bullet" .. math.random(1, 4) .. ".wav" or hitsnd)
    util.Effect("WheelDust", effectdata)
    util.Effect("GlassImpact", effectdata)
    SafeRemoveEntityDelayed(self, 0.05)
end