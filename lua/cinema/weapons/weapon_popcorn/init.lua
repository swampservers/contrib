-- This file is subject to copyright - contact swampservers@gmail.com for more information.
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("EatPopcorn")

local nospamlocations = {
    ["Movie Theater"] = true,
    ["Trump Tower Casino"] = true
}

function SWEP:SecondaryAttack()
    local bucket, att, phys, tr
    self:SetNextSecondaryFire(CurTime() + 0.15)
    if self:GetClass() == "weapon_popcorn_spam" and nospamlocations[self.Owner:GetLocationName()] then return end
    self.Owner:EmitSound("weapons/slam/throw.wav")
    self.Owner:ViewPunch(Angle(math.Rand(-8, 8), math.Rand(-8, 8), 0))
    bucket = ents.Create("ent_popcorn_thrown")

    if self:GetClass() == "weapon_sandcorn" then
        bucket.sandcorn = true
    end

    bucket:SetOwner(self.Owner)
    bucket:SetPos(self.Owner:GetShootPos())
    bucket:Spawn()
    bucket:Activate()
    phys = bucket:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetVelocity(self.Owner:GetPhysicsObject():GetVelocity())
        phys:AddVelocity(self.Owner:GetAimVector() * 128 * phys:GetMass())
        phys:AddAngleVelocity(VectorRand() * 128 * phys:GetMass())
    end

    if self:GetClass() ~= "weapon_popcorn_spam" then
        self.Owner:StripWeapon(self:GetClass())
    end
end
