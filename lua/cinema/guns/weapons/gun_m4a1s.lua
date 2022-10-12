-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "ar"
SWEP.PrintName = "M4A1-S"
SWEP.Purpose = "Good for firing short bursts and taps. Silencer attached."
SWEP.HoldType = "ar2"
SWEP.Slot = 0
CSKillIcon(SWEP, "w")
--
SWEP.WorldModel = "models/weapons/w_rif_m4a1_silencer.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.ShootSound = "Weapon_M4A1.Silenced"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.60
--
SWEP.Primary.Ammo = "BULLET_PLAYER_556MM"
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
-- headshot only at point blank
SWEP.Damage = 26.8 --33.6
SWEP.CycleTime = 0.0900
SWEP.HalfDamageDistance = 16384 * 0.66
--
SWEP.SpreadBase = 0.004
SWEP.SpreadMove = 0.06
SWEP.Spray = 0.06
SWEP.SprayExponent = 3

ComputeSpray(SWEP, {
    TapFireInterval = 0.35,
    ShotsTo90Spray = 16
})

--
SWEP.KickUBase = 0.2
SWEP.KickUSpray = 2.5
SWEP.KickLBase = 0.05
SWEP.KickLSpray = 0.3
SWEP.MoveSpeed = 230 / 250

function SWEP:TranslateViewModelActivity(act)
    return ({
        [ACT_VM_RELOAD] = ACT_VM_RELOAD_SILENCED,
        [ACT_VM_PRIMARYATTACK] = ACT_VM_PRIMARYATTACK_SILENCED,
        [ACT_VM_DRAW] = ACT_VM_DRAW_SILENCED,
        [ACT_VM_IDLE] = ACT_VM_IDLE_SILENCED,
    })[act] or act
end
