-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--- Omit FindMetaTable from your code because these globals always refer to their respective metatables.
-- Player/Entity are still callable and function the same as the default global functions.
--- Player, Entity, Weapon  (global variables)
if isfunction(Entity) then
    local EntityFunction = Entity
    Entity = FindMetaTable("Entity")

    setmetatable(Entity, {
        __call = function(_, x) return EntityFunction(x) end
    })
end

if isfunction(Player) then
    local PlayerFunction = Player
    Player = FindMetaTable("Player")

    setmetatable(Player, {
        __call = function(_, x) return PlayerFunction(x) end
    })
end

Weapon = FindMetaTable("Weapon")

local entity_meta,player_meta, weapon_meta = Entity, Player, Weapon




-- caches the Entity.GetTable so stuff is super fast
CEntityGetTable = CEntityGetTable or entity_meta.GetTable
local cgettable = CEntityGetTable

-- __mode = "kv",
EntityTable = setmetatable({}, {
    __mode = "k",
    __index = function(self, ent)
        local tab = cgettable(ent)
        -- extension: perhaps initialize default values in the entity table here?
        rawset(self, ent, tab)
        return tab
    end
})
local entity_table=EntityTable

function entity_meta:GetTable()
    return entity_table[self]
end

local ent_owner = entity_meta.GetOwner


function entity_meta:__index(key)
    local val = entity_meta[key]
    if val ~= nil then return val end
    local tab = entity_table[self]

    if tab ~= nil then
        local val = tab[key]
        if val ~= nil then return val end
    end

    -- TODO remove this and collapse this function to be like Player
    if key == "Owner" then return ent_owner(self) end
end

function player_meta:__index(key)
    local val = player_meta[key]
    if val ~= nil then return val end
    local val = entity_meta[key]
    if val ~= nil then return val end
    local tab = entity_table[self]
    if tab then return tab[key] end
end

function weapon_meta:__index(key)
    local val = weapon_meta[key]
    if val ~= nil then return val end
    local val = entity_meta[key]
    if val ~= nil then return val end
    local tab = entity_table[self]

    if tab ~= nil then
        local val = tab[key]
        if val ~= nil then return val end
    end

    -- TODO remove this and collapse this function to be like Player
    if key == "Owner" then return ent_owner(self) end
end
