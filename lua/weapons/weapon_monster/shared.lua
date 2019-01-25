
SWEP.PrintName = "Monster Zero" 
SWEP.Author	= "Noz"
SWEP.Instructions = "Left click for a sip. Right click for a boomer phrase."
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

SWEP.ViewModel	= "models/misc/monsterzero.mdl"
SWEP.WorldModel	= "models/misc/monsterzero.mdl"

function SWEP:Initialize()
    self:SetWeaponHoldType("slam") 
end

function SWEP:PrimaryAttack()
	if SERVER then MonsterUpdate(self.Owner) end
	self.Weapon:SetNextPrimaryFire(CurTime() + .1)
end

function SWEP:SecondaryAttack()
	self:ExtEmitSound("boomer/phrase.wav", {shared=true})
end

SWEP.OnDrop = SWEP.Holster
SWEP.OnRemove = SWEP.Holster