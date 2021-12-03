-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
    self:SetModel("models/props_junk/PlasticCrate01a.mdl")
    self:SetMoveCollide(COLLISION_GROUP_PROJECTILE)
    self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_CUSTOM)
    self:DrawShadow(false)
    local glow = ents.Create("env_sprite")
    glow:SetKeyValue("rendercolor", "20 100 50")
    glow:SetKeyValue("GlowProxySize", "2.0")
    glow:SetKeyValue("HDRColorScale", "1")
    glow:SetKeyValue("renderfx", "14")
    glow:SetKeyValue("rendermode", "3")
    glow:SetKeyValue("renderamt", "255")
    glow:SetKeyValue("disablereceiveshadows", "0")
    glow:SetKeyValue("mindxlevel", "0")
    glow:SetKeyValue("maxdxlevel", "0")
    glow:SetKeyValue("framerate", "10.0")
    glow:SetKeyValue("model", "sprites/flare1.spr")
    glow:SetKeyValue("spawnflags", "0")
    glow:SetKeyValue("scale", "2")
    glow:Spawn()
    glow:SetParent(self)
    glow:SetPos(self:GetPos())
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(5)
        phys:EnableDrag(false)
        phys:EnableGravity(false)
        phys:SetBuoyancyRatio(0)
    end

    self.bfgsound = CreateSound(self, "weapons/doom3/bfg/bfg_fly.wav")
    self.bfgsound:Play()
end

function ENT:SetDamage(rad, dmg)
    self.Radius = rad
    self.Damage = dmg
end

function ENT:PhysicsCollide(data, physobj)
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    util.Effect("doom3_bfg_exp", effectdata)
    util.Effect("doom3_bfg_exp_p", effectdata)
    local trace = {}
    trace.start = data.HitPos + data.HitNormal
    trace.endpos = data.HitPos - data.HitNormal
    trace.filter = self
    local tr = util.TraceLine(trace)

    if IsValid(self:GetOwner()) then
        local dmginfo = DamageInfo()
        dmginfo:SetAttacker(self:GetOwner())
        dmginfo:SetInflictor(self)
        dmginfo:SetDamage(self.Damage)
        util.BlastDamageInfo(dmginfo, tr.StartPos, self.Radius)
    end

    self:EmitSound("weapons/doom3/bfg/bfg_explode" .. math.random(1, 4) .. ".wav", 100, 100)
    self:Remove()
    local shake = ents.Create("env_shake")
    shake:SetOwner(self:GetOwner())
    shake:SetPos(self:GetPos())
    shake:SetKeyValue("amplitude", "5")
    shake:SetKeyValue("radius", "2048")
    shake:SetKeyValue("duration", "2.7")
    shake:SetKeyValue("frequency", "255")
    shake:SetKeyValue("spawnflags", "4")
    shake:Spawn()
    shake:Activate()
    shake:Fire("StartShake", "", 0)
end

function ENT:OnRemove()
    if self.bfgsound then
        self.bfgsound:Stop()
    end
end

function ENT:Think()
    if not IsValid(self:GetOwner()) or self:GetOwner():IsNPC() then return end
    local ents = ents.FindInSphere(self:GetPos(), 256)

    for k, v in pairs(ents) do
        local tr = util.TraceHull({
            start = self:GetPos(),
            endpos = v:GetPos() + v:OBBCenter(),
            filter = self
        })

        if IsValid(self:GetOwner()) and IsValid(tr.Entity) and tr.Entity:IsPlayer() and (not tr.Entity:InVehicle()) and tr.Entity ~= self:GetOwner() then
            local dmginfo = DamageInfo()
            dmginfo:SetDamage(10)
            dmginfo:SetDamageType(DMG_ENERGYBEAM)
            dmginfo:SetAttacker(self:GetOwner())
            dmginfo:SetInflictor(self)
            tr.Entity:TakeDamageInfo(dmginfo)
        end
    end
end
