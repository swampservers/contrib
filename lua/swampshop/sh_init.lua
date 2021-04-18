-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
include("net_hd.lua")
include("config.lua")
include("sh_items.lua")
include("sh_products.lua")
local Player = FindMetaTable('Player')

function SS_Initialize()
    local files, _ = file.Find('swampshop/tabs/*', 'LUA')
    table.sort(files)

    for _, name in pairs(files) do
        AddCSLuaFile('swampshop/tabs/' .. name)
        include('swampshop/tabs/' .. name)
    end
end 
SS_Initialize()   
-- if SERVER then for k,ply in pairs(player.GetAll()) do     SQL_LockPlayer(ply, function()
--     SQL_LoadPlayer(ply)   
-- end) end end 


function Player:SS_GetDonation()
    return self.SS_Donation or 0
end

function Player:SS_GetPoints()
    return self.SS_Points or 0
end

function Player:SS_HasPoints(points)
    return (self.SS_Points or 0) >= points
end

function Player:SS_FindItem(item_id)
    for k, v in ipairs(self.SS_Items or {}) do
        if v.id == item_id then return v end
    end
    return false
end

function Player:SS_HasItem(item_class)
    for k, v in ipairs(self.SS_Items or {}) do
        if v.class == item_class then return true end
    end

    return false
end

function Player:SS_CountItem(item_class)
    local c = 0

    for k, v in ipairs(self.SS_Items or {}) do
        if v.class == item_class then
            c = c + 1
        end
    end

    return c
end

function Player:SS_AccessorySlots()
    local c = 1

    for k, v in ipairs(self.SS_Items or {}) do
        if v.class:StartWith("accslot_") then
            c = c + 1
        end
    end

    return c
end
