-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "smg"
SWEP.PrintName = "MP7"
SWEP.Purpose = "Controllable SMG"
SWEP.HoldType = "smg"
SWEP.Slot = 0

if CLIENT then
    killicon.AddAlias("gun_mp7", "weapon_smg1")
end

--
SWEP.WorldModel = "models/weapons/w_smg1.mdl"
SWEP.ViewModel = "models/weapons/v_smg1.mdl"
SWEP.ShootSound = "Weapon_SMG1.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.10
--
SWEP.Primary.Ammo = "BULLET_PLAYER_9MM"
SWEP.Primary.ClipSize = 40
SWEP.Primary.DefaultClip = 40
SWEP.Primary.Automatic = true
SWEP.Damage = 26
SWEP.CycleTime = 0.075
SWEP.HalfDamageDistance = 4096
--
SWEP.SpreadBase = 0.012
SWEP.SpreadMove = 0.008
SWEP.Spray = 0.046
SWEP.SprayExponent = 3.5

ComputeSpray(SWEP, {
    TapFireInterval = 0.3,
    ShotsTo90Spray = 20
})

--
SWEP.KickUBase = 0.2
SWEP.KickUSpray = 1
SWEP.KickLBase = 0.1
SWEP.KickLSpray = 0.3
SWEP.MoveSpeed = 1
-- SWEP.KickMoving = {0.45, 0.3, 0.2, 0.0275, 4, 2.25, 7}
-- SWEP.KickStanding = {0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8}
-- SWEP.KickCrouching = {0.275, 0.2, 0.125, 0.02, 3, 1, 9}
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"		"250"
-- 	"WeaponType"			"SubMachinegun"
-- 	"FullAuto"				1
-- 	"WeaponPrice"			"1500"
-- 	"WeaponArmorRatio"		"1.0"
-- 	"CrosshairMinDistance"		"6"
-- 	"CrosshairDeltaDistance"	"2"
-- 	"Team"				"ANY"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension"	"mp5"
-- 	"MuzzleFlashScale"		"1.1"
-- 	"CanEquipWithShield"		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"			"1"
-- 	"Damage"			"26"
-- 	"Range"				"4096"
-- 	"RangeModifier"			"0.84"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.08"
-- 	"AccuracyDivisor"		"220"
-- 	"AccuracyOffset"		"0.45"
-- 	"MaxInaccuracy"			"0.75"
-- 	"TimeToIdle"			"2"
-- 	"IdleInterval"			"20"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00100
-- 	"InaccuracyCrouch"			0.01289
-- 	"InaccuracyStand"			0.01718
-- 	"InaccuracyJump"			0.23025
-- 	"InaccuracyLand"			0.04605
-- 	"InaccuracyLadder"			0.05756
-- 	"InaccuracyFire"			0.00638
-- 	"InaccuracyMove"			0.01785
-- 	"RecoveryTimeCrouch"		0.27960
-- 	"RecoveryTimeStand"			0.39144
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_MP5"
-- 	"viewmodel"			"models/weapons/v_smg_mp5.mdl"
-- 	"playermodel"			"models/weapons/w_smg_mp5.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"0"
-- 	"bucket_position"		"0"
-- 	"clip_size"			"30"
-- 	"primary_ammo"			"BULLET_PLAYER_9MM"
-- 	"secondary_ammo"		"BULLET_PLAYER_9MM"
-- 	"weight"			"25"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_MP5Navy.Single"
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"X"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"X"
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
-- 			Mins	"-10 -4 -13"
-- 			Maxs	"21 9 -1"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-10 -7 -6"
-- 			Maxs	"22 8 9"
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
