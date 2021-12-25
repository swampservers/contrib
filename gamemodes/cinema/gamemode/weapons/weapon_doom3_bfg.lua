-- This file is subject to copyright - contact swampservers@gmail.com for more information.
if CLIENT then
    SWEP.PrintName = "BFG9K"
    SWEP.Author = "Upset"
    SWEP.Slot = 4
    SWEP.SlotPos = 1
    SWEP.WepSelectIcon = surface.GetTextureID("vgui/icons/bfgw")
    SWEP.SwayBounds = 4
    killicon.Add("doom3_bfg", "vgui/icons/bfgw", Color(255, 80, 0, 255))
end

SWEP.VElements = {
    ["d3ammo"] = {
        type = "Quad",
        bone = "bone001",
        rel = "",
        pos = Vector(3.7, -4.76, -.01),
        angle = Angle(90, 0, -10),
        size = .018,
        draw_func = nil
    },
    ["d3ammoclip"] = {
        type = "Quad",
        bone = "bone001",
        rel = "",
        pos = Vector(3.85, -5.725, 0),
        angle = Angle(90, 0, -10),
        size = .038,
        draw_func = nil
    },
    ["bfgcharge"] = {
        type = "Quad",
        bone = "bone001",
        rel = "",
        pos = Vector(3.45, -3.4, -.625),
        angle = Angle(90, 0, -10),
        size = .0095,
        draw_func = nil
    }
}

function SWEP:AmmoDisplay()
    if CLIENT then
        local chargeadd = surface.GetTextureID("vgui/ammogui/chargeadd")
        local warnadd = surface.GetTextureID("vgui/ammogui/warnadd")

        self.VElements["d3ammoclip"].draw_func = function(weapon)
            local clip = weapon:Ammo1()
            local col = Color(100, 255, 255, 140)

            if clip <= 0 then
                col = Color(255, 130, 0, 140)
            end

            draw.DrawText(clip, "doom3ammodisp", 0, 0, col, TEXT_ALIGN_CENTER)
            draw.DrawText("8", "doom3ammodisp", 0, 0, Color(150, 200, 255, 10), TEXT_ALIGN_CENTER)
        end

        self.VElements["bfgcharge"].draw_func = function(weapon)
            local chargetime = self:GetChargeTime() > 0 and CurTime() - self:GetChargeTime() or 0
            local a = math.Clamp(chargetime * 150, 0, 255)
            surface.SetTexture(chargeadd)
            surface.SetDrawColor(255, 0, 0, a)
            surface.DrawTexturedRect(0, 0, 128, 100)
            local hold = math.sin(CurTime() * 1.5) * 50
            local charge = math.sin((CurTime() - 2) * 1.5) * 50

            if chargetime < 1.5 then
                draw.DrawText("HOLD TRIGGER", "doom3ammodisp", 64, -50, Color(200, 200, 200, hold), 1)
                draw.DrawText("TO CHARGE", "doom3ammodisp", 64, -50, Color(200, 200, 200, charge), 1)
            else
                surface.SetTexture(warnadd)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(-50, -220, 64, 256)
                surface.DrawTexturedRectUV(112, -220, 64, 256, 0, 0, -1, 1)
                draw.DrawText("WARNING", "doom3ammodisp", 64, -50, Color(255, 80, 40, 80), 1)
            end
        end
    end
end

function SWEP:Deploy()
    self:SetNextPrimaryFire(CurTime() + .5)
    self:SendWeaponAnim(ACT_VM_DRAW)
    self:PlayDeploySound()
    self:Idle()

    if SERVER then
        self.bfgsound = CreateSound(self.Owner, "weapons/doom3/bfg/bfg_idle.wav")
        self.bfgsound:Play()
        self.bfgsound:ChangeVolume(.5)
    end

    return true
end

function SWEP:OnRemove()
    self:SetAttack(nil)
    self:SetChargeTime(0)

    if self.ChargeSound then
        self.ChargeSound:Stop()
    end

    if SERVER then
        if self.bfgsound then
            self.bfgsound:Stop()
        end
    end
