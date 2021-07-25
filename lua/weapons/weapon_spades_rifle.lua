AddCSLuaFile()
SWEP.PrintName = "Semi Auto Rifle"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.UseHands = false
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_dod_garand.mdl"
SWEP.WorldModel = "models/weapons/w_garand.mdl"
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.HoldType = "physgun"
SWEP.FiresUnderwater = true
SWEP.Weight = 50
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
-- gets multiplied by 1.6 for player
SWEP.Primary.Damage = 25
SWEP.Primary.ClipSize = 8
SWEP.Primary.Ammo = "semiauto"
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Force = 0.01
SWEP.Primary.Spread = 0
SWEP.Primary.Delay = 0.35
SWEP.Primary.NumberofShots = 1
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Delay = 0
SWEP.Secondary.Damage = 0

game.AddAmmoType({
    name = "semiauto",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 25,
    npcdmg = 25,
    force = 0,
    minsplash = 10,
    maxsplash = 5
})

-- sound.Add({
--     name = "DOD_Garand.Fire",
--     channel = CHAN_STATIC,
--     volume = 0.9,
--     level = 110,
--     sound = {"dod_garand/scar20_01.wav", "dod_garand/scar20_02.wav", "dod_garand/scar20_03.wav"}
-- })
if SERVER then
    util.AddNetworkString("SpadesMuzzleFlash")

    function SpadesMuzzleFlash(ply)
        net.Start("SpadesMuzzleFlash", true)
        net.WriteEntity(ply)
        net.SendOmit(ply)
    end
else
    net.Receive("SpadesMuzzleFlash", function()
        SpadesMuzzleFlash(net.ReadEntity())
    end)
end

--[[
function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end]]
function SWEP:Think()
    if IsValid(self.Owner) then
        local desiredHoldType = self.HoldType -- self.Owner:IsSprinting() and "passive" or self.HoldType

        if desiredHoldType ~= self:GetHoldType() then
            self:SetHoldType(desiredHoldType)
        end
    end
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if (IsValid(ply)) then
        local bn = "ValveBiped.Bip01_R_Hand"
        local bon = ply:LookupBone(bn) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = ply:GetBonePosition(bon)

        if (bp) then
            opos = bp
        end

        if (ba) then
            oang = ba
        end

        oang:RotateAroundAxis(oang:Up(), -90)
        oang:RotateAroundAxis(oang:Forward(), -92)
        oang:RotateAroundAxis(oang:Right(), 12)
        oang:RotateAroundAxis(oang:Forward(), -5)
        oang:RotateAroundAxis(oang:Up(), 15)
        opos = opos + oang:Right() * -2

        if ply:Crouching() then
            oang:RotateAroundAxis(oang:Forward(), 5)
            opos = opos + oang:Right() * 5
        end

        -- oang:RotateAroundAxis(oang:Right(),180)
        self:SetupBones()
        self:SetModelScale(1.25, 0)
        local mrt = self:GetBoneMatrix(0)

        if (mrt) then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            self:SetBoneMatrix(0, mrt)
        end
    end

    self:DrawModel()
end

function SWEP:GetViewModelPosition(pos, ang)
    if self.setsight then
        self.ViewModelFOV = 40 -- this and 67 are like added together
        -- set it later to disable sway + lag

        return pos, ang
    end

    self.ViewModelFOV = 60
    pos = pos + ang:Up() * 2
    pos = pos + ang:Right() * -2
    -- ang:RotateAroundAxis(ang:Right(),PlayerSprintingness(self.Owner)*-15)

    return pos, ang
end

function SWEP:CalcView(ply, pos, ang, fov)
    -- fov = fov - self:GetNWInt("sc",0)*33
    if self.setsight then
        fov = math.min(fov, 66)
    end

    if CLIENT then
        self.lastfov = fov
    end

    return pos, ang, fov
end

function SWEP:AdjustMouseSensitivity()
    return self.setsight and 0.6 or 1.0
end

