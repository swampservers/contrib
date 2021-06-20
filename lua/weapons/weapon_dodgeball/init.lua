-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

makeDodgeball = makeDodgeball or function(pos, vel, player)
    e = ents.Create("dodgeball")
    e.thrower = player
    e:SetPos(pos)
    e:Spawn()
    e:Activate()
    e:GetPhysicsObject():AddVelocity(vel)
end