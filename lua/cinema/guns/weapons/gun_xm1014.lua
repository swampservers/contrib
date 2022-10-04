﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "autoshotgun"
SWEP.PrintName = "XM1014"
SWEP.Purpose = "Accurate semi-automatic shotgun."
SWEP.HoldType = "shotgun"
SWEP.Slot = 0
CSKillIcon(SWEP, "]")
--
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.ShootSound = "Weapon_XM1014.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.30
--
SWEP.Primary.Ammo = "BULLET_PLAYER_BUCKSHOT"
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = false
SWEP.Damage = 12
SWEP.CycleTime = 0.25
SWEP.HalfDamageDistance = 768 --1024
--
SWEP.SpreadBase = 0.006
SWEP.SpreadMove = 0.02
SWEP.Spray = 0.1
SWEP.SprayExponent = 2

ComputeSpray(SWEP, {
    TapFireInterval = 0.6,
    ShotsTo90Spray = 6
})

--
SWEP.NumPellets = 8
SWEP.PelletSpread = 0.03
SWEP.UseShellReload = true
SWEP.KickUBase = 1.5
SWEP.KickUSpray = 1.5
SWEP.KickLBase = 0.2
SWEP.KickLSpray = 0.3
SWEP.MoveSpeed = 230 / 250
-- SWEP.KickMoving = {0.45, 0.3, 0.2, 0.0275, 4, 2.25, 7}
-- SWEP.KickStanding = {0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8}
-- SWEP.KickCrouching = {0.275, 0.2, 0.125, 0.02, 3, 1, 9}
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed" 		"240"
-- 	"WeaponType" 			"Shotgun"
-- 	"FullAuto"				1
-- 	"WeaponPrice"			"3000"
-- 	"WeaponArmorRatio"		"1.0"
-- 	"CrosshairMinDistance"		"9"
-- 	"CrosshairDeltaDistance"	"4"
-- 	"Team"				"ANY"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension"	"xm1014"
-- 	"MuzzleFlashScale"		"1.3"
-- 	"CanEquipWithShield"		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"			"1"
-- 	"Damage"			"22"
-- 	"Range"				"3000"
-- 	"RangeModifier"			"0.70"
-- 	"Bullets"			"6"
-- 	"CycleTime"			"0.25"
-- 	// New accuracy model parameters
-- 	"Spread"					0.04000
-- 	"InaccuracyCrouch"			0.00750
-- 	"InaccuracyStand"			0.01000
-- 	"InaccuracyJump"			0.41176
-- 	"InaccuracyLand"			0.08235
-- 	"InaccuracyLadder"			0.07721
-- 	"InaccuracyFire"			0.03644
-- 	"InaccuracyMove"			0.03544
-- 	"RecoveryTimeCrouch"		0.32894
-- 	"RecoveryTimeStand"			0.46052
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_xm1014"
-- 	"viewmodel"			"models/weapons/v_shot_xm1014.mdl"
-- 	"playermodel"			"models/weapons/w_shot_xm1014.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"0"
-- 	"bucket_position"		"0"
-- 	"clip_size"			"7"
-- 	"primary_ammo"			"BULLET_PLAYER_BUCKSHOT"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"20"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"			"Weapon_XM1014.Single"
-- 		special3			Default.Zoom
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"]"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"]"
-- 		}
-- 		"ammo"
-- 		{
-- 				"font"		"CSTypeDeath"
-- 				"character"		"J"
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
-- 			Mins	"-13 -3 -11"
-- 			Maxs	"29 10 0"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-4 -8 -4"
-- 			Maxs	"30 8 6"
-- 		}
-- 	}
-- }]])
-- function SWEP:PrimaryAttack()
--     -- local pPlayer = self.Owner
--     -- if not IsValid(pPlayer) then return end
--     -- if pPlayer:WaterLevel() == 3 then
--     --     self:PlayEmptySound()
--     --     self:SetNextPrimaryFire(CurTime() + 0.15)
--     --     return
--     -- end
--     if self:GetNextPrimaryFire() > CurTime() then return end
--     self:GunFire(self:BuildSpread())
--     self:SetSpecialReload(0)
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
