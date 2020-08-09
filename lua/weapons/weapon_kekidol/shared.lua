SWEP.PrintName = "KEK Frog Idol"
SWEP.Purpose = "An ancient artifact of unknown origin. Very likely to fetch a reasonable sum of money."
SWEP.Spawnable = true

SWEP.Slot = 0

SWEP.ViewModel = "models/swamponions/kekfrog.mdl"
SWEP.WorldModel = "models/swamponions/kekfrog.mdl"
SWEP.HoldType = "slam"
SWEP.Material = Material("models/swamponions/kekfrog_gold")

SWEP.IdolPrize = 100000 --prize the player gets in points for reaching the surface in time
SWEP.IdolTimer = 100 --seconds the player should have to reach the surface
SWEP.IdolRespawnTime = 60*10 --seconds after the player fails that the artifact will respawn

function SWEP:Think() end
function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end

function SWEP:Deploy() self:SetHoldType(self.HoldType) end

function SWEP:Holster() return true end
