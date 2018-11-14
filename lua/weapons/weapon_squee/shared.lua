SWEP.PrintName = "Squee"

SWEP.Slot = 2

SWEP.WorldModel = ""

SWEP.Primary.ClipSize			= -1
SWEP.Primary.Damage				= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic			= false
SWEP.Primary.Ammo				= "none"

SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Damage			= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo				= "none"

function SWEP:PrimaryAttack()
	self:ExtEmitSound("squee.wav", {shared=true})
end

function SWEP:SecondaryAttack()
	self:ExtEmitSound("boop.wav", {shared=true})
end
