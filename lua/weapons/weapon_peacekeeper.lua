-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
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
SWEP.Primary.Automatic = false
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Force = 2000
SWEP.Primary.Spread = 0
SWEP.Primary.Recoil = 2
SWEP.Primary.Delay = 0.25
SWEP.Primary.NumberofShots = 18
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.DefaultClip = 1
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

    if (timer.Exists(timerName)) then
        timer.Destroy(timerName)
    end

    self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
    self.Weapon:SetNextPrimaryFire(CurTime() + .25)
    self.Weapon:SetNextSecondaryFire(CurTime() + .25)
    self.ActionDelay = (CurTime() + .25)
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

if CLIENT then
    function SWEP:Think()
        ply = self.Owner
        if LocalPlayer():GetActiveWeapon() ~= self then return end
    end
end

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
    self:SetHoldType(self.HoldType)
end

function SWEP:GetCone()
    local mc = math.max(((math.Clamp((self.Owner:GetVelocity():LengthSqr() + (20000)), 0, 70000)) * 0.000005) - 0.01, 0)
    -- (self:GetNWInt("sc",0)==0 and 0.04 or 0)

    return mc + 0.005 + 0.002
end

function SWEP:PrimaryAttack()
    local timerName = "ShotgunReload_" .. self.Owner:UniqueID()
    if (timer.Exists(timerName)) then return end

    if self:Clip1() == 0 then
        self:Reload()

        return
    end

    if (not self:CanPrimaryAttack()) then return end
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

    if self.Owner.HVP_EVOLVED then
        bullet.Damage = bullet.Damage * 2
    end

    self.Owner:FireBullets(bullet)
    self:EmitSound("Double_Barrel.Single")
    self:TakePrimaryAmmo(1)
    self.Owner:ViewPunch(Angle(rnda, rndb, rnda))
    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
    --[[
	local timerName = "ShotgunReload_" ..  self.Owner:UniqueID()
	if (timer.Exists(timerName)) then return end

	if self:Clip1()==0 then
		self:Reload()
		return
	end

	if ( !self:CanPrimaryAttack() ) then return end
	local bullet = {}
		bullet.Num = self.Primary.NumberofShots*2
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
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence( ACT_VM_PRIMARYATTACK ))
		vm:SetPlaybackRate(BOLTACTIONSPEED)

		self.Owner:FireBullets( bullet )
		--self:EmitSound("dbarrel_dblast")
	
		self:TakePrimaryAmmo(2)
		self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) )
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		--self.Owner:SetAnimation( PLAYER_ATTACK1 )

		
		--timer.Simple( 2, function() self:SendWeaponAnim( ACT_VM_SECONDARYATTACK ) end )

	--timer.Simple( self:SequenceDuration(), function() if ( !IsValid( self ) ) then return end self:SendWeaponAnim( ACT_VM_IDLE ) end )
	--]]
end

function SWEP:Reload()
    if not IsValid(self) then return end
    if not IsValid(self.Owner) then return end
    if not self.Owner:IsPlayer() then return end
    local maxcap = self.Primary.ClipSize
    local spaceavail = self.Weapon:Clip1()
    local shellz = (maxcap) - (spaceavail) + 1
    if (timer.Exists("ShotgunReload_" .. self.Owner:UniqueID())) or (self.Owner.NextReload or 0) > CurTime() or maxcap == spaceavail then return end

    if self.Owner:IsPlayer() then
        if self.Owner:GetAmmoCount(self.Primary.Ammo) == 0 then return end

        if self.Weapon:GetNextPrimaryFire() <= (CurTime() + 2) then
            self.Weapon:SetNextPrimaryFire(CurTime() + 2) -- wait TWO seconds before you can shoot again
        end

        self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START) -- sending start reload anim
        self.Owner:SetAnimation(PLAYER_RELOAD)
        self.Owner.NextReload = CurTime() + 1

        if (SERVER) then
            self.Owner:SetFOV(0, 0.15)
            --self:SetIronsights(false)
        end

        if SERVER and self.Owner:Alive() then
            local timerName = "ShotgunReload_" .. self.Owner:UniqueID()

            timer.Create(timerName, (.5 + .05), shellz, function()
                if not IsValid(self) then return end

                if IsValid(self.Owner) and IsValid(self.Weapon) then
                    if self.Owner:Alive() then
                        self:InsertShell()
                    end
                end
            end)
        end
    elseif self.Owner:IsNPC() then
        self.Weapon:DefaultReload(ACT_VM_RELOAD)
    end
end

function SWEP:InsertShell()
    if not IsValid(self) then return end
    if not IsValid(self.Owner) then return end
    if not self.Owner:IsPlayer() then return end
    local timerName = "ShotgunReload_" .. self.Owner:UniqueID()

    if self.Owner:Alive() then
        local curwep = self.Owner:GetActiveWeapon()

        if curwep:GetClass() ~= "weapon_peacekeeper" then
            timer.Destroy(timerName)

            return
        end

        if (self.Weapon:Clip1() >= self.Primary.ClipSize or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then
            -- if clip is full or ammo is out, then...
            self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH) -- send the pump anim
            timer.Destroy(timerName) -- kill the timer
        elseif (self.Weapon:Clip1() <= self.Primary.ClipSize and self.Owner:GetAmmoCount(self.Primary.Ammo) >= 0) then
            self.InsertingShell = true --well, I tried!

            timer.Simple(.05, function()
                self:ShellAnimCaller()
            end)

            if not self.Owner.HVP_EVOLVED then
                self.Owner:RemoveAmmo(1, self.Primary.Ammo, false)
            end

            self.Weapon:SetClip1(self.Weapon:Clip1() + 1)
        end
    else
        timer.Destroy(timerName) -- kill the timer
    end
end

function SWEP:ShellAnimCaller()
    self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
end