function SWEP:PreDrawViewModel(vm, weapon, ply)
    self.DrawDot = false

    if self.setsight then
        local trupos = EyePos()
        local truang = EyeAngles()
        trupos, truang = LocalToWorld(Vector(-2, 6.947, 5.085), Angle(0, 0, 0), trupos, truang)
        vm:SetPos(trupos)
        vm:SetAngles(truang)

        -- this resets the animation early
        if vm:GetSequenceActivity(vm:GetSequence()) ~= ACT_VM_PRIMARYATTACK or vm:GetCycle() > 0.35 then
            vm:SendViewModelMatchingSequence(1)
            vm:SetCycle(1)
            self.DrawDot = true
        end

        vm:SetupBones()
    end
end

function SWEP:DrawHUD()
    local mx = ScrW() / 2
    local my = ScrH() / 2
    -- TODO
    --[[
	]]
    if RETICLETOSCREEN then end -- mx = RETICLETOSCREEN.x --my = RETICLETOSCREEN.y
    surface.SetDrawColor(255, 255, 255, 255)

    -- and not PlayerIsSprintRecovering(self.Owner) then
    if not self.setsight then
        local ftan = math.tan(math.rad((self.lastfov or 90) * 0.5)) / math.sqrt(16.0 / 9.0)
        local spread = 0.5 * ScrH() * self:GetCone() / ftan
        spread = math.floor(spread)
        local lastx = math.floor(spread) - 1
        local lasty = 0
        local angstep = 5 -- 360/16

        for i = angstep, 360, angstep do
            local rad = math.rad(i)
            local nextx = math.Round(math.cos(rad) * spread)
            local nexty = math.Round(math.sin(rad) * spread)

            if nextx > 0 then
                nextx = nextx - 1
            end

            if nexty > 0 then
                nexty = nexty - 1
            end

            surface.DrawLine(mx + lastx, my + lasty, mx + nextx, my + nexty)
            lastx = nextx
            lasty = nexty
        end
    end

    if self.setsight then
        if not self.DrawDot then return end
        surface.SetDrawColor(255, 0, 0, 255)
    end

    surface.DrawRect(mx - 1, my - 1, 2, 2)
end

function SWEP:GetCone()
    return self.setsight and 0 or 0.018
end

function SWEP:PrimaryAttack()
    if self:IsReloading() then return end
    if (not self:CanPrimaryAttack()) then return end
    local vm = self.Owner:GetViewModel()

    if CLIENT and IsFirstTimePredicted() then
        -- this is such crap
        local ps, ng = vm:GetBonePosition(vm:LookupBone("ValveBiped.bolt"))

        if self.setsight then
            ps, ng = LocalToWorld(Vector(10, -2, 0), Angle(0, -45, 0), ps, ng)
        else
            ps, ng = LocalToWorld(Vector(18, -14, -9), Angle(0, -45, 0), ps, ng)
        end

        local shelldata = EffectData()
        shelldata:SetOrigin(ps)
        shelldata:SetAngles(ng)
        shelldata:SetEntity(self)
        util.Effect("RifleShellEject", shelldata, false, true)
    end

    local bullet = {}
    bullet.Num = 1
    bullet.Src = self.Owner:GetShootPos()
    bullet.Dir = self.Owner:GetAimVector()
    local ac = self:GetCone()
    bullet.Spread = Vector(ac, ac, 0)
    bullet.Tracer = 1
    bullet.TracerName = "Tracer"
    bullet.Force = self.Primary.Force
    bullet.Damage = self.Primary.Damage
    bullet.AmmoType = self.Primary.Ammo
    bullet.Distance = 5000

    if IsFirstTimePredicted() then
        bullet.Callback = function(att, tr, dmg)
            cvx_shot(tr, 0.34, att)
        end
    end

    self.Owner:FireBullets(bullet)
    self.Owner:MuzzleFlash()
    -- if SERVER or IsFirstTimePredicted() then SpadesMuzzleFlash(self.Owner) end
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    --[[ local rnda = -0.5
	local rndb = math.random(-1, 1)*0.5
	self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) ) ]]
    -- was 1,0.6
    self:DoRecoilOffset(1.1, 0.6)
    vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK))
    vm:SetPlaybackRate(1.2)
    self:EmitSound("DOD_Garand.Fire")
    self:TakePrimaryAmmo(1)

    if self:Clip1() == 0 then
        self.Owner:EmitSound("dod_garand/garand_clipding.wav")
        self:Reload()
    end

    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:DoRecoilOffset(vd, hd)
    if CLIENT and IsFirstTimePredicted() then
        -- self.Owner:SetEyeAngles(self.Owner:EyeAngles() + Angle(-vd,Lerp(CurTime()%1,hd,-hd),0))
        -- RecoilAngleOffset = RecoilAngleOffset + Vector(-vd,Lerp(CurTime()%1,hd,-hd),0)
        -- aos seems like a 1sec sin wave but a bit sharper?
        local s = math.sin(CurTime() * 4.2)
        local sign = s > 0 and 1 or -1
        RecoilAngleOffset = RecoilAngleOffset + Vector(-vd, sign * hd * math.pow(math.abs(s), 0.25), 0)
    end
