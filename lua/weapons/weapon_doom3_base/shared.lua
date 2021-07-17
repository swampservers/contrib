-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
if SERVER then
    AddCSLuaFile("shared.lua")
    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false

    CreateConVar("doom3_onlydoomflashlight", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Force players to use Doom3 flashlight")

    CreateConVar("doom3_restrictbfg", 0, FCVAR_NONE, "Restrict BFG9K")
    CreateConVar("doom3_sk_pistol_damage", 15, FCVAR_ARCHIVE, "Pistol damage")
    CreateConVar("doom3_sk_shotgun_damage", 15, FCVAR_ARCHIVE, "Shotgun damage")
    CreateConVar("doom3_sk_machinegun_damage", 12, FCVAR_ARCHIVE, "Machinegun damage")
    CreateConVar("doom3_sk_chaingun_damage", 25, FCVAR_ARCHIVE, "Chaingun damage")
    CreateConVar("doom3_sk_rocketlauncher_damage", 100, FCVAR_ARCHIVE, "Rocket explosion damage")
    CreateConVar("doom3_sk_rocketlauncher_radius", 125, FCVAR_ARCHIVE, "Rocket explosion radius")
    CreateConVar("doom3_sk_grenade_damage", 75, FCVAR_ARCHIVE, "Grenade explosion damage")
    CreateConVar("doom3_sk_plasmagun_damage", 30, FCVAR_ARCHIVE, "Plasma damage")
    CreateConVar("doom3_sk_plasmagun_ammocapacity", 30, FCVAR_ARCHIVE, "Plasmagun ammo capacity")
    util.AddNetworkString("D3HitCheck")
else
    SWEP.DrawCrosshair = false
    SWEP.ViewModelFOV = 90
    SWEP.BobScale = 0
    SWEP.SwayBounds = 3
    SWEP.WepSelectIconY = 20
    SWEP.WepSelectIconX = 10
    SWEP.WepSelectIconWide = 20
    CreateClientConVar("doom3_hud", 0)
    CreateClientConVar("doom3_crosshair", 1)
    CreateClientConVar("doom3_firelight", 1)
    CreateClientConVar("doom3_smokeeffect", 1)
    CreateClientConVar("doom3_autoreload", 1, true, true)

    surface.CreateFont("doom3ammodisp", {
        font = "Arial",
        size = 32,
        weight = 0,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false
    })
end

SWEP.Author = "Upset"
SWEP.Category = "DOOM 3"
SWEP.Primary.Recoil = 1
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0
SWEP.Primary.Delay = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none"
SWEP.ReloadAmmo = 0
SWEP.IdleAmmoCheck = false
SWEP.SmokeForward = 30
SWEP.SmokeRight = 6
SWEP.SmokeUp = -18
SWEP.SmokeSize = 20
SWEP.MuzzleName = "doom3_muzzlelight"
local DOOM3_STATE_DEPLOY = 0
local DOOM3_STATE_HOLSTER = 1
local DOOM3_STATE_RELOAD = 2
local DOOM3_STATE_IDLE = 3
local DOOM3_STATE_ATTACK = 4

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "CannotReload")
    self:NetworkVar("Bool", 1, "Attack")
    self:NetworkVar("Int", 0, "State")
    self:NetworkVar("Float", 0, "IdleDelay")
    self:NetworkVar("Float", 1, "CannotHolster")
    self:NetworkVar("Float", 2, "ReloadTimer")
    self:NetworkVar("Float", 3, "ChargeTime")
    self:NetworkVar("Float", 4, "AttackDelay")
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self:AmmoDisplay()
    hook.Add("EntityTakeDamage", self, self.HitCheck)
end

function SWEP:AmmoDisplay()
end

function SWEP:Deploy()
    self:SetNextPrimaryFire(CurTime() + .5)
    self:SendWeaponAnim(ACT_VM_DRAW)
    self:PlayDeploySound()
    self:Idle()
    self:SpecialDeploy()

    return true
end

function SWEP:SpecialDeploy()
end

function SWEP:PlayDeploySound()
    self:SetState(DOOM3_STATE_DEPLOY)
    self:SetCannotReload(nil)
    local owner = self:GetOwner()

    if (owner and owner:IsValid() and owner:IsPlayer() and owner:Alive()) then
        self:EmitSound(self.DeploySound)
    end
end

