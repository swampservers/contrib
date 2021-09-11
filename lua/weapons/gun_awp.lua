-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "sniper"
SWEP.PrintName = "AWP"
SWEP.Purpose = "Powerful sniper rifle. Can remove props."
SWEP.HoldType = "ar2"
SWEP.Slot = 0
CSKillIcon(SWEP, "r")
--
SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.ShootSound = "Weapon_AWP.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.35
--
SWEP.Primary.Ammo = "BULLET_PLAYER_338MAG"
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Damage = 120
SWEP.CycleTime = 1.5000
SWEP.HalfDamageDistance = 32768
--
SWEP.SpreadBase = 0.0000
SWEP.SpreadMove = 0.1
SWEP.Spray = 0.2
SWEP.SprayExponent = 2

ComputeSpray(SWEP, {
    TapFireInterval = 1.3,
    ShotsTo90Spray = 1
})

--
SWEP.SpreadUnscoped = 0.2

SWEP.ScopeLevels = {40 / 90, 10 / 90}

SWEP.UnscopeOnShoot = true
SWEP.KickUBase = 3
SWEP.MoveSpeed = 210 / 250
SWEP.ScopedSpeedRatio = 0.5
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"			"210"
-- 	"WeaponType" 			"SniperRifle"
-- 	"FullAuto"				0
-- 	"WeaponPrice"			"4750"
-- 	"WeaponArmorRatio"		"1.95"
-- 	"CrosshairMinDistance"		"8"
-- 	"CrosshairDeltaDistance"	"3"
-- 	"Team"				"ANY"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension" 	"awp"
-- 	"MuzzleFlashScale"		"1.35"
-- 	"CanEquipWithShield"		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"			"3"
-- 	"Damage"			"115"
-- 	"Range"				"8192"
-- 	"RangeModifier"			"0.99"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"1.5"	// 1.455
-- 	"AccuracyDivisor"		"-1"
-- 	"AccuracyOffset"		"0"
-- 	"MaxInaccuracy"			"0"
-- 	"TimeToIdle"			"2"
-- 	"IdleInterval"			"60"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00020
-- 	"InaccuracyCrouch"			0.06060
-- 	"InaccuracyStand"			0.08080
-- 	"InaccuracyJump"			0.54600
-- 	"InaccuracyLand"			0.05460
-- 	"InaccuracyLadder"			0.13650
-- 	"InaccuracyFire"			0.14000
-- 	"InaccuracyMove"			0.27300
-- 	"SpreadAlt"					0.00020
-- 	"InaccuracyCrouchAlt"		0.00150
-- 	"InaccuracyStandAlt"		0.00200
-- 	"InaccuracyJumpAlt"			0.54600
-- 	"InaccuracyLandAlt"			0.05460
-- 	"InaccuracyLadderAlt"		0.13650
-- 	"InaccuracyFireAlt"			0.14000
-- 	"InaccuracyMoveAlt"			0.27300
-- 	"RecoveryTimeCrouch"		0.24671
-- 	"RecoveryTimeStand"			0.34539
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_AWP"
-- 	"viewmodel"			"models/weapons/v_snip_awp.mdl"
-- 	"playermodel"			"models/weapons/w_snip_awp.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"0"
-- 	"bucket_position"		"0"
-- 	"clip_size"			"10"
-- 	"primary_ammo"			"BULLET_PLAYER_338MAG"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"30"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Weapon_AWP.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_AWP.Single"
-- 		special3			Default.Zoom
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"R"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"R"
-- 		}
-- 		"ammo"
-- 		{
-- 				"font"		"CSTypeDeath"
-- 				"character"		"W"
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
-- 			Mins	"-11 -3 -12"
-- 			Maxs	"32 10 0"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-12 -6 -15"
-- 			Maxs	"38 9 15"
-- 		}
-- 	}
-- }]])
-- function SWEP:GunFire(spread)
--     local pPlayer = self:GetOwner()
--     if (CurTime() < self:GetZoomFullyActiveTime()) then
--         self:SetNextPrimaryFire(self:GetZoomFullyActiveTime())
--         return
--     end
--     if (not self:IsScoped()) then
--         spread = spread + .08
--     end
--     if not self:BaseGunFire(spread, self.CycleTime, true) then return end
--     if (self:IsScoped()) then
--         self:SetLastZoom(self:GetTargetFOVRatio())
--         self:SetResumeZoom(true)
--         self:SetFOVRatio(1, 0.1)
--     end
--     local a = self:GetOwner():GetViewPunchAngles()
--     a.p = a.p - 2
--     self:GetOwner():SetViewPunchAngles(a)
-- end
