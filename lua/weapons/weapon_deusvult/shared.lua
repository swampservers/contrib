SWEP.PrintName = "DEUS VULT"

SWEP.Slot = 2

SWEP.WorldModel = ""

function SWEP:PrimaryAttack()
	self:ExtEmitSound("deusvult.wav", {speech=0.8, pitch=math.random(90,110),crouchpitch=math.random(150,170)})
end

function SWEP:SecondaryAttack()
end