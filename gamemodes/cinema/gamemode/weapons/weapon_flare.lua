-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Flare"
SWEP.DrawAmmo = false
SWEP.ViewModelFOV = 85
SWEP.Slot = 0
SWEP.SlotPos = 2
SWEP.Purpose = "Light Gnomes On Fire"
SWEP.Instructions = "Primary: Use"
SWEP.AdminSpawnable = false
SWEP.ViewModel = Model("models/brian/flare.mdl")
SWEP.WorldModel = Model("models/brian/flare.mdl")
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Damage = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.RenderGroup = RENDERGROUP_BOTH

function SWEP:Initialize()
    self:SetHoldType("slam")
end

if SERVER then
    timer.Create("FlareControl", 5, 0, function()
        for k, v in pairs(ents.FindByClass("weapon_flare")) do
            if v:GetPos().z > -10 then
                v:Remove()
            end
        end
    end)
end

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()

    --if(SERVER)then self:CallOnClient("PrimaryAttack") end
    if SERVER then
        SuppressHostEvents(ply)
    end

    self:SetNextPrimaryFire(CurTime() + 1)
    ply:SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("Weapon_StunStick.Swing", nil, 60, 0.2)

    ply:TimerSimple(0.15, function()
        if not IsValid(self) then return end
        local dir = ply:GetAimVector()
        local org = ply:GetShootPos() + dir * 20 + Vector(0, 0, -10)
        local effectdata = EffectData()
        effectdata:SetOrigin(org)
        effectdata:SetNormal(dir)
        effectdata:SetRadius(1)
        effectdata:SetMagnitude(1)
        effectdata:SetScale(0.1)
        util.Effect("ElectricSpark", effectdata)

        if SERVER then
            for k, v in ipairs(Ents.ent_keem) do
                if v:GetPos():Distance(self.Owner:GetPos()) < 80 then
                    v:FireAttack()
                    SafeRemoveEntityDelayed(self, 0.2)
                end
            end
        end
    end)

    if SERVER then
        SuppressHostEvents()
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
    if CLIENT then
        if (not IsValid(self.Owner)) or self.Owner:GetActiveWeapon() ~= self then return end
        local dlight = DynamicLight(self:EntIndex())

        if dlight then
            dlight.pos = self.Owner:EyePos()
            dlight.r = 255
            dlight.g = 50
            dlight.b = 50
            dlight.brightness = 0.5 --math.random(10,22)*0.1
            dlight.Decay = 1000
            dlight.Size = 2000
            dlight.DieTime = CurTime() + 0.05
        end
    end
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if (IsValid(ply)) then
        local bn = "ValveBiped.Bip01_R_Hand"
        local bon = ply:LookupBone(bn) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = ply:GetBonePosition(bon)

        if bp then
            opos = bp
        end

        if ba then
            oang = ba
        end

        opos = opos + oang:Right() * 1
        opos = opos + oang:Forward() * 4
        oang:RotateAroundAxis(oang:Right(), 180)
        self:SetupBones()
        self:SetModelScale(0.8, 0)
        local mrt = self:GetBoneMatrix(0)

        if mrt then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            self:SetBoneMatrix(0, mrt)
        end
    end

    self:DrawModel()
end

flarefxpos = Vector()
flaresprite = Material("sprites/glow04_noz")

function SWEP:GetViewModelPosition(pos, ang)
    local pos2 = pos * 1 --copy vector
    local ang2 = ang * 1
    pos = pos + ang:Right() * 19
    pos = pos + ang:Up() * -15
    pos = pos + ang:Forward() * 25
    pos2 = pos2 + ang:Forward() * 44
    pos2 = pos2 + ang:Up() * -15
    ang2:RotateAroundAxis(ang2:Right(), -90)
    local thrustv = (self:GetNextPrimaryFire() - 0.3) > CurTime() and 1 or 0
    local spd = thrustv == 1 and 1.5 or 1
    self.ThrustLerp = math.Approach(self.ThrustLerp or 0, thrustv, FrameTime() * spd)
    self.ThrustLerp2 = math.Approach(self.ThrustLerp2 or 0, thrustv, FrameTime() * spd * 0.5)
    local ez = 1
    local ez2 = 1
    pos = LerpVector(math.EaseInOut(self.ThrustLerp2, ez, ez2), pos, pos2)
    ang = LerpAngle(math.EaseInOut(self.ThrustLerp, ez, ez2), ang, ang2)
    flarefxpos:Set(pos)
    flarefxpos = flarefxpos + ang:Up() * 7 + ang:Forward() * -1 + ang:Right() * -1

    return pos, ang
end

function SWEP:PostDrawViewModel()
    render.SetMaterial(flaresprite)
    local a = 0.1
    local b = math.Rand(0.6, 1)
    render.DrawSprite(flarefxpos + Vector(math.Rand(-a, a), math.Rand(-a, a), math.Rand(-a, a)), 15, 15, Color(255 * b, 255 * b, 255 * b))
end
