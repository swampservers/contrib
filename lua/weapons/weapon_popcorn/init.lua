AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")
include ("shared.lua")

util.AddNetworkString("Popcorn_Eat")
util.AddNetworkString("Popcorn_Eat_Start")

function SWEP:Initialize()
	self:SetHoldType("slam")
end