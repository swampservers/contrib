-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SWEP.ViewModel = "models/Teh_Maestro/popcorn.mdl"
SWEP.WorldModel = "models/Teh_Maestro/popcorn.mdl"
SWEP.PrintName = "Popcorn"
SWEP.Slot = 0
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

function SWEP:PrimaryAttack()
    if IsFirstTimePredicted() then
        self.Owner:EmitSound("crisps/eat.wav", 60)
    end

    if SERVER then
        net.Start("EatPopcorn")
        net.WriteEntity(self.Owner)
        net.Broadcast()
        self.Owner:SetHealth(math.min(self.Owner:Health() + 25, self.Owner:GetMaxHealth()))
    end

    self.Weapon:SetNextPrimaryFire(CurTime() + 12)
end
