-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
if (SERVER) then
    function SWEP:Deploy()
        self.Owner:DrawViewModel(false)
    end

    SWEP.HoldType = "normal"
end

SWEP.DrawWeaponInfoBox = true
SWEP.Instructions = "Wow, it's nothing."
SWEP.Category = "Swamp Cinema"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.IconLetter = "C"
SWEP.Primary.Recoil = 0
SWEP.Primary.Damage = 0
SWEP.Primary.NumShots = -1
SWEP.Primary.Delay = 3
SWEP.Primary.Distance = 75
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 3
SWEP.ViewModel = Model("models/weapons/v_pistol.mdl")
SWEP.WorldModel = ""

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:DrawWorldModel()
end

function SWEP:Reload()
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end