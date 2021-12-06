



SWEP.PrintName = "Squee"
SWEP.Slot = 2
SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.DrawWeaponInfoBox = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

function SWEP:Initialize()
    self:SetHoldType("normal")
end


function SWEP:PrimaryAttack()
    self:ExtEmitSound("squee.wav", {
        shared = true
    })
end

function SWEP:SecondaryAttack()
    self:ExtEmitSound("boop.wav", {
        shared = true
    })
end

function SWEP:Reload()
    if (self.SqueeReloadCooldown or 0) > CurTime() then return end
    self.SqueeReloadCooldown = CurTime() + 0.7

    self:ExtEmitSound("mowsquee.wav", {
        shared = true
    })
end



