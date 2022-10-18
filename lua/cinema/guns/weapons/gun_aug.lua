-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "ar"
SWEP.PrintName = "AUG"
SWEP.Purpose = "Good for firing short bursts and long-range tap fire."
SWEP.HoldType = "smg"
SWEP.Slot = 0
CSKillIcon(SWEP, "e")
--
SWEP.WorldModel = "models/weapons/w_rif_aug.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_rif_aug.mdl"
SWEP.ShootSound = "Weapon_AUG.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = true
SWEP.CSMuzzleFlashScale = 1.30
--
SWEP.Primary.Ammo = "BULLET_PLAYER_762MM"
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Damage = 26 --33
SWEP.CycleTime = 0.0900
SWEP.HalfDamageDistance = 16384
--
SWEP.SpreadBase = 0.001
SWEP.SpreadMove = 0.08
SWEP.Spray = 0.07
SWEP.SprayExponent = 4

ComputeSpray(SWEP, {
    TapFireInterval = 0.4,
    ShotsTo90Spray = 20
})

--
SWEP.SpreadUnscoped = 0.003

SWEP.ScopeLevels = {40 / 90}

SWEP.ScopedSpeedRatio = 220 / 260
--
SWEP.KickUBase = 0.4
SWEP.KickUSpray = 2.5
SWEP.KickLBase = 0.1
SWEP.KickLSpray = 0.4
SWEP.KickDance = 1.5
SWEP.MoveSpeed = 220 / 250
SWEP.ScopedSpeedRatio = 0.5
-- SWEP.KickMoving = {1, 0.45, 0.275, 0.05, 4, 2.5, 7}
-- SWEP.KickStanding = {0.625, 0.375, 0.25, 0.0125, 3.5, 2.25, 8}
-- SWEP.KickCrouching = {0.575, 0.325, 0.2, 0.011, 3.25, 2, 8}
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"		"221"
-- 	"WeaponType"			"Rifle"
-- 	"FullAuto"				1
-- 	"WeaponPrice"			"3500"
-- 	"WeaponArmorRatio"		"1.4"
-- 	"CrosshairMinDistance"		"3"
-- 	"CrosshairDeltaDistance"	"3"
-- 	"Team"				"CT"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension"	"aug"
-- 	"MuzzleFlashScale"		"1.3"
-- 	"MuzzleFlashStyle"		"CS_MUZZLEFLASH_X"
-- 	"CanEquipWithShield"		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"			"2"
-- 	"Damage"			"32"
-- 	"Range"				"8192"
-- 	"RangeModifier"			"0.96"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.09"
-- 	"AccuracyDivisor"		"215"
-- 	"AccuracyOffset"		"0.3"
-- 	"MaxInaccuracy"			"1.0"
-- 	"TimeToIdle"			"1.9"
-- 	"IdleInterval"			"20"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00060
-- 	"InaccuracyCrouch"			0.00412
-- 	"InaccuracyStand"			0.00549
-- 	"InaccuracyJump"			0.36936
-- 	"InaccuracyLand"			0.07387
-- 	"InaccuracyLadder"			0.09234
-- 	"InaccuracyFire"			0.01090
-- 	"InaccuracyMove"			0.07268
-- 	"SpreadAlt"					0.00060
-- 	"InaccuracyCrouchAlt"		0.00288
-- 	"InaccuracyStandAlt"		0.00385
-- 	"InaccuracyJumpAlt"			0.36936
-- 	"InaccuracyLandAlt"			0.07387
-- 	"InaccuracyLadderAlt"		0.09234
-- 	"InaccuracyFireAlt"			0.01090
-- 	"InaccuracyMoveAlt"			0.07268
-- 	"RecoveryTimeCrouch"		0.30263
-- 	"RecoveryTimeStand"			0.42368
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_Aug"
-- 	"viewmodel"			"models/weapons/v_rif_aug.mdl"
-- 	"playermodel"			"models/weapons/w_rif_aug.mdl"
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
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_AUG.Single"
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"E"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"E"
-- 		}
-- 		"ammo"
-- 		{
-- 				"font"		"CSTypeDeath"
-- 				"character"		"V"
-- 		}
-- 		"zoom"
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
-- 			Mins	"-9 -3 -15"
-- 			Maxs	"25 12 -1"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-11 -1 -5"
-- 			Maxs	"23 4 10"
-- 		}
-- 	}
-- }]])
-- function SWEP:PreDrawViewModel(vm, weapon, ply)
-- end
-- function SWEP:SecondaryAttack()
--     local pPlayer = self:GetOwner()
--     if not IsValid(pPlayer) then return end
--     if self:GetZoomFullyActiveTime() > CurTime() or self:GetNextPrimaryFire() > CurTime() then
--         self:SetNextSecondaryFire(self:GetZoomFullyActiveTime() + 0.15)
--         return
--     end
--     if not self:IsScoped() then
--         self:SetFOVRatio(55 / 90, 0.2)
--     else
--         self:SetFOVRatio(1, 0.15)
--     end
--     self:SetNextSecondaryFire(CurTime() + 0.3)
--     self:SetZoomFullyActiveTime(CurTime() + 0.2)
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
-- function SWEP:PrimaryAttack()
--     if self:GetNextPrimaryFire() > CurTime() then return end
--     self:GunFire(self:BuildSpread())
-- end
-- function SWEP:GunFire(spread)
--     local cycleTime = self.CycleTime
--     if self:IsScoped() then
--         cycleTime = 0.135
--     end
--     if not self:BaseGunFire(spread, cycleTime, true) then return end
--     local pPlayer = self:GetOwner()
--     if not IsValid(pPlayer) then return end
--     if pPlayer:GetAbsVelocity():Length2D() > 5 then
--         self:KickBack(1, 0.45, 0.275, 0.05, 4, 2.5, 7)
--     elseif not pPlayer:OnGround() then
--         self:KickBack(1.25, 0.45, 0.22, 0.18, 5.5, 4, 5)
--     elseif pPlayer:Crouching() then
--         self:KickBack(0.575, 0.325, 0.2, 0.011, 3.25, 2, 8)
--     else
--         self:KickBack(0.625, 0.375, 0.25, 0.0125, 3.5, 2.25, 8)
--     end
-- end
