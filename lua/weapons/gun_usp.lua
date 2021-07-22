-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
DEFINE_BASECLASS("gun")
SWEP.GunType = "pistol"
SWEP.PrintName = "USP"
SWEP.Purpose = "Long range pistol"
SWEP.HoldType = "pistol"
SWEP.Slot = 0
CSKillIcon(SWEP, "a")
--
SWEP.WorldModel = "models/weapons/w_pist_usp.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_pist_usp.mdl"
SWEP.ShootSound = "Weapon_USP.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.00
--
SWEP.Primary.Ammo = "BULLET_PLAYER_45ACP"
SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Automatic = false
SWEP.Damage = 29
SWEP.CycleTime = 0.14
SWEP.HalfDamageDistance = 4096
--
SWEP.SpreadBase = 0.006
SWEP.SpreadMove = 0.014
SWEP.Spray = 0.05
SWEP.SprayExponent = 2.5

ComputeSpray(SWEP, {
    TapFireInterval = 0.35,
    ShotsTo90Spray = 7
})

--
SWEP.KickUBase = 1
SWEP.KickUSpray = 1
SWEP.KickLBase = 0
SWEP.KickLSpray = 1

SWEP.MoveSpeed = 1

-- SWEP.KickSimple = 2
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed"		"250"
-- 	"WeaponType"			"Pistol"
-- 	"FullAuto"				0
-- 	"WeaponPrice"			"500"
-- 	"WeaponArmorRatio"		"1.0"
-- 	"CrosshairMinDistance"		"8"
-- 	"CrosshairDeltaDistance" 	"3"
-- 	"Team" 				"ANY"
-- 	"BuiltRightHanded" 		"0"
-- 	"PlayerAnimationExtension" 	"pistol"
-- 	"MuzzleFlashScale"		"1"
-- 	"CanEquipWithShield" 		"1"
-- 	// Weapon characteristics:
-- 	"Penetration"			"1"
-- 	"Damage"			"34"
-- 	"Range"				"4096"
-- 	"RangeModifier"			"0.79"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"0.15"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00400
-- 	"InaccuracyCrouch"			0.00600
-- 	"InaccuracyStand"			0.00800
-- 	"InaccuracyJump"			0.28725
-- 	"InaccuracyLand"			0.05745
-- 	"InaccuracyLadder"			0.01915
-- 	"InaccuracyFire"			0.03495
-- 	"InaccuracyMove"			0.01724
-- 	"SpreadAlt"					0.00300
-- 	"InaccuracyCrouchAlt"		0.00600
-- 	"InaccuracyStandAlt"		0.00800
-- 	"InaccuracyJumpAlt"			0.29625
-- 	"InaccuracyLandAlt"			0.05925
-- 	"InaccuracyLadderAlt"		0.01975
-- 	"InaccuracyFireAlt"			0.02504
-- 	"InaccuracyMoveAlt"			0.01778
-- 	"RecoveryTimeCrouch"		0.23371
-- 	"RecoveryTimeStand"			0.28045
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_USP45"
-- 	"viewmodel"			"models/weapons/v_pist_usp.mdl"
-- 	"playermodel"			"models/weapons/w_pist_usp.mdl"
-- 	"shieldviewmodel"		"models/weapons/v_shield_usp_r.mdl"
-- 	"SilencerModel"			"models/weapons/w_pist_usp_silencer.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"1"
-- 	"bucket_position"		"1"
-- 	"clip_size"			"12"
-- 	"primary_ammo"			"BULLET_PLAYER_45ACP"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"5"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Default.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_USP.Single"
-- 		"special1"			"Weapon_USP.SilencedShot"
-- 		"special2"			"Weapon_USP.DetachSilencer"
-- 		"special3"			"Weapon_USP.AttachSilencer"
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"A"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"A"
-- 		}
-- 		"ammo"
-- 		{
-- 				"font"		"CSTypeDeath"
-- 				"character"		"M"
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
-- 			Mins	"-7 -4 -14"
-- 			Maxs	"24 9 -2"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-1 -4 -3"
-- 			Maxs	"17 5 6"
-- 		}
-- 	}
-- }]])
-- function SWEP:PrimaryAttack()
--     if self:GetNextPrimaryFire() > CurTime() then return end
--     self:GunFire(self:BuildSpread(), true)
-- end
-- function SWEP:GunFire(spread, mode)
--     --Jvs: technically this should be > 1, but since this is increased in basegunfire, we have to do it this way
--     if self:GetShotsFired() > 0 then return end
--     self:SetAccuracy(self:GetAccuracy() - 0.275 * (0.3 - CurTime() - self:GetLastFire()))
--     if self:GetAccuracy() > 0.92 then
--         self:SetAccuracy(0.92)
--     elseif self:GetAccuracy() < 0.6 then
--         self:SetAccuracy(0.6)
--     end
--     self:SetNextIdle(CurTime() + 2)
--     if not self:BaseGunFire(spread, self.CycleTime, mode) then return end
--     local angle = self:GetOwner():GetViewPunchAngles()
--     angle.p = angle.p - 2
--     self:GetOwner():SetViewPunchAngles(angle)
-- end
--
--
--
-- set this for silenced variants AND USE SilencerModel for worldmodel
-- SWEP.Silenced = true
-- function SWEP:TranslateViewModelActivity(act)
-- 	return {
-- 		[ACT_VM_RELOAD] = ACT_VM_RELOAD_SILENCED,
-- 		[ACT_VM_PRIMARYATTACK] = ACT_VM_PRIMARYATTACK_SILENCED,
-- 		[ACT_VM_DRAW] = ACT_VM_DRAW_SILENCED,
-- 		[ACT_VM_IDLE] = ACT_VM_IDLE_SILENCED,
-- 	}[act] or act 
-- end
