-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SWEP.PrintName = "DEUS VULT"
SWEP.Slot = 2
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.DrawWeaponInfoBox = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    self.Owner:DrawViewModel(false)
end

function SWEP:PrimaryAttack()
    self:ExtEmitSound("deusvult.wav", {
        speech = 0.8,
        pitch = math.random(90, 110),
        crouchpitch = math.random(150, 170),
        shared = true
    })
end

function SWEP:SecondaryAttack()
end
