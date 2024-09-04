-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("weapon_swamp_base")
SWEP.Author = "Noz"
SWEP.Instructions = "Eat while watching Cars 2"
SWEP.PrintName = "Beans"
SWEP.ViewModel = "models/noz/beans.mdl"
SWEP.WorldModel = "models/noz/beans.mdl"
SWEP.Spawnable = true
SWEP.ViewModelFOV = 100
SWEP.Primary.Clipsize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Clipsize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = false
SWEP.Slot = 1
SWEP.SlotPos = 1

function SWEP:Deploy()
    BaseClass.Deploy(self)
    self:SetHoldType("slam")

    return true
end

function SWEP:Reload()
end

function SWEP:GetViewModelPosition(pos, ang)
    pos, ang = LocalToWorld(Vector(10, -10, -7), Angle(0, 200, 0), pos, ang)

    return pos, ang
end

function SWEP:Think()
    if (self.Owner.ChewScale or 0) > 0 then
        if SERVER then
            if CurTime() >= (self.Owner.BiteStart or 0) + 0.625 and (self.Owner.BitesRem or 0) > 0 then
                self.Owner.BiteStart = CurTime()
                self.Owner.BitesRem = self.Owner.BitesRem - 1
                net.Start("Beans_Eat")
                net.WriteEntity(self.Owner)
                net.WriteFloat(math.Round(math.Rand(4, 8) + self.Owner.BitesRem * 8))
                net.Broadcast()
            end
        end

        self.Owner.ChewScale = math.Clamp((self.Owner.ChewStart + self.Owner.ChewDur - CurTime()) / self.Owner.ChewDur, 0, 1)
    end
end

function SWEP:Initialize()
    util.PrecacheSound("beans/eating.wav")
end

function SWEP:PrimaryAttack()
    if SERVER then
        self.Owner:ExtEmitSound("beans/eating.wav", {
            level = 60
        })

        self.Owner.BiteStart = 0
        self.Owner.BitesRem = 3
        net.Start("Beans_Eat_Start")
        net.WriteEntity(self.Owner)
        net.Broadcast()
        self.Owner:SetHealth(math.min(self.Owner:Health() + 10, self.Owner:GetMaxHealth()))
        self.Owner.BeansEaten = self.Owner.BeansEaten or 0
        self.Owner.BeansEaten = self.Owner.BeansEaten + 1
    end

    self.Owner.ChewScale = 1
    self.Owner.ChewStart = CurTime()
    self.Owner.ChewDur = SoundDuration("beans/eating.wav")
    self.Weapon:SetNextPrimaryFire(CurTime() + 3)
end

function SWEP:SecondaryAttack()
    self:ExtEmitSound("beans/niggaeatingbeans.wav", {
        speech = 1.5,
        pitch = math.random(90, 110),
        crouchpitch = math.random(150, 170)
    })

    self.Weapon:SetNextSecondaryFire(CurTime() + 3)
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if IsValid(ply) then
        local bone = (self.Owner:IsPony() and self.Owner:LookupBone("LrigScull") or self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = self.Owner:GetBonePosition(bone)

        if bp then
            opos = bp
        end

        if ba then
            oang = ba
        end

        if self.Owner:IsPony() then
            opos = opos + oang:Right() * -3.25
            opos = opos + oang:Forward() * 6.75
            opos = opos + oang:Up()
            oang:RotateAroundAxis(oang:Up(), 200)
        else
            opos = opos + oang:Right() * 2
            opos = opos + oang:Forward() * 4
            opos = opos + oang:Up() * -2.5
            oang:RotateAroundAxis(oang:Right(), 205)
            oang:RotateAroundAxis(oang:Forward(), -30)
            oang:RotateAroundAxis(oang:Up(), 105)
        end

        self:SetupBones()
        local mrt = self:GetBoneMatrix(0)

        if mrt then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            mrt:SetScale(Vector(.9, .9, .9))
            self:SetBoneMatrix(0, mrt)
        end
    end

    self:DrawModel()
end
