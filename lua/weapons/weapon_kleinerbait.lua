-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.UseHands = true
SWEP.PrintName = "#kleiner_bait"
SWEP.Author = "PYROTEKNIK"
SWEP.Instructions = "Left Click: Throw\nRight Click: Attract Kleiners\nReload: Repel Kleiners"
SWEP.Category = "PYROTEKNIK"
SWEP.Spawnable = true
SWEP.Slot = 5
SWEP.SlotPos = 5
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/weapons/w_bugbait.mdl"
SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false
SWEP.DrawAmmo = true
SWEP.Primary.Ammo = "kleinerbait"
SWEP.Primary.DefaultClip = 1
SWEP.Primary.ClipSize = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1

hook.Add("Initialize", "kleinerbait_ammo", function()
    game.AddAmmoType({
        name = "kleinerbait",
        maxcarry = 50,
    })
end)

if (CLIENT) then
    language.Add("kleiner_bait", "Kleiner Larvae")
    language.Add("kleinerbait_ammo", "Kleiner Larvae")
end

function SWEP:GetBaitCount()
    local ply = self:GetOwner()
    if (IsValid(ply)) then return ply:GetAmmoCount(self.Primary.Ammo) end
end

function SWEP:Initialize()
    self:SetHoldType("slam")
end

function SWEP:Reload()
    self:SecondaryAttack(true)
end

function SWEP:SecondaryAttack(undo)
    if (self:GetNextSecondaryFire() > CurTime()) then return end

    if (self:GetBaitCount() <= 0) then
        self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

        return
    end

    local ply = self:GetOwner()
    self:EmitSound("Weapon_Bugbait.Splat")
    self:EmitSound(undo and "vo/k_lab/kl_hedyno03.wav" or "vo/k_lab2/kl_greatscott.wav", 45, 200, 0.2, nil, nil, 56)
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

    if (SERVER) then
        local num = 0

        for ent, _ in pairs(KLEINER_NPCS) do
            if ((undo and ent:GetTarget() == ply) or (not undo and ent:CanBecomeTarget(ply) and ent:GetTarget() ~= ply)) then
                if (not undo) then
                    ent:BaitFollow(ply)
                else
                    ent:ResetBehavior()
                    ent:SetTarget(nil)
                end
            end
        end
    end

    self:SetNextPrimaryFire(CurTime() + 0.8)
    self:SetNextSecondaryFire(CurTime() + 0.8)
end

function SWEP:PrimaryAttack()
    if (self:GetNextPrimaryFire() > CurTime()) then return end
    if (self:GetBaitCount() <= 0) then return end
    local ply = self:GetOwner()
    self:SendWeaponAnim(ACT_VM_THROW)
    self:EmitSound("WeaponFrag.Throw")
    self.Throwing = true
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)

    if (SERVER) then
        local bait = ents.Create("thrown_kleiner_bait")
        bait:SetPos(ply:GetShootPos() + (ply:GetVelocity() * FrameTime()))
        bait:SetOwner(ply)
        bait:Spawn()
        bait:SetVelocity(ply:GetAimVector() * 700)
    end

    ply:RemoveAmmo(1, "kleinerbait")
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:Think()
    local ply = self:GetOwner()

    if (CurTime() > self:GetNextPrimaryFire() and self.Throwing) then
        self:SendWeaponAnim(ACT_VM_DRAW)
        self.Throwing = nil

        if (SERVER and self:GetBaitCount() <= 0) then
            ply:SelectWeapon(ply:GetWeapons()[1])
            self:Remove()
        end
    end
end

function SWEP:Deploy()
    local ply = self:GetOwner()

    if (SERVER and self:GetBaitCount() <= 0) then
        ply:SelectWeapon(ply:GetWeapons()[1])
        self:Remove()
    end

    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self:SendWeaponAnim(ACT_VM_DRAW)
    timer.Simple(1, function() end)
end

local nonemat = Material("engine/occlusionproxy")
local baitmat1 = Material("models/pyroteknik/kleinerbait_sheet")
local baitmat2 = Material("models/pyroteknik/kleinerbait_inside")
local baitmat2a = Material("models/pyroteknik/kleinerbait_inside_empty")

function SWEP:PreDrawViewModel(vm, weapon, ply)
    local ammo = self:GetOwner():GetAmmoCount(self.Primary.Ammo)
    local zero = ammo < 1
    render.MaterialOverrideByIndex(0, zero and nonemat or baitmat1)
    render.MaterialOverrideByIndex(1, zero and nonemat or baitmat2)
end

function SWEP:PostDrawViewModel(vm, weapon, ply)
end