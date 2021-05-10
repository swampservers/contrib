-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
SWEP.PrintName = "Sniper"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.ViewModelFOV = 75
SWEP.ViewModel = "models/weapons/v_m98bravo.mdl"
SWEP.WorldModel = "models/weapons/w_barrett_m98b.mdl"
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.HoldType = "ar2"
SWEP.FiresUnderwater = true
SWEP.Weight = 50
SWEP.DrawCrosshair = false
SWEP.Category = "SMOD"

game.AddAmmoType({
    name = "sniper",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 100,
    npcdmg = 100,
    force = 200,
    minsplash = 10,
    maxsplash = 5
})

SWEP.Primary.Damage = 120
SWEP.Primary.ClipSize = 5
SWEP.Primary.Ammo = "sniper"
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Force = 2000
SWEP.Primary.Spread = 0
SWEP.Primary.Recoil = 0.7
SWEP.Primary.Delay = 1.5
SWEP.Primary.NumberofShots = 1
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Delay = 0
SWEP.Secondary.Damage = 0
local HitSound = Sound("weapons/kar98/kar_shoot.wav")
local BoltBack = Sound("weapons/kar98/boltback.wav")
local BoltForward = Sound("weapons/kar98/boltforward.wav")

function SWEP:SprintMod()
    return ((math.cos(((self.SprintNess or 0) + 1) * math.pi) + 1) * 0.5)
end

function SWEP:IsSprinting()
    return self.Owner:GetVelocity():Length() > (self.Owner:GetWalkSpeed() + self.Owner:GetRunSpeed()) * 0.5
end

function SWEP:DrawWorldModel()
    self:SetupBones()
    local mrt = self:GetBoneMatrix(0)

    if (mrt) then
        mrt:SetTranslation(mrt:GetTranslation() + (mrt:GetUp() * -0.8))
        self:SetBoneMatrix(0, mrt)
    end

    self:DrawModel()
end

function SWEP:GetViewModelPosition(pos, ang)
    if self:GetNWInt("sc", 0) > 0 then return Vector(0, 0, -10000), ang end
    pos = pos + (0 * ang:Up()) + (1 * ang:Right()) + (0 * ang:Forward())
    ang:RotateAroundAxis(ang:Right(), -2)
    local sm = self:SprintMod()
    pos = pos + (0 * sm * ang:Up()) + (1 * sm * ang:Right())
    ang:RotateAroundAxis(ang:Up(), sm * 20)
    ang:RotateAroundAxis(ang:Right(), sm * -20)

    return pos, ang
end

local scope_material = Material("scope/gdcw_parabolicsight")

function SWEP:DrawHUD()
    local mx = ScrW() / 2
    local my = ScrH() / 2
    self.XHairspread = (EyePos() + EyeAngles():Forward() + EyeAngles():Right() * self:GetCone()):ToScreen().x - mx
    local spread = self.XHairspread
    local len = 10
    local mx = ScrW() / 2
    local my = ScrH() / 2

    if self:GetNWInt("sc", 0) > 0 then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(scope_material)
        surface.DrawTexturedRect(((ScrW() - ScrH()) / 2) + (spread * 0.06 * math.sin(CurTime() * self.Owner:GetVelocity():Length() * 0.03)), 0, ScrH(), ScrH())

        return
    end
    --[[
	surface.SetDrawColor(255,200,20,Lerp(math.Clamp((self:GetCone()-0.3)*10,0,1),255,0))

	surface.DrawLine(mx-(spread+len),my,mx-spread,my)
	surface.DrawLine(mx+(spread+len),my,mx+spread,my)
	surface.DrawLine(mx,my-(spread+len),mx,my-spread)
	surface.DrawLine(mx,my+(spread+len),mx,my+spread)]]
end

function SWEP:CalcView(ply, pos, ang, fov)
    if SERVER then return pos, ang, fov end
    -- fov = fov - self:GetNWInt("sc", 0) * 33
    local sc = self:GetNWInt("sc", 0)

    if sc == 1 then
        fov = 40
    end

    if sc == 2 then
        fov = 15
    end

    return pos, ang, fov
end

function SWEP:AdjustMouseSensitivity()
    return 1.0 - (self:GetNWInt("sc", 0) * 0.4)
end

if CLIENT then
    function SWEP:Think()
        ply = self.Owner
        if LocalPlayer():GetActiveWeapon() ~= self then return end
        local changesprintness = 2.2 * RealFrameTime()

        if self:IsSprinting() then
            changesprintness = -1 * changesprintness
        end

        self.SprintNess = math.Clamp((self.SprintNess or 0) - changesprintness, 0, 1)
    end
