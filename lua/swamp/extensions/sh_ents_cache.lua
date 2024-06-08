-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--- A global cache of all entities, in subtables divided by classname.
-- Works on client and server. Much, much faster than `ents.FindByClass` or even `player.GetAll`
-- Each subtable is ordered and will never be nil even if no entities were created.
-- To use it try something like this: `for i,v in ipairs(Ents.prop_physics) do` ...
--- Ents  (global variable)
local EntClass = Entity.GetClass
local EntIndex = Entity.EntIndex
local EntTable = Entity.GetTable

local classmapping = SERVER and {
    prop_physics_override = "prop_physics",
    prop_dynamic_override = "prop_dynamic",
} or {}

Ents = memo(function() return List() end)
local ents_ = Ents

local function add(tab, ent)
    if tab[ent] == nil then
        tab:Push(ent)
        tab[ent] = tab:Length()
    end
end

local function create(ent)
    if EntIndex(ent) <= 0 then return end
    local cl = EntClass(ent)
    cl = classmapping[cl] or cl
    add(ents_["all"], ent)
    add(ents_[cl], ent)

    if ent:IsPlayer() then
        add(ents_[ent:IsBot() and "bot" or "human"], ent)
    end

    timer.Simple(0, function()
        if IsValid(ent) and cl ~= EntClass(ent) then
            error("ENTITY CLASS CHANGED FROM " .. cl .. " TO " .. EntClass(ent))
        end
    end)
end

for _, ent in ents.Iterator() do
    create(ent)
end

local function remove(tab, ent)
    local ci = tab[ent]

    -- TODO(winter): This happens consistently with point_message for some reason... maybe we should be using EntIndexes or something instead
    if ci == nil then
        if SERVER then
            ErrorNoHaltWithStack("cant remove ent " .. tostring(ent))
        end

        return
    end

    tab[ent] = nil
    local last = tab:Pop()
    assert((ent == last) == (tab:Length() == ci - 1))

    if ent ~= last then
        tab[ci] = last
        tab[last] = ci
    end
end

hook.Add("OnEntityCreated", "Ents_OnEntityCreated", create)
hook.Add("NetworkEntityCreated", "Ents_NetworkEntityCreated", create)
-- NOTE: This gets called asynchronously, so iterate-and-remove works
-- BUG(winter): This is NOT reliable on the client (PVS, FullUpdate, sometimes ents are created but not removed, etc; server should be telling us instead or something!)
-- Semi-related issues: https://github.com/Facepunch/garrysmod-issues/issues/5800 and https://github.com/Facepunch/garrysmod-issues/issues/5792
local lastremovewasfullupdate = false

hook.Add("EntityRemoved", "Ents_EntityRemoved", function(ent, fullupdate)
    if EntIndex(ent) <= 0 then return end
    --[[
    if CLIENT and fullupdate then
        -- Fix full update causing desync sometimes (just flush the entire cache)
        -- Don't do it more than once per full update
        if not lastremovewasfullupdate then
            -- TODO(winter): I'm betting just recreating the whole List is faster than removing items one by one...is it? Emptying a regular table would DEFINITELY be faster...
            print("TOASTING ENTS")
            Ents = memo(function() return List() end)
            ents_ = Ents
        end
    else
    ]]
    local cl = EntClass(ent)
    cl = classmapping[cl] or cl
    remove(ents_["all"], ent)
    remove(ents_[cl], ent)

    if ent:IsPlayer() then
        remove(ents_[ent:IsBot() and "bot" or "human"], ent)
    end
end)

--lastremovewasfullupdate = fullupdate
-- An even faster version of player.Iterator and ipairs(Ents.player)
local inext = ipairs({})

if SERVER then
    function player.Iterator()
        return inext, ents_["player"], 0
    end

    function player.BotIterator()
        return inext, ents_["bot"], 0
    end

    function player.HumanIterator()
        return inext, ents_["human"], 0
    end
else
    -- NOTE(winter): ents_ has too many problems desyncing on the client, so we're doing a separate approach
    -- See the EntityRemoved comments above
    local BotCache = nil
    local HumanCache = nil

    function player.BotIterator()
        if BotCache == nil then
            BotCache = player.GetBots()
        end

        return inext, BotCache, 0
    end

    function player.HumanIterator()
        if HumanCache == nil then
            HumanCache = player.GetHumans()
        end

        return inext, HumanCache, 0
    end

    local function InvalidatePlayerCache(ent)
        if ent:IsPlayer() then
            BotCache = nil
            HumanCache = nil
        end
    end

    hook.Add("OnEntityCreated", "Ents_OnEntityCreated_Players", InvalidatePlayerCache)
    hook.Add("EntityRemoved", "Ents_EntityRemoved_Players", InvalidatePlayerCache)
end
-- needs to be fixed to deal with Ents[class][ent] = index
-- function EntsWithPrefix(pfx)
--     local ok, ov, ik, iv
--     local function nextmatching()
--         while true do
--             ok, ov = next(Ents, ok)
--             if not ov then return nil end
--             if ok:StartWith(pfx) then return nov end
--         end
--     end
--     nextmatching()
--     return function()
--         while true do
--             ik, iv = next(ov, ik)
--             if iv then
--                 return iv
--             else
--                 nextmatching()
--                 if not ov then return end
--                 ik = nil
--             end
--         end
--     end
-- end
-- function _TestEnts()
--     local classcount = 0
--     local allents = ents.GetAll()
--     for k, v in pairs(Ents) do
--         if table.Count(v) > 0 then
--             classcount = classcount + 1
--             local svl = {}
--             -- ents.FindByClass(k) is different...
--             for sk2, sv2 in pairs(allents) do
--                 if sv2:GetClass() ~= k then continue end
--                 if EntIndex(sv2) <= 0 then continue end
--                 svl[sv2] = true
--             end
--             for k2, v2 in pairs(v) do
--                 -- local sv2 = sv[k2]
--                 -- assert(sv2)
--                 -- assert(v2 == sv2)
--                 assert(IsValid(v2))
--                 if not svl[v2] then
--                     print(v2, v2:EntIndex(), v2.EntsCacheIndex, table.Count(Ents[k]), k, v2:GetClass(), #ents.FindByClass(k))
--                 end
--                 assert(svl[v2])
--             end
--             assert(table.Count(v) == table.Count(svl), k .. " " .. table.Count(v) .. " " .. table.Count(svl))
--             assert(#v == table.Count(v))
--         end
--     end
--     local realclasses = {}
--     for k, v in ents.Iterator() do
--         if EntIndex(v) <= 0 then continue end
--         realclasses[v:GetClass()] = true
--     end
--     assert(classcount == table.Count(realclasses))
--     print("ENTS OK")
-- end
-- --
-- timer.Create("TestTheEnts", 5, 0, function() end) -- if SERVER or IsValid(Me) and Me:Nick() == "Joker Gaming" then --     _TestEnts() -- end
-- function _TestEnts()
--     local ShouldBe = _SetupEnts()
--     local classcount = 0
--     for k, v in pairs(Ents) do
--         if table.Count(v) > 0 then
--             classcount = classcount + 1
--             local sv = ShouldBe[k]
--             assert(sv)
--             assert(table.Count(v) == table.Count(sv))
--             for k2, v2 in pairs(v) do
--                 local sv2 = sv[k2]
--                 assert(sv2)
--                 assert(v2 == sv2)
--                 assert(IsValid(v2))
--             end
--         end
--     end
--     assert(classcount == table.Count(ShouldBe))
--     print("ENTS OK")
-- end
