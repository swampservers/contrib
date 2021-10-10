AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Thrown Kleiner Egg"
ENT.Author = "PYROTEKNIK"
ENT.Category = "PYROTEKNIK"
ENT.Spawnable = false
ENT.AdminSpawnable = true

function ENT:Initialize()
    if (SERVER) then
        self.Entity:SetModel("models/weapons/w_bugbait.mdl")
        local bmins, bmaxs = Vector(-1, -1, -1), Vector(1, 1, 1)
        self:SetCollisionBounds(bmins, bmaxs)
        self.Entity:PhysicsInit(SOLID_BBOX)
        self.Entity:SetMoveType(MOVETYPE_FLYGRAVITY)
        self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
        self:SetUseType(SIMPLE_USE)
        self:EmitSound("vo/k_lab/kl_ahhhh.wav", 66, math.Rand(180, 210), 0.2, nil, nil, 56)
    end
end

local TRIGGER_BLACKLIST = {}
TRIGGER_BLACKLIST["trigger_hurt"] = true

--TRIGGER_BLACKLIST[FSOLID_NOT_SOLID] = true
--TRIGGER_BLACKLIST[FSOLID_TRIGGER] = true
function ENT:Touch(entity)
    if (TRIGGER_BLACKLIST[entity:GetClass()]) then return end

    for flag, _ in pairs(TRIGGER_BLACKLIST) do
        if (type(flag) == "number" and self:GetSolidFlags() >= flag) then return end
    end

    local trace = self:GetTouchTrace()
    local target

    for k, v in pairs(ents.FindInSphere(trace.HitPos, 64)) do
        if (v:IsPlayer() and v ~= self:GetOwner()) then
            target = v
            break
        end
    end

    if (IsValid(target)) then
        for ent, _ in pairs(KLEINER_NPCS) do
            if (ent:CanBecomeTarget(target)) then
                ent.KleinerBaitPriority = CurTime() + 30
                ent:SetTargetViolence(target, ent:GetTargetViolence() + 10)
                ent:CheckBaitTargeting(target)
            end
        end
    else
        for ent, _ in pairs(KLEINER_NPCS) do
            if (ent:GetRangeTo(self:GetPos()) <= ent.SearchRadius) then
                ent:ResetBehavior()
                ent.ManualTargeting = true
                ent:SetTarget(nil)
                ent:WanderToPos(self:GetPos())
            end
        end
    end

    if (trace.Hit) then
        util.Decal("Blood", trace.StartPos, trace.StartPos + trace.Normal * 32, {self})

        local vPoint = trace.HitPos
        local effectdata = EffectData()
        effectdata:SetOrigin(vPoint)
        util.Effect("BloodImpact", effectdata)
    end

    self:EmitSound("GrenadeBugBait.Splat")
    self:Remove()
end

--lol i caught it
function ENT:Use(ply)
    ply:Give("weapon_kleinerbait")
    self:Remove()
end