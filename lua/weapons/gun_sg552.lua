-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
DEFINE_BASECLASS("gun")
SWEP.GunType = "ar"
SWEP.PrintName = "SG 552"
SWEP.Purpose = "Good for long-range headshots and spraying."
SWEP.HoldType = "ar2"
SWEP.Slot = 0
CSKillIcon(SWEP, "[")
--
SWEP.WorldModel = "models/weapons/w_rif_sg552.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_rif_sg552.mdl"
SWEP.ShootSound = "Weapon_SG552.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = true
SWEP.CSMuzzleFlashScale = 1.30
--
SWEP.Primary.Ammo = "BULLET_PLAYER_556MM"
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Damage = 36
SWEP.CycleTime = 0.1
SWEP.HalfDamageDistance = 16384
--
SWEP.SpreadBase = 0.001
SWEP.SpreadUnscoped = 0.003
SWEP.SpreadMove = 0.08
SWEP.Spray = 0.045
SWEP.SprayExponent = 2

ComputeSpray(SWEP, {
    TapFireInterval = 0.45,
    ShotsTo90Spray = 12
})

--
SWEP.ScopeLevels = {40 / 90}

SWEP.ScopedSpeedRatio = 200 / 260
--
SWEP.KickUBase = 0.8
SWEP.KickUSpray = 2
SWEP.KickLBase = 0.4
SWEP.KickLSpray = 0.2
SWEP.KickDance = 1
-- SWEP.KickMoving = {1, 0.45, 0.28, 0.04, 4.25, 2.5, 7}
-- SWEP.KickStanding = {0.625, 0.375, 0.25, 0.0125, 4, 2.25, 9}
-- SWEP.KickCrouching = {0.6, 0.35, 0.2, 0.0125, 3.7, 2, 10}
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"		"235"
-- 	"WeaponType"			"Rifle"
-- 	"FullAuto"				1
-- 	"WeaponPrice"			"3500"
-- 	"WeaponArmorRatio"		"1.4"
-- 	"CrosshairMinDistance"		"5"
-- 	"CrosshairDeltaDistance"	"3"
-- 	"Team"				"TERRORIST"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension"	"sg552"
-- 	"MuzzleFlashScale"		"1.3"
-- 	"MuzzleFlashStyle"		"CS_MUZZLEFLASH_X"
-- 	"CanEquipWithShield"		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"			"2"
-- 	"Damage"			"33"
-- 	"Range"				"8192"
-- 	"RangeModifier"			"0.955"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.09"
-- 	"AccuracyDivisor"		"220"
-- 	"AccuracyOffset"		"0.3"
-- 	"MaxInaccuracy"			"1.0"
-- 	"TimeToIdle"			"2"
-- 	"IdleInterval"			"20"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00060
-- 	"InaccuracyCrouch"			0.00405
-- 	"InaccuracyStand"			0.00540
-- 	"InaccuracyJump"			0.33464
-- 	"InaccuracyLand"			0.06693
-- 	"InaccuracyLadder"			0.08366
-- 	"InaccuracyFire"			0.01227
-- 	"InaccuracyMove"			0.06132
-- 	"SpreadAlt"					0.00060
-- 	"InaccuracyCrouchAlt"		0.00284
-- 	"InaccuracyStandAlt"		0.00378
-- 	"InaccuracyJumpAlt"			0.33464
-- 	"InaccuracyLandAlt"			0.06693
-- 	"InaccuracyLadderAlt"		0.08366
-- 	"InaccuracyFireAlt"			0.00859
-- 	"InaccuracyMoveAlt"			0.06132
-- 	"RecoveryTimeCrouch"		0.27631
-- 	"RecoveryTimeStand"			0.38683
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_SG552"
-- 	"viewmodel"			"models/weapons/v_rif_sg552.mdl"
-- 	"playermodel"			"models/weapons/w_rif_sg552.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"0"
-- 	"bucket_position"		"0"
-- 	"clip_size"			"30"
-- 	"primary_ammo"			"BULLET_PLAYER_556MM"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"25"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Weapon_AWP.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_SG552.Single"
-- 		special3			Default.Zoom
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"["
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"["
-- 		}
-- 		"ammo"
-- 		{
-- 				"font"		"CSTypeDeath"
-- 				"character"		"N"
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
-- 			Mins	"-7 -2 -15"
-- 			Maxs	"30 11 -1"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-10 -8 -4"
-- 			Maxs	"25 8 9"
-- 		}
-- 	}
-- }]])
-- function SWEP:PreDrawViewModel(vm, weapon, ply)
-- end
-- -- function SWEP:PrimaryAttack()
-- --     if self:GetNextPrimaryFire() > CurTime() then return end
-- --     self:GunFire(self:BuildSpread())
-- -- end
-- function SWEP:SecondaryAttack()
--     local pPlayer = self:GetOwner()
--     if not IsValid(pPlayer) then return end
--     if self:GetZoomFullyActiveTime() > CurTime() or self:GetNextPrimaryFire() > CurTime() then
--         self:SetNextSecondaryFire(self:GetZoomFullyActiveTime() + 0.15)
--         return
--     end
--     if not self:IsScoped() then
--         self:SetFOVRatio(55 / 90, 0.2)
--     elseif (math.abs(self:GetFOVRatio() - 55 / 90) < 0.00001) then
--         self:SetFOVRatio(1, 0.15)
--     else
--         self:SetFOVRatio(1, 0)
--     end
--     self:SetNextSecondaryFire(CurTime() + 0.3)
--     self:SetZoomFullyActiveTime(CurTime() + 0.2) -- The worst zoom time from above.
-- end
-- function SWEP:IsScoped()
--     return self:GetFOVRatio() ~= 1
-- end
-- function SWEP:HandleReload()
--     self:SetFOVRatio(1, 0.05)
-- end
-- function SWEP:GunFire(spread)
--     local flCycleTime = self.CycleTime
--     if self:IsScoped() then
--         flCycleTime = 0.135
--     end
--     if not self:BaseGunFire(spread, flCycleTime, true) then return end
--     --Jvs: this is so goddamn lame
--     if self:GetOwner():GetAbsVelocity():Length2D() > 5 then
--         self:KickBack(1, 0.45, 0.28, 0.04, 4.25, 2.5, 7)
--     elseif not self:GetOwner():OnGround() then
--         self:KickBack(1.25, 0.45, 0.22, 0.18, 6, 4, 5)
--     elseif self:GetOwner():Crouching() then
--         self:KickBack(0.6, 0.35, 0.2, 0.0125, 3.7, 2, 10)
--     else
--         self:KickBack(0.625, 0.375, 0.25, 0.0125, 4, 2.25, 9)
--     end
-- end
-- function SWEP:GetSpeedRatio()
--     if self:IsScoped() then return 200 / 260 end
--     return 1
-- end
