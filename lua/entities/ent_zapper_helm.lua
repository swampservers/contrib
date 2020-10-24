-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
 
ENT.PrintName = "Zapper"

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
    self:NetworkVar( "Bool", 0, "Zapping" )
    self:NetworkVar( "Vector", 0, "TruePos" )
    self:NetworkVar( "Angle", 0, "TrueAng" )
    self:NetworkVar( "Entity", 0, "Subject" )
end

function ENT:Initialize()
    self:SetModel("models/props_interiors/pot01a.mdl")
    self:SetModelScale(0.8)
    if SERVER then
        self:SetZapping(false)
        self:SetTruePos(self:GetPos())
        self:SetTrueAng(self:GetAngles())
        self:SetSubject(NULL)
    end
    if CLIENT then self:SetRenderBounds(Vector(-100,-100,-100),Vector(100,100,50)) end
end


function ENT:AcceptInput(input, activator, caller, data)
    if input=="TurnOn" then self:SetZapping(true) self:EmitSound("ambient/energy/electric_loop.wav", 60) return true end
    if input=="TurnOff" then self:SetZapping(false) self:StopSound("ambient/energy/electric_loop.wav") return true end
end

function ENT:Draw(flags)
    -- if self:GetZapping() then
    --     render.SetColorModulation(1, 0, 0)
    -- else
    --     render.SetColorModulation(1,1,1)
    -- end
    self:DrawModel()
end

local beamtargets = {
    Vector(-2294,-47,-208),
    Vector(-2294,-47,-224),
    Vector(-2294,-47,-240),
    Vector(-2294,-47,-256),
    Vector(-2294,-47,-272),
    Vector(-2294,-113,-208),
    Vector(-2294,-113,-224),
    Vector(-2294,-113,-240),
    Vector(-2294,-113,-256),
    Vector(-2294,-113,-272),
    Vector(-2271, -60, -217),
    Vector(-2271, -60, -230),
    Vector(-2271, -60, -243),
    Vector(-2271, -100, -217),
    Vector(-2271, -100, -230),
    Vector(-2271, -100, -243),
    Vector(-2263, -80, -208),
    Vector(-2263, -80, -221),
    Vector(-2263, -80, -234)
}
function SHUFFLEE(t)
local n = #t
while n > 2 do
    local k = math.random(n)
    t[n], t[k] = t[k], t[n]
    n = n - 1
end
end
SHUFFLEE(beamtargets)

local zapp = Material("swamponions/zap")

function ENT:DrawTranslucent(flags)
    if self:GetZapping() then
        local seed = math.random()

        render.SetMaterial(zapp)
        for i,targ in ipairs(beamtargets) do
            math.randomseed(i*100 + math.floor(CurTime()*(i+10)/30+i*0.13))
            if math.random() > 0.65 then
                render.DrawBeam(self:GetPos(), targ, math.pow(math.Rand(2,4),2), 0, 1, Color( 255, 255, 255 ) ) 
            end
        end
    end
end

function ENT:Think()
    if CLIENT then
        if IsValid(self:GetSubject()) then
            att = self:GetSubject():GetAttachment(self:GetSubject():LookupAttachment("eyes"))
            local p = att.Pos
            local a = att.Ang
            a:RotateAroundAxis(a:Up(),-90)
            self:SetPos(p + a:Up()*7 + a:Right()*3)
            if self:GetSubject():IsPony() then
                self:SetPos(p + a:Up()*15 + a:Right()*10)
            end
            self:SetAngles(a)
        else
            self:SetPos(self:GetTruePos())
            self:SetAngles(self:GetTrueAng())
        end



        -- if IsValid(LocalPlayer()) and LocalPlayer():GetPos():Distance(self:GetPos()) < 500 then
        --     if self:GetZapping() then
        --         local dlight = DynamicLight( self:EntIndex() )
        --         if ( dlight ) then
        --             dlight.pos = self:GetPos() + Vector(0,0,10)
        --             dlight.r = 10
        --             dlight.g = 150
        --             dlight.b = 255
        --             dlight.brightness = 1 --math.random(10,20)*0.1
        --             dlight.Style = 1
        --             dlight.Decay = 2000
        --             dlight.Size = 1000
        --             dlight.DieTime = CurTime() + 0.05
        --         end
        --     end
        -- end
    end

    if SERVER then
        local s = NULL
        
        for k,v in pairs(player.GetAll()) do
            if v:InVehicle() and v:GetPos():Distance(self:GetPos()) < 100 then s=v end
        end

        if self:GetSubject() ~= s then self:SetSubject(s) end
        --self:SetPos(player.GetAll()[1]:GetPos())
    end
    self:NextThink( CurTime() )
    return true 
end
