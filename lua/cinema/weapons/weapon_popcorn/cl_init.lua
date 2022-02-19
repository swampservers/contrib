-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include('shared.lua')
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Instructions = "Primary: Eat Popcorn\nSecondary: Throw Bucket"
local emitter = ParticleEmitter(Vector(0, 0, 0))

function SWEP:GetViewModelPosition(pos, ang)
    pos, ang = LocalToWorld(Vector(20, -10, -15), Angle(0, 0, 0), pos, ang)

    return pos, ang
end

local function kernel_init(particle, vel)
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

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if IsValid(ply) then
        local bp, ba = ply:GetBonePosition(ply:LookupBone(ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand") or 0)
        local pos, ang

        if bp then
            pos, ang = bp, ba
        else
            pos, ang = self:GetPos(), self:GetAngles()
        end

        if ply:IsPony() then
            ang:RotateAroundAxis(ang:Forward(), -90)
            pos = pos + ang:Up() * 10 + ang:Right() * -1 + ang:Forward() * 7
        else
            ang:RotateAroundAxis(ang:Forward(), 30)
            pos = pos + ang:Right() * 7 + ang:Up() * 3 + ang:Forward() * -4
        end

        self:SetupBones()
        local mrt = self:GetBoneMatrix(0)

        if mrt then
            mrt:SetTranslation(pos)
            mrt:SetAngles(ang)
            mrt:SetScale(Vector(0.8, 0.8, 0.8))
            self:SetBoneMatrix(0, mrt)
        end
    end

    self:DrawModel()
end


--NOMINIFY
net.Receive("EatPopcorn", function()
    local ply = net.ReadEntity()
    if not IsValid(ply) then return end
    
    ply.ChewScale = 1
    ply.ChewStart = CurTime()
    ply.ChewDur = SoundDuration("crisps/eat.wav")

    local amt = 15

    local function eat()
            amt=amt-5
    
            local fwd,pos
    
            if ply ~= Me then
                local attach = ply:GetAttachment(ply:LookupAttachment("eyes"))
                if not attach then return end
        
                fwd = (attach.Ang:Forward() - attach.Ang:Up()):GetNormalized()
                pos =  attach.Pos + fwd * 3
            else
                fwd,pos = ply:GetAimVector():GetNormalized(),ply:GetShootPos() + gui.ScreenToVector(ScrW() / 2, ScrH() / 4 * 3) * 10
            end
    
            for i = 1, amt+math.random(0,10) do
                if not IsValid(ply) then return end
                local particle = emitter:Add("particle/popcorn-kernel", pos)
        
                if particle then
                    kernel_init(particle, (fwd + VectorRand():GetNormalized()):GetNormalized() * math.Rand(0, 40))
                end
            end
    
        end
    
        eat()
    ply:TimerCreate("EatPopcorn", 1, 3, eat)

   
end)



function SWEP:SecondaryAttack()
end
