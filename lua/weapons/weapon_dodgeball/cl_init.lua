-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")
SWEP.Instructions = "Primary: Throw hard\nSecondary: Throw soft\nReload: Pass"
SWEP.DrawAmmo = false
SWEP.ViewModelFOV = 85

function SWEP:ThrownBallExists()
    local ply = self:GetOwner()
    if(self:GetThrowState() < 2)then return false end
    if(IsValid(self:GetThrownBall()))then return true end
    if(IsValid(self.fakethrownball))then return true end
    local lookent = ply:GetEyeTrace().Entity
    if(IsValid(lookent) and lookent:GetClass() == "dodgeball" and lookent:GetPos():Distance(ply:EyePos()) < 128)then
        self.fakethrownball = lookent
        return true
    end
    return false
end

function SWEP:DrawWorldModel()
    if(self:ThrownBallExists())then return end 
    local ply = self:GetOwner()

    if (IsValid(ply)) then
        local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
        local bon = ply:LookupBone(bn) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = ply:GetBonePosition(bon)

        if (bp) then
            opos = bp
        end

        if (ba) then
            oang = ba
        end

        if ply:IsPony() then
            oang:RotateAroundAxis(oang:Forward(), 90)
            oang:RotateAroundAxis(oang:Up(), -90)
            opos = opos + (oang:Up() * -12) + (oang:Right() * -12)
        else
            opos = opos + oang:Forward() * 6
            opos = opos + oang:Right() * 8
            opos = opos + oang:Up() * -0.5
        end

        self:SetupBones()
        self:SetModelScale(0.8, 0)
        local mrt = self:GetBoneMatrix(0)

        if (mrt) then
            mrt:Scale(Vector(0.5,0.5,0.5))
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            self:SetBoneMatrix(0, mrt)
        end
    end

    render.SetColorModulation(1, 0, 0)
    self:SetColor(255, 0, 0, 255)
    self:DrawModel()
    render.SetColorModulation(1, 1, 1)
end

function SWEP:PreDrawViewModel(vm, wp, ply)
    render.SetColorModulation(1, 0, 0)
end

function SWEP:GetViewModelPosition(pos, ang)
    if(self:ThrownBallExists())then 
        return Vector(0,0,-10000),ang
    end

   
    

    local targetpos = Vector(0,25,-23)
    local state = self:GetThrowState()
    local power = self:GetThrowPower()
    if(state == 1)then 
        targetpos = power >= 600 and Vector(15,30,23) or Vector(0,20,-23)
    end
    if(state == 2)then 
        targetpos = power >= 600 and Vector(0,60,23) or Vector(0,60,-23)
    end

    self.PosLerp = LerpVector(FrameTime()*2,self.PosLerp or targetpos,targetpos)
    local localpos = self.PosLerp        



    pos = pos + ang:Right()*localpos.x
    pos = pos + ang:Forward()*localpos.y
    pos = pos + ang:Up()*localpos.z
    
    return pos, ang
end

function SWEP:PostDrawViewModel(vm, wp, ply)
    render.SetColorModulation(1, 1, 1)
end