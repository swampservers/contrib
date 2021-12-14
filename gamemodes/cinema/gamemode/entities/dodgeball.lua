-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Dodgeball"

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel("models/pyroteknik/dodgeball.mdl")
    self:SetColor(Color(255, 0, 0, 255))

    if self.Clientside then
        self:SetColor(Color(0, 0, 255))
    end

    -- self:PhysicsInitSphere(8, "rubber")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    phys:Wake()
    phys:SetMass(phys:GetMass() * 1.75)
    phys:SetMaterial("rubber")
    phys:SetBuoyancyRatio(0.9)
    self.birth = CurTime()
end

function ENT:Use(activator, caller)
    if caller:IsPlayer() then
        self:Pickup(caller)
    end
end

function ENT:Think()
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:Pickup(ply)
    if ply == self.thrower and CurTime() - self.birth < 0.4 then return end
    self.removing = true

    timer.Simple(0, function()
        if IsValid(self) then
            if ply:HasWeapon("weapon_dodgeball") then return end
            ply:Give("weapon_dodgeball")

            if ply:GetLocationName():lower():find("gym") then
                ply:SelectWeapon("weapon_dodgeball")
            end

            self:Remove()
        end
    end)
end

function ENT:PhysicsCollide(data, phys)
    if self.removing then return end
    local ent = data.HitEntity

    if ent:IsPlayer() then
        if data.Speed > 200 and self.thrower ~= ent then
            if ent:GetLocationName():lower():find("gym") then
                if IsValid(self.thrower) then
                    local dmginfo = DamageInfo()
                    dmginfo:SetAttacker(self.thrower)
                    dmginfo:SetInflictor(self)
                    dmginfo:SetDamageForce(Vector(0, 0, 0))
                    dmginfo:SetDamage(1000)
                    ent:TakeDamageInfo(dmginfo)
                else
                    timer.Simple(0, function()
                        ent:Kill()
                    end)
                end
            else
                if (ent.lastDodgeballSound or 0) + 1 < CurTime() then
                    ent:EmitSound("vo/npc/female01/pain01.wav")
                    ent.lastDodgeballSound = CurTime()
                end
            end
        else
            self:Pickup(ent)
        end
    else
        local max = 300
        local scale = math.Clamp(data.Speed - 100, 0, max) / max

        if scale > 0 then
            local pitch = Lerp(scale, 80, 110)
            local vol = Lerp(scale, 0.2, 1)
            self:EmitSound("dodgeball_hithard.wav", 100, pitch, vol)
        end
    end
end

hook.Add("EntityTakeDamage", "nododgeballphysicskill", function(target, dmg)
    if IsValid(target) and target:IsPlayer() and IsValid(dmg:GetInflictor()) and dmg:GetInflictor():GetClass() == "dodgeball" and dmg:GetDamageType() == 1 then return true end
end)
-- if CLIENT then
--     killicon.AddAlias("dodgeball", "prop_physics")
-- end
