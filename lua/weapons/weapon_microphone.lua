-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- Microphone SWEP by swamponions - STEAM_0:0:38422842
AddCSLuaFile()
SWEP.PrintName = "Microphone"
SWEP.Author = "swamponions"
SWEP.Purpose = "Speak your mind."
SWEP.Slot = 1
SWEP.SlotPos = 99
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModelFOV = 85
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/props_fairgrounds/mic_stand.mdl")
SWEP.WorldModel = Model("models/props_fairgrounds/mic_stand.mdl")
SWEP.Weight = 5
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

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if (IsValid(ply)) then
        local bn = "ValveBiped.Bip01_R_Hand"
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

        oang:RotateAroundAxis(oang:Forward(), 180)
        oang:RotateAroundAxis(oang:Right(), -20)
        opos = opos + oang:Right() * -2
        opos = opos + oang:Forward() * 2
        opos = opos + oang:Up() * -35
        self:SetupBones()
        local mrt = self:GetBoneMatrix(0)

        if (mrt) then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            self:SetBoneMatrix(0, mrt)
        end
    end

    self:DrawModel()
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 8
    pos = pos + ang:Up() * -60
    pos = pos + ang:Forward() * 18
    ang:RotateAroundAxis(ang:Forward(), -3)
    ang:RotateAroundAxis(ang:Up(), -30)
    pos = pos + ang:Forward() * 0.2

    return pos, ang
end

function SWEP:DrawHUD()
    draw.DrawText("You have the mic! Everyone else's voice is muted. Reload to drop.", "TargetID", ScrW() * 0.5, ScrH() * 0.93, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
end

function SWEP:Initialize()
    self:SetHoldType("slam")
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
    if SERVER then
        self:Remove()
    end
end

function SWEP:Holster()
    if SERVER then
        self:Remove()
    end
end

function SWEP:OnRemove()
    if SERVER then
        self.SourceMic:SetSpeaker(NULL)
    end
end

function SWEP:Think()
    if SERVER then
        if self.Owner:InVehicle() or self.Owner:GetPos():Distance(self.SourceMic:GetPos()) > 250 or self.Owner:GetPos().x > -2680 then
            self:Remove()
        end
    end
end