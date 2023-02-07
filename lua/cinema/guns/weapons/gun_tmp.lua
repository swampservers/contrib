-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "smg"
SWEP.PrintName = "TMP"
SWEP.Purpose = "Silenced SMG"
SWEP.HoldType = "smg"
SWEP.Slot = 0
CSKillIcon(SWEP, "d")
--
SWEP.WorldModel = "models/weapons/w_smg_tmp.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.ShootSound = "Weapon_TMP.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 0.8
--
SWEP.Primary.Ammo = "BULLET_PLAYER_9MM"
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Damage = 18 --26
SWEP.CycleTime = 0.07
SWEP.HalfDamageDistance = 2048 * 0.9
--
SWEP.SpreadBase = 0.01
SWEP.SpreadMove = 0.01
SWEP.Spray = 0.05
SWEP.SprayExponent = 3.5

ComputeSpray(SWEP, {
    TapFireInterval = 0.3,
    ShotsTo90Spray = 20
})

--
-- SWEP.Silenced = true
SWEP.KickUBase = 0.5
SWEP.KickUSpray = 0.6
SWEP.KickLBase = 0.3
SWEP.KickLSpray = 0
SWEP.MoveKickMultiplier = 1
SWEP.MoveSpeed = 240 / 250
--
SWEP.SpawnPriceMod = 1.07 -- (18 / 0.07) / (18 / 0.075)
-- SWEP.KickMoving = {0.8, 0.4, 0.2, 0.03, 3, 2.5, 7}
-- SWEP.KickStanding = {0.725, 0.375, 0.15, 0.025, 2.75, 2.25, 9}
-- SWEP.KickCrouching = {0.7, 0.35, 0.125, 0.025, 2.5, 2, 10}
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"		"250"
-- 	"WeaponType"			"SubMachinegun"
-- 	"FullAuto"				1
-- 	"WeaponPrice"			"1250"
-- 	"WeaponArmorRatio"		"1.0"
-- 	"CrosshairMinDistance"		"7"
-- 	"CrosshairDeltaDistance"	"3"
-- 	"Team"				"CT"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension"	"tmp"
-- 	"MuzzleFlashScale"		"0.8"
-- 	"MuzzleFlashStyle"		"CS_MUZZLEFLASH_NONE"
-- 	"CanEquipWithShield"		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"			"1"
-- 	"Damage"			"26"
-- 	"Range"				"4096"
-- 	"RangeModifier"			"0.84"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.07"
-- 	"AccuracyDivisor"		"200"
-- 	"AccuracyOffset"		"0.55"
-- 	"MaxInaccuracy"			"1.4"
-- 	"TimeToIdle"			"2"
-- 	"IdleInterval"			"20"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00100
-- 	"InaccuracyCrouch"			0.01500
-- 	"InaccuracyStand"			0.02000
-- 	"InaccuracyJump"			0.11180
-- 	"InaccuracyLand"			0.02236
-- 	"InaccuracyLadder"			0.02795
-- 	"InaccuracyFire"			0.01594
-- 	"InaccuracyMove"			0.00389
-- 	"RecoveryTimeCrouch"		0.15131
-- 	"RecoveryTimeStand"			0.21184
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_Tmp"
-- 	"viewmodel"			"models/weapons/v_smg_tmp.mdl"
-- 	"playermodel"			"models/weapons/w_smg_tmp.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"0"
-- 	"bucket_position"		"0"
-- 	"clip_size"			"30"
-- 	"primary_ammo"			"BULLET_PLAYER_9MM"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"25"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"			"Weapon_TMP.Single"
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"D"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"D"
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
-- 			Mins	"-7 -4 -12"
-- 			Maxs	"27 10 -1"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-1 -5 -7"
-- 			Maxs	"22 6 6"
-- 		}
-- 	}
-- }]])
-- function SWEP:PrimaryAttack()
--     if self:GetNextPrimaryFire() > CurTime() then return end
--     self:GunFire(self:BuildSpread())
-- end
-- function SWEP:GunFire(spread)
--     if not self:BaseGunFire(spread, self.CycleTime, true) then return end
--     if not self:GetOwner():OnGround() then
--         self:KickBack(1.1, 0.5, 0.35, 0.045, 4.5, 3.5, 6)
--     elseif self:GetOwner():GetAbsVelocity():Length2D() > 5 then
--         self:KickBack(0.8, 0.4, 0.2, 0.03, 3, 2.5, 7)
--     elseif self:GetOwner():Crouching() then
--         self:KickBack(0.7, 0.35, 0.125, 0.025, 2.5, 2, 10)
--     else
--         self:KickBack(0.725, 0.375, 0.15, 0.025, 2.75, 2.25, 9)
--     end
-- end
-- function SWEP:FireAnimationEvent()
--     return true
-- end
