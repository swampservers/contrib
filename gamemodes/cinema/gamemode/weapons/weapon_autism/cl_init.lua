-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include("shared.lua")
SWEP.Instructions = "Primary: Vocal Outburst\nSecondary: Self-Harming\nReload: Greeting"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

function SWEP:DrawWorldModel()
end

net.Receive("AutismArm", function()
    local ply = net.ReadEntity()
    if not IsValid(ply) then return end
    local mult = net.ReadFloat()
    if not ply:LookupBone("ValveBiped.Bip01_L_Upperarm") then return end
    ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Upperarm"), Angle(-30 * mult, -50 * mult, -10 * mult), "autism")
    ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Forearm"), Angle(5 * mult, -100 * mult, 0), "autism")
    ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Hand"), Angle(0, 0, -30 * mult), "autism")
end)
