-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("gun")
SWEP.GunType = "shotgun"
SWEP.PrintName = "Peacekeeper"
SWEP.Purpose = "Keep the peace."
SWEP.HoldType = "shotgun"
SWEP.Slot = 0

if CLIENT then
    killicon.AddAlias("gun_spas12", "weapon_shotgun")
end

--
SWEP.WorldModel = "models/weapons/w_sawed-off.mdl"
SWEP.ViewModel = "models/weapons/v_sawed.mdl"
SWEP.ShootSound = "weapons/peacekeeper/peacekeeper_fire.wav"
SWEP.CSMuzzleFlashes = true
SWEP.CSMuzzleX = false
SWEP.CSMuzzleFlashScale = 1.30
--
SWEP.Primary.Ammo = "peaceshot"
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Automatic = false
SWEP.Damage = 15
SWEP.CycleTime = 0.26
SWEP.HalfDamageDistance = 512
--
SWEP.SpreadBase = 0.006
SWEP.SpreadMove = 0.02
SWEP.Spray = 0.12
SWEP.SprayExponent = 2

ComputeSpray(SWEP, {
    TapFireInterval = 0.7,
    ShotsTo90Spray = 5
})

--
SWEP.NumPellets = 15
SWEP.PelletSpread = 0.1
SWEP.UseShellReload = true
SWEP.KickUBase = 2.5
SWEP.KickUSpray = 1.5
SWEP.KickLBase = 0.2
SWEP.KickLSpray = 0.3
SWEP.MoveSpeed = 230 / 250

game.AddAmmoType({
    name = "peaceshot",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 100,
    npcdmg = 100,
    force = 200,
    minsplash = 10,
    maxsplash = 5
})

function SWEP:Think()
    BaseClass.Think(self)

    if SERVER and not self:GetItem() then
        if not IsValid(self.Owner) or not ProtectionShotgunAllowed(self.Owner) then
            self:Remove()
        else
            if self.Owner:GetAmmoCount("peaceshot") < 2 then
                self.Owner:SetAmmo(2, "peaceshot")
            end
        end
    end
