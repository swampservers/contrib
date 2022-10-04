﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "pistol"
SWEP.PrintName = "Glock"
SWEP.Purpose = "Lightweight pistol"
SWEP.HoldType = "pistol"
SWEP.Slot = 0
CSKillIcon(SWEP, "c")
--
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.ShootSound = "Weapon_Glock.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.00
--
SWEP.Primary.Ammo = "BULLET_PLAYER_9MM"
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = false
SWEP.Damage = 25 --26
SWEP.CycleTime = 0.13
SWEP.HalfDamageDistance = 2048
--
SWEP.SpreadBase = 0.008
SWEP.SpreadMove = 0.01
SWEP.Spray = 0.05
SWEP.SprayExponent = 3

ComputeSpray(SWEP, {
    TapFireInterval = 0.3,
    ShotsTo90Spray = 8
})

--
SWEP.KickUBase = 0.3
SWEP.KickUSpray = 1.875
SWEP.KickLBase = 0.225
SWEP.KickLSpray = 0.3
SWEP.MoveSpeed = 1
--
SWEP.AmmoPriceMod = 1.5
-- SWEP.KickMoving = {0.45, 0.3, 0.2, 0.0275, 4, 2.25, 7}
-- SWEP.KickStanding = {0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8}
-- SWEP.KickCrouching = {0.275, 0.2, 0.125, 0.02, 3, 1, 9}
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"		"250"
-- 	"WeaponType"			"Pistol"
-- 	"FullAuto"				0
-- 	"WeaponPrice"			"400"
-- 	"WeaponArmorRatio"		"1.05"
-- 	"CrosshairMinDistance"		"8"
-- 	"CrosshairDeltaDistance"	"3"
-- 	"Team" 				"ANY"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension" 	"pistol"
-- 	"MuzzleFlashScale"		"1.0"
-- 	"CanEquipWithShield"		"1"
-- 	// Weapon characteristics:
-- 	"Penetration"			"1"
-- 	"Damage"			"25"
-- 	"Range"				"4096"
-- 	"RangeModifier"			"0.75"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.15"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00400
-- 	"InaccuracyCrouch"			0.00750
-- 	"InaccuracyStand"			0.01000
-- 	"InaccuracyJump"			0.27750
-- 	"InaccuracyLand"			0.05550
-- 	"InaccuracyLadder"			0.01850
-- 	"InaccuracyFire"			0.03167
-- 	"InaccuracyMove"			0.01665
-- 	"SpreadAlt"					0.00400
-- 	"InaccuracyCrouchAlt"		0.00750
-- 	"InaccuracyStandAlt"		0.01000
-- 	"InaccuracyJumpAlt"			0.27750
-- 	"InaccuracyLandAlt"			0.05550
-- 	"InaccuracyLadderAlt"		0.01850
-- 	"InaccuracyFireAlt"			0.02217
-- 	"InaccuracyMoveAlt"			0.01665
-- 	"RecoveryTimeCrouch"		0.21875
-- 	"RecoveryTimeStand"			0.26249
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_Glock18"
-- 	"viewmodel"			"models/weapons/v_pist_glock18.mdl"
-- 	"playermodel"			"models/weapons/w_pist_glock18.mdl"
-- 	"shieldviewmodel"		"models/weapons/v_shield_glock18_r.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"1"
-- 	"bucket_position"		"1"
-- 	"clip_size"			"20"
-- 	"primary_ammo"			"BULLET_PLAYER_9MM"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"5"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_Glock.Single"
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"C"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"C"
-- 		}
-- 		"ammo"
-- 		{
-- 				"font"		"CSTypeDeath"
-- 				"character"		"R"
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
-- 			Mins	"-8 -4 -14"
-- 			Maxs	"17 9 -1"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-1 -3 -3"
-- 			Maxs	"11 4 4"
-- 		}
-- 	}
-- }]])
-- function SWEP:Deploy()
--     self:SetAccuracy(0.9)
--     return BaseClass.Deploy(self)
-- end
-- -- function SWEP:PrimaryAttack()
-- --     if self:GetNextPrimaryFire() > CurTime() then return end
-- --     self:GunFire(self:BuildSpread(), true) -- self:GetBurstFireEnabled())
-- -- end
-- -- function SWEP:TranslateViewModelActivity(act)
-- --     if self:GetBurstFireEnabled() and act == ACT_VM_PRIMARYATTACK then
-- --         return ACT_VM_SECONDARYATTACK
-- --     else
-- --         return BaseClass.TranslateViewModelActivity(self, act)
-- --     end
-- -- end
-- function SWEP:GunFire(spread, mode)
--     self:SetAccuracy(self:GetAccuracy() - 0.275 * (0.325 - CurTime() - self:GetLastFire()))
--     if self:GetAccuracy() > 0.9 then
--         self:SetAccuracy(0.9)
--     elseif self:GetAccuracy() < 0.6 then
--         self:SetAccuracy(0.6)
--     end
--     self:BaseGunFire(spread, self.CycleTime, mode)
-- end
-- It had no kick...?