end

local DOOM3_STATE_DEPLOY = 0
local DOOM3_STATE_HOLSTER = 1
local DOOM3_STATE_RELOAD = 2
local DOOM3_STATE_IDLE = 3
local DOOM3_STATE_ATTACK = 4

function SWEP:CanPrimaryAttack()
    if not IsValid(self.Owner) then return false end

    if self:Ammo1() <= 0 then
        self:DryFire()
        self:SetNextPrimaryFire(CurTime() + 0.3)
        --self:Reload()

        return false
    end

    self:SetState(4)

    return true
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() or self:GetAttack() then return end

    if self.Owner:IsNPC() then
        if self:GetNextPrimaryFire() <= CurTime() then
            self:SetNextPrimaryFire(CurTime() + 1.5)
            self:WeaponSound(self.Primary.Sound)
            self:Muzzleflash()
            self:TakePrimaryAmmo(1)

            if SERVER then
                local pos = self.Owner:GetShootPos()
                local ang = self.Owner:GetAimVector():Angle()
                pos = pos + ang:Right() * 0 + ang:Up() * 0
                local ent = ents.Create("doom3_bfg")
                ent:SetAngles(ang)
                ent:SetPos(pos)
                ent:SetOwner(self.Owner)
                ent:SetDamage(self.Primary.Radius, self.Primary.Damage / 2)
                ent:Spawn()
                ent:Activate()
                local phys = ent:GetPhysicsObject()

                if IsValid(phys) then
                    phys:SetVelocity(ang:Forward() * 350)
                end
            end
        end

        return
    end

    self:SetAttack(true)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_1)

    if not self.ChargeSound then
        self.ChargeSound = CreateSound(self.Owner, self.Primary.Special1)
        self.ChargeSound:SetSoundLevel(90)
        self.ChargeSound:Play()
    else
        if IsFirstTimePredicted() and self.ChargeSound:IsPlaying() then
            self.ChargeSound:Stop()
        end

        self.ChargeSound:Play()
    end

    self:Shake()
    self:SetChargeTime(CurTime())
end

function SWEP:Shake()
    if game.SinglePlayer() and SERVER or CLIENT and IsFirstTimePredicted() then
        util.ScreenShake(self:GetPos(), FrameTime() * 100, 255, 1.5, 64)
    end
end

function SWEP:Think()
    if game.SinglePlayer() and CLIENT then return end
    local chargetime = CurTime() - self:GetChargeTime()

    if self:GetAttack() and chargetime >= .05 then
        if chargetime > 2.5 then
            --self:OverCharge()
            self:SetAttack(nil)
            self:BfgFire(2.49)
            self:SetChargeTime(0)
        elseif not self.Owner:KeyDown(IN_ATTACK) then
            self:SetAttack(nil)
            self:BfgFire(chargetime)
            self:SetChargeTime(0)
        end
    end
end

function SWEP:DryFire()
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_EMPTY)
    self:EmitSound("weapons/doom3/bfg/bfg_dryfire.wav")
    self:Idle()
end

function SWEP:Muzzleflash()
    if not IsFirstTimePredicted() then return end
    local pos = self.Owner:GetShootPos()
    local ang = self.Owner:GetAimVector():Angle()
    pos = pos + ang:Forward() * 50 + ang:Right() * 8 + ang:Up() * -10
    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    util.Effect("doom3_bfg_muzzle", effectdata)
end

