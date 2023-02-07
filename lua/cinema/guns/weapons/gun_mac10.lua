-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "smg"
SWEP.PrintName = "MAC-10"
SWEP.Purpose = "It spits lead"
SWEP.HoldType = "pistol"
SWEP.Slot = 0
CSKillIcon(SWEP, "l")
--
SWEP.WorldModel = "models/weapons/w_smg_mac10.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_smg_mac10.mdl"
SWEP.ShootSound = "Weapon_MAC10.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.10
--
SWEP.Primary.Ammo = "BULLET_PLAYER_45ACP"
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Damage = 19 --27
SWEP.CycleTime = 0.06
SWEP.HalfDamageDistance = 2048 * 0.8 --Lots of damage but short range
--
SWEP.SpreadBase = 0.013
SWEP.SpreadMove = 0.01
SWEP.Spray = 0.05
SWEP.SprayExponent = 2

ComputeSpray(SWEP, {
    TapFireInterval = 0.3,
    ShotsTo90Spray = 20
})

--
SWEP.KickDance = 3
SWEP.KickUBase = 0.2
SWEP.KickUSpray = 1
SWEP.KickLBase = 0.1
SWEP.KickLSpray = 0.5
SWEP.MoveKickMultiplier = 2
SWEP.MoveSpeed = 245 / 250
--
SWEP.SpawnPriceMod = 1.06 -- 19 / 18
-- SWEP.KickMoving = {0.45, 0.3, 0.2, 0.0275, 4, 2.25, 7}
-- SWEP.KickStanding = {0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8}
-- SWEP.KickCrouching = {0.275, 0.2, 0.125, 0.02, 3, 1, 9}
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"		"250"
-- 	"WeaponType"			"SubMachinegun"
-- 	"FullAuto"				1
-- 	"WeaponPrice"			"1400"
-- 	"WeaponArmorRatio"		"0.95"
-- 	"CrosshairMinDistance"		"9"
-- 	"CrosshairDeltaDistance"	"3"
-- 	"Team"				"TERRORIST"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension"	"mac10"
-- 	"MuzzleFlashScale"		"1.1"
-- 	"CanEquipWithShield"		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"			"1"
-- 	"Damage"			"29"
-- 	"Range"				"4096"
-- 	"RangeModifier"			"0.82"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.075"
-- 	"AccuracyDivisor"		"200"
-- 	"AccuracyOffset"		"0.6"
-- 	"MaxInaccuracy"			"1.65"
-- 	"TimeToIdle"			"2"
-- 	"IdleInterval"			"20"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00100
-- 	"InaccuracyCrouch"			0.01425
-- 	"InaccuracyStand"			0.01900
-- 	"InaccuracyJump"			0.13704
-- 	"InaccuracyLand"			0.02741
-- 	"InaccuracyLadder"			0.03426
-- 	"InaccuracyFire"			0.00845
-- 	"InaccuracyMove"			0.00620
-- 	"RecoveryTimeCrouch"		0.25263
-- 	"RecoveryTimeStand"			0.35368
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_MAC10"
-- 	"viewmodel"			"models/weapons/v_smg_mac10.mdl"
-- 	"playermodel"			"models/weapons/w_smg_mac10.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"0"
-- 	"bucket_position"		"0"
-- 	"clip_size"			"30"
-- 	"primary_ammo"			"BULLET_PLAYER_45ACP"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"25"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_MAC10.Single"
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"L"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"L"
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
-- 			Mins	"-4 -5 -14"
-- 			Maxs	"20 10 0"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-2 -4 -7"
-- 			Maxs	"13 4 7"
-- 		}
-- 	}
-- }]])
-- print(SWEP.WeaponData)
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