function SWEP:WeaponSound(snd, lvl)
    lvl = lvl or 100
    local chan = CHAN_AUTO

    if self.Owner:IsNPC() then
        chan = CHAN_WEAPON
    end

    self:EmitSound(snd, lvl, 100, 1, chan)
end

function SWEP:DoSound(snd)
    if game.SinglePlayer() and SERVER or not game.SinglePlayer() then
        self:EmitSound(snd, 75, 100, 1, CHAN_AUTO)
    end
end

function SWEP:DoomRecoil(num)
    if not IsFirstTimePredicted() and SERVER then return end

    if not self.Owner:IsNPC() then
        if num < 1 then
            local rand = math.Rand(-2, -1) * num
            self.Owner:SetViewPunchAngles(Angle(rand, 0, 0))
            self.Owner:ViewPunch(Angle(-rand, 0, 0))
        else
            self.Owner:ViewPunch(Angle(math.Rand(-1, -.5) * num, 0, 0))
        end
    end
end

function SWEP:SpecialHolster()
end

function SWEP:OnRemove()
end

function SWEP:Holster(wep)
    if self == wep then return end
    --if self:GetState() == DOOM3_STATE_HOLSTER or !IsValid(wep) then
    self:SetState(DOOM3_STATE_HOLSTER)
    self:OnRemove()
    --end
    --[[
	if self:GetCannotReload() or self:GetCannotHolster() > 0 or self:GetIdleDelay() > 0 or self:GetAttack() then return false end

	if IsValid(wep) then
		self:SpecialHolster()
		self:SetCannotReload(true)
		self:SetNextPrimaryFire(CurTime() + .5)
		self:SendWeaponAnim(ACT_VM_HOLSTER)
		self.NewWeapon = wep:GetClass()
		if self:GetState() == DOOM3_STATE_HOLSTER then return end
		timer.Simple(.2, function()
			if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() then
				self:SetState(DOOM3_STATE_HOLSTER)
				if SERVER then self.Owner:SelectWeapon(self.NewWeapon) end
			end
		end)
	end

	return false ]]

    return true
end

function SWEP:SecondaryAttack()
end

function SWEP:LowAmmoWarning(ammo)
    if SERVER then return end

    if self:Clip1() <= ammo then
        if not self.LowAmmo then
            self.LowAmmo = true
            self:EmitSound("weapons/doom3/machinegun/lowammo3.wav")
        end
    else
        self.LowAmmo = nil
    end
end

function SWEP:CanPrimaryAttack()
    if not IsValid(self.Owner) then return false end

    if (self:Clip1() <= 0) then
        self:DryFire()
        self:SetNextPrimaryFire(CurTime() + 0.3)
        --self:Reload()

        return false
    end

    self:SetState(DOOM3_STATE_ATTACK)

    return true
end

function SWEP:Reload()
    if self.Owner:IsNPC() then
        self:DefaultReload(ACT_VM_RELOAD)
        self:SetClip1(self:Clip1() + self.Primary.ClipSize)

        return
    end

    if self:Ammo1() <= self.ReloadAmmo or self:Clip1() >= self.Primary.ClipSize then return end
    if self:GetState() == DOOM3_STATE_RELOAD or self:GetCannotReload() or self:GetAttack() or self:GetCannotHolster() > 0 then return end
    self:SetState(DOOM3_STATE_RELOAD)
    self:SpecialReload()
    self:DefaultReload(ACT_VM_RELOAD)
    self:EmitSound(self.ReloadSound)
    self:Idle()
end

function SWEP:Idle(time)
    time = time or self:SequenceDuration() - .2
    self:SetIdleDelay(CurTime() + time)
end

function SWEP:HitCheck(victim, dmginfo)
    local attacker = dmginfo:GetAttacker()

    if attacker and IsValid(attacker) and attacker == self:GetOwner() and IsValid(self) and attacker:GetActiveWeapon() == self and self:GetOwner():IsPlayer() and victim:IsValid() and (victim:IsPlayer() or victim:IsNPC()) and attacker ~= victim then
        if victim:IsPlayer() and not victim:Alive() then return end
        net.Start("D3HitCheck")
        net.Send(self.Owner)
    end
end

