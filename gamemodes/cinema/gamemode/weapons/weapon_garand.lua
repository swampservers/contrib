-- This file is subject to copyright - contact swampservers@gmail.com for more information.
AddCSLuaFile()
SWEP.PrintName = "Garand"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.ViewModelFOV = 75
SWEP.ViewModel = "models/weapons/c_dod_garand.mdl"
SWEP.WorldModel = "models/weapons/w_garand.mdl"
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
    name = "garand",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 100,
    npcdmg = 100,
    force = 200,
    minsplash = 10,
    maxsplash = 5
})

SWEP.Primary.Damage = 60
SWEP.Primary.ClipSize = 8
SWEP.Primary.Ammo = "garand"
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Force = 2000
SWEP.Primary.Spread = 0
SWEP.Primary.Recoil = 0.7
SWEP.Primary.Delay = 0.3
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

-- Override function for displaying ammo count
function SWEP:CustomAmmoDisplay()
    if (InGarandZone(self.Owner)) then
        return {
            PrimaryAmmo = self.Primary.ClipSize * 999
        }
    end

    return {
        PrimaryAmmo = 0
    }
end

game.AddAmmoType({
    name = "garand",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 60,
    npcdmg = 60,
    force = 0,
    minsplash = 10,
    maxsplash = 5
})

function SWEP:SprintMod()
    return ((math.cos(((self.SprintNess or 0) + 1) * math.pi) + 1) * 0.5)
end

function SWEP:IsSprinting()
    return self.Owner:GetVelocity():Length() > (self.Owner:GetWalkSpeed() + self.Owner:GetRunSpeed()) * 0.5
end

function SWEP:DrawWorldModel()
    -- self:SetupBones()
    local mrt = self:GetBoneMatrix(0)
    if mrt then end -- mrt:SetTranslation(mrt:GetTranslation()+(mrt:GetUp()*-0.8)) --self:SetBoneMatrix(0, mrt )
    self:DrawModel()
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + (0 * ang:Up()) + (1 * ang:Right()) + (0 * ang:Forward())
    ang:RotateAroundAxis(ang:Right(), -2)
    local sm = self:SprintMod()
    pos = pos + (0 * sm * ang:Up()) + (1 * sm * ang:Right())
    ang:RotateAroundAxis(ang:Up(), sm * 20)
    ang:RotateAroundAxis(ang:Right(), sm * -20)

    return pos, ang
end

function SWEP:DrawHUD()
    local mx = ScrW() / 2
    local my = ScrH() / 2
    self.XHairspread = (EyePos() + EyeAngles():Forward() + EyeAngles():Right() * self:GetCone()):ToScreen().x - mx
    local spread = self.XHairspread
    local len = 10
    local mx = ScrW() / 2
    local my = ScrH() / 2
    surface.SetDrawColor(255, 200, 20, Lerp(math.Clamp((self:GetCone() - 0.3) * 10, 0, 1), 255, 0))
    surface.DrawLine(mx - (spread + len), my, mx - spread, my)
    surface.DrawLine(mx + (spread + len), my, mx + spread, my)
    surface.DrawLine(mx, my - (spread + len), mx, my - spread)
    surface.DrawLine(mx, my + (spread + len), mx, my + spread)
end

if CLIENT then
    function SWEP:Think()
        ply = self.Owner
        if Me:GetActiveWeapon() ~= self then return end
        local changesprintness = 2.2 * RealFrameTime()

        if self:IsSprinting() then
            changesprintness = -1 * changesprintness
        end

        self.SprintNess = math.Clamp((self.SprintNess or 0) - changesprintness, 0, 1)
    end
end

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
    self:SetHoldType(self.HoldType)
end

function SWEP:GetCone()
    local mc = math.max((self.Owner:GetVelocity():LengthSqr() * 0.000005) - 0.01, 0)
    -- (self:GetNWInt("sc",0)==0 and 0.04 or 0)

    return mc + 0.005
end

local BOLTACTIONSPEED = 1

function SWEP:PrimaryAttack()
    self.Owner:SetAmmo(80, "garand")

    if self:Clip1() == 0 and InGarandZone(self.Owner) then
        self:Reload()

        return
    end

    if (not self:CanPrimaryAttack()) then
        self:EmitSound("Weapon_SMG1.Empty")
        self:SendWeaponAnim(ACT_VM_DRYFIRE)
        self:SetNextPrimaryFire(CurTime() + 0.5)

        return
    end

    if self:IsSprinting() then return end
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
    self:EmitSound("DOD_Garand.Fire")

    if self:Clip1() == 1 then
        timer.Simple(0.01, function()
            if IsValid(self) and IsValid(self.Owner) then
                self.Owner:EmitSound("dod_garand/garand_clipding.wav")
            end
        end)
    end

    self:TakePrimaryAmmo(1)
    self.Owner:ViewPunch(Angle(rnda, rndb, rnda))
    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    -- self.Owner:SetAnimation( PLAYER_ATTACK1 )
    -- timer.Simple( 2, function() self:SendWeaponAnim( ACT_VM_SECONDARYATTACK ) end )
    -- timer.Simple( self:SequenceDuration(), function() if ( !IsValid( self ) ) then return end self:SendWeaponAnim( ACT_VM_IDLE ) end ) 
end

function SWEP:SecondaryAttack()
    if (not self:CanPrimaryAttack()) then return end
end

function SWEP:Reload()
    if self.Weapon:GetNextPrimaryFire() > CurTime() then return end
    local wep = self.Weapon
    local owner = self.Owner

    -- if wep:Clip1() == 8 then return false end
    if not InGarandZone(self.Owner) then
        if SERVER then
            self.Owner:Notify("There's no ammo here!")
        end

        return false
    end

    self:DefaultReload(ACT_VM_RELOAD)
    owner:DoReloadEvent()
    self:SetNextPrimaryFire(CurTime() + 2)

    timer.Simple(0, function()
        if IsValid(self) then
            self:EmitSound("weapons/smg1/smg1_reload.wav")
        end
    end)
end

--[[
if CLIENT then
killicon.Add( "weapon_sniper", "HUD/killicons/kcon_kar98", Color ( 0, 255, 0, 255 ) )
end
]]
function InGarandZone(v)
    local origin = Vector(-578, -1375, 396)
    local ang = Angle(0, 26.75, 0)
    local size = Vector(275, 350, 128)
    local pos, normal, frac = util.IntersectRayWithOBB(v:EyePos(), v:GetAimVector(), origin, ang, -size / 2, size / 2)
    if frac == 0 then return true end

    return false
end

hook.Add("ScalePlayerDamage", "garandthing", function(ply, hg, dmg)
    if dmg:GetAmmoType() == game.GetAmmoID("garand") then
        if ply:GetLocationName() ~= "The Pit" then
            dmg:SetDamage(10)
        end
    end
end)
