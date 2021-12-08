-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- weapon_vape/shared.lua
-- Defines common shared code/defaults for Vape SWEP
-- Vape SWEP by Swamp Onions - http://steamcommunity.com/id/swamponions/
SWEP.Author = "Swamp Onions"
SWEP.Instructions = "LMB: Rip Fat Clouds\n (Hold and release)\nRMB & Reload: Play Sounds\n\nVape Nation!"
SWEP.PrintName = "Vape"
SWEP.IconLetter = "V"
SWEP.Category = "Vapes"
SWEP.Slot = 3
SWEP.SlotPos = 0
SWEP.ViewModelFOV = 62 --default
SWEP.WepSelectIcon = surface and surface.GetTextureID("vape_icon")
SWEP.BounceWeaponIcon = false
SWEP.ViewModel = "models/swamponions/vape.mdl"
SWEP.WorldModel = "models/swamponions/vape.mdl"
SWEP.Spawnable = true
SWEP.Primary.Clipsize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Clipsize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = false
SWEP.HoldType = "slam"
SWEP.VapeID = 1
SWEP.DrawCrosshair = false

function SWEP:Deploy()
    self:SetHoldType("slam")
end

function SWEP:PrimaryAttack()
    if SERVER then
        VapeUpdate(self.Owner, self.VapeID)
    end

    self.Weapon:SetNextPrimaryFire(CurTime() + 0.1)
end

function SWEP:SecondaryAttack()
    -- if GetConVar("vape_block_sounds"):GetBool() then return end
    local pitch = 100 + (self.SoundPitchMod or 0) + (self.Owner:Crouching() and 40 or 0)

    self:ExtEmitSound("vapegogreen.wav", {
        pitch = pitch,
        speech = -1
    })
end

function SWEP:Reload()
    -- if GetConVar("vape_block_sounds"):GetBool() then return end
    if self.reloading then return end
    self.reloading = true

    timer.Simple(0.5, function()
        self.reloading = false
    end)

    local pitch = 100 + (self.SoundPitchMod or 0) + (self.Owner:Crouching() and 40 or 0)

    self:ExtEmitSound("vapenaysh.wav", {
        pitch = pitch,
        speech = -1
    })
end

function SWEP:Holster()
    if SERVER and IsValid(self.Owner) then
        ReleaseVape(self.Owner)
    end

    return true
end

SWEP.OnDrop = SWEP.Holster
SWEP.OnRemove = SWEP.Holster
