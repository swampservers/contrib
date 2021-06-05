-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")
include("sv_logic.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("sv_effects.lua")
include("sv_placement.lua")

function ENT:Initialize()
    self.Entity:SetModel("models/pyroteknik/secretbutton.mdl")
    local bmins, bmaxs = Vector(-4.8, -3.1, 0), Vector(4.8, 3.1, 2)
    self:SetCollisionBounds(bmins, bmaxs)
    self.Entity:PhysicsInitBox(bmins, bmaxs)
    self.Entity:SetMoveType(MOVETYPE_NONE)
    self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
    self:SetUseType(SIMPLE_USE)
    self:SetColor(HSVToColor(math.Rand(0, 360), 1, 1))
    local phys = self:GetPhysicsObject()

    if (IsValid(phys)) then
        phys:EnableMotion(false)
    end

    --self:FindHidingSpot()
    if (not self.HasSpot) then
        local trace = self:FindHidingSpot()
        self:MoveToTraceResult(trace)
    end

    timer.Simple(60 * 60, function()
        if (IsValid(self)) then
            self:Remove()
        end
    end)
end

function ENT:SpawnFunction(ply, tr, ClassName)
    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos)
    ent:SetAngles(VectorRand():AngleEx(tr.HitNormal))
    local trace = ply:GetEyeTrace()
    ent:MoveToTraceResult(trace)
    ent.HasSpot = true
    ent:Spawn()
    ent:Activate()

    return ent
end

util.AddNetworkString("magicbutton_transmitclone")

function ENT:Transmit()
    local recip = MAGICBUTTON_SENDFILTER(self)
    local c = self:GetColor()
    net.Start("magicbutton_transmitclone")
    net.WriteInt(self:EntIndex(), 17)
    net.WriteVector(self:GetPos())
    net.WriteAngle(self:GetAngles())
    net.WriteColor(Color(c.r, c.g, c.b, c.a)) --for some reason GetColor is returning a table and it really doesn't like that
    net.WriteBool(self.Pressed or false)
    net.Send(recip)
end

function ENT:Think()
    self:Transmit()
    self:NextThink(CurTime() + 1)

    if (self.HintSound and not self.Pressed) then
        Sound(self.HintSound)

        if (math.random(1, 2) == 1 or true) then
            self:EmitSound(self.HintSound, 70, 100, 1, CHAN_VOICE, nil)
        end
    end

    return true
end

--NOTE: On these functions, please return a string if there was a success, and nil if there was not.
function ENT:Effect(ply)
    local effect
    local item
    local outcometable = {}
    local coolonly = self.CoolEffectOnly
    local uncool = MAGICBUTTON_MODIFY(ply)

    for k, v in pairs(MagicButtonOutcomes) do
        if (not uncool and coolonly and not v.cool) then continue end
        if (uncool and not v.uncool) then continue end

        for i = 1, v.weight * (v.weightbonus or 1) or 1 do
            table.insert(outcometable, math.random(1, #outcometable + 1), k)
        end
    end

    for _, index in pairs(outcometable) do
        effect = MagicButtonOutcomes[index]

        if (effect.func ~= nil) then
            item = effect.func(ply, self)
        end

        if (item ~= nil) then break end
    end

    return item
end

function ENT:UpdateTransmitState()
    if (self.HintSound) then return TRANSMIT_ALWAYS end

    return TRANSMIT_NEVER
end

function ENT:Use(activator)
    if (not self.Pressed) then
        self.Pressed = true
        self:Transmit()

        timer.Simple(8, function()
            if (IsValid(self)) then
                self:Remove()
            end
        end)

        MAGICBUTTON_STAT_TRACKING(activator)
        local message = self:Effect(activator)
        assert(message ~= nil)
        message = "[white]" .. activator:Nick() .. "[fbc] pressed a hidden button " .. message
        BotSayGlobal(";clap;[fbc]" .. message)
        activator:EmitSound("buttons/button9.wav")
    end
end