function SWEP:ShootBullet(dmg, recoil, numbul, cone)
    numbul = numbul or 1
    cone = cone or 0.01
    local bullet = {}
    bullet.Num = numbul
    bullet.Src = self.Owner:GetShootPos()
    bullet.Dir = self.Owner:GetAimVector()
    bullet.Spread = Vector(cone, cone, 0)
    bullet.Tracer = 3
    bullet.Force = 4
    bullet.Damage = dmg
    self.Owner:FireBullets(bullet)
    self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
    surface.SetDrawColor(255, 235, 20, alpha)
    surface.SetTexture(self.WepSelectIcon)
    local texw, texh = surface.GetTextureSize(self.WepSelectIcon)
    wide = (texw * wide) / 160
    tall = tall / 1.75
    x = x + wide / 8
    y = y + tall / 3

    if texw == 64 then
        x = x + wide * .6
    end

    surface.DrawTexturedRect(x, y, wide, tall)
end

function SWEP:DryFire()
end

--self:EmitSound("weapons/doom3/shotgun/dryfire_0"..math.random(1,3)..".wav")
function SWEP:Smoke()
    if IsFirstTimePredicted() then
        local fx = EffectData()
        fx:SetEntity(self)
        fx:SetOrigin(self.Owner:GetShootPos() + self.Owner:GetForward() * self.SmokeForward + self.Owner:GetRight() * self.SmokeRight + self.Owner:GetUp() * self.SmokeUp)
        fx:SetNormal(self.Owner:GetAimVector())
        fx:SetAttachment("1")
        fx:SetScale(self.SmokeSize)
        util.Effect("doom3_smoke", fx)
    end
end

function SWEP:Muzzleflash()
    if IsFirstTimePredicted() then
        local fx = EffectData()
        fx:SetEntity(self)
        fx:SetOrigin(self.Owner:GetShootPos())
        fx:SetAttachment(1)
        util.Effect(self.MuzzleName, fx)
    end
end

