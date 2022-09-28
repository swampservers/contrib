﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "pistol"
SWEP.PrintName = "Five-Seven"
SWEP.Purpose = "High damage pistol"
SWEP.HoldType = "pistol"
SWEP.Slot = 0
CSKillIcon(SWEP, "u")
--
SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.ShootSound = "Weapon_FiveSeven.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.00
--
SWEP.Primary.Ammo = "BULLET_PLAYER_57MM"
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = false
SWEP.Damage = 34
SWEP.CycleTime = 0.14
SWEP.HalfDamageDistance = 2048
--
SWEP.SpreadBase = 0.008
SWEP.SpreadMove = 0.01
SWEP.Spray = 0.05
SWEP.SprayExponent = 2

ComputeSpray(SWEP, {
    TapFireInterval = 0.4,
    ShotsTo90Spray = 6
})

--
SWEP.KickUBase = 0.8
SWEP.KickUSpray = 1
SWEP.KickLBase = 0.2
SWEP.KickLSpray = 0.3
SWEP.MoveSpeed = 1
--
SWEP.SpawnPriceMod = 1.5
SWEP.AmmoPriceMod = 1.5
-- SWEP.KickMoving = {0.45, 0.3, 0.2, 0.0275, 4, 2.25, 7}
-- SWEP.KickStanding = {0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8}
-- SWEP.KickCrouching = {0.275, 0.2, 0.125, 0.02, 3, 1, 9}
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"		"250"
-- 	"WeaponType"			"Pistol"
-- 	"FullAuto"				0
-- 	"WeaponPrice"			"750"
-- 	"WeaponArmorRatio"		"1.5"
-- 	"CrosshairMinDistance"		"8"
-- 	"CrosshairDeltaDistance"	"3"
-- 	"Team"				"CT"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension"	"pistol"
-- 	"MuzzleFlashScale"		"1"
-- 	"CanEquipWithShield"		"1"
-- 	// Weapon characteristics:
-- 	"Penetration"			"1"
-- 	"Damage"			"25"
-- 	"Range"				"4096"
-- 	"RangeModifier"			"0.885"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.15"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00400
-- 	"InaccuracyCrouch"			0.00600
-- 	"InaccuracyStand"			0.01000
-- 	"InaccuracyJump"			0.25635
-- 	"InaccuracyLand"			0.05127
-- 	"InaccuracyLadder"			0.01709
-- 	"InaccuracyFire"			0.05883
-- 	"InaccuracyMove"			0.01538
-- 	"RecoveryTimeCrouch"		0.18628
-- 	"RecoveryTimeStand"			0.22353
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_FiveSeven"
-- 	"viewmodel"			"models/weapons/v_pist_fiveseven.mdl"
-- 	"playermodel"			"models/weapons/w_pist_fiveseven.mdl"
-- 	"shieldviewmodel"		"models/weapons/v_shield_fiveseven_r.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"1"
-- 	"bucket_position"		"1"
-- 	"clip_size"			"20"
-- 	"primary_ammo"			"BULLET_PLAYER_57MM"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"5"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_FiveSeven.Single"
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"U"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"U"
-- 		}
-- 		"ammo"
-- 		{
-- 				"font"		"CSTypeDeath"
-- 				"character"		"S"
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
-- 			Mins	"-8 -4 -16"
-- 			Maxs	"18 9 -3"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-1 -3 -2"
-- 			Maxs	"11 4 5"
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
