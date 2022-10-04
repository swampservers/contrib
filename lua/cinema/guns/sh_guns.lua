-- This file is subject to copyright - contact swampservers@gmail.com for more information.
function ComputeSpray(SWEP, args)
    local stableinterval, shotsto90 = args.TapFireInterval, args.ShotsTo90Spray
    local targetsos = 0.9

    if stableinterval < SWEP.CycleTime then
        SWEP.SprayIncrement = 1
        SWEP.SprayDecay = 1 / stableinterval
        SWEP.SpraySaturation = 2 -- doesnt matter unless the gun has special stats, but its a good default

        return
    end

    SWEP.SpraySaturation = stableinterval / SWEP.CycleTime

    local function shotdecay()
        return SWEP.SprayIncrement / SWEP.SpraySaturation
    end

    local function sos()
        local sdecay = shotdecay()
        local prevspray, spray = 0, 0

        for i = 1, math.floor(shotsto90) + 1 do
            prevspray = spray
            spray = math.max(0, spray + SWEP.SprayIncrement / SWEP.SpraySaturation ^ spray - sdecay)
        end

        return Lerp(shotsto90 - math.floor(shotsto90), prevspray, spray)
    end

    SWEP.SprayIncrement = 0.5
    local approach = 0.25

    for refine = 1, 10 do
        SWEP.SprayIncrement = SWEP.SprayIncrement + (sos() < targetsos and approach or -approach)
        approach = 0.5 * approach
    end

    SWEP.SprayDecay = shotdecay() / SWEP.CycleTime

    if math.abs(sos() - targetsos) > 0.01 then
        print(SWEP.PrintName, "can't reach target spray")
    end
end

-- function SetupSpray(SWEP)
--     SWEP.SpraySaturation = SWEP.SpraySaturation or 2
--     SWEP.SprayDecay = SWEP.SprayIncrement / (SWEP.CycleTime * SWEP.SpraySaturation)
-- end
function SprayControlFactor(self, control)
    self.SprayDecay = control * self.SprayIncrement / self.CycleTime
end

game.AddAmmoType{
    name = "BULLET_PLAYER_50AE",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 0,
    npcdmg = 0,
    force = 2400,
    minsplash = 10,
    maxsplash = 14
}

game.AddAmmoType{
    name = "BULLET_PLAYER_762MM",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 0,
    npcdmg = 0,
    force = 2400,
    minsplash = 10,
    maxsplash = 14
}

game.AddAmmoType{
    name = "BULLET_PLAYER_556MM",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 0,
    npcdmg = 0,
    force = 2400,
    minsplash = 10,
    maxsplash = 14
}

game.AddAmmoType{
    name = "BULLET_PLAYER_556MM_BOX",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 0,
    npcdmg = 0,
    force = 2400,
    minsplash = 10,
    maxsplash = 14
}

game.AddAmmoType{
    name = "BULLET_PLAYER_338MAG",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 0,
    npcdmg = 0,
    force = 2800,
    minsplash = 12,
    maxsplash = 16
}

game.AddAmmoType{
    name = "BULLET_PLAYER_9MM",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 0,
    npcdmg = 0,
    force = 2000,
    minsplash = 5,
    maxsplash = 10
}

game.AddAmmoType{
    name = "BULLET_PLAYER_BUCKSHOT",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 0,
    npcdmg = 0,
    force = 600,
    minsplash = 3,
    maxsplash = 6
}

game.AddAmmoType{
    name = "BULLET_PLAYER_AIRSOFT",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 0,
    npcdmg = 0,
    force = 600,
    minsplash = 3,
    maxsplash = 6
}

game.AddAmmoType{
    name = "BULLET_PLAYER_45ACP",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 0,
    npcdmg = 0,
    force = 2100,
    minsplash = 6,
    maxsplash = 10
}

game.AddAmmoType{
    name = "BULLET_PLAYER_357SIG",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 0,
    npcdmg = 0,
    force = 2000,
    minsplash = 4,
    maxsplash = 8
}

