-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
if SERVER then
    if not file.Exists("swampshop/sv_init.lua", "LUA") then return end
    include("swampshop/sv_init.lua")
end

if CLIENT then
    include("swampshop/cl_init.lua")
end

SS_Initialize()
SS_INITIALIZED = true