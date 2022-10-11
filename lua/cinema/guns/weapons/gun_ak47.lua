-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "ar"
SWEP.PrintName = "AK-47"
SWEP.Purpose = "Good for headshots and crouched spraying."
SWEP.HoldType = "ar2"
SWEP.Slot = 0
CSKillIcon(SWEP, "b")
--
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.ShootSound = "Weapon_AK47.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = true
SWEP.CSMuzzleFlashScale = 1.60
--
SWEP.Primary.Ammo = "BULLET_PLAYER_762MM"
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Damage = 28 --36
SWEP.CycleTime = 0.1
SWEP.HalfDamageDistance = 16384
--
SWEP.SpreadBase = 0.005
SWEP.SpreadMove = 0.06
SWEP.Spray = 0.06
SWEP.SprayExponent = 3
SWEP.CrouchSprayDecayMultiplier = 1.5
SWEP.CrouchKickMultiplier = 0.8

ComputeSpray(SWEP, {
    TapFireInterval = 0.5,
    ShotsTo90Spray = 14
})

SWEP.KickUBase = 0.5
SWEP.KickUSpray = 3
SWEP.KickLBase = 0.1
SWEP.KickLSpray = 0.5
SWEP.MoveSpeed = 221 / 250
-- SWEP.SprayIncrement = 0.5
--TODO: CycleTime for no spread instead of SprayIncrement?
-- SprayShotsTo80(SWEP, 8)   
-- SWEP.SprayDecay = 0.5     
--
-- SWEP.KickMoving = {1.5, 0.45, 0.225, 0.05, 6.5, 2.5, 7}
-- SWEP.KickStanding = {1, 0.375, 0.175, 0.0375, 5.75, 1.75, 8}
-- SWEP.KickCrouching = {0.9, 0.35, 0.15, 0.025, 5.5, 1.5, 9}
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"		"221"
-- 	"WeaponType"			"Rifle"
-- 	"FullAuto"				1
-- 	"WeaponPrice"			"2500"
-- 	"WeaponArmorRatio"		"1.55"
-- 	"CrosshairMinDistance"		"4"
-- 	"CrosshairDeltaDistance"	"4"
-- 	"Team" 				"TERRORIST"
-- 	"BuiltRightHanded" 		"0"
-- 	"PlayerAnimationExtension" 	"ak"
-- 	"MuzzleFlashScale"		"1.6"
-- 	"MuzzleFlashStyle"		"CS_MUZZLEFLASH_X"
-- 	"CanEquipWithShield"		"0"
-- 	// Weapon characteristics:  
-- 	"Penetration"			"2"
-- 	"Damage"			"36"
-- 	"Range"				"8192"
-- 	"RangeModifier"			"0.98"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.1"
-- 	"AccuracyDivisor"		"200"
-- 	"AccuracyOffset"		"0.35"
-- 	"MaxInaccuracy"			"1.25"
-- 	"TimeToIdle"			"1.9"
-- 	"IdleInterval"			"20"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00060
-- 	"InaccuracyCrouch"			0.00687
-- 	"InaccuracyStand"			0.00916
-- 	"InaccuracyJump"			0.43044
-- 	"InaccuracyLand"			0.08609
-- 	"InaccuracyLadder"			0.10761
-- 	"InaccuracyFire"			0.01158
-- 	"InaccuracyMove"			0.09222
-- 	"RecoveryTimeCrouch"		0.34868
-- 	"RecoveryTimeStand"			0.48815
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_AK47"
-- 	"viewmodel"			"models/weapons/v_rif_ak47.mdl"
-- 	"playermodel"			"models/weapons/w_rif_ak47.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"0"
-- 	"bucket_position"		"0"
-- 	"clip_size"			"30"
-- 	"primary_ammo"			"BULLET_PLAYER_762MM"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"25"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		"single_shot"		"Weapon_AK47.Single"
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		//Weapon Select Images
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"B"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"B"
-- 		}
-- 		"ammo"
-- 		{
-- 				"font"		"CSTypeDeath"
-- 				"character"		"V"
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
-- 			Mins	"-9 -3 -13"
-- 			Maxs	"30 11 0"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-9 -9 -9"
-- 			Maxs	"30 9 7"
-- 		}
-- 	}
-- }]])
-- function SWEP:PrimaryAttack()
--     if self:GetNextPrimaryAttack() > CurTime() then return end
--     self:GunFire(self:BuildSpread())
-- end
-- function SWEP:GunFire(spread)
--     if not self:BaseGunFire(spread, self.CycleTime, true) then return end
--     --Jvs: this is so goddamn lame
--     if self:GetOwner():GetAbsVelocity():Length2D() > 5 then
--         self:KickBack(1.5, 0.45, 0.225, 0.05, 6.5, 2.5, 7)
--     elseif not self:GetOwner():OnGround() then
--         self:KickBack(2, 1.0, 0.5, 0.35, 9, 6, 5)
--     elseif self:GetOwner():Crouching() then
--         self:KickBack(0.9, 0.35, 0.15, 0.025, 5.5, 1.5, 9)
--     else
--         self:KickBack(1, 0.375, 0.175, 0.0375, 5.75, 1.75, 8)
--     end
-- end
