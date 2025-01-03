﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("weapon_swamp_base")
SWEP.PrintName = "Flappy Fedora"
SWEP.Slot = 1
SWEP.Instructions = "Press jump to tip your fedora!"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 85
SWEP.WorldModel = "models/fedora_rainbowdash/fedora_rainbowdash.mdl"
SWEP.ViewModel = "models/fedora_rainbowdash/fedora_rainbowdash.mdl"
SWEP.NoHolsterOnPhysicsPickup = true

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    BaseClass.Deploy(self)
    local owner = self:GetOwner()

    if IsValid(owner) and not owner:InTheater() then
        self:EmitSound("mlady.ogg")
    end

    return true
end

function SWEP:SetupMove(ply, mv, cmd)
    if mv:KeyPressed(IN_JUMP) then
        if ply:IsJuggernaut() then return end
        local power = 200

        if ply.InTheater and ply:InTheater() and ply:GetLocationName() ~= "Trump Tower Casino" then
            power = 155
            if not ply:IsOnGround() then return end
        end

        if CLIENT and IsFirstTimePredicted() then
            self.TipTime = SysTime()
        end

        local vel = mv:GetVelocity()
        vel.z = power
        mv:SetVelocity(vel)
        ply:DoCustomAnimEvent(PLAYERANIMEVENT_JUMP, -1)

        self:ExtEmitSound("tip.ogg", {
            speech = 0,
            shared = true
        })

        if SERVER and not ply:IsAFK() then
            ply:AddStat("fedoratip")
        end
    end
end

function SWEP:PrimaryAttack()
    self:ExtEmitSound("nice meme.ogg", {
        speech = 0.7,
        shared = true
    })
end

function SWEP:SecondaryAttack()
    self:ExtEmitSound("mlady.ogg", {
        speech = 0.8,
        shared = true
    })
end

function SWEP:Reload()
    if self:GetOwner():KeyPressed(IN_RELOAD) then
        self:ExtEmitSound("friendzoned.ogg", {
            speech = 0.85,
            shared = true
        })
    end
end
