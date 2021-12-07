-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local Player = FindMetaTable("Player")
local Weapon = FindMetaTable("Weapon")
local Entity = FindMetaTable("Entity")
ENTITY_CGETTABLE = ENTITY_CGETTABLE or Entity.GetTable
local cgettable = ENTITY_CGETTABLE

-- Thanks to trolge#2286 on the GMod discord for help with this
--weak references
local EntTableCache = setmetatable({}, {
    __mode = "kv"
})

function Entity:GetTable()
    local tab = EntTableCache[self]

    if not tab then
        tab = cgettable(self)
        EntTableCache[self] = tab
        -- TODO: perhaps initialize default values in the entity table here?
    end

    return tab
end

local EntTable = Entity.GetTable
local EntOwner = Entity.GetOwner

function Entity:__index(key)
    local val = Entity[key]
    if val ~= nil then return val end
    local tab = EntTable(self)

    if tab ~= nil then
        local val = tab[key]
        if val ~= nil then return val end
    end

    -- TODO remove this and collapse this function to be like Player
    if key == "Owner" then return EntOwner(self) end
end

function Player:__index(key)
    local val = Player[key]
    if val ~= nil then return val end
    local val = Entity[key]
    if val ~= nil then return val end
    local tab = EntTable(self)
    if tab then return tab[key] end
end

function Weapon:__index(key)
    local val = Weapon[key]
    if val ~= nil then return val end
    local val = Entity[key]
    if val ~= nil then return val end
    local tab = EntTable(self)

    if tab ~= nil then
        local val = tab[key]
        if val ~= nil then return val end
    end

    -- TODO remove this and collapse this function to be like Player
    if key == "Owner" then return EntOwner(self) end
end
