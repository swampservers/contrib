-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "ASS WE CAN"
SWEP.Slot = 2
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.HoldType = "normal"
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

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    self:ExtEmitSound("billyh/asswecan.ogg", {
        speech = 1.25,
        shared = true
    })
end

function SWEP:SecondaryAttack()
    self:ExtEmitSound("billyh/endurethelash.ogg", {
        speech = 2.1,
        shared = true
    })
end

function SWEP:OnRemove()
    if self.Owner and self.Owner:IsValid() then
        self:ExtEmitSound("billyh/spank.ogg", {
            shared = true,
            channel = CHAN_AUTO
        })
    end
end