if CLIENT then
    function SWEP:DrawHUD()
        local x, y

        if self.Owner == LocalPlayer() and self.Owner:ShouldDrawLocalPlayer() then
            local tr = util.GetPlayerTrace(self.Owner)
            local trace = util.TraceLine(tr)
            local coords = trace.HitPos:ToScreen()
            x, y = coords.x, coords.y
        else
            x, y = ScrW() / 2, ScrH() / 2
        end

        surface.SetDrawColor(255, 255, 255, 255)
        local gap = 10
        local length = gap + 5
        surface.DrawLine(x - length, y, x - gap, y)
        surface.DrawLine(x + length, y, x + gap, y)
        surface.DrawLine(x, y - length, x, y - gap)
        surface.DrawLine(x, y + length, x, y + gap)
    end

    net.Receive("D3HitCheck", function()
        LocalPlayer():GetActiveWeapon().cHitTime = CurTime() + .15
    end)

    local SwayOldAng = Angle()
    local t = 1
    local BobTime = 0
    local BobTimeLast = RealTime()

    function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
        if not IsValid(vm) or not IsValid(self.Owner) then return end
        local reg = debug.getregistry()
        local GetVelocity = reg.Entity.GetVelocity
        local Length = reg.Vector.Length2D
        local vel = Length(GetVelocity(self.Owner))
        local bob
        local RT = RealTime()

        if game.SinglePlayer() then
            RT = CurTime()
        end

        local cl_bobmodel_side = .3
        local cl_bobmodel_up = .05
        local cl_viewmodel_scale = 3.5
        local xyspeed = math.Clamp(vel, 0, 800)
        BobTime = BobTime + (RT - BobTimeLast) * (math.min(xyspeed, 400) / 40)
        BobTimeLast = RT

        if (not game.SinglePlayer() and IsFirstTimePredicted()) or game.SinglePlayer() then
            if self.Owner:IsOnGround() then
                t = Lerp(FrameTime() * 16, t, 1)
            else
                t = math.max(Lerp(FrameTime() * 6, t, 0.01), 0)
            end
        end

        local swayangles = SwayOldAng

        if not game.SinglePlayer() and IsFirstTimePredicted() or game.SinglePlayer() then
            swayangles = LerpAngle(FrameTime() * 8, swayangles, oldang)
        end

        SwayOldAng = swayangles
        local sway = oldang - swayangles
        local swayscale = self.SwayBounds * .1
        oldang:RotateAroundAxis(oldang:Up() * swayscale, -sway[2])
        oldang:RotateAroundAxis(oldang:Right() * swayscale, sway[1])
        local bspeed = xyspeed * 0.01
        local idle = math.sin(CurTime()) * math.Clamp(vel * .01, .25, 8)
        bob = bspeed * cl_bobmodel_side * cl_viewmodel_scale * math.sin(BobTime) * t
        oldang:RotateAroundAxis(oldang:Up(), bob + idle)
        oldang:RotateAroundAxis(oldang:Forward(), bob / 3 + idle)
        bob = bspeed * cl_bobmodel_up * cl_viewmodel_scale * math.cos(BobTime * 2) * t
        oldang:RotateAroundAxis(oldang:Right(), bob - idle)

        return oldpos, oldang
    end

    SWEP.vRenderOrder = nil

    function SWEP:ViewModelDrawn()
        local vm = self.Owner:GetViewModel()
        if not IsValid(vm) then return end
        if (not self.VElements) then return end
        self:UpdateBonePositions(vm)

        if (not self.vRenderOrder) then
            -- we build a render order because sprites need to be drawn after models
            self.vRenderOrder = {}

            for k, v in pairs(self.VElements) do
                if (v.type == "Model") then
                    table.insert(self.vRenderOrder, 1, k)
                elseif (v.type == "Sprite" or v.type == "Quad") then
                    table.insert(self.vRenderOrder, k)
                end
            end
        end

        for k, name in ipairs(self.vRenderOrder) do
            local v = self.VElements[name]

            if (not v) then
                self.vRenderOrder = nil
                break
            end

            if (v.hide) then continue end
            local model = v.modelEnt
            local sprite = v.spriteMaterial
            if (not v.bone) then continue end
            local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)
            if (not pos) then continue end

            if (v.type == "Model" and IsValid(model)) then
                model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
                model:SetAngles(ang)
                --model:SetModelScale(v.size)
                local matrix = Matrix()
                matrix:Scale(v.size)
                model:EnableMatrix("RenderMultiply", matrix)

                if (v.material == "") then
                    model:SetMaterial("")
                elseif (model:GetMaterial() ~= v.material) then
                    model:SetMaterial(v.material)
                end

                if (v.skin and v.skin ~= model:GetSkin()) then
                    model:SetSkin(v.skin)
                end

                if (v.bodygroup) then
                    for k, v in pairs(v.bodygroup) do
                        if (model:GetBodygroup(k) ~= v) then
                            model:SetBodygroup(k, v)
                        end
                    end
                end

                if (v.surpresslightning) then
                    render.SuppressEngineLighting(true)
                end

                render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
                render.SetBlend(v.color.a / 255)
                model:DrawModel()
                render.SetBlend(1)
                render.SetColorModulation(1, 1, 1)

                if (v.surpresslightning) then
                    render.SuppressEngineLighting(false)
                end
            elseif (v.type == "Sprite" and sprite) then
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                render.SetMaterial(sprite)
                render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
            elseif (v.type == "Quad" and v.draw_func) then
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
                cam.Start3D2D(drawpos, ang, v.size)
                v.draw_func(self)
                cam.End3D2D()
            end
        end
    end

    function SWEP:GetBoneOrientation(basetab, tab, ent, bone_override)
        local bone, pos, ang

        if (tab.rel and tab.rel ~= "") then
            local v = basetab[tab.rel]
            if (not v) then return end
            -- Technically, if there exists an element with the same name as a bone
            -- you can get in an infinite loop. Let's just hope nobody's that stupid.
            pos, ang = self:GetBoneOrientation(basetab, v, ent)
            if (not pos) then return end
            pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)
        else
            bone = ent:LookupBone(bone_override or tab.bone)
            if (not bone) then return end
            pos, ang = Vector(0, 0, 0), Angle(0, 0, 0)
            local m = ent:GetBoneMatrix(bone)

            if (m) then
                pos, ang = m:GetTranslation(), m:GetAngles()
            end

            if (IsValid(self.Owner) and self.Owner:IsPlayer() and ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
                ang.r = -ang.r -- Fixes mirrored models
            end
        end

        return pos, ang
    end

    function SWEP:UpdateBonePositions(vm)
    end

    function SWEP:ResetBonePositions(vm)
        if (not vm:GetBoneCount()) then return end

        for i = 0, vm:GetBoneCount() do
            vm:ManipulateBoneScale(i, Vector(1, 1, 1))
            vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
            vm:ManipulateBonePosition(i, Vector(0, 0, 0))
        end
    end
end
