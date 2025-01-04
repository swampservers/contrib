-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "ar"
SWEP.PrintName = "Famas"
SWEP.Purpose = "Fires quick bursts; try to get a headshot and a bodyshot."
SWEP.HoldType = "ar2"
SWEP.Slot = 0
CSKillIcon(SWEP, "t")
--
SWEP.WorldModel = "models/weapons/w_rif_famas.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.ShootSound = "Weapon_FAMAS.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = true
SWEP.CSMuzzleFlashScale = 1.30
--
SWEP.Primary.Ammo = "BULLET_PLAYER_556MM"
SWEP.Primary.ClipSize = 25
SWEP.Primary.DefaultClip = 25
SWEP.Primary.Automatic = false
SWEP.Damage = 26 --32
SWEP.CycleTime = 0.07 --90
SWEP.HalfDamageDistance = 8192
--
SWEP.SpreadBase = 0.005
SWEP.SpreadMove = 0.06
SWEP.Spray = 0.01
SWEP.SprayExponent = 2
SWEP.SprayIncrement = 0.18
SWEP.SprayDecay = 0.4
SWEP.SpreadBase = 0.005
SWEP.SpreadMove = 0.07
SWEP.Spray = 0.06
SWEP.SprayExponent = 3

ComputeSpray(SWEP, {
    TapFireInterval = 0.7,
    ShotsTo90Spray = 18
})

--
SWEP.KickUBase = 0.1
SWEP.KickUSpray = 1.8
SWEP.KickLBase = 0.0
SWEP.KickLSpray = 0.3
-- SWEP.KickMoving = {0.45, 0.3, 0.2, 0.0275, 4, 2.25, 7}
-- SWEP.KickStanding = {0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8}
-- SWEP.KickCrouching = {0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8}
-- BURST NEEDS FIX
SWEP.BurstFire = 3
SWEP.BurstFireInterval = 0.1
SWEP.MoveSpeed = 220 / 250

SWEP.CSPrice  = 2250
SWEP.CSTeam = "CT"
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"			"220"
-- 	"WeaponType"			"Rifle"
-- 	"FullAuto"				1
-- 	"WeaponPrice"			"2250"
-- 	"WeaponArmorRatio"		"1.4"
-- 	"CrosshairMinDistance"		"4"
-- 	"CrosshairDeltaDistance"	"3"
-- 	"Team"				"CT"
-- 	"BuiltRightHanded"		"1"
-- 	"PlayerAnimationExtension"	"famas"
-- 	"MuzzleFlashScale"		"1.3"
-- 	"MuzzleFlashStyle"		"CS_MUZZLEFLASH_X"
-- 	"CanEquipWithShield"		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"			"2"
-- 	"Damage"			"30"
-- 	"Range"				"8192"
-- 	"RangeModifier"			"0.96"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.09"
-- 	"AccuracyDivisor"		"215"
-- 	"AccuracyOffset"		"0.3"
-- 	"MaxInaccuracy"			"1.0"
-- 	"TimeToIdle"			"1.1"
-- 	"IdleInterval"			"20"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00060
-- 	"InaccuracyCrouch"			0.00412
-- 	"InaccuracyStand"			0.00549
-- 	"InaccuracyJump"			0.36527
-- 	"InaccuracyLand"			0.07305
-- 	"InaccuracyLadder"			0.09132
-- 	"InaccuracyFire"			0.01186
-- 	"InaccuracyMove"			0.06980
-- 	"SpreadAlt"					0.00060
-- 	"InaccuracyCrouchAlt"		0.00412
-- 	"InaccuracyStandAlt"		0.00549
-- 	"InaccuracyJumpAlt"			0.36527
-- 	"InaccuracyLandAlt"			0.07305
-- 	"InaccuracyLadderAlt"		0.09132
-- 	"InaccuracyFireAlt"			0.00593
-- 	"InaccuracyMoveAlt"			0.06980
-- 	"RecoveryTimeCrouch"		0.30328
-- 	"RecoveryTimeStand"			0.42460
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_Famas"
-- 	"viewmodel"			"models/weapons/v_rif_famas.mdl"
-- 	"playermodel"			"models/weapons/w_rif_famas.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"0"
-- 	"bucket_position"		"0"
-- 	"clip_size"			"25"
-- 	"primary_ammo"			"BULLET_PLAYER_556MM"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"75"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Weapon_AWP.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_FAMAS.Single"
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"T"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"T"
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
-- 			Mins	"-6 -10 -15"
-- 			Maxs	"23 7 0"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-12 -8 -6"
-- 			Maxs	"22 8 8"
-- 		}
-- 	}
-- }]])
-- function SWEP:Initialize()
--     BaseClass.Initialize(self)
--     self:SetBurstFireEnabled(false)
--     self:SetMaxBurstFires(3)
--     self:SetBurstFireDelay(0.05)
-- end
-- function SWEP:PrimaryAttack()
--     if self:GetNextPrimaryFire() > CurTime() then return end
--     self:GunFire(self:BuildSpread(), true) --self:GetBurstFireEnabled())
-- end
-- function SWEP:GunFire(spread, mode)
--     local cycleTime = self.CycleTime
--     if mode then
--         cycleTime = 0.55
--     else
--         spread = spread + 0.01
--     end
--     if not self:BaseGunFire(spread, cycleTime, mode) then return end
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
