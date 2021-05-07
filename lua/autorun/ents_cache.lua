-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include('autorun/swamp_core.lua') --defaultdict needed
local Entity = FindMetaTable("Entity")
local EntClass = Entity.GetClass
local EntIndex = Entity.EntIndex
local EntTable = Entity.GetTable

function _SetupEnts()
    local _Ents = defaultdict(function() return {} end)

    for i, v in ipairs(ents.GetAll()) do
        local idx = EntIndex(v)

        if idx > 0 then
            _Ents[EntClass(v)][idx] = v
        end
    end

    return _Ents
end

Ents = Ents or _SetupEnts()

-- Ents = _SetupEnts()
hook.Add("OnEntityCreated", "Ents_OnEntityCreated", function(v)
    local idx = EntIndex(v)

    --Filter CS ents and worldspawn
    if idx > 0 then
        Ents[EntClass(v)][idx] = v
    end
end)

hook.Add("NetworkEntityCreated", "Ents_NetworkEntityCreated", function(v)
    local idx = EntIndex(v)

    if idx > 0 then
        Ents[EntClass(v)][idx] = v
    end
end)

hook.Add("EntityRemoved", "Ents_EntityRemoved", function(v)
    local idx = EntIndex(v)

    if idx > 0 then
        Ents[EntClass(v)][idx] = nil
    end
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

function _TestEnts()
    local ShouldBe = _SetupEnts()
    local classcount = 0

    for k, v in pairs(Ents) do
        if table.Count(v) > 0 then
            classcount = classcount + 1
            local sv = ShouldBe[k]
            assert(sv)
            assert(table.Count(v) == table.Count(sv))

            for k2, v2 in pairs(v) do
                local sv2 = sv[k2]
                assert(sv2)
                assert(v2 == sv2)
                assert(IsValid(v2))
            end
        end
    end

    assert(classcount == table.Count(ShouldBe))
    print("ENTS OK")
end
-- timer.Create("TestTheEnts",5,0,function()
-- if SERVER or LocalPlayer():Nick()=="Joker Gaming" 
-- then _TestEnts() end
-- end)