end
--[[
AddCSLuaFile()
SWEP.PrintName = "Peacekeeper"
SWEP.Instructions = "Keep the peace"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/weapons/v_sawed.mdl"
SWEP.WorldModel = "models/weapons/w_sawed-off.mdl"
SWEP.Slot = 3
SWEP.HoldType = "shotgun"
SWEP.FiresUnderwater = true
SWEP.Weight = 50
SWEP.DrawCrosshair = false

game.AddAmmoType({
    name = "peaceshot",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 100,
    npcdmg = 100,
    force = 200,
    minsplash = 10,
    maxsplash = 5
})

SWEP.Primary.Damage = 15
SWEP.Primary.ClipSize = 2
SWEP.Primary.Ammo = "peaceshot"
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Automatic = false
-- SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Force = 2000
SWEP.Primary.Spread = 0
SWEP.Primary.Recoil = 2
SWEP.Primary.Delay = 0.25
SWEP.Primary.NumberofShots = 18
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Delay = 0
SWEP.Secondary.Damage = 0

sound.Add({
    name = "Double_Barrel.Single",
    channel = CHAN_USER_BASE + 10,
    volume = 1.0,
    sound = "weapons/peacekeeper/peacekeeper_fire.wav"
})

sound.Add({
    name = "Double_Barrel.InsertShell",
    channel = CHAN_ITEM,
    volume = 1.0,
    sound = "weapons/peacekeeper/xm1014_insertshell.mp3"
})

sound.Add({
    name = "Double_Barrel.barreldown",
    channel = CHAN_ITEM,
    volume = 1.0,
    sound = "weapons/peacekeeper/barreldown.mp3"
})

sound.Add({
    name = "Double_Barrel.barrelup",
    channel = CHAN_ITEM,
    volume = 1.0,
    sound = "weapons/peacekeeper/barrelup.mp3"
})

function SWEP:Deploy()
    if not IsValid(self) then return end
    if not IsValid(self.Owner) then return end
    if not self.Owner:IsPlayer() then return end
    self:SetHoldType(self.HoldType)
    local timerName = "ShotgunReload_" .. self.Owner:UniqueID()

    if timer.Exists(timerName) then
        timer.Destroy(timerName)
    end

    self:SendWeaponAnim(ACT_VM_DRAW)
    self:SetNextPrimaryFire(CurTime() + .25)
    self:SetNextSecondaryFire(CurTime() + .25)
    self.ActionDelay = CurTime() + .25
    self.Owner.NextReload = CurTime() + 1

    return true
end

function SWEP:DrawWorldModel()
    self:DrawModel()
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

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
    self:SetHoldType(self.HoldType)
end

function SWEP:GetCone()
    local mc = 0.1 --math.max(((math.Clamp((self.Owner:GetVelocity():LengthSqr() + (20000)), 0, 70000)) * 0.000005) - 0.01, 0)
    -- (self:GetNWInt("sc",0)==0 and 0.04 or 0)

    return mc + 0.005 + 0.002
end

function SWEP:PrimaryAttack()
    local timerName = "ShotgunReload_" .. self.Owner:UniqueID()
    if timer.Exists(timerName) then return end

    if self:Clip1() == 0 and self:Ammo1() > 0 then
        self:Reload()

        return
    end

    if not self:CanPrimaryAttack() then
        self:EmitSound("Weapon_Shotgun.Empty")
        self:SendWeaponAnim(ACT_VM_DRYFIRE)
        self:SetNextPrimaryFire(CurTime() + 0.5)

        return
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
    --self.Owner:MuzzleFlash() -- Crappy muzzle light
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK))

    if not self.Owner:OnGround() then
        self.Owner:SetVelocity(self.Owner:GetAimVector() * -400)
    end

    if self.Owner:GetNWBool("HVP_EVOLVED") and self.Owner:GetNWInt("hvp") == 1 then
        bullet.Damage = bullet.Damage
        bullet.Num = bullet.Num * 2 --math.floor(bullet.Num * 1.5)
        bullet.Spread.x = 2.5 * bullet.Spread.x
    end

    self.Owner:FireBullets(bullet)
    self:EmitSound("Double_Barrel.Single")
    self:TakePrimaryAmmo(1)
    self.Owner:ViewPunch(Angle(rnda, rndb, rnda))
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
    if not IsValid(self) then return end
    if not IsValid(self.Owner) then return end
    if not self.Owner:IsPlayer() then return end
    local maxcap = self.Primary.ClipSize
    local spaceavail = self:Clip1()
    local shellz = maxcap - spaceavail + 1
    if timer.Exists("ShotgunReload_" .. self.Owner:UniqueID()) or (self.Owner.NextReload or 0) > CurTime() or maxcap == spaceavail then return end

    if self.Owner:IsPlayer() then
        -- if self.Owner:GetAmmoCount(self.Primary.Ammo) == 0 then return end
        local TIMESCALE = (self.Owner:GetNWBool("HVP_EVOLVED") and self.Owner:GetNWInt("hvp") == 1) and 0.5 or 1
        local DLY = 2 * TIMESCALE

        if self:GetNextPrimaryFire() <= CurTime() + DLY then
            self:SetNextPrimaryFire(CurTime() + DLY) -- wait TWO seconds before you can shoot again
        end

        self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START) -- sending start reload anim
        self.Owner:SetAnimation(PLAYER_RELOAD)
        self.Owner.NextReload = CurTime() + 1

        if SERVER then
            self.Owner:SetFOV(0, 0.15)
            --self:SetIronsights(false)
        end

        if SERVER and self.Owner:Alive() then
            local timerName = "ShotgunReload_" .. self.Owner:UniqueID()

            timer.Create(timerName, (.5 + .05) * TIMESCALE, shellz, function()
                if not IsValid(self) then return end

                if IsValid(self.Owner) then
                    if self.Owner:Alive() then
                        self:InsertShell()
                    end
                end
            end)
        end
    elseif self.Owner:IsNPC() then
        self:DefaultReload(ACT_VM_RELOAD)
    end
end

function SWEP:InsertShell()
    if not IsValid(self.Owner) then return end
    if not self.Owner:IsPlayer() then return end
    local timerName = "ShotgunReload_" .. self.Owner:UniqueID()

    if self.Owner:Alive() then
        local curwep = self.Owner:GetActiveWeapon()

        if curwep:GetClass() ~= "weapon_peacekeeper" then
            timer.Destroy(timerName)

            return
        end

        if self:Clip1() >= self.Primary.ClipSize then -- or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
            -- if clip is full or ammo is out, then...
            self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH) -- send the pump anim
            timer.Destroy(timerName) -- kill the timer
        elseif self:Clip1() <= self.Primary.ClipSize then --and self.Owner:GetAmmoCount(self.Primary.Ammo) >= 0 then
            self.InsertingShell = true --well, I tried!

            self:TimerSimple(0.05, function()
                self:ShellAnimCaller()
            end)

            -- if not self.Owner.HVP_EVOLVED then
            --     self.Owner:RemoveAmmo(1, self.Primary.Ammo, false)
            -- end

            self:SetClip1(self:Clip1() + 1)
        end
    else
        timer.Destroy(timerName) -- kill the timer
    end
end

function SWEP:ShellAnimCaller()
    self:SendWeaponAnim(ACT_VM_RELOAD)
end

if SERVER then function SWEP:Think()

    if (not IsValid(self.Owner)) or (not ProtectionShotgunAllowed(self.Owner)) then
        self:Remove()
            end
end
end

]]
