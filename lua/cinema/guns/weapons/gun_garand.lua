-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "sniper"
SWEP.PrintName = "M1 Garand"
SWEP.Purpose = "Powerful semi-automatic rifle. Can remove props."
SWEP.HoldType = "ar2"
SWEP.Slot = 0
-- CSKillIcon(SWEP, "o")
--
SWEP.WorldModel = "models/weapons/w_garand.mdl"
SWEP.ViewModel = "models/weapons/c_dod_garand.mdl"

sound.Add({
    name = "DOD_Garand.Fire",
    channel = CHAN_STATIC,
    volume = 0.9,
    level = 70,
    sound = {"dod_garand/scar20_01.wav", "dod_garand/scar20_02.wav", "dod_garand/scar20_03.wav"}
})

SWEP.ShootSound = "DOD_Garand.Fire"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = true
SWEP.CSMuzzleFlashScale = 1.60
--
SWEP.Primary.Ammo = "BULLET_PLAYER_556MM"
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false
SWEP.Damage = 65
SWEP.CycleTime = 0.22
SWEP.HalfDamageDistance = 16384
--
SWEP.SpreadBase = 0.004
SWEP.SpreadMove = 0.1
SWEP.Spray = 0.1
SWEP.SprayExponent = 3

ComputeSpray(SWEP, {
    TapFireInterval = 0.65,
    ShotsTo90Spray = 5
})

--
-- SWEP.ScopeLevels = {40 / 90, 10 / 90}
SWEP.MoveSpeed = 220 / 250
SWEP.ScopedSpeedRatio = 220 / 260
SWEP.KickUBase = 1
SWEP.KickUSpray = 1
SWEP.KickLBase = 0
SWEP.KickLSpray = 1.5
--
SWEP.AmmoPriceMod = 0.5

function SWEP:GunFire()
    local basedfire = BaseClass.GunFire(self)

    if basedfire and self:Clip1() == 0 then
        -- timer.Simple(0.01, function()
        if IsValid(self) and IsValid(self.Owner) then
            self.Owner:EmitSound("dod_garand/garand_clipding.wav")
        end
        -- end)
    end

    return basedfire
end
