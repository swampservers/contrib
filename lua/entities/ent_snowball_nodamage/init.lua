AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local hitsnd = Sound("weapons/weapon_snowball/snowhit.ogg")

function ENT:Initialize()
	self.Entity:SetModel(self.Model)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInitSphere(3, "ice")

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableGravity(true)
	end

	local plycol = self.Owner:GetNWVector("SnowballColor", Vector(1, 1, 1)):ToColor()

	self.Trail = util.SpriteTrail(self.Entity, 0, plycol, false, 15, 0, 0.8, 1/(15+0)*0.5, "trails/laser.vmt") --color trail
end

function ENT:PhysicsCollide(data)
	local pos = self.Entity:GetPos()
	local effectdata = EffectData()
	local fwd = self:GetOwner():GetAimVector()
	if data.HitEntity:IsPlayer() then --push players around a small amount
		data.HitEntity:SetVelocity(Vector(fwd * 100))
	end

	local p1 = data.HitPos + (data.HitNormal * 2)
	local p2 = data.HitPos - (data.HitNormal * 2)
	util.Decal("Splash.Large", p1, p2)

	effectdata:SetOrigin(pos)
	effectdata:SetScale(1.5)
	self:EmitSound(hitsnd)
	util.Effect("WheelDust", effectdata)
	util.Effect("GlassImpact", effectdata)
	SafeRemoveEntityDelayed(self, 0.1)
end
