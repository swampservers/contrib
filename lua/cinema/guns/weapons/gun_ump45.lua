-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "smg"
SWEP.PrintName = "UMP-45"
SWEP.Purpose = "High damage, long range SMG"
SWEP.HoldType = "smg"
SWEP.Slot = 0
CSKillIcon(SWEP, "q")
--
SWEP.WorldModel = "models/weapons/w_smg_ump45.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_smg_ump45.mdl"
SWEP.ShootSound = "Weapon_UMP45.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.15
--
SWEP.Primary.Ammo = "BULLET_PLAYER_45ACP"
SWEP.Primary.ClipSize = 25
SWEP.Primary.DefaultClip = 25
SWEP.Primary.Automatic = true
SWEP.Damage = 28 --36
SWEP.CycleTime = 0.102
SWEP.HalfDamageDistance = 4096
--
SWEP.SpreadBase = 0.008
SWEP.SpreadMove = 0.02
SWEP.Spray = 0.05
SWEP.SprayExponent = 2.5

ComputeSpray(SWEP, {
    TapFireInterval = 0.5,
    ShotsTo90Spray = 16
})

--
SWEP.KickUBase = 0.3
SWEP.KickUSpray = 1
SWEP.KickLBase = 0.2
SWEP.KickLSpray = 0.3
SWEP.MoveSpeed = 1

SWEP.CSPrice  = 1700
-- SWEP.KickMoving = {0.45, 0.3, 0.2, 0.0275, 4, 2.25, 7}
-- SWEP.KickStanding = {0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8}
-- SWEP.KickCrouching = {0.275, 0.2, 0.125, 0.02, 3, 1, 9}
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"		"250"
-- 	"WeaponType"			"SubMachinegun"
-- 	"FullAuto"				1
-- 	"WeaponPrice"			"1700"
-- 	"WeaponArmorRatio"		"1.0"
-- 	"CrosshairMinDistance"		"6"
-- 	"CrosshairDeltaDistance"	"3"
-- 	"Team"				"ANY"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension"	"ump45"
-- 	"MuzzleFlashScale"		"1.15"
-- 	"CanEquipWithShield"		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"			"1"
-- 	"Damage"			"30"
-- 	"Range"				"4096"
-- 	"RangeModifier"			"0.82"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.105"
-- 	"AccuracyQuadratic"		"1"
-- 	"AccuracyDivisor"		"210"
-- 	"AccuracyOffset"		"0.5"
-- 	"MaxInaccuracy"			"1"
-- 	"TimeToIdle"			"2"
-- 	"IdleInterval"			"20"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00100
-- 	"InaccuracyCrouch"			0.01439
-- 	"InaccuracyStand"			0.01919
-- 	"InaccuracyJump"			0.16941
-- 	"InaccuracyLand"			0.03388
-- 	"InaccuracyLadder"			0.04235
-- 	"InaccuracyFire"			0.01129
-- 	"InaccuracyMove"			0.01366
-- 	"RecoveryTimeCrouch"		0.21710
-- 	"RecoveryTimeStand"			0.30394
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_UMP45"
-- 	"viewmodel"			"models/weapons/v_smg_ump45.mdl"
-- 	"playermodel"			"models/weapons/w_smg_ump45.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"0"
-- 	"bucket_position"		"0"
-- 	"clip_size"			"25"
-- 	"primary_ammo"			"BULLET_PLAYER_45ACP"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"25"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_UMP45.Single"
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"Q"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"Q"
-- 		}
-- 		"ammo"
-- 		{
-- 				"font"		"CSTypeDeath"
-- 				"character"		"M"
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
-- 			Mins	"-7 -1 -15"
-- 			Maxs	"27 11 -2"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-10 -7 -8"
-- 			Maxs	"20 8 8"
-- 		}
-- 	}
-- }]])
-- function SWEP:PrimaryAttack()
--     if self:GetNextPrimaryFire() > CurTime() then return end
--     self:GunFire(self:BuildSpread())
-- end
-- function SWEP:GunFire(spread)
--     if not self:BaseGunFire(spread, self.CycleTime, true) then return end
--     if self:GetOwner():GetAbsVelocity():Length2D() > 5 then
--         self:KickBack(0.45, 0.3, 0.2, 0.0275, 4, 2.25, 7)
--     elseif not self:GetOwner():OnGround() then
--         self:KickBack(0.9, 0.45, 0.35, 0.04, 5.25, 3.5, 4)
--     elseif self:GetOwner():Crouching() then
--         self:KickBack(0.275, 0.2, 0.125, 0.02, 3, 1, 9)
--     else
--         self:KickBack(0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8)
--     end
-- end
