-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
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

sound.Add({
    name = "DOD_Garand.Fire",
    channel = CHAN_STATIC,
    volume = 0.9,
    level = 70,
    sound = {
        "dod_garand/scar20_01.wav", "dod_garand/scar20_02.wav",
        "dod_garand/scar20_03.wav"
    }
})

function SWEP:SprintMod()
    return ((math.cos(((self.SprintNess or 0) + 1) * math.pi) + 1) * 0.5)
end

function SWEP:IsSprinting()
    return self.Owner:GetVelocity():Length() >
               (self.Owner:GetWalkSpeed() + self.Owner:GetRunSpeed()) * 0.5
end

function SWEP:DrawWorldModel()
    -- self:SetupBones()
    local mrt = self:GetBoneMatrix(0)
    if (mrt) then end -- mrt:SetTranslation(mrt:GetTranslation()+(mrt:GetUp()*-0.8)) --self:SetBoneMatrix(0, mrt )
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
    self.XHairspread = (EyePos() + EyeAngles():Forward() + EyeAngles():Right() *
                           self:GetCone()):ToScreen().x - mx
    local spread = self.XHairspread
    local len = 10
    local mx = ScrW() / 2
    local my = ScrH() / 2
    surface.SetDrawColor(255, 200, 20, Lerp(
                             math.Clamp((self:GetCone() - 0.3) * 10, 0, 1), 255,
                             0))
    surface.DrawLine(mx - (spread + len), my, mx - spread, my)
    surface.DrawLine(mx + (spread + len), my, mx + spread, my)
    surface.DrawLine(mx, my - (spread + len), mx, my - spread)
    surface.DrawLine(mx, my + (spread + len), mx, my + spread)
end

if CLIENT then
    function SWEP:Think()
        ply = self.Owner
        if LocalPlayer():GetActiveWeapon() ~= self then return end
        local changesprintness = 2.2 * RealFrameTime()

        if self:IsSprinting() then
            changesprintness = -1 * changesprintness
        end

        self.SprintNess = math.Clamp((self.SprintNess or 0) - changesprintness,
                                     0, 1)
    end
end

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
    self:SetHoldType(self.HoldType)
end

function SWEP:GetCone()
    local mc = math.max(
                   (self.Owner:GetVelocity():LengthSqr() * 0.000005) - 0.01, 0)
    -- (self:GetNWInt("sc",0)==0 and 0.04 or 0)

    return mc + 0.005
end

local BOLTACTIONSPEED = 1

function SWEP:PrimaryAttack()
    self.Owner:SetAmmo(80, "garand")

    if self:Clip1() == 0 then
        self:Reload()

        return
    end

    if (not self:CanPrimaryAttack()) then return end
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
    vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(
                                         ACT_VM_PRIMARYATTACK))
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

function SWEP:SecondaryAttack() if (not self:CanPrimaryAttack()) then return end end

function SWEP:Reload()
    if self.Weapon:GetNextPrimaryFire() > CurTime() then return end
    local wep = self.Weapon
    local owner = self.Owner

    -- if wep:Clip1() == 8 then return false end
    if not InGarandZone(self.Owner) then
        if SERVER then self.Owner:Notify("There's no ammo here!") end

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
    if v:GetPos()
        :WithinAABox(Vector(-959, -1732, 332), Vector(-276, -1048, 431)) then
        if v:GetPos():DistToSqr(Vector(-618, -1390, 382)) < 168 * 168 then
            return true
        end
    end

    return false
end

hook.Add("ScalePlayerDamage", "garandthing", function(ply, hg, dmg)
    if dmg:GetAmmoType() == game.GetAmmoID("garand") then
        if ply:GetLocationName() ~= "The Pit" then dmg:SetDamage(10) end
    end
end)
