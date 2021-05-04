-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Flappy Fedora"
SWEP.Slot = 1
SWEP.Instructions = "Press jump to tip your fedora!"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 85
SWEP.WorldModel = Model("models/fedora_rainbowdash/fedora_rainbowdash.mdl")
SWEP.ViewModel = Model("models/fedora_rainbowdash/fedora_rainbowdash.mdl")

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    if not self.Owner:InTheater() then
        self:EmitSound("mlady.ogg")
    end
end

function SWEP:Holster()
    return true
end

hook.Add("SetupMove", "flappy_SetupMove", function(ply, mv, cmd)
    if mv:KeyPressed(IN_JUMP) and not ply:InVehicle() then
        local self = ply:GetActiveWeapon()
        if not IsValid(self) or self:GetClass() ~= "weapon_flappy" then return end
        local power = 200

        if ply.InTheater and ply:InTheater() then
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
    end
end)

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
    if self.Owner:KeyPressed(IN_RELOAD) then
        self:ExtEmitSound("friendzoned.ogg", {
            speech = 0.85,
            shared = true
        })
    end
end