game.AddAmmoType{
    name = "BULLET_PLAYER_57MM",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 0,
    npcdmg = 0,
    force = 2000,
    minsplash = 4,
    maxsplash = 8
}

local wepinfo_default = {
    MaxPlayerSpeed = 250,
    WeaponPrice = -1,
    WeaponArmorRatio = 1,
    CrosshairMinDistance = 4,
    CrosshairDeltaDistance = 3,
    CanEquipWithShield = false,
    MuzzleFlashScale = 1,
    MuzzleFlashStyle = "CS_MUZZLEFLASH_NORM",
    Penetration = 1,
    Damage = 42,
    Range = 8192,
    RangeModifier = 0.98,
    Bullets = 1,
    CycleTime = 0.15,
    AccuracyQuadratic = 0,
    AccuracyDivisor = -1,
    AccuracyOffset = 0,
    MaxInaccuracy = 0,
    TEAM = "ANY",
    shieldviewmodel = "",
    PlayerAnimationExtension = "m4",
    BotAudibleRange = 2000,
    WeaponType = 0,
    Spread = 0,
    InaccuracyStand = 0,
    InaccuracyCrouch = 0,
    InaccuracyMove = 0,
    InaccuracyJump = 0,
    InaccuracyLadder = 0,
    SpreadAlt = 0,
    InaccuracyStandAlt = 0,
    InaccuracyCrouchAlt = 0,
    InaccuracyMoveAlt = 0,
    InaccuracyJumpAlt = 0,
    InaccuracyLadderAlt = 0,
    SoundData = {},
    RecoveryTimeStand = 0.5,
    RecoveryTimeCrouch = 0.4,
}

wepinfo_default.__index = wepinfo_default

if CLIENT then
    surface.CreateFont("CSTypeDeath", {
        font = "csd",
        size = ScreenScale(20),
        weight = 300,
        additive = true,
    })
end

function CSKillIcon(self, letter)
    if SERVER then return end
    killicon.AddFont(self.Folder:Replace(".lua", ""):Replace("weapons/", ""), "CSTypeDeath", letter, Color(255, 80, 0, 255))
end

local classlist = {}

