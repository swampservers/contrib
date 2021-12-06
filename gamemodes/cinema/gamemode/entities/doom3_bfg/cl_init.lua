-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include('shared.lua')

function ENT:Initialize()
    local Pos = self:GetPos()
    local emitter = ParticleEmitter(Pos)
    self.particle = emitter:Add("particles/fire_glow", Pos)

    if (self.particle) then
        self.particle:SetLifeTime(0)
        self.particle:SetDieTime(100)
        self.particle:SetStartAlpha(60)
        self.particle:SetEndAlpha(0)
        self.particle:SetStartSize(85)
        self.particle:SetEndSize(255)
        self.particle:SetAngles(Angle(0, 0, 0))
        self.particle:SetAngleVelocity(Angle(3, 0, 0))
        self.particle:SetRoll(math.Rand(0, 360))
        self.particle:SetColor(20, 255, 80, 255)
        self.particle:SetGravity(Vector(0, 0, 0))
        self.particle:SetAirResistance(0)
        self.particle:SetCollide(true)
        self.particle:SetBounce(0)
    end

    emitter:Finish()
end

local bfgballblast = Material("sprites/doom3/bfgballblast")
local bfgballsac = Material("sprites/doom3/bfgballsac")
local bfgboltarc = Material("sprites/doom3/bfgboltarc")
local bfgboltarc2 = Material("sprites/doom3/bfgboltarc2")

function ENT:Draw()
    local Pos = self:GetPos()
    render.SetMaterial(bfgballblast)
    render.DrawSprite(Pos, 46, 46)
    render.SetMaterial(bfgballsac)
    render.DrawSprite(Pos, 64, 64)

    if cvars.Bool("doom3_firelight") then
        local dynlight = DynamicLight(self:EntIndex())
        dynlight.Pos = Pos
        dynlight.Size = 128
        dynlight.Decay = 0
        dynlight.R = 155
        dynlight.G = 255
        dynlight.B = 150
        dynlight.Brightness = 8
        dynlight.DieTime = CurTime() + .1
    end

    if self:GetOwner():IsNPC() then return end
    local ents = ents.FindInSphere(Pos, 256)

    for k, v in pairs(ents) do
        --if IsValid(v) and v:IsNPC() and v != self:GetOwner() then
        local tr = util.TraceHull({
            start = Pos,
            endpos = v:GetPos() + v:OBBCenter(),
            filter = self
        })

        if IsValid(self:GetOwner()) and IsValid(tr.Entity) and tr.Entity:IsPlayer() and (not tr.Entity:InVehicle()) and tr.Entity ~= self:GetOwner() then
            local ct = CurTime()
            render.SetMaterial(bfgboltarc)
            render.DrawBeam(tr.StartPos, tr.HitPos, 24, ct * 1.5, ct * 1.5 - 1, Color(255, 255, 255, 255))
            render.SetMaterial(bfgboltarc2)
            render.DrawBeam(tr.StartPos, tr.HitPos, 32, ct, ct - 1, Color(255, 255, 255, 255))
            self:SetRenderBoundsWS(tr.StartPos, tr.HitPos)
        end
        --end
    end
end

function ENT:Think()
    local Pos = self:GetPos()
    self.particle:SetPos(Pos)
end

function ENT:OnRemove()
    self.particle:SetDieTime(1)
end
