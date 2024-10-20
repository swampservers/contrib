-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("weapon_swamp_base")
SWEP.PrintName = "Monster Zero"
SWEP.Author = "Noz"
SWEP.Instructions = "Left click for a sip. Right click for a boomer phrase. Reload to crack open another."
SWEP.Slot = 2
SWEP.SlotPos = 2
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = false
SWEP.Spawnable = true
SWEP.ViewModel = "models/noz/monsterzero.mdl"
SWEP.WorldModel = "models/noz/monsterzero.mdl"

function SWEP:Initialize()
    self:SetHoldType("slam")
end

function SWEP:Deploy()
    BaseClass.Deploy(self)
    local owner = self:GetOwner()

    if IsValid(owner) then
        self:ExtEmitSound("boomer/crack_open.wav", {
            speech = 0.85,
            shared = true
        })
    end

    return true
end

function SWEP:PrimaryAttack()
    if SERVER then
        MonsterUpdate(self.Owner)
    end

    self.Weapon:SetNextPrimaryFire(CurTime() + .1)
end

function SWEP:SecondaryAttack()
    self:ExtEmitSound("boomer/phrase1.wav", {
        shared = true,
        speech = 1.8
    })
end

function SWEP:Reload()
    if self:GetOwner():KeyPressed(IN_RELOAD) then
        self:ExtEmitSound("boomer/crack_open.wav", {
            speech = 0.85,
            shared = true
        })
    end
end

SWEP.OnDrop = SWEP.Holster
SWEP.OnRemove = SWEP.Holster
