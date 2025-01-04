-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "smg"
SWEP.PrintName = "P90"
SWEP.Purpose = "Mobile SMG with lots of ammo"
SWEP.HoldType = "ar2"
SWEP.Slot = 0
CSKillIcon(SWEP, "m")
--
SWEP.WorldModel = "models/weapons/w_smg_p90.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_smg_p90.mdl"
SWEP.ShootSound = "Weapon_P90.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = true
SWEP.CSMuzzleFlashScale = 1.20
--
SWEP.Primary.Ammo = "BULLET_PLAYER_57MM"
SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true
SWEP.Damage = 21 --26
SWEP.CycleTime = 0.066
SWEP.HalfDamageDistance = 4096
--
SWEP.SpreadBase = 0.01
SWEP.SpreadMove = 0.01
SWEP.Spray = 0.05
SWEP.SprayExponent = 3

ComputeSpray(SWEP, {
    TapFireInterval = 0.3,
    ShotsTo90Spray = 20
})

-- 
SWEP.KickDance = 1
SWEP.KickUBase = 0.2
SWEP.KickUSpray = 1.5
SWEP.KickLBase = 0.1
SWEP.KickLSpray = 0.3
SWEP.MoveSpeed = 245 / 250
--
SWEP.AmmoPriceMod = 1.5
SWEP.CSPrice = 2350
-- SWEP.KickMoving = {0.45, 0.3, 0.2, 0.0275, 4, 2.25, 7}
-- SWEP.KickStanding = {0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8}
-- SWEP.KickCrouching = {0.275, 0.2, 0.125, 0.02, 3, 1, 9}
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"		"245"
-- 	"WeaponType"			"SubMachinegun"
-- 	"FullAuto"				1
-- 	"WeaponPrice"			"2350"
-- 	"WeaponArmorRatio"		"1.5"
-- 	"CrosshairMinDistance"		"7"
-- 	"CrosshairDeltaDistance"	"3"
-- 	"Team"				"ANY"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension"	"p90"
-- 	"MuzzleFlashScale"		"1.2"
-- 	"MuzzleFlashStyle"		"CS_MUZZLEFLASH_X"
-- 	"CanEquipWithShield"		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"			"1"
-- 	"Damage"			"26"
-- 	"Range"				"4096"
-- 	"RangeModifier"			"0.84"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.07"
-- 	"AccuracyQuadratic"		"1"
-- 	"AccuracyDivisor"		"175"
-- 	"AccuracyOffset"		"0.45"
-- 	"MaxInaccuracy"			"1.0"
-- 	"TimeToIdle"			"2"
-- 	"IdleInterval"			"20"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00100
-- 	"InaccuracyCrouch"			0.01463
-- 	"InaccuracyStand"			0.01951
-- 	"InaccuracyJump"			0.16494
-- 	"InaccuracyLand"			0.03299
-- 	"InaccuracyLadder"			0.04124
-- 	"InaccuracyFire"			0.00732
-- 	"InaccuracyMove"			0.01062
-- 	"RecoveryTimeCrouch"		0.23289
-- 	"RecoveryTimeStand"			0.32605
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_P90"
-- 	"viewmodel"			"models/weapons/v_smg_p90.mdl"
-- 	"playermodel"			"models/weapons/w_smg_p90.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"0"
-- 	"bucket_position"		"0"
-- 	"clip_size"			"50"
-- 	"primary_ammo"			"BULLET_PLAYER_57MM"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"26"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_P90.Single"
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"M"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"M"
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
-- 			Mins	"-8 -3 -13"
-- 			Maxs	"19 9 -1"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-8 -1 -3"
-- 			Maxs	"14 3 9"
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