function SWEP:BfgFire(charge)
    local power = math.min(4 * (charge / 2), 4)
    local dmgPower = math.floor(power) + 1

    if dmgPower < 4 then
        self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
        self:SendWeaponAnim(ACT_VM_IDLE)

        if self.ChargeSound then
            self.ChargeSound:Stop()
        end

        self:Idle(.8)

        return
    end

    --[[
	if dmgPower > self:Clip1() then
		dmgPower = self:Clip1()
	end
]]
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:WeaponSound(self.Primary.Sound)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self:Muzzleflash()
    self:TakePrimaryAmmo(1) --dmgPower)

    if self.ChargeSound then
        self.ChargeSound:Stop()
    end

    self:Idle(.8)
    self:SetCannotHolster(CurTime() + .7)
    self:SetAttack(false)
    self:SetChargeTime(0)

    if SERVER then
        --strip after firing
        self:TimerSimple(0.5, function()
            if SERVER and self:Ammo1() <= 0 then
                if IsValid(self) then
                    self:Remove()
                end
            end
        end)

        local pos = self.Owner:GetShootPos()
        local ang = self.Owner:GetAimVector():Angle()
        pos = pos + ang:Right() * 5 + ang:Up() * -5
        local ent = ents.Create("doom3_bfg")
        ent:SetAngles(ang)
        ent:SetPos(pos)
        ent:SetOwner(self.Owner)
        ent:SetDamage(self.Primary.Radius * 2, self.Primary.Damage * 2)
        --ent:SetDamage(self.Primary.Radius * dmgPower, self.Primary.Damage * dmgPower)
        ent:Spawn()
        ent:Activate()
        local phys = ent:GetPhysicsObject()

        if IsValid(phys) then
            phys:SetVelocity(ang:Forward() * 350)
        end
    end

    self:Shake()
end

function SWEP:OverCharge()
    self:SetNextPrimaryFire(CurTime() + 2)
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    util.Effect("HelicopterMegaBomb", effectdata)
    self:EmitSound("weapons/doom3/bfg/bfg_explode" .. math.random(1, 4) .. ".wav", 100, 100)
    self.Owner:ViewPunch(Angle(math.Rand(-5, -10), math.Rand(1, 0), math.Rand(1, 2)))
    self:TakePrimaryAmmo(self:Clip1())
    self:SetAttack(nil)
    self:SetChargeTime(0)
    self:Idle(.8)
    util.BlastDamage(self, self:GetOwner(), self:GetPos(), 500, 500)
end

local textures = {"models/weapons/doom3/bfg/bfgblast1", "models/weapons/doom3/bfg/bfgblast2"}

local flare = Material("models/weapons/doom3/bfg/bfg_flare1")

function SWEP:UpdateBonePositions(vm)
    local charge = self:GetChargeTime()

    for _, path in pairs(textures) do
        local mat = Material(path)

        if charge > 0 then
            local col = math.min(.25 + (CurTime() - charge) * .5, 1)
            local sin = math.Clamp(math.sin(CurTime() * 40), .5, 1)
            mat:SetVector("$color2", Vector(col, col, col))
            flare:SetVector("$color2", Vector(col * sin, col * sin, col * sin))
        else
            mat:SetVector("$color2", Vector(0, 0, 0))
            flare:SetVector("$color2", Vector(0, 0, 0))
        end
    end
end

SWEP.HoldType = "physgun"
SWEP.Base = "weapon_doom3_base"
SWEP.Category = "DOOM 3"
SWEP.Spawnable = true
SWEP.ViewModel = "models/weapons/doom3/v_bfg.mdl"
SWEP.WorldModel = "models/weapons/doom3/w_bfg.mdl"
SWEP.Primary.Sound = Sound("weapons/doom3/bfg/bfg_fire.wav")
SWEP.Primary.Special1 = Sound("weapons/doom3/bfg/bfg_firebegin.wav")
SWEP.Primary.Damage = 200
SWEP.Primary.Radius = 200
SWEP.Primary.Delay = .95
SWEP.Primary.DefaultClip = 1
SWEP.Primary.ClipSize = 0
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "doom3_bfg"

game.AddAmmoType({
    name = "doom3_bfg",
})

SWEP.DeploySound = Sound("weapons/doom3/bfg/bfg_raise.wav")
SWEP.ReloadSound = Sound("weapons/doom3/bfg/bfg_reload.wav")
SWEP.IdleAmmoCheck = true