function CSParseWeaponInfo(self, str)
    local class = self.Folder:Replace(".lua", ""):Replace("weapons/", "")
    local tab = util.KeyValuesToTable(str, nil, true) or {}

    -- setmetatable(tab, wepinfo_default)
    for k, v in pairs(wepinfo_default) do
        self[k] = tab[k] or v
    end

    self._WeaponInfo = tab
    -- self.CSInfo = tab
    self.SpeedRatio = tab.MaxPlayerSpeed / 250
    self.ScopedSpeedRatio = self.SpeedRatio / 2
    self.CSMuzzleFlashes = true --
    self.CSMuzzleX = tab.MuzzleFlashStyle == "CS_MUZZLEFLASH_X"
    self.CSMuzzleFlashScale = tab.MuzzleFlashScale
    self.Primary.Automatic = tonumber(tab.FullAuto) == 1
    self.Primary.ClipSize = tab.clip_size
    self.Primary.Ammo = tab.primary_ammo
    self.Primary.DefaultClip = tab.clip_size
    self.Secondary.Automatic = false --
    self.Secondary.ClipSize = -1 --
    self.Secondary.DefaultClip = 0 --
    self.Secondary.Ammo = -1 --
    --Jvs: if this viewmodel can't be converted into the corresponding c_ model, apply viewmodel flip as usual
    local convertedvm = tab.viewmodel:Replace("/v_", "/cstrike/c_")

    if file.Exists(convertedvm, "GAME") then
        self.ViewModel = convertedvm
    else
        self.ViewModelFlip = tab.BuiltRightHanded == 0
    end

    self.WorldModel = self.Silenced and tab.SilencerModel or tab.playermodel
    self.ViewModelFOV = 60
    self.Weight = tab.weight
    self.m_WeaponDeploySpeed = 1

    if self.GunType == "smg" then
        self.CycleTime = self.CycleTime * 5 / 6
    end

    self.HeadshotMultiplier = 3 --
    self.LegshotMultiplier = 0.8 --

    if class == "gun_awp" then
        self.Damage = 200
    end

    local definedexponent = tab.AccuracyQuadratic == 1 and 2 or 3
    local defineddivider = tab.AccuracyDivisor and tab.AccuracyDivisor > 0 and tab.AccuracyDivisor or 20
    local shotincrement = (defineddivider * (tab.MaxInaccuracy and tab.MaxInaccuracy > 0 and tab.MaxInaccuracy or 1)) ^ (-1 / definedexponent)
    -- (tab.MaxInaccuracy or 1)  ^ (1/definedexponent)
    -- self.SprayExponent = 2 --(tab.AccuracyQuadratic==1) and 2 or 3
    -- self.SprayMin = tab.AccuracyOffset or 0.2
    -- self.SprayMax = ( (tab.MaxInaccuracy or 1) ) ^ (1/self.SprayExponent)
    -- self.SprayIncrement = shotincrement
    -- self.SprayDecay = shotincrement / self.RecoveryTimeStand
    -- self.SprayDecayCrouch = shotincrement / self.RecoveryTimeCrouch
    local based = tab.AccuracyOffset or 0.2
    local maxxed = tab.MaxInaccuracy or 1
    self.SpreadBase = based * ((tab.InaccuracyStand or 0) + (tab.Spread or 0))
    self.SpreadMove = based * (tab.InaccuracyMove or 0)
    self.Spray = maxxed * (tab.InaccuracyStand or 0) --(maxxed-based)
    self.SprayExponent = definedexponent
    self.SprayIncrement = shotincrement
    self.SprayDecay = shotincrement / self.RecoveryTimeStand
    self.HalfDamageDistance = math.log(0.5, tab.RangeModifier) * 500

    if CLIENT then
        if tab.TextureData then
            killicon.AddFont(class, "CSTypeDeath", tab.TextureData.weapon.character:lower(), Color(255, 80, 0, 255))

            if self.ProjectileClass then
                killicon.AddAlias(self.ProjectileClass, class)
            end
        end
    end

    if true then
        print(class)
        print(([[

CSKillIcon(SWEP, "%s")
--
SWEP.WorldModel = "%s"
SWEP.ViewModel = "%s"
SWEP.ShootSound = "%s"
SWEP.CSMuzzleFlashes = %s
SWEP.CSMuzzleX = %s
SWEP.CSMuzzleFlashScale = %4.2f
--
SWEP.Primary.Ammo = "%s"
SWEP.Primary.ClipSize = %s
SWEP.Primary.DefaultClip = %s
SWEP.Primary.Automatic = %s
SWEP.Damage = %s
SWEP.CycleTime = %4.4f
SWEP.HalfDamageDistance = %s
--
SWEP.SpreadBase = %4.4f
SWEP.SpreadMove = %4.4f
SWEP.Spray = %4.4f
SWEP.SprayExponent = %s
SWEP.SprayIncrement = %4.4f
SWEP.SprayDecay = %4.4f
--
  
]]):format(tab.TextureData and tab.TextureData.weapon.character:lower() or "?", self.WorldModel, self.ViewModel, tab.SoundData.single_shot, true, self.CSMuzzleX, self.CSMuzzleFlashScale, self.Primary.Ammo, self.Primary.ClipSize, self.Primary.ClipSize, self.Primary.Automatic, self.Damage, self.CycleTime, math.floor(self.HalfDamageDistance), self.SpreadBase, self.SpreadMove, self.Spray, self.SprayExponent, self.SprayIncrement, self.SprayDecay))
    end
end
-- hook.Add( "SetupMove" , "CSS - Speed Modify" , function( ply , mv , cmd )
-- 	local weapon = ply:GetActiveWeapon()
-- 	if IsValid( weapon ) and weapon.CSSWeapon then
-- 		mv:SetMaxClientSpeed( mv:GetMaxClientSpeed() * weapon:GetSpeedRatio() )
-- 	end
-- end)
