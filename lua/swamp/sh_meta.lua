-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--- Omit FindMetaTable from your code because these globals always refer to their respective metatables.
-- Player/Entity are still callable and function the same as the default global functions.
--- Player, Entity, Weapon  (global variables)
-- do them all automatically?
-- for k,v in pairs(debug.getregistry()) do if isstring(k) and istable(v) and (_G[k] == nil or isfunction(_G[k])) then print("GLOBAL METATABLE", k, _G[k]) end end
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
CRecipientFilter = FindMetaTable("CRecipientFilter")
-- Do all and auto add the functions?
-- for k,v in pairs(debug.getregistry()) do if isstring(k) and istable(v) then print(k) end end
local entity_meta, player_meta, weapon_meta = Entity, Player, Weapon
-- caches the Entity.GetTable so stuff is super fast
CEntitySetTable = CEntitySetTable or entity_meta.SetTable
CEntityGetTable = CEntityGetTable or entity_meta.GetTable
local cgettable = CEntityGetTable

-- __mode = "kv",
EntityTable = setmetatable({}, {
    __mode = "k",
    __index = function(self, ent)
        local tab = cgettable(ent)
        -- BUG(winter): Don't cache clientside entity tables; they get replaced in some scenarios and don't even go through ENT.SetTable
        if IsValid(ent) and ent:EntIndex() == -1 then return tab end
        -- extension: perhaps initialize default values in the entity table here?
        rawset(self, ent, tab)

        return tab
    end
})

local entity_table = EntityTable

-- Apparently entities cant be weak keys
hook.Add("EntityRemoved", "CleanupEntityTableCache", function(ent)
    timer.Simple(0, function()
        entity_table[ent] = nil
    end)
end)

function entity_meta:SetTable(tab)
    -- Need to update the cached value since it changed
    entity_table[self] = tab

    return CEntitySetTable(self, tab)
end

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
-- Makes it so like Entity_GetTable maps to Entity.GetTable automatically.
-- TODO: Auto-localize these. Organize the code so all our overrides happen prior to this caching. Or maybe have a hook that updates the localized values once when loading is finished and again when files are changed?
-- local metatables = {
--     Player=Player,
--     Entity=Entity,
--     Weapon=Weapon,
--     string=string,
--     math=math,
--     table=table,
--     timer=timer,
--     util=util
-- }
-- if not RanGlobalCache then
--     RanGlobalCache=true
--     for name,mt in pairs(metatables) do
--         name = name.."_"
--         for k,v in pairs(mt) do
--             k = name..k
--             assert(_G[k]==nil, k)
--             _G[k] = v
--         end
--     end
-- end
-- local ignore = {}
-- local stringsub,stringfind = string.sub, string.find
-- setmetatable(_G, {
--     __index = function(t, k)
--         if ignore[k] or not isstring(k) then return nil end
--         local split,_ = stringfind(k, "_", 5, true)
--         local split1 = split+1
--         if not split or stringfind(k, "_", split1, true) then ignore[k]=true return end
--         local mt = metatables[stringsub(k, 1, split-1)]
--         if not mt then ignore[k]=true return end
--         t[k] = stringsub()
--     end
-- })
-- local unused_G = rawget(_G, "unused_G") or {}
-- setmetatable(_G, {
--     __index = function(t, k)
--         local v = unused_G[k]
--         if v!=nil then
--             rawset(t,k,v)
--             unused_G[k] = nil
--         end
--         return v
--     end,
--     __newindex = function(t,k,v)
--         -- if v==nil then
--         --     print("NILLED", k)
--         --     rawset(t,k,v)
--         -- end
--         rawset(unused_G, k, v)
--     end
-- })
-- rawset(_G, "unused_G", unused_G)
