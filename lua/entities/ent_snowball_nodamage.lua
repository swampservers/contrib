-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

AddCSLuaFile()

ENT.Type = "anim"
DEFINE_BASECLASS("base_gmodentity")

ENT.Model = Model("models/weapons/w_snowball_thrown.mdl")

local hitsnd = Sound("weapons/weapon_snowball/snowhit.ogg")

function ENT:Initialize()
	local plycol = self.Owner:GetNWVector("SnowballColor", Vector(1, 1, 1)):ToColor()

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

	self.Trail = util.SpriteTrail(self.Entity, 0, plycol, false, 4, 0, 0.8, 1/(15+0)*0.5, "trails/smoke.vmt") --color trail
	SafeRemoveEntityDelayed(self, 10) --remove the entity automatically in a case where it gets stuck
end

function ENT:Think() end

function ENT:Draw()
	self.Entity:DrawModel()
end

function ENT:PhysicsCollide(data)
	local plycol = self.Owner:GetNWVector("SnowballColor", Vector(1, 1, 1)):ToColor()
	local pos = self.Entity:GetPos()
	local effectdata = EffectData()
	local fwd = self:GetOwner():GetAimVector()
	if data.HitEntity:IsPlayer() then --push players around a small amount
		data.HitEntity:SetVelocity(Vector(fwd * 100))
	end

	--local p1 = data.HitPos + (data.HitNormal * 2)
	--local p2 = data.HitPos - (data.HitNormal * 2)
	--util.Decal("Splash.Large", p1, p2)
	util.DecalEx("Splash.Large", nil, data.HitPos, data.HitNormal, plycol, 1, 1)

	effectdata:SetOrigin(pos)
	effectdata:SetScale(1.5)
	effectdata:SetColor(plycol)
	self:EmitSound(hitsnd)
	util.Effect("WheelDust", effectdata)
	util.Effect("GlassImpact", effectdata)
	SafeRemoveEntityDelayed(self, 0.05)
end
