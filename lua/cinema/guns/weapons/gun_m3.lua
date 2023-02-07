-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "shotgun"
SWEP.PrintName = "M3"
SWEP.Purpose = "Powerful shotgun."
SWEP.HoldType = "shotgun"
SWEP.Slot = 0
CSKillIcon(SWEP, "k")
--
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.ShootSound = "Weapon_M3.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.30
--
SWEP.Primary.Ammo = "BULLET_PLAYER_BUCKSHOT"
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false
SWEP.Damage = 11
SWEP.CycleTime = 0.88
SWEP.HalfDamageDistance = 1024 * 0.88
--
SWEP.SpreadBase = 0.005
SWEP.SpreadMove = 0.02
SWEP.Spray = 0.12
SWEP.SprayExponent = 2

ComputeSpray(SWEP, {
    TapFireInterval = 1.5,
    ShotsTo90Spray = 5
})

--
SWEP.NumPellets = 12
SWEP.PelletSpread = 0.04
SWEP.UseShellReload = true
SWEP.KickUBase = 5
SWEP.KickUSpray = 0
SWEP.KickLBase = 0
SWEP.KickLSpray = 1
SWEP.MoveSpeed = 220 / 250
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed" 		"220"
-- 	"WeaponType"			"Shotgun"
-- 	"FullAuto"				1
-- 	"WeaponPrice"			"1700"
-- 	"WeaponArmorRatio"		"1.0"
-- 	"CrosshairMinDistance"		"8"
-- 	"CrosshairDeltaDistance"	"6"
-- 	"Team"				"ANY"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension" 	"m3s90"
-- 	"MuzzleFlashScale"		"1.3"
-- 	"CanEquipWithShield"		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"			"1"
-- 	"Damage"			"26"
-- 	"Range"				"3000"
-- 	"RangeModifier"			"0.70"
-- 	"Bullets"			"9"
-- 	"CycleTime"			"0.88"
-- 	// New accuracy model parameters
-- 	"Spread"					0.04000
-- 	"InaccuracyCrouch"			0.00750
-- 	"InaccuracyStand"			0.01000
-- 	"InaccuracyJump"			0.42000
-- 	"InaccuracyLand"			0.08400
-- 	"InaccuracyLadder"			0.07875
-- 	"InaccuracyFire"			0.04164
-- 	"InaccuracyMove"			0.04320
-- 	"RecoveryTimeCrouch"		0.29605
-- 	"RecoveryTimeStand"			0.41447
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_m3"
-- 	"viewmodel"			"models/weapons/v_shot_m3super90.mdl"
-- 	"playermodel"			"models/weapons/w_shot_m3super90.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"0"
-- 	"bucket_position"		"0"
-- 	"clip_size"			"8"
-- 	"primary_ammo"			"BULLET_PLAYER_BUCKSHOT"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"20"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_M3.Single"
-- 		special3			Default.Zoom
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"K"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"K"
-- 		}
-- 		"ammo"
-- 		{
-- 				"font"		"CSTypeDeath"
-- 				"character"		"J"
-- 		}
-- 		"crosshair"
-- 		{
-- 				"file"		"sprites/crosshairs"
-- 				"x"			"0"
-- 				"y"			"48"
-- 				"width"		"24"
-- 				"height"	"24"
-- 		}
-- 		"autoaim"
-- 		{
-- 				"file"		"sprites/crosshairs"
-- 				"x"			"0"
-- 				"y"			"48"
-- 				"width"		"24"
-- 				"height"	"24"
-- 		}
-- 	}
-- 	ModelBounds
-- 	{
-- 		Viewmodel
-- 		{
-- 			Mins	"-13 -3 -13"
-- 			Maxs	"26 10 -3"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-9 -8 -5"
-- 			Maxs	"28 9 9"
-- 		}
-- 	}
-- }]])
-- function SWEP:PrimaryAttack()
--     local pPlayer = self.Owner
--     if not IsValid(pPlayer) then return end
--     if self:GetNextPrimaryFire() > CurTime() then return end
--     if pPlayer:WaterLevel() == 3 then
--         self:PlayEmptySound()
--         self:SetNextPrimaryFire(CurTime() + 0.2)
--         return false
--     end
--     local spread = self:BuildSpread()
--     if not self:BaseGunFire(spread, self.CycleTime, true) then return end
--     self:SetSpecialReload(0)
--     local angle = pPlayer:GetViewPunchAngles()
--     -- Update punch angles.
--     if not pPlayer:OnGround() then
--         angle.x = angle.x - util.SharedRandom("M3PunchAngleGround", 4, 6)
--     else
--         angle.x = angle.x - util.SharedRandom("M3PunchAngle", 8, 11)
--     end
--     pPlayer:SetViewPunchAngles(angle)
--     return true
-- end
