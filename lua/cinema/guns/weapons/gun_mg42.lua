-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "lmg"
SWEP.PrintName = "MG42"
SWEP.Purpose = "Very high rate of fire; easier to control when crouched."
SWEP.HoldType = "ar2"
SWEP.Slot = 0
-- autoicon plz
--
SWEP.WorldModel = "models/weapons/w_mg42bu.mdl"
SWEP.ViewModel = "models/weapons/c_dod_mg42.mdl"

sound.Add({
    name = "DOD_MG42.Fire",
    channel = CHAN_WEAPON,
    volume = 0.8,
    level = 75,
    sound = "weapons/dod_mg42/negev-1.wav"
})

SWEP.ShootSound = "DOD_MG42.Fire"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = true
SWEP.CSMuzzleFlashScale = 1.50
--
SWEP.Primary.Ammo = "BULLET_PLAYER_556MM_BOX"
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Damage = 32
SWEP.CycleTime = 0.05 --4
SWEP.HalfDamageDistance = 8192
--
SWEP.SpreadBase = 0.008
SWEP.SpreadMove = 0.08
SWEP.Spray = 0.08
SWEP.SprayExponent = 3

ComputeSpray(SWEP, {
    TapFireInterval = 0.4,
    ShotsTo90Spray = 20
})

--
SWEP.CrouchSprayDecayMultiplier = 2
SWEP.CrouchKickMultiplier = 0.4
SWEP.KickUBase = 1
SWEP.KickUSpray = 1
SWEP.KickLBase = 0.35
SWEP.KickLSpray = 0.5
SWEP.MoveSpeed = 200 / 250
--
SWEP.KickDance = 3
SWEP.CrouchKickDanceMultiplier = 0.2
--
SWEP.SpawnPriceMod = 1.2
