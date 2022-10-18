-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "pistol"
SWEP.Purpose = "High DPS pistol, but small magazine"
SWEP.PrintName = "P228"
SWEP.HoldType = "pistol"
SWEP.Slot = 0
CSKillIcon(SWEP, "y")
--
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.ShootSound = "Weapon_P228.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.00
--
SWEP.Primary.Ammo = "BULLET_PLAYER_357SIG"
SWEP.Primary.ClipSize = 13
SWEP.Primary.DefaultClip = 13
SWEP.Primary.Automatic = false
SWEP.Damage = 30
SWEP.CycleTime = 0.14
SWEP.HalfDamageDistance = 2048
--
SWEP.SpreadBase = 0.008
SWEP.SpreadMove = 0.01
SWEP.Spray = 0.05
SWEP.SprayExponent = 3

ComputeSpray(SWEP, {
    TapFireInterval = 0.4,
    ShotsTo90Spray = 7
})

--
SWEP.KickUBase = 0.325
SWEP.KickUSpray = 1.875
SWEP.KickLBase = 0.225
SWEP.KickLSpray = 0.3
SWEP.MoveSpeed = 1
--
SWEP.SpawnPriceMod = 1.5
-- SWEP.KickMoving = {0.45, 0.3, 0.2, 0.0275, 4, 2.25, 7}
-- SWEP.KickStanding = {0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8}
-- SWEP.KickCrouching = {0.275, 0.2, 0.125, 0.02, 3, 1, 9}
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed" 		"250"
-- 	"WeaponType" 			"Pistol"
-- 	"FullAuto"				0
-- 	"WeaponPrice" 			"600"
-- 	"WeaponArmorRatio" 		"1.25"
-- 	"CrosshairMinDistance"		"8"
-- 	"CrosshairDeltaDistance"	"3"
-- 	"Team" 				"ANY"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension" 	"pistol"
-- 	"MuzzleFlashScale"		"1"
-- 	"CanEquipWithShield"		"1"
-- 	// Weapon characteristics:
-- 	"Penetration"			"1"
-- 	"Damage"			"40"
-- 	"Range"				"4096"
-- 	"RangeModifier"			"0.8"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.15"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00400
-- 	"InaccuracyCrouch"			0.00825
-- 	"InaccuracyStand"			0.01100
-- 	"InaccuracyJump"			0.28500
-- 	"InaccuracyLand"			0.05700
-- 	"InaccuracyLadder"			0.01900
-- 	"InaccuracyFire"			0.03318
-- 	"InaccuracyMove"			0.01710
-- 	"RecoveryTimeCrouch"		0.23026
-- 	"RecoveryTimeStand"			0.27631
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_P228"
-- 	"viewmodel"			"models/weapons/v_pist_p228.mdl"
-- 	"shieldviewmodel"		"models/weapons/v_shield_p228_r.mdl"
-- 	"playermodel"			"models/weapons/w_pist_p228.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"1"
-- 	"bucket_position"		"1"
-- 	"clip_size"			"13"
-- 	"primary_ammo"			"BULLET_PLAYER_357SIG"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"5"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_P228.Single"
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"Y"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"Y"
-- 		}
-- 		"ammo"
-- 		{
-- 				"font"		"CSTypeDeath"
-- 				"character"		"T"
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
-- 			Mins	"-8 -3 -14"
-- 			Maxs	"17 9 0"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-1 -3 -2"
-- 			Maxs	"10 3 5"
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
