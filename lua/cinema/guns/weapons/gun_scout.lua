-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "sniper"
SWEP.PrintName = "Scout"
SWEP.Purpose = "Lightweight sniper rifle. Can remove props."
SWEP.HoldType = "ar2"
SWEP.Slot = 0
CSKillIcon(SWEP, "n")
--
SWEP.WorldModel = "models/weapons/w_snip_scout.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.ShootSound = "Weapon_Scout.Single"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.10
--
SWEP.Primary.Ammo = "BULLET_PLAYER_762MM"
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Damage = 80
SWEP.CycleTime = 1.2500
SWEP.HalfDamageDistance = 32768
--
SWEP.SpreadBase = 0.0000
SWEP.SpreadMove = 0.05
SWEP.Spray = 0.2
SWEP.SprayExponent = 2

ComputeSpray(SWEP, {
    TapFireInterval = 1,
    ShotsTo90Spray = 1
})

--
SWEP.SpreadUnscoped = 0.2

SWEP.ScopeLevels = {40 / 90, 10 / 90}

SWEP.ScopedSpeedRatio = 220 / 260
SWEP.UnscopeOnShoot = true
--
SWEP.KickUBase = 2
SWEP.KickUSpray = 0
SWEP.KickLBase = 0
SWEP.KickLSpray = 1
SWEP.MoveSpeed = 1
--
SWEP.SpawnPriceMod = 0.7
SWEP.AmmoPriceMod = 0.6
SWEP.CSPrice = 2750
-- CSParseWeaponInfo(SWEP, [[WeaponData
-- {
-- 	"MaxPlayerSpeed" 		"260"
-- 	"WeaponType" 			"SniperRifle"
-- 	"FullAuto"				0
-- 	"WeaponPrice"			"2750"
-- 	"WeaponArmorRatio"		"1.7"
-- 	"CrosshairMinDistance"		"5"
-- 	"CrosshairDeltaDistance"	"3"
-- 	"Team"				"ANY"
-- 	"BuiltRightHanded"		"0"
-- 	"PlayerAnimationExtension"	"scout"
-- 	"MuzzleFlashScale"		"1.1"
-- 	"CanEquipWithShield"		"0"
-- 	// Weapon characteristics:
-- 	"Penetration"			"3"
-- 	"Damage"			"75"
-- 	"Range"				"8192"
-- 	"RangeModifier"			"0.98"
-- 	"Bullets"			"1"
-- 	"CycleTime"			"1.25"
-- 	"AccuracyDivisor"		"-1"
-- 	"AccuracyOffset"		"0"
-- 	"MaxInaccuracy"			"0"
-- 	"TimeToIdle"			"1.8"
-- 	"IdleInterval"			"60"
-- 	// New accuracy model parameters
-- 	"Spread"					0.00030
-- 	"InaccuracyCrouch"			0.02378
-- 	"InaccuracyStand"			0.03170
-- 	"InaccuracyJump"			0.38195
-- 	"InaccuracyLand"			0.03819
-- 	"InaccuracyLadder"			0.09549
-- 	"InaccuracyFire"			0.06667
-- 	"InaccuracyMove"			0.19097
-- 	"SpreadAlt"					0.00030
-- 	"InaccuracyCrouchAlt"		0.00300
-- 	"InaccuracyStandAlt"		0.00400
-- 	"InaccuracyJumpAlt"			0.38195
-- 	"InaccuracyLandAlt"			0.03819
-- 	"InaccuracyLadderAlt"		0.09549
-- 	"InaccuracyFireAlt"			0.06667
-- 	"InaccuracyMoveAlt"			0.19097
-- 	"RecoveryTimeCrouch"		0.17681
-- 	"RecoveryTimeStand"			0.24753
-- 	// Weapon data is loaded by both the Game and Client DLLs.
-- 	"printname"			"#Cstrike_WPNHUD_Scout"
-- 	"viewmodel"			"models/weapons/v_snip_scout.mdl"
-- 	"playermodel"			"models/weapons/w_snip_scout.mdl"
-- 	"anim_prefix"			"anim"
-- 	"bucket"			"0"
-- 	"bucket_position"		"0"
-- 	"clip_size"			"10"
-- 	"primary_ammo"			"BULLET_PLAYER_762MM"
-- 	"secondary_ammo"		"None"
-- 	"weight"			"30"
-- 	"item_flags"			"0"
-- 	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
-- 	SoundData
-- 	{
-- 		//"reload"			"Weapon_AWP.Reload"
-- 		//"empty"				"Default.ClipEmpty_Rifle"
-- 		"single_shot"		"Weapon_Scout.Single"
-- 		special3			Default.Zoom
-- 	}
-- 	// Weapon Sprite data is loaded by the Client DLL.
-- 	TextureData
-- 	{
-- 		"weapon"
-- 		{
-- 				"font"		"CSweaponsSmall"
-- 				"character"	"N"
-- 		}
-- 		"weapon_s"
-- 		{
-- 				"font"		"CSweapons"
-- 				"character"	"N"
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
-- 			Mins	"-12 -4 -11"
-- 			Maxs	"27 12 -1"
-- 		}
-- 		World
-- 		{
-- 			Mins	"-10 -4 -13"
-- 			Maxs	"32 8 12"
-- 		}
-- 	}
-- }]])
-- function SWEP:PrimaryAttack()
--     if self:GetNextPrimaryFire() > CurTime() then return end
--     self:GunFire(self:BuildSpread())
-- end
-- function SWEP:SecondaryAttack()
--     local pPlayer = self:GetOwner()
--     if not IsValid(pPlayer) then return end
--     if (self:GetZoomFullyActiveTime() > CurTime() or self:GetNextPrimaryFire() > CurTime()) then
--         self:SetNextSecondaryFire(self:GetZoomFullyActiveTime() + 0.15)
--         return
--     end
--     if (not self:IsScoped()) then
--         self:SetFOVRatio(40 / 90, 0.15)
--     elseif (math.abs(self:GetFOVRatio() - 40 / 90) < 0.00001) then
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
