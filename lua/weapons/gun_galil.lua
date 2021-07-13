-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
DEFINE_BASECLASS("gun")
SWEP.GunType = "ar"
SWEP.PrintName = "Galil"
SWEP.Purpose = "Good for spraying."
SWEP.HoldType = "ar2"
SWEP.Slot = 0
CSKillIcon(SWEP, "v")
--
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.ShootSound = "Weapon_Galil.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = true
SWEP.CSMuzzleFlashScale = 1.60
--
SWEP.Primary.Ammo = "BULLET_PLAYER_556MM"
SWEP.Primary.ClipSize = 35
SWEP.Primary.DefaultClip = 35
SWEP.Primary.Automatic = true
SWEP.Damage = 33
SWEP.CycleTime = 0.0900
SWEP.HalfDamageDistance = 8192
--
SWEP.SpreadBase = 0.006
SWEP.SpreadMove = 0.06
SWEP.Spray = 0.045
SWEP.SprayExponent = 3

ComputeSpray(SWEP, {
    TapFireInterval = 0.45,
    ShotsTo90Spray = 18
})

--
SWEP.KickUBase = 0.3
SWEP.KickUSpray = 1.8
SWEP.KickLBase = 0.2
SWEP.KickLSpray = 0.3
-- SWEP.KickMoving = {0.45, 0.3, 0.2, 0.0275, 4, 2.25, 7}
-- SWEP.KickStanding = {0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8}
-- SWEP.KickCrouching = {0.275, 0.2, 0.125, 0.02, 3, 1, 9}
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"		"215"
-- 	"WeaponType"			"Rifle"
-- 	"FullAuto"				1
-- 	"WeaponPrice"			"2000"
-- 	"WeaponArmorRatio"		"1.55"
-- 	"CrosshairMinDistance"		"4"
-- 	"CrosshairDeltaDistance"	"3"
-- 	"Team"				"TERRORIST"
-- 	"BuiltRightHanded" 		"1"
-- 	"PlayerAnimationExtension"	"galil"
-- 	"MuzzleFlashScale"		"1.6"
-- 	"MuzzleFlashStyle"		"CS_MUZZLEFLASH_X"
-- 	"CanEquipWithShield" 		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"			"2"
-- 	"Damage"			"30"
-- 	"Range"				"8192"
-- 	"RangeModifier"			"0.98"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.09"
-- 	"AccuracyDivisor"		"200"
-- 	"AccuracyOffset"		"0.35"
-- 	"MaxInaccuracy"			"1.25"
-- 	"TimeToIdle"			"1.28"
-- 	"IdleInterval"			"20"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00060
-- 	"InaccuracyCrouch"			0.00939
-- 	"InaccuracyStand"			0.01253
-- 	"InaccuracyJump"			0.45434
-- 	"InaccuracyLand"			0.09087
-- 	"InaccuracyLadder"			0.11358
-- 	"InaccuracyFire"			0.00984
-- 	"InaccuracyMove"			0.10561
-- 	"RecoveryTimeCrouch"		0.35197
-- 	"RecoveryTimeStand"			0.49275
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_Galil"
-- 	"viewmodel"			"models/weapons/v_rif_galil.mdl"
-- 	"playermodel"			"models/weapons/w_rif_galil.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"0"
-- 	"bucket_position"		"0"
-- 	"clip_size"			"35"
-- 	"primary_ammo"			"BULLET_PLAYER_556MM"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"25"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_Galil.Single"
-- 		special3			Default.Zoom
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"V"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"V"
-- 		}
-- 		"ammo"
-- 		{
-- 				"font"		"CSTypeDeath"
-- 				"character"		"N"
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
-- 			Mins	"-6 -8 -15"
-- 			Maxs	"36 4 0"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-10 -9 -7"
-- 			Maxs	"31 10 8"
-- 		}
-- 	}
-- }]])
-- function SWEP:PrimaryAttack()
--     if self:GetNextPrimaryAttack() > CurTime() then return end
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
