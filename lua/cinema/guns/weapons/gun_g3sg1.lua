﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "autosniper"
SWEP.PrintName = "G3SG1"
SWEP.Purpose = "Powerful semi-automatic sniper rifle."
SWEP.HoldType = "ar2"
SWEP.Slot = 0
CSKillIcon(SWEP, "i")
--
SWEP.WorldModel = "models/weapons/w_snip_g3sg1.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_snip_g3sg1.mdl"
SWEP.ShootSound = "Weapon_G3SG1.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = true
SWEP.CSMuzzleFlashScale = 1.50
--
SWEP.Primary.Ammo = "BULLET_PLAYER_762MM"
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = false
SWEP.Damage = 65
SWEP.CycleTime = 0.28
SWEP.HalfDamageDistance = 16384
--
SWEP.SpreadBase = 0.0000
SWEP.SpreadUnscoped = 0.05
SWEP.SpreadMove = 0.1
SWEP.Spray = 0.1
SWEP.SprayExponent = 3

ComputeSpray(SWEP, {
    TapFireInterval = 0.65,
    ShotsTo90Spray = 8
})

--
SWEP.ScopeLevels = {40 / 90, 10 / 90}

SWEP.ScopedSpeedRatio = 220 / 260
SWEP.KickUBase = 2
SWEP.KickUSpray = 0
SWEP.KickLBase = 0
SWEP.KickLSpray = 1
SWEP.MoveSpeed = 210 / 250

SWEP.CSTeam = "T"
SWEP.CSPrice = 5000
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed" 		"210"
-- 	"WeaponType" 			"SniperRifle"
-- 	"FullAuto"				1
-- 	"WeaponPrice" 			"5000"
-- 	"WeaponArmorRatio" 		"1.65"
-- 	"CrosshairMinDistance" 		"6"
-- 	"CrosshairDeltaDistance" 	"4"
-- 	"Team" 				"TERRORIST"
-- 	"BuiltRightHanded" 		"0"
-- 	"PlayerAnimationExtension"	 "g3"
-- 	"MuzzleFlashScale"		"1.5"
-- 	"MuzzleFlashStyle"		"CS_MUZZLEFLASH_X"
-- 	"CanEquipWithShield" 		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"			"3"
-- 	"Damage"			"80"
-- 	"Range"				"8192"
-- 	"RangeModifier"			"0.98"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.25"
-- 	"AccuracyDivisor"		"-1"
-- 	"AccuracyOffset"		"0"
-- 	"MaxInaccuracy"			"0"
-- 	"TimeToIdle"			"1.8"
-- 	"IdleInterval"			"60"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00030
-- 	"InaccuracyCrouch"			0.01935
-- 	"InaccuracyStand"			0.02580
-- 	"InaccuracyJump"			0.46557
-- 	"InaccuracyLand"			0.04656
-- 	"InaccuracyLadder"			0.11639
-- 	"InaccuracyFire"			0.04989
-- 	"InaccuracyMove"			0.23279
-- 	"SpreadAlt"					0.00030
-- 	"InaccuracyCrouchAlt"		0.00150
-- 	"InaccuracyStandAlt"		0.00200
-- 	"InaccuracyJumpAlt"			0.46557
-- 	"InaccuracyLandAlt"			0.04656
-- 	"InaccuracyLadderAlt"		0.11639
-- 	"InaccuracyFireAlt"			0.04989
-- 	"InaccuracyMoveAlt"			0.23279
-- 	"RecoveryTimeCrouch"		0.22245
-- 	"RecoveryTimeStand"			0.31142
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_G3SG1"
-- 	"viewmodel"			"models/weapons/v_snip_g3sg1.mdl"
-- 	"playermodel"			"models/weapons/w_snip_g3sg1.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"0"
-- 	"bucket_position"		"0"
-- 	"clip_size"			"20"
-- 	"primary_ammo"			"BULLET_PLAYER_762MM"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"20"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_G3SG1.Single"
-- 		special3			Default.Zoom
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"I"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"I"
-- 		}
-- 		"ammo"
-- 		{
-- 				"font"		"CSTypeDeath"
-- 				"character"		"V"
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
-- 			Maxs	"33 10 -1"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-11 -9 -4"
-- 			Maxs	"28 9 9"
-- 		}
-- 	}
-- }]])
-- function SWEP:PrimaryAttack()
--     if self:GetNextPrimaryAttack() > CurTime() then return end
--     self:GunFire(self:BuildSpread())
-- -- end
-- function SWEP:SecondaryAttack()
--     local pPlayer = self:GetOwner()
--     if not IsValid(pPlayer) then return end
--     if (self:GetZoomFullyActiveTime() > CurTime() or self:GetNextPrimaryAttack() > CurTime()) then
--         self:SetNextSecondaryFire(self:GetZoomFullyActiveTime() + 0.15)
--         return
--     end
--     if (not self:IsScoped()) then
--         self:SetFOVRatio(40 / 90, 0.15)
--     elseif (FloatEquals(self:GetFOVRatio(), 40 / 90)) then
--         self:SetFOVRatio(10 / 90, 0.08)
--     else
--         self:SetFOVRatio(1, 0.1)
--     end
--     -- If this isn't guarded, the sound will be emitted twice, once by the server and once by the client.
--     -- Let the server play it since if only the client plays it, it's liable to get played twice cause of
--     -- a prediction error. joy.
--     self:EmitSound("Default.Zoom", nil, nil, nil, CHAN_AUTO)
--     self:SetNextSecondaryFire(CurTime() + 0.3)
--     self:SetZoomFullyActiveTime(CurTime() + 0.15) -- The worst zoom time from above.
-- end
-- function SWEP:AdjustMouseSensitivity()
--     if (self:IsScoped()) then return self:GetCurrentFOVRatio() * GetConVar"zoom_sensitivity_ratio":GetFloat() end -- is a hack, maybe change?
-- end
-- function SWEP:IsScoped()
--     return self:GetTargetFOVRatio() ~= 1
-- end
-- function SWEP:HandleReload()
--     self:SetFOVRatio(1, 0.05)
-- end
-- function SWEP:GetSpeedRatio()
--     if (self:IsScoped()) then return 220 / 260 end
--     return 1
-- end
-- function SWEP:GunFire(spread)
--     local pPlayer = self:GetOwner()
--     if (CurTime() < self:GetZoomFullyActiveTime()) then
--         self:SetNextPrimaryAttack(self:GetZoomFullyActiveTime())
--         return
--     end
--     if (not self:IsScoped()) then
--         spread = spread + .08
--     end
--     if not self:BaseGunFire(spread, self.CycleTime, true) then return end
--     local a = self:GetOwner():GetViewPunchAngles()
--     a.p = a.p - 2
--     self:GetOwner():SetViewPunchAngles(a)
-- end
