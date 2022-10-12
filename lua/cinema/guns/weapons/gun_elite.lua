﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "pistol"
SWEP.PrintName = "Dual Berettas"
SWEP.Purpose = "How come you get TWO guns?"
SWEP.HoldType = "duel"
SWEP.Slot = 0
CSKillIcon(SWEP, "s")
--
SWEP.WorldModel = "models/weapons/w_pist_elite.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_pist_elite.mdl"
SWEP.ShootSound = "Weapon_Elite.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.00
--
SWEP.Primary.Ammo = "BULLET_PLAYER_9MM"
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = false
SWEP.Damage = 27
SWEP.CycleTime = 0.12
SWEP.HalfDamageDistance = 2048
--
SWEP.SpreadBase = 0.008
SWEP.SpreadMove = 0.01
SWEP.Spray = 0.06
SWEP.SprayExponent = 2

ComputeSpray(SWEP, {
    TapFireInterval = 0.45,
    ShotsTo90Spray = 8
})

--
SWEP.KickDance = 2
SWEP.KickUBase = 0.5
SWEP.KickUSpray = 1.5
SWEP.KickLBase = 0.2
SWEP.KickLSpray = 1
SWEP.MoveSpeed = 1
--
SWEP.SpawnPriceMod = 1.5
SWEP.AmmoPriceMod = 2
-- SWEP.KickMoving = {0.45, 0.3, 0.2, 0.0275, 4, 2.25, 7}
-- SWEP.KickStanding = {0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8}
-- SWEP.KickCrouching = {0.275, 0.2, 0.125, 0.02, 3, 1, 9}
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"		"250"
-- 	"WeaponType" 			"Pistol"
-- 	"FullAuto"				0
-- 	"WeaponPrice" 			"800"
-- 	"WeaponArmorRatio" 		"1.05"
-- 	"CrosshairMinDistance" 		"4"
-- 	"CrosshairDeltaDistance" 	"3"
-- 	"Team" 				"TERRORIST"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension" 	"elites"
-- 	"MuzzleFlashScale"		"1"
-- 	"CanEquipWithShield"		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"		"1"
-- 	"Damage"			"45"
-- 	"Range"				"4096"
-- 	"RangeModifier"		"0.75"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.12"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00400
-- 	"InaccuracyCrouch"			0.00600
-- 	"InaccuracyStand"			0.00800
-- 	"InaccuracyJump"			0.29625
-- 	"InaccuracyLand"			0.05925
-- 	"InaccuracyLadder"			0.01975
-- 	"InaccuracyFire"			0.03162
-- 	"InaccuracyMove"			0.01778
-- 	"RecoveryTimeCrouch"		0.24753
-- 	"RecoveryTimeStand"			0.29703
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_Elites"
-- 	"viewmodel"			"models/weapons/v_pist_elite.mdl"
-- 	"playermodel"			"models/weapons/w_pist_elite.mdl"
-- 	"AddonModel"			"models/weapons/w_pist_elite_single.mdl"
-- 	"DroppedModel"			"models/weapons/w_pist_elite_dropped.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"1"
-- 	"bucket_position"		"1"
-- 	"clip_size"			"30"
-- 	"primary_ammo"			"BULLET_PLAYER_9MM"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"5"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		"single_shot"		"Weapon_Elite.Single"
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"S"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"S"
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
-- 			Mins	"-3 -12 -12"
-- 			Maxs	"18 11 2"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-1 -7 -4"
-- 			Maxs	"12 9 5"
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
