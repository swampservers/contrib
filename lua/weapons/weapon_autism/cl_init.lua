-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

include("shared.lua")

SWEP.Instructions	= "Primary: Vocal Outburst\nSecondary: Self-Harming\nReload: Greeting"

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

net.Receive("AutismArm",function()
	ply=net.ReadEntity()
	if !IsValid(ply) then return end
	mult=net.ReadFloat()
	if not ply:LookupBone("ValveBiped.Bip01_L_Upperarm") then return end
ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Upperarm"),Angle(-30*mult,-50*mult,-10*mult))
ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Forearm"),Angle(5*mult,-100*mult,0))
ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Hand"),Angle(0,0,-30*mult))
end)
