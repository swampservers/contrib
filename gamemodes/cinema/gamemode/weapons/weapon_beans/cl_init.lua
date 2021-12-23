-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include("shared.lua")
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
local emitter = ParticleEmitter(Vector(0, 0, 0))

local function bean_init(particle, vel)
    particle:SetColor(255, 255, 255, 255)
    particle:SetVelocity(vel or VectorRand():GetNormalized() * 15)
    particle:SetGravity(Vector(0, 0, -200))
    particle:SetLifeTime(0)
    particle:SetDieTime(math.Rand(5, 10))
    particle:SetStartSize(1)
    particle:SetEndSize(0)
    particle:SetStartAlpha(255)
    particle:SetEndAlpha(0)
    particle:SetCollide(true)
    particle:SetBounce(0.25)
    particle:SetRoll(math.pi * math.Rand(0, 1))
    particle:SetRollDelta(math.pi * math.Rand(-4, 4))
end

function SWEP:Initialize()
end

net.Receive("Beans_Eat", function()
    local ply = net.ReadEntity()
    if not IsValid(ply) then return end
    local size = net.ReadFloat()
    local attachid = ply:LookupAttachment("eyes") or 0
    emitter:SetPos(Me:GetPos())
    local angpos = ply:GetAttachment(attachid)
    local fwd
    local pos

    if (ply ~= Me and IsValid(angpos)) then
        fwd = (angpos.Ang:Forward() - angpos.Ang:Up()):GetNormalized()
        pos = angpos.Pos + fwd * 3
    else
        fwd = ply:GetAimVector():GetNormalized()
        pos = ply:GetShootPos() + gui.ScreenToVector(ScrW() / 2, ScrH() / 4 * 3) * 10
    end

    for i = 1, size do
        if not IsValid(ply) then return end
        local particle = emitter:Add("particle/bean", pos)

        if particle then
            local dir = VectorRand():GetNormalized()
            bean_init(particle, ((fwd) + dir):GetNormalized() * math.Rand(0, 40))
        end
    end
end)

net.Receive("Beans_Eat_Start", function()
    local ply = net.ReadEntity()
    ply.ChewScale = 1
    ply.ChewStart = CurTime()
    ply.ChewDur = SoundDuration("eating.wav")
end)
