-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "pistol"
SWEP.PrintName = "USP-S"
SWEP.Purpose = "Long range pistol, with silencer."
SWEP.HoldType = "pistol"
SWEP.Slot = 0
CSKillIcon(SWEP, "a")
--
SWEP.WorldModel = "models/weapons/w_pist_usp_silencer.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_pist_usp.mdl"
SWEP.ShootSound = "Weapon_USP.SilencedShot"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.00
--
SWEP.Primary.Ammo = "BULLET_PLAYER_45ACP"
SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Automatic = false
SWEP.Damage = 18 --29
SWEP.CycleTime = 0.14
SWEP.HalfDamageDistance = 4096 * 0.9
--
SWEP.SpreadBase = 0.006
SWEP.SpreadMove = 0.014
SWEP.Spray = 0.05
SWEP.SprayExponent = 2.5

ComputeSpray(SWEP, {
    TapFireInterval = 0.35,
    ShotsTo90Spray = 7
})

--
SWEP.KickUBase = 1
SWEP.KickUSpray = 1
SWEP.KickLBase = 0
SWEP.KickLSpray = 1
SWEP.MoveSpeed = 1
--
SWEP.SpawnPriceMod = 1.05 -- 18 / 17

function SWEP:TranslateViewModelActivity(act)
    return ({
        [ACT_VM_RELOAD] = ACT_VM_RELOAD_SILENCED,
        [ACT_VM_PRIMARYATTACK] = ACT_VM_PRIMARYATTACK_SILENCED,
        [ACT_VM_DRAW] = ACT_VM_DRAW_SILENCED,
        [ACT_VM_IDLE] = ACT_VM_IDLE_SILENCED,
    })[act] or act
end