end

if CLIENT then
    RecoilAngleOffset = Vector(0, 0, 0)

    function RecoilUpdateFunction()
        if RecoilAngleOffset == Vector(0, 0, 0) then return end
        local mult = 1.0 / math.pow(2, RealFrameTime() * 50)
        local nxt = RecoilAngleOffset * mult

        if nxt:Length() < 0.01 then
            nxt = Vector(0, 0, 0)
        end

        if IsValid(LocalPlayer()) then
            local diff = RecoilAngleOffset - nxt
            LocalPlayer():SetEyeAngles(LocalPlayer():EyeAngles() + Angle(diff.x, diff.y, 0))
        end

        RecoilAngleOffset = nxt
    end

    hook.Add("Think", "RecoilUpdater", RecoilUpdateFunction)
end

function SWEP:Deploy()
    self:DisableSight()
end

function SWEP:SecondaryAttack()
    if self:IsReloading() then return end

    if SERVER or (CLIENT and IsFirstTimePredicted()) then
        self.setsight = not self:GetNWBool("sight", false)

        if SERVER then
            self:SetNWBool("sight", self.setsight or false)
        end
    end

    self.Weapon:SetNextSecondaryFire(CurTime())
end

function SWEP:Reload()
    if self.Weapon:GetNextPrimaryFire() > CurTime() then return end
    if self.Owner:GetAmmoCount(self.Primary.Ammo) == 0 then return end
    if self:Clip1() >= self.Primary.ClipSize then return end
    self:DisableSight()
    self.ReloadEndTime = CurTime() + 2.5
    self:DefaultReload(ACT_VM_RELOAD)
    self.Owner:DoReloadEvent()
    self.Owner:GetViewModel():SetPlaybackRate(0.65)
    self.Weapon:EmitSound("dod_garand/bizon_boltback.wav")

    timer.Simple(0.7, function()
        if IsValid(self) then
            if SERVER and IsValid(self.Owner) then
                SuppressHostEvents(self.Owner)
            end

            self:EmitSound("dod_garand/awp_draw.wav")

            if SERVER then
                SuppressHostEvents()
            end
        end
    end)

    timer.Simple(1.5, function()
        if IsValid(self) then
            if SERVER and IsValid(self.Owner) then
                SuppressHostEvents(self.Owner)
            end

            self:EmitSound("dod_garand/bizon_boltforward.wav")

            if SERVER then
                SuppressHostEvents()
            end
        end
    end)
end

-- this is only necessary due to the custom playbackrate
function SWEP:IsReloading()
    return CurTime() < (self.ReloadEndTime or 0)
end

function SWEP:DisableSight()
    self.setsight = false
    self:SetNWBool("sight", false)
end
--[[
if CLIENT then
killicon.Add( "weapon_sniper", "HUD/killicons/kcon_kar98", Color ( 0, 255, 0, 255 ) )
end
]]
