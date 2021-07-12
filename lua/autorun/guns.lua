-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
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
    CS_KILLICON_FONT = "CSTypeDeath"

    surface.CreateFont(CS_KILLICON_FONT, {
        font = "csd",
        size = ScreenScale(20),
        antialias = true,
        weight = 300
    })
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
    self.CSMuzzleFlashes = true
    self.CSMuzzleX = tab.MuzzleFlashStyle == "CS_MUZZLEFLASH_X"
    self.Primary.Automatic = tonumber(tab.FullAuto) == 1
    self.Primary.ClipSize = tab.clip_size
    self.Primary.Ammo = tab.primary_ammo
    self.Primary.DefaultClip = tab.clip_size
    self.Secondary.Automatic = false
    self.Secondary.ClipSize = -1
    self.Secondary.DefaultClip = 0
    self.Secondary.Ammo = -1
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

    self.HeadshotMultiplier = 3
    self.LegshotMultiplier = 0.8

    if class == "gun_awp" then
        self.Damage = 200
    end

    self.SprayBase = tab.AccuracyOffset or 0.2
    self.SprayExponent = 2 --(tab.AccuracyQuadratic==1) and 2 or 3
    self.SprayIncrement = (tab.AccuracyDivisor or 200) ^ (-1 / self.SprayExponent)
    self.SprayMax = ((tab.MaxInaccuracy or 1) - self.SprayBase) ^ (1 / self.SprayExponent)

    if CLIENT then
        if tab.TextureData then
            killicon.AddFont(class, CS_KILLICON_FONT, tab.TextureData.weapon.character:lower(), Color(255, 80, 0, 255))

            if self.ProjectileClass then
                killicon.AddAlias(self.ProjectileClass, class)
            end
        end
    end
end
-- hook.Add( "SetupMove" , "CSS - Speed Modify" , function( ply , mv , cmd )
-- 	local weapon = ply:GetActiveWeapon()
-- 	if IsValid( weapon ) and weapon.CSSWeapon then
-- 		mv:SetMaxClientSpeed( mv:GetMaxClientSpeed() * weapon:GetSpeedRatio() )
-- 	end
-- end)
