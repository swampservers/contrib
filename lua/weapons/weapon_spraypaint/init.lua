-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function SWEP:Initialize()
    self:SetHoldType("pistol")
end

util.AddNetworkString("spraypaint_equipanim")
util.AddNetworkString("spraypaint_networkdecal")

function SPRAYPAINT_MAKEDOT(trace, size, color)
    net.Start("spraypaint_networkdecal")
    net.WriteVector(trace.HitPos)
    net.WriteVector(trace.HitNormal)
    net.WriteColor(color)
    net.WriteFloat(size)
    net.WriteEntity(trace.Entity)
    net.SendPVS(trace.HitPos)
end

util.AddNetworkString("SpraypaintRequestCustomColor")
util.AddNetworkString("SpraypaintUpdateCustomColor")

net.Receive("SpraypaintUpdateCustomColor", function(len, ply)
    if not ply:HasWeapon("weapon_spraypaint") then return end
    if ((ply.LastspraypaintCustomization or 0) + 1) > CurTime() then return end
    ply.LastspraypaintCustomization = CurTime()
    local wep = ply:GetWeapon("weapon_spraypaint")
    local clr = net.ReadVector()
    local alpha = net.ReadFloat()
    local size = net.ReadFloat()
    local dropcan = net.ReadBool()
    ply.spraypaintColorSaved = clr
    ply.spraypaintAlphaSaved = alpha
    ply.spraypaintSizeSaved = size
    local col = wep:GetCustomColor()
    wep:PlayEquipAnimation(dropcan, col)
    wep:UpdateCustomColor()
end)

function SWEP:OwnerChanged()
    self:UpdateCustomColor()
end

function SWEP:UpdateCustomColor()
    local ply = self:GetOwner()
    local clr = ply.spraypaintColorSaved or Vector(1, 1, 1)
    local alpha = ply.spraypaintAlphaSaved or 1
    local size = ply.spraypaintSizeSaved or 16
    size = math.Clamp(size, 2, 64)
    self:SetPaintSize(size)
    self:SetPaintAlpha(alpha)
    self:SetCustomColor(clr)
end