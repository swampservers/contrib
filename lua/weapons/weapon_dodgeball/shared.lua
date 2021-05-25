-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Dodgeball"
SWEP.Slot = 0
SWEP.ViewModel = Model("models/pyroteknik/dodgeball.mdl")
SWEP.WorldModel = Model("models/pyroteknik/dodgeball.mdl")
SWEP.Primary.Automatic = true 
SWEP.Secondary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none" --you should really leave these in here so that people don't receive pistol ammo when they pick it up
SWEP.Spawnable = true
SWEP.Category = "Swamp Cinema" --todo remove these later i just need  this for testing 

local outie = 64
local innie = 28

function SWEP:SetupDataTables()
    self:NetworkVar("Int",0,"ThrowState")
    self:NetworkVar("Int",1,"ThrowPower")
    self:NetworkVar("Float",0,"ExpireTime")
    self:NetworkVar("Entity",0,"ThrownBall")
    if ( SERVER ) then
		self:NetworkVarNotify( "ThrowState", self.OnChangeThrowState )
	end
end 

function SWEP:Initialize()
    self:SetHoldType("physgun")
end


function SWEP:OnChangeThrowState( name, old, new )
    local holdtype = "melee"
    local power = self:GetThrowPower()
    if(new > 0 and power < 600)then
        holdtype = "physgun"
    end
    if(new == 0)then 
        holdtype = "physgun"
    end

    if(self:GetHoldType() != holdtype)then 
        self:SetHoldType(holdtype) 
    end
end


function SWEP:PrimaryAttack(power)
    if(self:GetNextPrimaryFire() > CurTime())then return true end
    power = power or 1400
    self:SetThrowPower(power)
    self:AdvanceState()
    local state = self:GetThrowState()
    
    return true
end

function SWEP:SecondaryAttack()
    self:PrimaryAttack(600)
    return true
end

function SWEP:Reload()
    self:PrimaryAttack(200)
end

function SWEP:Think()
    if(self:GetExpireTime() != 0 and CurTime() >= self:GetExpireTime())then
        if(self.Thrown)then
            if(SERVER)then self:Remove() end
        else
            self:SetExpireTime(0)
        self:SetThrowState(0)
        end
    end
end

function SWEP:AdvanceState()
    local curstate = self:GetThrowState()

    if(curstate == 0)then --change to throw pose
        --self:EmitSound("Weapon_Pistol.Empty")
        self:SetNextPrimaryFire(CurTime() + 0.15)
        self:SetThrowState(1)
        return 
    end
    if(curstate == 1)then --play throw animation
        --self:EmitSound("Weapon_Pistol.Empty")
        self:ThrowBall(self:GetThrowPower())
        self:SetNextPrimaryFire(CurTime() + 0.35)
        self.Thrown = true
        self:SetThrowState(2)
        return 
    end
    if(curstate == 2)then --play throw animation
        self:EmitSound("Weapon_Pistol.Empty")
        self:SetNextPrimaryFire(CurTime() + 0.35)
        self:Remove()
        return 
    end  
end

function SWEP:ThrowBall(force)
    if SERVER then
       self:GetOwner():SetAnimation(PLAYER_ATTACK1)
        if self.THREW then return end
        self.THREW = true
        
        if IsValid(self) and IsValid(self.Owner) then
            local p1 = self.Owner:GetPos() + self.Owner:GetCurrentViewOffset()
            local p2 = p1 + (self.Owner:GetAimVector() * outie)
            local tr = util.TraceLine({
                    start = p1,
                    endpos = p2,
                    mask = MASK_SOLID_BRUSHONLY
            })
            if tr.Hit then
                p2 = tr.HitPos
            end

            p2 = p2 - (self.Owner:GetAimVector() * innie)
            local ball = makeDodgeball(p2, (self.Owner:GetAimVector() * force) + self.Owner:GetVelocity(), self.Owner)
            self:SetThrownBall(ball)
            end
    end
end

