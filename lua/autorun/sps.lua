-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
if SERVER then
    AddCSLuaFile("sps/cl_init.lua")
    if not file.Exists("sps/sv_init.lua", "LUA") then return end
    include("sps/sv_init.lua")
end

if CLIENT then
    include("sps/cl_init.lua")
end

PS_Initialize()
PS_INITIALIZED = true