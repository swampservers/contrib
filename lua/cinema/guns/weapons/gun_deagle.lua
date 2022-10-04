﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "heavypistol"
SWEP.PrintName = "Desert Eagle"
SWEP.Purpose = "Powerful handgun. Can remove props."
SWEP.HoldType = "revolver"
SWEP.Slot = 0
CSKillIcon(SWEP, "f")
--
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.ShootSound = "Weapon_DEagle.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.20
--
SWEP.Primary.Ammo = "BULLET_PLAYER_50AE"
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = false
SWEP.Damage = 56
SWEP.CycleTime = 0.225
SWEP.HalfDamageDistance = 4096
--
SWEP.SpreadBase = 0.004
SWEP.SpreadMove = 0.02
SWEP.Spray = 0.1
SWEP.SprayExponent = 2

ComputeSpray(SWEP, {
    TapFireInterval = 1,
    ShotsTo90Spray = 3
})

--
SWEP.KickUBase = 2
SWEP.KickUSpray = 1
SWEP.KickLBase = 0
SWEP.KickLSpray = 1
SWEP.MoveSpeed = 1
--
SWEP.SpawnPriceMod = 1.4
-- SWEP.ShootSound = "Weapon_DEagle.Single"
-- SWEP.CSSTeam = "ANY" 
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"		"250"
-- 	"WeaponType"			"Pistol"
-- 	"FullAuto"				0
-- 	"WeaponPrice"			"650"
-- 	"WeaponArmorRatio"		"1.5"
-- 	"CrosshairMinDistance"		"8"
-- 	"CrosshairDeltaDistance"	"3"
-- 	"Team"				"ANY"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension"	"pistol"
-- 	"MuzzleFlashScale"		"1.2"
-- 	"CanEquipWithShield"		"1"
-- 	// Weapon characteristics:
-- 	"Penetration"			"2"
-- 	"Damage"			"54"
-- 	"Range"				"4096"
-- 	"RangeModifier"			"0.81"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.225"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00400
-- 	"InaccuracyCrouch"			0.00975
-- 	"InaccuracyStand"			0.01300
-- 	"InaccuracyJump"			0.34500
-- 	"InaccuracyLand"			0.06900
-- 	"InaccuracyLadder"			0.02300
-- 	"InaccuracyFire"			0.05500
-- 	"InaccuracyMove"			0.02070
-- 	"RecoveryTimeCrouch"		0.32236
-- 	"RecoveryTimeStand"			0.38683
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_DesertEagle"
-- 	"viewmodel"			"models/weapons/v_pist_deagle.mdl"
-- 	"playermodel"			"models/weapons/w_pist_deagle.mdl"
-- 	"shieldviewmodel"		"models/weapons/v_shield_de_r.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"1"
-- 	"bucket_position"		"1"
-- 	"clip_size"			"7"
-- 	"primary_ammo"			"BULLET_PLAYER_50AE"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"7"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_DEagle.Single"
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"F"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"F"
-- 		}
-- 		"ammo"
-- 		{
-- 				"font"		"CSTypeDeath"
-- 				"character"		"U"
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
-- 			Mins	"-7 -3 -14"
-- 			Maxs	"19 10 -2"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-1 -3 -2"
-- 			Maxs	"13 4 6"
-- 		}
-- 	}
-- }]])
-- function SWEP:Deploy()
--     self:SetAccuracy(0.9)
--     return BaseClass.Deploy(self)
-- end
-- -- function SWEP:PrimaryAttack()
-- --     if self:GetNextPrimaryFire() > CurTime() then return end
-- --     self:GunFire(self:BuildSpread(), true)
-- -- end
-- -- function SWEP:TranslateViewModelActivity(act)
-- --     -- if self:GetBurstFireEnabled() and act == ACT_VM_PRIMARYATTACK then
-- --     --     return ACT_VM_SECONDARYATTACK
-- --     -- else
-- --         return BaseClass.TranslateViewModelActivity(self, act)
-- --     -- end
-- -- end
-- function SWEP:GunFire(spread, mode)
--     self:SetAccuracy(self:GetAccuracy() - 0.35 * (0.4 - CurTime() - self:GetLastFire()))
--     if self:GetAccuracy() > 0.9 then
--         self:SetAccuracy(0.9)
--     elseif self:GetAccuracy() < 0.55 then
--         self:SetAccuracy(0.55)
--     end
--     if not self:BaseGunFire(spread, self.CycleTime, mode) then return end
--     --Python: this is so goddamn lame
--     local a = self:GetOwner():GetViewPunchAngles()
--     a.p = a.p - 2
--     self:GetOwner():SetViewPunchAngles(a)
-- end
-- SWEP.InaccuracyMove = 0.1
-- SWEP.SprayExponent = 1 --(tab.AccuracyQuadratic==1) and 2 or 3
-- SWEP.SprayMin = 0.2
-- SWEP.SprayMax = 1
-- SWEP.SprayIncrement = 0.5
-- SWEP.SprayDecay = 0.4
-- SWEP.SprayDecayCrouch = 0.5
-- SWEP.SprayMin = tab.AccuracyOffset or 0.2
-- SWEP.SprayMax = ( (tab.MaxInaccuracy or 1) ) ^ (1/self.SprayExponent)
-- SWEP.SprayIncrement = shotincrement
-- self.SprayDecay = shotincrement / self.RecoveryTimeStand
-- self.SprayDecayCrouch 
