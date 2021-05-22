-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function SWEP:Initialize()
    self:SetHoldType("pistol")
end

util.AddNetworkString("spraypaint_equipanim")

function SWEP:OwnerChanged()
end