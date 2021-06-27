AddCSLuaFile()
SWEP.Base = "weapon_spades_rifle"
SWEP.PrintName = "Machine Gun"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.UseHands = false
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_dod_mg42.mdl"
SWEP.WorldModel = "models/weapons/w_mg42bu.mdl"
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 0
SWEP.HoldType = "physgun"
SWEP.FiresUnderwater = true
SWEP.Weight = 50
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.Primary.Damage = 26
SWEP.Primary.ClipSize = 100
SWEP.Primary.Ammo = "lmg"
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Force = 0.01
SWEP.Primary.Spread = 0
SWEP.Primary.Delay = 0.04
SWEP.Primary.NumberofShots = 1
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Delay = 0
SWEP.Secondary.Damage = 0

game.AddAmmoType({
    name = "lmg",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 25, --18,
    npcdmg = 25, --18,
    force = 0,
    minsplash = 10,
    maxsplash = 5
})

sound.Add({
    name = "DOD_MG42.Fire",
    channel = CHAN_STATIC,
    volume = 0.85,
    level = 75,
    sound = "weapons/dod_mg42/negev-1.wav"
})

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()
    -- if(IsValid(ply))then
    -- 	local bn = "ValveBiped.Bip01_R_Hand"
    -- 	local bon = ply:LookupBone(bn) or 0
    -- 	local opos = self:GetPos()
    -- 	local oang = self:GetAngles()
    -- 	local bp,ba = ply:GetBonePosition(bon)
    -- 	if(bp)then opos = bp end
    -- 	if(ba)then oang = ba end
    -- 	oang:RotateAroundAxis(oang:Up(),-90)
    -- 	oang:RotateAroundAxis(oang:Forward(),-92)
    -- 	oang:RotateAroundAxis(oang:Right(),12)
    -- 	oang:RotateAroundAxis(oang:Forward(),-5)
    -- 	oang:RotateAroundAxis(oang:Up(),15)
    -- 	opos = opos + oang:Right()*-2
    -- 	if ply:Crouching() then
    -- 		oang:RotateAroundAxis(oang:Forward(),5)
    -- 		opos = opos + oang:Right()*5
    -- 	end
    -- 	--oang:RotateAroundAxis(oang:Right(),180)
    -- 	self:SetupBones()
    -- 	self:SetModelScale(1.25,0)
    -- 	local mrt = self:GetBoneMatrix(0)
    -- 	if(mrt)then
    -- 	mrt:SetTranslation(opos)
    -- 	mrt:SetAngles(oang)
    -- 	self:SetBoneMatrix(0, mrt )
    -- 	end
    -- end
    self:DrawModel()
end

function SWEP:GetViewModelPosition(pos, ang)
    if self.setsight then
        self.ViewModelFOV = 40
        --set it later to disable sway + lag

        return pos, ang
    end

    self.ViewModelFOV = 60
    pos = pos + ang:Up() * -2
    --pos = pos+ang:Right()*-0
    -- ang:RotateAroundAxis(ang:Right(),PlayerSprintingness(self.Owner)*-15)

    return pos, ang
end

function SWEP:PreDrawViewModel(vm, weapon, ply)
    self.DrawDot = false

    if self.setsight then
        local trupos = EyePos()
        local truang = EyeAngles()
        trupos, truang = LocalToWorld(Vector(-2, 3.63, 0.56), Angle(0, 0, 0), trupos, truang)
        vm:SetPos(trupos)
        vm:SetAngles(truang)
    end

    if self:Bipod() then
        vm:ManipulateBoneAngles(39, Angle(0, 0, -90))
        vm:ManipulateBoneAngles(41, Angle(45, 0, 0))
        vm:ManipulateBoneAngles(42, Angle(-45, 0, 0))
    end

    vm:SetupBones()
end

function SWEP:PostDrawViewModel(vm, weapon, ply)
    vm:ManipulateBoneAngles(39, Angle(0, 0, 0))
    vm:ManipulateBoneAngles(41, Angle(0, 0, 0))
    vm:ManipulateBoneAngles(42, Angle(0, 0, 0))
end

function SWEP:GetCone()
    return self:Bipod() and (self.setsight and 0.01 or 0.015) or (self.setsight and 0.025 or 0.03)
end

function SWEP:Bipod()
    -- local bc = self.Owner:EyePos() + self.Owner:GetAimVector()*30
    -- local bl = bc/CVX_SCALE
    -- local x = math.floor(bl.x)
    -- local y = math.floor(bl.y)
    -- local z = math.floor(bl.z)
    -- if not cvx_get_vox_solid(x,y,z) and cvx_get_vox_solid(x,y,z-1) then
    -- 	return true
    -- end
    -- return false
    return self.Owner:Crouching()
end

function SWEP:PrimaryAttack()
    if self:IsReloading() then return end
    if (not self:CanPrimaryAttack()) then return end
    local vm = self.Owner:GetViewModel()

    if CLIENT and IsFirstTimePredicted() then
        --this is such crap
        local bb = vm:LookupBone("ValveBiped.bolt")
        if not bb then return end
        local ps, ng = vm:GetBonePosition(bb)
        --if self.setsight then
        --	ps,ng = LocalToWorld( Vector(10,-2,0), Angle(0,-45,0), ps,ng)
        --else
        ps, ng = LocalToWorld(Vector(30, -12, -9), Angle(0, -45, 0), ps, ng)
        --end
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
            cvx_shot(tr, 0.26, att)
        end
    end

    self.Owner:FireBullets(bullet)
    self.Owner:MuzzleFlash()
    -- if SERVER or IsFirstTimePredicted() then SpadesMuzzleFlash(self.Owner) end
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    --[[local rnda = -0.5
	local rndb = math.random(-1, 1)*0.5
	if self:Bipod() then
		rnda = -0.1
		rndb = math.random(-1, 1)*0.1
	end
	self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) ) ]]
    local bp = self:Bipod()
    self:DoRecoilOffset(bp and 0.45 or 1, bp and 0.2 or 0.8)
    --[[
	if CLIENT and IsFirstTimePredicted() then
		local v = self.Owner:GetAimVector() 
		v = v+Vector(0,0, self:Bipod() and 0.008 or 0.02)
		self.Owner:SetEyeAngles(v:Angle())
	end]]
    vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK))
    --vm:SetPlaybackRate(1.2)
    self:EmitSound("DOD_MG42.Fire")
    self:TakePrimaryAmmo(1)

    if self:Clip1() == 0 then
        self:Reload()
    end

    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:Reload()
    if self.Weapon:GetNextPrimaryFire() > CurTime() then return end
    if self.Owner:GetAmmoCount(self.Primary.Ammo) == 0 then return end
    if self:Clip1() >= self.Primary.ClipSize then return end
    self:DisableSight()
    --self.ReloadEndTime = CurTime() + 2.5
    self:DefaultReload(ACT_VM_RELOAD)
    self.Owner:DoReloadEvent()
    --self.Owner:GetViewModel():SetPlaybackRate(0.65)
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