end

function SWEP:Initialize()
    util.PrecacheSound("weapons/kar98/kar_shoot.wav")
    util.PrecacheSound("weapons/kar98/boltback.wav")
    util.PrecacheSound("weapons/kar98/boltforward.wav")
    self:SetWeaponHoldType(self.HoldType)
    self:SetHoldType(self.HoldType)
end

function SWEP:GetCone()
    local mc = math.max((self.Owner:GetVelocity():LengthSqr() * 0.000005) - 0.01, 0)

    return mc + (self:GetNWInt("sc", 0) == 0 and 0.04 or 0)
end

local BOLTACTIONSPEED = 1

function SWEP:PrimaryAttack()
    if (not self:CanPrimaryAttack()) then return end
    if self:IsSprinting() then return end

    if SERVER or IsFirstTimePredicted() then
        timer.Simple(0.2, function()
            self:SetNWInt("sc", 0)
        end)
    end

    local bullet = {}
    bullet.Num = self.Primary.NumberofShots
    bullet.Src = self.Owner:GetShootPos()
    bullet.Dir = self.Owner:GetAimVector()
    local ac = self:GetCone()
    bullet.Spread = Vector(ac, ac, 0)
    bullet.Tracer = 2
    bullet.TracerName = "Tracer"
    bullet.Force = self.Primary.Force
    bullet.Damage = self.Primary.Damage
    bullet.AmmoType = self.Primary.Ammo
    local rnda = self.Primary.Recoil * -1
    local rndb = self.Primary.Recoil * math.random(-1, 1)
    local vm = self.Owner:GetViewModel()
    self.Owner:MuzzleFlash() -- Crappy muzzle light
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK))
    vm:SetPlaybackRate(BOLTACTIONSPEED)
    self.Owner:FireBullets(bullet)
    self.Weapon:EmitSound(HitSound, 100, math.random(90, 110))
    self.Owner:ViewPunch(Angle(rnda, rndb, rnda))
    self:TakePrimaryAmmo(self.Primary.TakeAmmo)
    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    --self.Owner:SetAnimation( PLAYER_ATTACK1 )
    timer.Simple(0.5 / BOLTACTIONSPEED, function()
        if IsValid(self) and IsValid(self.Owner) then
            self.Owner:EmitSound(BoltBack)
        end
    end)

    timer.Simple(0.9 / BOLTACTIONSPEED, function()
        if IsValid(self) and IsValid(self.Owner) then
            self.Owner:EmitSound(BoltForward)
        end
    end)
    --timer.Simple( 2, function() self:SendWeaponAnim( ACT_VM_SECONDARYATTACK ) end )
    --timer.Simple( self:SequenceDuration(), function() if ( !IsValid( self ) ) then return end self:SendWeaponAnim( ACT_VM_IDLE ) end ) 
end

function SWEP:SecondaryAttack()
    if (not self:CanPrimaryAttack()) then return end

    if SERVER or (CLIENT and IsFirstTimePredicted()) then
        self:SetNWInt("sc", (self:GetNWInt("sc", 0) + 1) % 3)

        if CLIENT then
            self.scop = self:GetNWInt("sc", 0)
            surface.PlaySound("weapons/smg1/switch_single.wav")
        end
    else
        self:SetNWInt("sc", self.scop)
    end
end

function SWEP:Reload()
    local wep = self.Weapon
    local owner = self.Owner
    if wep:Clip1() == 5 or owner:GetAmmoCount(self.Primary.Ammo) == 0 then return false end

    if wep:Clip1() < 5 then
        self:DefaultReload(ACT_VM_RELOAD)
        owner:DoReloadEvent()
        self:SetNextPrimaryFire(CurTime() + 2.4)

        timer.Simple(0, function()
            self:EmitSound("weapons/smg1/smg1_reload.wav")
        end)

        timer.Simple(2.2, function()
            if IsValid(self) and IsValid(self.Owner) then
                self:EmitSound(BoltBack)
            end
        end)

        timer.Simple(2.7, function()
            if IsValid(self) and IsValid(self.Owner) then
                self:EmitSound(BoltForward)
            end
        end)
    end
end

if CLIENT then
    surface.CreateFont("SniperKillicon", {
        font = "csd",
        size = ScreenScale(30),
        antialias = true,
        additive = true
    })

    killicon.AddFont("weapon_sniper", "SniperKillicon", "o", Color(255, 80, 0, 255))
end