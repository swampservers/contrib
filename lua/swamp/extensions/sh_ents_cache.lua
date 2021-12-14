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

function _SetupEnts1()
    local _Ents = defaultdict(function() return {} end)

    for i, v in ipairs(ents.GetAll()) do
        local idx = EntIndex(v)

        if idx > 0 then
            _Ents[EntClass(v)][idx] = v
        end
    end

    return _Ents
end

function _SetupEnts2()
    local _Ents = defaultdict(function() return {} end)

    for i, v in ipairs(ents.GetAll()) do
        if EntIndex(v) <= 0 then continue end
        local cl = EntClass(v)
        cl = classmapping[cl] or cl
        local tab = _Ents[cl]
        table.insert(tab, v)
        v.EntsCacheIndex = #tab
    end

    return _Ents
end

-- Ents = Ents or _SetupEnts()
Ents = _SetupEnts2()

-- Ents = _SetupEnts()
hook.Add("OnEntityCreated", "Ents_OnEntityCreated", function(v)
    local cl = EntClass(v)
    cl = classmapping[cl] or cl
    local idx = EntIndex(v)
    -- print("MAKECLASS", EntClass(v))
    --Filter CS ents and worldspawn
    -- if idx > 0 then
    --     Ents[cl][idx] = v
    -- end
    if idx <= 0 then return end

    if not v.EntsCacheIndex then
        local tab = Ents[cl]
        table.insert(tab, v)
        v.EntsCacheIndex = #tab
    end

    local oldclass = cl

    timer.Simple(0, function()
        if not IsValid(v) then return end
        local newclass = EntClass(v)

        if oldclass ~= newclass then
            print("CLASSCHANGED", oldclass, newclass)
        end
    end)
end)

hook.Add("NetworkEntityCreated", "Ents_NetworkEntityCreated", function(v)
    local cl = EntClass(v)
    cl = classmapping[cl] or cl
    local idx = EntIndex(v)
    -- if idx > 0 then
    --     Ents[cl][idx] = v
    -- end
    if idx <= 0 then return end

    if not v.EntsCacheIndex then
        local tab = Ents[cl]
        table.insert(tab, v)
        v.EntsCacheIndex = #tab
    end
end)

-- Note: This gets called asynchronously, so iterate-and-remove works
hook.Add("EntityRemoved", "Ents_EntityRemoved", function(v)
    -- if v:GetClass():find("dodgeball") then print("ONREMOVE", v) end
    local cl = EntClass(v)
    cl = classmapping[cl] or cl
    local idx = EntIndex(v)
    -- if idx > 0 then
    --     Ents[cl][idx] = nil
    -- end
    if idx <= 0 then return end
    local tab = Ents[cl]
    local lastone = table.remove(tab)

    if not v.EntsCacheIndex then
        print("FUCK", v)

        return
    end

    -- assert(v.EntsCacheIndex)
    -- if v.EntsCacheIndex then
    if lastone ~= v then
        tab[v.EntsCacheIndex] = lastone
        lastone.EntsCacheIndex = v.EntsCacheIndex
    end

    v.EntsCacheIndex = nil
end)

function EntsWithPrefix(pfx)
    local ok, ov, ik, iv

    local function nextmatching()
        while true do
            ok, ov = next(Ents, ok)
            if not ov then return nil end
            if ok:StartWith(pfx) then return nov end
        end
    end

    nextmatching()

    return function()
        while true do
            ik, iv = next(ov, ik)

            if iv then
                return iv
            else
                nextmatching()
                if not ov then return end
                ik = nil
            end
        end
    end
end

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
function _TestEnts()
    local classcount = 0
    local allents = ents.GetAll()

    for k, v in pairs(Ents) do
        if table.Count(v) > 0 then
            classcount = classcount + 1
            local svl = {}

            -- ents.FindByClass(k) is different...
            for sk2, sv2 in pairs(allents) do
                if sv2:GetClass() ~= k then continue end
                if EntIndex(sv2) <= 0 then continue end
                svl[sv2] = true
            end

            for k2, v2 in pairs(v) do
                -- local sv2 = sv[k2]
                -- assert(sv2)
                -- assert(v2 == sv2)
                assert(IsValid(v2))

                if not svl[v2] then
                    print(v2, v2:EntIndex(), v2.EntsCacheIndex, table.Count(Ents[k]), k, v2:GetClass(), #ents.FindByClass(k))
                end

                assert(svl[v2])
            end

            assert(table.Count(v) == table.Count(svl), k .. " " .. table.Count(v) .. " " .. table.Count(svl))
            assert(#v == table.Count(v))
        end
    end

    local realclasses = {}

    for k, v in ipairs(ents.GetAll()) do
        if EntIndex(v) <= 0 then continue end
        realclasses[v:GetClass()] = true
    end

    assert(classcount == table.Count(realclasses))
    print("ENTS OK")
end

--
timer.Create("TestTheEnts", 5, 0, function() end) -- if SERVER or IsValid(Me) and Me:Nick() == "Joker Gaming" then --     _TestEnts() -- end
