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
    self:NetworkVar("Int", 0, "ThrowState")
    self:NetworkVar("Int", 1, "ThrowPower")
    self:NetworkVar("Float", 0, "StateTime")
    self:NetworkVar("Entity", 0, "ThrownBall")
    self:NetworkVarNotify("ThrowState", self.OnChangeThrowState)
end

function SWEP:Initialize()
    self:SetHoldType("physgun")
end

function SWEP:OnChangeThrowState(name, old, new)
    local holdtype = "melee"
    local power = self:GetThrowPower()

    if new > 0 and power <= 600 then
        holdtype = "physgun"
    end

    if new == 0 then
        holdtype = "physgun"
    end

    if new == 1 and old == 0 then
        if (IsValid(self:GetOwner())) then
            local gest = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
            self:GetOwner():AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, gest, true)
        end
    end

    if (self:GetHoldType() ~= holdtype) then
        self:SetHoldType(holdtype)
    end
end

function SWEP:GetThrowing()
    return self:GetThrowState() > 0
end

function SWEP:BeginThrow(power)
    if (self:GetThrowing() or self:GetStateTime() > CurTime()) then return true end
    self:SetThrowPower(power)
    self:AdvanceState()
end

function SWEP:PrimaryAttack()
    self:BeginThrow(1400)

    return true
end

function SWEP:SecondaryAttack()
    self:BeginThrow(600)

    return true
end

function SWEP:Reload()
    self:BeginThrow(200)
end

function SWEP:Think()
    if (self:GetThrowing() and CurTime() >= self:GetStateTime()) then
        self:AdvanceState()
    end
end

function SWEP:AdvanceState()
    local curstate = self:GetThrowState()
    local ply = self:GetOwner()
    local delaytweak = SERVER and math.max(ply:Ping() / 1000, 0) or 0

    --change to throw pose
    if curstate == 0 then
        self:SetStateTime(CurTime() + 0.15 - (delaytweak))
        self:SetThrowState(1)

        return
    end

    --play throw animation
    if curstate == 1 then
        self:ThrowBall(self:GetThrowPower())
        self:SetStateTime(CurTime() + 0.3)
        self:SetThrowState(2)

        return
    end

    --die
    if curstate == 2 then
        self:SetStateTime(CurTime() + 0.35)
        self:SetThrowState(3)

        if SERVER then
            self:Remove()
        end

        return
    end
end

function SWEP:ThrowBall(force)
    if SERVER then
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
